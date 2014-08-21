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


/*


SYSEX_RESPONSE[QUERY_FIRMWARE] = function(board) {
  var firmwareBuf = [];
  board.firmware.version = {};
  board.firmware.version.major = board.currentBuffer[2];
  board.firmware.version.minor = board.currentBuffer[3];
  for (var i = 4, length = board.currentBuffer.length - 2; i < length; i += 2) {
    firmwareBuf.push((board.currentBuffer[i] & 0x7F) | ((board.currentBuffer[i + 1] & 0x7F) << 7));
  }

  board.firmware.name = new Buffer(firmwareBuf).toString("utf8", 0, firmwareBuf.length);
  board.emit("queryfirmware");
};

 */


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

  Board(String portname) : _serialPort = new SerialPort(portname) {
    /*
     events.EventEmitter.call(this);
  if (typeof options === "function" || typeof options === "undefined") {
    callback = options;
    options = {
      reportVersionTimeout: 5000
    };
     */
  }

  Future<bool> open() => _serialPort.open();

  void pinMode(int pin, int mode){
    _pins[pin] = mode;
    _serialPort.write([PIN_MODE, pin, mode]);
  }

  void digitalWrite(int pin, int value){
    final int port = pin ~/ 8;
    _pins[pin] = value;
    int portValue = 0;
    for(int i=0; i<8; i++){
      if(_pins[8 * port+i] == 1){
        portValue |= (1 << i);
      }
    }
    print("port=$port, portValue=$portValue");
    _serialPort.write([DIGITAL_MESSAGE | port, portValue & 0x7F, (portValue >> 7) & 0x7F]);
  }

  Future<bool> queryFirmware() {
    //this.once("queryfirmware", callback);
    return _serialPort.write([START_SYSEX, QUERY_FIRMWARE, END_SYSEX]);
  }

  Future<bool> close() => _serialPort.close();

}
