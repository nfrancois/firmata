part of serial_port;

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
