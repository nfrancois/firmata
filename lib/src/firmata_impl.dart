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
const int EXTENDED_ANALOG = 0x6F;
const int CAPABILITY_QUERY = 0x6B;
const int CAPABILITY_RESPONSE = 0x6C;
const int PIN_STATE_QUERY = 0x6D;
const int PIN_STATE_RESPONSE = 0x6E;
const int ANALOG_MAPPING_QUERY = 0x69;
const int ANALOG_MAPPING_RESPONSE = 0x6A;
const int I2C_REQUEST = 0x76;
const int I2C_REPLY = 0x77;
const int I2C_CONFIG = 0x78;
const int STRING_DATA = 0x71;
const int SYSTEM_RESET = 0xFF;
const int PULSE_OUT = 0x73;
const int PULSE_IN = 0x74;
const int SAMPLING_INTERVAL = 0x7A;
const int STEPPER = 0x72;
const int ONEWIRE_DATA = 0x73;
const int ONEWIRE_CONFIG_REQUEST = 0x41;
const int ONEWIRE_SEARCH_REQUEST = 0x40;
const int ONEWIRE_SEARCH_REPLY = 0x42;
const int ONEWIRE_SEARCH_ALARMS_REQUEST = 0x44;
const int ONEWIRE_SEARCH_ALARMS_REPLY = 0x45;
const int ONEWIRE_READ_REPLY = 0x43;
const int ONEWIRE_RESET_REQUEST_BIT = 0x01;
const int ONEWIRE_READ_REQUEST_BIT = 0x08;
const int ONEWIRE_DELAY_REQUEST_BIT = 0x10;
const int ONEWIRE_WRITE_REQUEST_BIT = 0x20;
const int ONEWIRE_WITHDATA_REQUEST_BITS = 0x3C;


class Modes {

  static final int INPUT = 0x00;
  static final int OUTPUT = 0x01;
  static final int ANALOG = 0x02;
  static final int PWM = 0x03;
  static final int SERVO = 0x04;
  static final int SHIFT = 0x05;
  static final int I2C = 0x06;
  static final int ONEWIRE = 0x07;
  static final int STEPPER = 0x08;
  static final int IGNORE = 0x7F;
  static final int UNKOWN = 0x10;

}


class Board {

  static final int HIGH = 1;
  static final int LOW = 0;

  Map<int, int> _pins = {};

  final SerialPort _serialPort;
  final _parser = new SysexParser();

  FirmataVersion _firmaware;

  Board(String portname) : _serialPort = new SerialPort(portname, baudrate: 57600);

  /// Open the connection with the board
  Future<bool> open() {
    final completer = new Completer<bool>();
    _serialPort.open().then((_){
      _serialPort.onRead.listen(_parser.append);
    });
    _parser.onReportVersion.listen((firmware){
      _firmaware = firmware;
      for (var i = 0; i < 16; i++) {
        _serialPort.write([REPORT_DIGITAL | i, 1]);
        _serialPort.write([REPORT_ANALOG | i, 1]);
      }
      queryCapability().then((_) => queryAnalogMapping())
                       .then((_) =>  completer.complete(true));
    });
    return completer.future;
  }

  /// Getter for firmware information
  FirmataVersion get firmware => _firmaware;

  void pinMode(int pin, int mode){
    _pins[pin] = mode;
    _serialPort.write([PIN_MODE, pin, mode]);
  }

  ///Asks the arduino to write a value to a digital pin
  Future<bool> digitalWrite(int pin, int value){
    final int port = pin ~/ 8;
    _pins[pin] = value;
    int portValue = 0;
    for(int i=0; i<8; i++){
      if(_pins[8 * port+i] == 1){
        portValue |= (1 << i);
      }
    }
    return _serialPort.write([DIGITAL_MESSAGE | port, portValue & 0x7F, (portValue >> 7) & 0x7F]);
  }


 /// Asks the arduino to write an analog message.
 // TODO : when pin > 15 ?
 Future<bool> analogWrite(int pin, int value) {
   _pins[pin] =  value;
   return _serialPort.write([ANALOG_MESSAGE | pin, value & 0x7F, (value >> 7) & 0x7F]);
 }

  /// Resquest a QUERY_FIRMWARE call
  Future<bool> queryFirmware() =>
    _serialPort.write([START_SYSEX, QUERY_FIRMWARE, END_SYSEX]);

  /// Request a CAPABILITY_RESPONSE call
  Future<bool> queryCapability() =>
    _serialPort.write([START_SYSEX, CAPABILITY_QUERY, END_SYSEX]);

  /// Asks the arduino to tell us its analog pin mapping
  Future<bool> queryAnalogMapping() =>
    _serialPort.write([START_SYSEX, ANALOG_MAPPING_QUERY, END_SYSEX]);


  /// Close the connection
  Future<bool> close() => _serialPort.close();

}


/// Parser which read message sent from arduino
class SysexParser {

  final _reportVersionController = new StreamController<FirmataVersion>();

  List<int> _buffer = [];
  int _currentAnalyse = 0;

  /// Append byte to parse
  void append(List<int> bytes){
    //print(bytes);
    // find current analyse if necessary
    if (_currentAnalyse == 0) {
      // Only analyse some messages
      if (bytes.first == REPORT_VERSION) {
        _buffer.addAll(bytes);
        _currentAnalyse = REPORT_VERSION;
      }
    } else if (bytes.last == END_SYSEX) {
      switch (_currentAnalyse) {
        case REPORT_VERSION:
          _buffer.addAll(bytes);
          _readReportVersion();
      }
      _currentAnalyse = 0;
      _buffer.clear();
    } else if(_currentAnalyse != 0){
      _buffer.addAll(bytes);
    }
  }

  void _readReportVersion(){
    final major = _buffer[1];
    final minor = _buffer[2];
    final name = new String.fromCharCodes(_buffer.getRange(5, _buffer.length-1));
    _reportVersionController.add(new FirmataVersion(name, major, minor));
  }

  /// Stream that sent FirmataVersion
  Stream<FirmataVersion> get onReportVersion =>
      _reportVersionController.stream;

}

/// Information about Firmata version
class FirmataVersion {
  final String name;
  final int major;
  final int minor;

  FirmataVersion(this.name, this.major, this.minor);

}
