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

part of firmata_internal;

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

/// Adapter to communicate with SerialPort
abstract class SerialPortAdapter {

  /// Declare a adapter on a portName
  SerialPortAdapter(String portName);

  /// Open communication with serial port
  Future open();

  /// Close communication with serial port
  Future close();

  /// Write bytes to serial port
  Future write(List<int> bytes);

  /// Open a bytes stream sent by serial port
  Stream<List<int>> get onRead;

}

/// Represent the arduino board
class Board {

  /// Adapter to SerialPort
  final SerialPortAdapter adapter;
  /// Stream controller for digital read
  final _digitalReadController = new StreamController<PinState>();
  Stream<PinState> digitalReadStream;
  /// Stream controller for analog read
  final _analogReadController = new StreamController<PinState>();
  Stream<PinState> _analogReadStream;
  final Map<int, int> _pins = {};
  final SysexParser _parser = new SysexParser();
  final List<int> _digitalOutputData = new List.filled(16, 0);
  final Map<int, int> _digitalInputData = {};
  final Map<int, int> _analogInputData = {};

  FirmataVersion _firmware;

  Board(this.adapter);

  /// Open communication with Arduino.
  /// Please DO NOT call yourself this method dans use helper construction to start communication with Arduino
  Future open() {
    final completer = new Completer<bool>();
    adapter.open().then((_) {
      adapter.onRead.listen(_parser.append);
    });
    _parser.onReportVersion.listen((firmware) {
      this._firmware = firmware;
      for (var i = 0; i < 16; i++) {
        adapter.write([REPORT_DIGITAL | i, 1]);
        adapter.write([REPORT_ANALOG | i, 1]);
      }
      queryCapability().then((_) => queryAnalogMapping()).then((_) => completer.complete(true));
    });
    _parser.onDigitalMessage.listen(_digitalPinStatesChanged);
    _parser.onAnaloglMessage.listen(_analogPinStatesChanged);
    return completer.future;
  }

  void _digitalPinStatesChanged(Map<int, int> states){
    states.forEach((pin, state){
      if(_pins[pin] == PinModes.INPUT){
        _digitalInputData[pin] = state;
        _digitalReadController.add(new PinState(pin, state));
      }
    });
  }

  void _analogPinStatesChanged(Map<int, int> states){
    states.forEach((pin, state){
        _analogInputData[pin] = state;
        _analogReadController.add(new PinState(pin, state));
    });
  }

  /// Asks the arduino to set the pin to a certain mode.
  Future pinMode(int pin, int mode) {
    _pins[pin] = mode;
    return adapter.write([PIN_MODE, pin, mode]);
  }

  /// Getter for firmware information
  FirmataVersion get firmware => _firmware;

  /// Send SYSTEM_RESET to arduino
  Future reset() => adapter.write([SYSTEM_RESET]);

  /// Resquest a QUERY_FIRMWARE call
  Future queryFirmware() => adapter.write([START_SYSEX, QUERY_FIRMWARE, END_SYSEX]);

  //Future<bool> queryPinState(int pin) => _serialPort.write(([START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX]));

  /// Request a CAPABILITY_RESPONSE call
  Future queryCapability() => adapter.write([START_SYSEX, CAPABILITY_QUERY, END_SYSEX]);

  /// Asks the arduino to tell us its analog pin mapping
  Future queryAnalogMapping() => adapter.write([START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX]);

  /// Close the connection
  Future close() => adapter.close();

  /// Asks the arduino to write a value to a digital pin
  Future digitalWrite(int pin, int value) {
    final portNumber = (pin >> 3) & 0x0F;
    if (value == 0) {
      _digitalOutputData[portNumber] &= ~(1 << (pin & 0x07)); // Clear bit
    } else {
      _digitalOutputData[portNumber] |= (1 << (pin & 0x07)); // Set bit
    }
    return adapter.write([DIGITAL_MESSAGE | portNumber, _digitalOutputData[portNumber] & 0x7F, _digitalOutputData[portNumber] >> 7]);
  }

  /// Stream that sent state from digital value
  Stream<PinState> get onDigitalRead {
    if(digitalReadStream == null){
      digitalReadStream = _digitalReadController.stream.asBroadcastStream();
    }
    return digitalReadStream;
  }

  /// Stream that sent analogic value
  Stream<PinState> get onAnalogRead {
    if(_analogReadStream == null){
      _analogReadStream = _analogReadController.stream.asBroadcastStream();
    }
    return _analogReadStream;
  }

  /// Read the digatal value from pin;
  int digitalRead(int pin) => _digitalInputData.containsKey(pin) ? _digitalInputData[pin] : 0;

  /// Asks the arduino to write an analog message.
  Future analogWrite(int pin, int value) {
    pinMode(pin, PinModes.PWM);
    return adapter.write([ANALOG_MESSAGE | (pin & 0x0F), value & 0x7F, value >> 7]);
  }

  /// Read the analog value from pin
  int analogRead(int pin) => _analogInputData.containsKey(pin) ? _analogInputData[pin] : 0;

  /// Asks the arduino to move a servo
  Future servoWrite(int pin, int angle) {
    pinMode(pin, PinModes.SERVO);
    return adapter.write([ANALOG_MESSAGE | (pin & 0x0F), angle & 0x7F, angle >> 7]);
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
