// Copyright (c) 2014-2015, Nicolas François
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

/// The arduino board
abstract class Board {

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

  /// Configure a pin as a servo pin.
  Future servoConfig(int pin, int min, int max);

}

class BoardImpl implements Board {

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

  BoardImpl(this.adapter){
    adapter.onRead.listen(_parser.append);
    _parser.onDigitalMessage.listen(_digitalPinStatesChanged);
    _parser.onAnaloglMessage.listen(_analogPinStatesChanged);
  }

  Future open() async {
    await adapter.open();
    _firmware = await _parser.onReportVersion.first;
    for (var i = 0; i < 16; i++) {
      await adapter.write([REPORT_DIGITAL | i, 1]);
      await adapter.write([REPORT_ANALOG | i, 1]);
    }
    return true;
  }

  Future sendSysex(int command, [List<int> sysexData]) async {
    List<int> data = [START_SYSEX, command];
    if(sysexData != null){
      data.addAll(sysexData);
    }
    data.add(END_SYSEX);
    await adapter.write(data);
    return true;
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

  Future pinMode(int pin, int mode) {
    _pins[pin] = mode;
    return adapter.write([PIN_MODE, pin, mode]);
  }

  FirmataVersion get firmware => _firmware;

  Future reset() => adapter.write([SYSTEM_RESET]);

  Future queryFirmware() => sendSysex(QUERY_FIRMWARE);

  //Future<bool> queryPinState(int pin) => sendSysex( PIN_STATE_QUERY, [pin]);

  Future queryCapability() => sendSysex(CAPABILITY_QUERY);

  Future queryAnalogMapping() => sendSysex(ANALOG_MAPPING_QUERY);

  Future close() => adapter.close();

  Future digitalWrite(int pin, int value) {
    final portNumber = (pin >> 3) & 0x0F;
    if (value == 0) {
      _digitalOutputData[portNumber] &= ~(1 << (pin & 0x07)); // Clear bit
    } else {
      _digitalOutputData[portNumber] |= (1 << (pin & 0x07)); // Set bit
    }
    return adapter.write([DIGITAL_MESSAGE | portNumber, lsb(_digitalOutputData[portNumber]), msb(_digitalOutputData[portNumber])]);
  }

  Stream<PinState> get onDigitalRead {
    if(digitalReadStream == null){
      digitalReadStream = _digitalReadController.stream.asBroadcastStream();
    }
    return digitalReadStream;
  }

  Stream<PinState> get onAnalogRead {
    if(_analogReadStream == null){
      _analogReadStream = _analogReadController.stream.asBroadcastStream();
    }
    return _analogReadStream;
  }

  int digitalRead(int pin) => _digitalInputData.containsKey(pin) ? _digitalInputData[pin] : 0;

  Future analogWrite(int pin, int value) async {
    await pinMode(pin, PinModes.PWM);
    return adapter.write([ANALOG_MESSAGE | (pin & 0x0F), lsb(value), msb(value)]);
  }

  int analogRead(int pin) => _analogInputData.containsKey(pin) ? _analogInputData[pin] : 0;

  Future servoWrite(int pin, int angle) async {
    await pinMode(pin, PinModes.SERVO);
    return adapter.write([ANALOG_MESSAGE | (pin & 0x0F), lsb(angle), msb(angle)]);
  }

  Future servoConfig(int pin, int min, int max) => sendSysex(SERVO_CONFIG, [lsb(min), msb(min), lsb(max), msb(max)]);

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

/// Filter portName for MacOs
bool isMacPortName(String name) => name.startsWith("/dev/tty") && name.contains("usb");
