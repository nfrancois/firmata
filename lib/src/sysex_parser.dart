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

/// Parser which read message sent from arduino
class SysexParser {

  final _reportVersionController = new StreamController<FirmataVersion>();
  final _digitalMessageController = new StreamController<Map<int, int>>();
  final _analoglMessageController = new StreamController<Map<int, int>>();
  final List<int> _buffer = [];
  int _currentAnalyse = 0;
  bool hasReceiveVersion;

  SysexParser([this.hasReceiveVersion = false]);

  /// Append byte to parse
  void append(List<int> bytes) {
    bytes.forEach(_processByte);
  }

  /// Analyse byte by byte
  void _processByte(int byte){
    if (_currentAnalyse == 0) { // find current analyse if necessary
      // Only analyse some messages
      if ((byte == REPORT_VERSION && !hasReceiveVersion)
          || (hasReceiveVersion && (byte == DIGITAL_MESSAGE || (byte >= ANALOG_MESSAGE && byte <= ANALOG_MESSAGE+4)))){
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
      } else if(_currentAnalyse >= ANALOG_MESSAGE && _currentAnalyse <= ANALOG_MESSAGE+4  && _buffer.length == 3){
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
    hasReceiveVersion = true;
    _reportVersionController.add(new FirmataVersion(name, major, minor));
  }

  void _decodeDigitalMessage(List<int> message){
    final pins = new List<int>.generate(8, (i) => i+(message[2]*8));
    final states = new List<int>.generate(8, (i) => (message[1] & (1 << i)) >> i);
    final pinStates = new HashMap.fromIterables(pins, states);
    _digitalMessageController.add(pinStates);
  }

  void _decodeAnaloglMessage(List<int> message){
    final pin = message[0]-ANALOG_MESSAGE;
    final value = message[1] + (message[2] << 7);
    _analoglMessageController.add({pin : value });
  }

  /// Stream that sent FirmataVersion
  Stream<FirmataVersion> get onReportVersion => _reportVersionController.stream;

  /// Stream pin digital states
  Stream<Map<int, int>> get onDigitalMessage => _digitalMessageController.stream;

  /// Stream pin analog states
  Stream<Map<int, int>> get onAnaloglMessage => _analoglMessageController.stream;

}
