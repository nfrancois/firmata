part of serial_port;

// Constants
const int PIN_MODE = 0xF4;
const int REPORT_DIGITAL = 0xD0;
const int REPORT_ANALOG = 0xC0;
const int DIGITAL_MESSAGE = 0x90;
const int START_SYSEX = 0xF0;
const int END_SYSEX = 0xF7;

const int QUERY_FIRMWARE = 0x79;
const int REPORT_VERSION = 0xF9;
const int ANALOG_MESSAGE = 0xE0;
//const int EXTENDED_ANALOG = 0x6F;
const int CAPABILITY_QUERY = 0x6B;
//const int CAPABILITY_RESPONSE = 0x6C;
//const int PIN_STATE_QUERY = 0x6D;
//const int PIN_STATE_RESPONSE = 0x6E;
const int ANALOG_MAPPING_QUERY = 0x69;
//const int ANALOG_MAPPING_RESPONSE = 0x6A;
//const int I2C_REQUEST = 0x76;
//const int I2C_REPLY = 0x77;
//const int I2C_CONFIG = 0x78;
//const int STRING_DATA = 0x71;
//const int SYSTEM_RESET = 0xFF;
//const int PULSE_OUT = 0x73;
//const int PULSE_IN = 0x74;
//const int SAMPLING_INTERVAL = 0x7A;
//const int STEPPER = 0x72;
//const int ONEWIRE_DATA = 0x73;
//const int ONEWIRE_CONFIG_REQUEST = 0x41;
//const int ONEWIRE_SEARCH_REQUEST = 0x40;
//const int ONEWIRE_SEARCH_REPLY = 0x42;
//const int ONEWIRE_SEARCH_ALARMS_REQUEST = 0x44;
//const int ONEWIRE_SEARCH_ALARMS_REPLY = 0x45;
//const int ONEWIRE_READ_REPLY = 0x43;
//const int ONEWIRE_RESET_REQUEST_BIT = 0x01;
//const int ONEWIRE_READ_REQUEST_BIT = 0x08;
//const int ONEWIRE_DELAY_REQUEST_BIT = 0x10;
//const int ONEWIRE_WRITE_REQUEST_BIT = 0x20;
//const int ONEWIRE_WITHDATA_REQUEST_BITS = 0x3C;

/// Pin usage modes
class Modes {

  static final int INPUT = 0x00;
  static final int OUTPUT = 0x01;
  //static final int ANALOG = 0x02;
  static final int PWM = 0x03;
  //static final int SERVO = 0x04;
  //static final int SHIFT = 0x05;
  //static final int I2C = 0x06;
  //static final int ONEWIRE = 0x07;
  //static final int STEPPER = 0x08;
  //static final int IGNORE = 0x7F;
  //static final int UNKOWN = 0x10;

}

/// The arduino board
abstract class Board {

  /// Constant to set a pins value to HIGH when the pin is set to an output.
  static final int HIGH = 1;
  /// Constant to set a pins value to LOW when the pin is set to an output.
  static final int LOW = 0;

  /// Try to detect a arduino board
  static Future<Board> detect(){
    final completer = new Completer<Board>();
    SerialPort.avaiblePortNames.then((List<String> portNames){
      final avaibles = Platform.isMacOS ? portNames.where((name) => name.contains("usb")).toList() : portNames;
      if(avaibles.isEmpty){
        completer.completeError("Impossible to detect Arduino board on usb.");
      } else {
        final board =  new _Board(avaibles.first);
        board.open().then((_) => completer.complete(board));
      }
    });
    return completer.future;
  }

  static Future<Board> fromPortName(String portName) {
    final completer = new Completer<Board>();
    final board =  new _Board(portName);
    board.open().then((_) => completer.complete(board));
    return completer.future;
  }

  /// Asks the arduino to set the pin to a certain mode.
  void pinMode(int pin, int mode);

  /// Getter for firmware information
  FirmataVersion get firmware;

  /// Resquest a QUERY_FIRMWARE call
  Future<bool> queryFirmware();

  /// Request a CAPABILITY_RESPONSE call
  Future<bool> queryCapability();

  /// Asks the arduino to tell us its analog pin mapping
  Future<bool> queryAnalogMapping();

  /// Close the connection
  Future<bool> close();

  /// Asks the arduino to write a value to a digital pin
  Future<bool> digitalWrite(int pin, int value);

  /// Stream that sent FirmataVersion
  Stream<PinState> get onDigitalRead;

  /// Stream that sent FirmataVersion
  Stream<PinState> get onAnalogRead;

  /// Read the digatal value from pin;
  int digitalRead(int pin);

  /// Asks the arduino to write an analog message.
  Future<bool> analogWrite(int pin, int value);

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

  /// Create a board on port name
  _Board(String portname) : serialPort = new SerialPort(portname, baudrate: 57600);

  /// Open the connection with the board
  Future<bool> open() {
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
    parser.onDigitalMessage.listen(pinStatesChanged);
    //_parser.onAnaloglMessage.listen(_pinStatesChanged);
    return completer.future;
  }

  /// Analyse the change and dispatch wich pin as change
  void pinStatesChanged(Map<int, int> states){
    states.forEach((pin, state){
      if(pins[pin] == Modes.INPUT){
        digitalInputData[pin] = state;
        digitalReadController.add(new PinState(pin, state));
      }
    });
  }

  /// Asks the arduino to set the pin to a certain mode.
  void pinMode(int pin, int mode) {
    pins[pin] = mode;
    serialPort.write([PIN_MODE, pin, mode]);
  }

  /// Resquest a QUERY_FIRMWARE call
  Future<bool> queryFirmware() => serialPort.write([START_SYSEX, QUERY_FIRMWARE, END_SYSEX]);

  /// Asks the arduino to tell us the current state of a pin
  //Future<bool> queryPinState(int pin) => _serialPort.write(([START_SYSEX, PIN_STATE_QUERY, pin, END_SYSEX]));

  /// Request a CAPABILITY_RESPONSE call
  Future<bool> queryCapability() => serialPort.write([START_SYSEX, CAPABILITY_QUERY, END_SYSEX]);

  /// Asks the arduino to tell us its analog pin mapping
  Future<bool> queryAnalogMapping() => serialPort.write([START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX]);

  /// Close the connection
  Future<bool> close() => serialPort.close();

  /// Asks the arduino to write a value to a digital pin
  Future<bool> digitalWrite(int pin, int value) {
    final portNumber = (pin >> 3) & 0x0F;
    if (value == 0) {
      digitalOutputData[portNumber] &= ~(1 << (pin & 0x07)); // Clear bit
    } else {
      digitalOutputData[portNumber] |= (1 << (pin & 0x07)); // Set bit
    }
    return serialPort.write([DIGITAL_MESSAGE | portNumber, digitalOutputData[portNumber] & 0x7F, digitalOutputData[portNumber] >> 7]);
  }

  /// Stream that sent FirmataVersion
  Stream<PinState> get onDigitalRead => digitalReadController.stream;

  /// Stream that sent FirmataVersion
  Stream<PinState> get onAnalogRead => analogReadController.stream;

  /// Read the digatal value from pin;
  int digitalRead(int pin) => digitalInputData.containsKey(pin) ? digitalInputData[pin] : 0;

  /// Asks the arduino to write an analog message.
  Future<bool> analogWrite(int pin, int value) {
    pinMode(pin, Modes.PWM);
    return serialPort.write([ANALOG_MESSAGE | (pin & 0x0F), value & 0x7F, value >> 7]);
  }

  // TODO analog read stream

  // Read the analog value from pin;
  //int analogRead(int pin) => _analogInputData.containsKey(pin) ? _analogInputData[pin] : 0;

  // Asks the arduino to move a servo
  //Future<bool> servoWrite(int pin, num angle) {
  //  pinMode(pin, Modes.SERVO);
  //  return _serialPort.write([ArduinoFirmata.ANALOG_MESSAGE | (pin & 0x0F), angle & 0x7F, angle >> 7]);
  //);

}


/// Parser which read message sent from arduino
class SysexParser {

  final _reportVersionController = new StreamController<FirmataVersion>();
  final _digitalMessageController = new StreamController<Map<int, int>>();
  final _analoglMessageController = new StreamController<Map<int, int>>();
  final List<int> _buffer = [];
  int _currentAnalyse = 0;

  /// Append byte to parse
  void append(List<int> bytes) {
    bytes.forEach(_processByte);
  }

  /// Analyse byte by byte
  void _processByte(int byte){
    if (_currentAnalyse == 0) { // find current analyse if necessary
      // Only analyse some messages
      if (byte == REPORT_VERSION || byte == DIGITAL_MESSAGE /*|| byte == ANALOG_MESSAGE*/){
        _currentAnalyse = byte;
        _buffer.add(byte);
      }
    } else {// Reading bytes
      _buffer.add(byte);
      // Could be end of message
      if (_currentAnalyse == REPORT_VERSION && byte == END_SYSEX) {
        _decodeReportVersion(_buffer);
        _reset();
      } else if(_currentAnalyse == DIGITAL_MESSAGE && _buffer.length == 3) {
        _decodeDigitalMessage(_buffer);
        _reset();
      } else if(_currentAnalyse == ANALOG_MESSAGE && _buffer.length == 3){
        _decodeAnaloglMessage(_buffer);
        _reset();
      }
    }
  }

  /// Reset the parser
  void _reset(){
    _buffer.clear();
    _currentAnalyse = 0;
  }

  /// Decode report version in buffer and trig the stream
  void _decodeReportVersion(List<int> message) {
    final major = message[1];
    final minor = message[2];
    final name = new String.fromCharCodes(message.getRange(5, message.length - 1));
    _reportVersionController.add(new FirmataVersion(name, major, minor));
  }

  void _decodeDigitalMessage(List<int> message){
    final pins = new List<int>.generate(8, (i) => i+(message[2]*8));
    final states = new List<int>.generate(8, (i) => (message[1] & (1 << i)) >> i);
    final pinStates = new HashMap.fromIterables(pins, states);
    _digitalMessageController.add(pinStates);
  }

  void _decodeAnaloglMessage(List<int> message){
    final pins = new List<int>.generate(8, (i) => i+(message[2]*8));
    final states = new List<int>.generate(8, (i) => (message[1] & (1 << i)) >> i);
    final pinStates = new HashMap.fromIterables(pins, states);
    _analoglMessageController.add(pinStates);
  }

  /// Stream that sent FirmataVersion
  Stream<FirmataVersion> get onReportVersion => _reportVersionController.stream;

  /// Stream pin digital states
  Stream<Map<int, int>> get onDigitalMessage => _digitalMessageController.stream;

  /// Stream pin analog states
  Stream<Map<int, int>> get onAnaloglMessage => _analoglMessageController.stream;

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

/// A pin state
class PinState {
  /// pin number
  final int pin;
  /// Value of pin
  final int value;

  PinState(this.pin, this.value);
}
