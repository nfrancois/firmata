// Copyright (c) 2014, Nicolas François
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of serial_port;

/// Pin usage modes
class PinModes {

  static final int INPUT = 0x00;
  static final int OUTPUT = 0x01;
  //static final int ANALOG = 0x02;
  static final int PWM = 0x03;
  static final int SERVO = 0x04;
  //static final int SHIFT = 0x05;
  //static final int I2C = 0x06;
  //static final int ONEWIRE = 0x07;
  //static final int STEPPER = 0x08;
  //static final int IGNORE = 0x7F;
  //static final int UNKOWN = 0x10;

}

/// Digital value for pins
class PinValue {
  /// Constant to set a pins value to HIGH when the pin is set to an output.
  static final int HIGH = 1;
  /// Constant to set a pins value to LOW when the pin is set to an output.
  static final int LOW = 0;
}

/// The arduino board
abstract class Board {

  /// Try to detect a arduino board
  static Future<Board> detect(){
    final completer = new Completer<Board>();
    SerialPort.avaiblePortNames.then((List<String> portNames){
      // FIXME name.startsWith("tty") && name.contains("usb")
      final avaibles = Platform.isMacOS ?
                        portNames.where((name) => name.startsWith("/dev/tty") && name.contains("usb")).toList() :
                        portNames;
      if(avaibles.isEmpty){
        completer.completeError("Impossible to detect Arduino board on usb.");
      } else {
        final board =  new _Board(avaibles.first);
        board.open().then((_) => completer.complete(board));
      }
    });
    return completer.future;
  }

  /// Find a arduino board from the port name.
  static Future<Board> fromPortName(String portName) {
    final completer = new Completer<Board>();
    final board =  new _Board(portName);
    board.open().then((_) => completer.complete(board));
    return completer.future;
  }

  /// Send SYSTEM_RESET to arduino
  Future reset();

  /// Asks the arduino to set the pin to a certain mode.
  Future pinMode(int pin, int mode);

  /// Getter for firmware information
  FirmataVersion get firmware;

  /// Resquest a QUERY_FIRMWARE call
  Future queryFirmware();

  /// Request a CAPABILITY_RESPONSE call
  Future queryCapability();

  /// Asks the arduino to tell us its analog pin mapping
  Future queryAnalogMapping();

  /// Close the connection
  Future close();

  /// Asks the arduino to write a value to a digital pin
  Future digitalWrite(int pin, int value);

  /// Stream that sent state from digital value
  Stream<PinState> get onDigitalRead;

  /// Stream that sent analogic value
  Stream<PinState> get onAnalogRead;

  /// Read the digatal value from pin;
  int digitalRead(int pin);

  /// Asks the arduino to write an analog message.
  Future analogWrite(int pin, int value);

  /// Read the analog value from pin;
  int analogRead(int pin);

  /// Asks the arduino to move a servo
  Future servoWrite(int pin, int angle);

}


class _Board extends Board {

  final SerialPort serialPort;
  /// Stream controller for digital read
  final digitalReadController = new StreamController<PinState>();
  /// Stream controller for analog read
  final analogReadController = new StreamController<PinState>();
  final Map<int, int> pins = {};
  final SysexParser parser = new SysexParser();
  final List<int> digitalOutputData = new List.filled(16, 0);
  final Map<int, int> digitalInputData = {};
  final Map<int, int> analogInputData = {};
  FirmataVersion firmware;

  _Board(String portname) : serialPort = new SerialPort(portname, baudrate: 57600);

  Future open() {
    final completer = new Completer<bool>();
    serialPort.open().then((_) {
      serialPort.onRead.listen(parser.append);
    });
    parser.onReportVersion.listen((firmware) {
      this.firmware = firmware;
      for (var i = 0; i < 16; i++) {
        serialPort.write([REPORT_DIGITAL | i, 1]);
        serialPort.write([REPORT_ANALOG | i, 1]);
      }
      queryCapability().then((_) => queryAnalogMapping()).then((_) => completer.complete(true));
    });
    parser.onDigitalMessage.listen(digitalPinStatesChanged);
    parser.onAnaloglMessage.listen(analogPinStatesChanged);
    return completer.future;
  }

  void digitalPinStatesChanged(Map<int, int> states){
    states.forEach((pin, state){
      if(pins[pin] == PinModes.INPUT){
        digitalInputData[pin] = state;
        digitalReadController.add(new PinState(pin, state));
      }
    });
  }

  void analogPinStatesChanged(Map<int, int> states){
    states.forEach((pin, state){
        analogInputData[pin] = state;
        analogReadController.add(new PinState(pin, state));
    });
  }

  Future pinMode(int pin, int mode) {
    pins[pin] = mode;
    return serialPort.write([PIN_MODE, pin, mode]);
  }

  Future reset() =>
    serialPort.write([SYSTEM_RESET]);

  Future queryFirmware() => serialPort.write([START_SYSEX, QUERY_FIRMWARE, END_SYSEX]);

  //Future<bool> queryPinState(int pin) => _serialPort.write(([START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX]));

  Future queryCapability() => serialPort.write([START_SYSEX, CAPABILITY_QUERY, END_SYSEX]);

  Future queryAnalogMapping() => serialPort.write([START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX]);

  Future close() => serialPort.close();

  Future digitalWrite(int pin, int value) {
    final portNumber = (pin >> 3) & 0x0F;
    if (value == 0) {
      digitalOutputData[portNumber] &= ~(1 << (pin & 0x07)); // Clear bit
    } else {
      digitalOutputData[portNumber] |= (1 << (pin & 0x07)); // Set bit
    }
    return serialPort.write([DIGITAL_MESSAGE | portNumber, digitalOutputData[portNumber] & 0x7F, digitalOutputData[portNumber] >> 7]);
  }

  Stream<PinState> get onDigitalRead => digitalReadController.stream;

  Stream<PinState> get onAnalogRead => analogReadController.stream;

  int digitalRead(int pin) => digitalInputData.containsKey(pin) ? digitalInputData[pin] : 0;

  Future analogWrite(int pin, int value) {
    pinMode(pin, PinModes.PWM);
    return serialPort.write([ANALOG_MESSAGE | (pin & 0x0F), value & 0x7F, value >> 7]);
  }

  int analogRead(int pin) => analogInputData.containsKey(pin) ? analogInputData[pin] : 0;

  Future servoWrite(int pin, int angle) {
    pinMode(pin, PinModes.SERVO);
    return serialPort.write([ANALOG_MESSAGE | (pin & 0x0F), angle & 0x7F, angle >> 7]);
  }

}

/// Information about Firmata version
class FirmataVersion {
  /// Name of firmware
  final String name;
  /// Major version of firmware
  final int major;
  /// Minor version of firmware
  final int minor;

  FirmataVersion(this.name, this.major, this.minor);

}
