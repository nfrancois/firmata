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

enum ParserAnalyse { NONE, REPORT_VERSION, DIGITAL_MESSAGE, ANALOG_MESSAGE, ANALOG_MAPPING, QUERY_CAPACITY}

/// Parser which read message sent from arduino
class SysexParser {

  final _firmataVersion = new StreamController<FirmataVersion>();
  final _digitalMessageController = new StreamController<Map<int, int>>();
  final _analogMessageController = new StreamController<Map<int, int>>();
  final _analogMappingController = new StreamController<List<int>>();
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
          || (hasReceiveVersion && (byte == DIGITAL_MESSAGE ||
                                   (byte >= ANALOG_MESSAGE && byte <= ANALOG_MESSAGE+0x0F)) ||
                                   (byte == QUERY_FIRMWARE) ||
                                   (byte == ANALOG_MAPPING_RESPONSE)
              )
      ){
        _currentAnalyse = byte;
        _buffer.add(byte);
      }
    } else {// Reading bytes
      _buffer.add(byte);
      // Could be end of message
      if (_currentAnalyse == REPORT_VERSION && byte == END_SYSEX) {
        _decodeFirmataVersion(_buffer.getRange(4, _buffer.length-1).toList());
        _reset();
      } else if(_currentAnalyse == QUERY_FIRMWARE && byte == END_SYSEX){
        _decodeFirmataVersion(_buffer);
        _reset();
      } else if(_currentAnalyse == DIGITAL_MESSAGE && _buffer.length == 3) {
        _decodeDigitalMessage(_buffer);
        _reset();
      } else if(_currentAnalyse >= ANALOG_MESSAGE && _currentAnalyse <= ANALOG_MESSAGE+0x0F  && _buffer.length == 3){
        _decodeAnalogMessage(_buffer);
        _reset();
      } else if(_currentAnalyse == ANALOG_MAPPING_RESPONSE && byte == END_SYSEX){
        _decodeAnalogMapping(_buffer);
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
  void _decodeFirmataVersion(List<int> message) {
    final major = message[1];
    final minor = message[2];
    // TODO   analyse lsb/msb
    final name = new String.fromCharCodes(message.getRange(3, message.length - 1).where((b) => b!=0));
    hasReceiveVersion = true;
    _firmataVersion.add(new FirmataVersion(name, major, minor));
  }

  void _decodeDigitalMessage(List<int> message){
    final pins = new List<int>.generate(8, (i) => i+(message[2]*8));
    final states = new List<int>.generate(8, (i) => (message[1] & (1 << i)) >> i);
    final pinStates = new HashMap.fromIterables(pins, states);
    _digitalMessageController.add(pinStates);
  }

  void _decodeAnalogMessage(List<int> message){
    final pin = message[0]-ANALOG_MESSAGE;
    final value = message[1] + (message[2] << 7);
    _analogMessageController.add({pin : value });
  }

  void _decodeAnalogMapping(List<int> message){
    final analogPins = message.getRange(1, _buffer.length-1).where((byte) => byte != 0x7f).toList();
    _analogMappingController.add(analogPins);
  }

  /// Stream that sent FirmataVersion
  Stream<FirmataVersion> get onFirmataVersion => _firmataVersion.stream;

  /// Stream pin digital states
  Stream<Map<int, int>> get onDigitalMessage => _digitalMessageController.stream;

  /// Stream pin analog states
  Stream<Map<int, int>> get onAnalogMessage => _analogMessageController.stream;

  /// Stream analog mapping
  Stream<List<int>> get onAnalogMapping => _analogMappingController.stream;

}
