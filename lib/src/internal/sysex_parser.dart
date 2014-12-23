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

enum ParserAnalyse { NONE, REPORT_VERSION, DIGITAL_MESSAGE, ANALOG_MESSAGE, ANALOG_MAPPING, CAPACITY, PIN_STATE}

/// Parser which read message sent from arduino
class SysexParser {

  final _firmataVersion = new StreamController<FirmataVersion>();
  final _digitalMessageController = new StreamController<Map<int, int>>();
  final _analogMessageController = new StreamController<Map<int, int>>();
  final _analogMappingController = new StreamController<List<int>>();
  final _capabilityController = new StreamController<Map<int, List<int>>>();
  final _pinStateController = new StreamController<PinState>();
  final _i2cReplyController = new StreamController<I2CResponse>();
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
                                   (byte == CAPABILITY_RESPONSE) ||
                                   (byte == ANALOG_MAPPING_RESPONSE) ||
                                   (byte == I2C_REPLY) ||
                                   (byte == PIN_STATE_RESPONSE)
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
      }  else if(_currentAnalyse == CAPABILITY_RESPONSE && byte == END_SYSEX){
        _decodeCapability(_buffer);
        _reset();
      } else if(_currentAnalyse == PIN_STATE_RESPONSE && byte == END_SYSEX){
        _decodePinState(_buffer);
        _reset();
      } else if(_currentAnalyse == I2C_REPLY && byte == END_SYSEX){
        _decodeI2CReply(_buffer);
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

  void _decodeCapability(List<int> message){
    final length = message.length - 1;// Avoid end_sysex byte
    var i = 1;
    var jump = 2;
    var pin = 0;
    Map<int, List<int>> capabilities = new Map();
    while(i<length){
      final byte = message[i];
      if(!capabilities.containsKey(pin)){
        capabilities[pin] = [];
      }
      if(byte == 0x7F){// End of current pin config
        pin++;
        jump = 1;
      } else {// can pin mode
        capabilities[pin].add(byte);
        jump = 2;
      }
      i += jump;
    }
    _capabilityController.add(capabilities);
  }

  void _decodePinState(List<int> message){
    int pin = message[1];
    List<int> valueAsBytes = message.getRange(3, message.length-1).toList();
    var value = 0;
    for(int i=0; i<valueAsBytes.length; i++){
      value += valueAsBytes[i] << (7*i);
    }
    _pinStateController.add(new PinState(pin, value));
  }

  void _decodeI2CReply(List<int> message){
    final address = message[1] | message[2]<< 7;
    final register = message[3] | message[4]<< 7;
    List<int> valuesAsBytes = message.getRange(5, message.length-1).toList();
    final data = [];
    for(int i=0; i<valuesAsBytes.length; i+=2){
      data.add(message[i] | message[i+1]<< 7);
    }
    _i2cReplyController.add(new I2CResponse(address, register, data));
  }

  /// Stream that sent FirmataVersion
  Stream<FirmataVersion> get onFirmataVersion => _firmataVersion.stream;

  /// Stream pin digital states
  Stream<Map<int, int>> get onDigitalMessage => _digitalMessageController.stream;

  /// Stream pin analog states
  Stream<Map<int, int>> get onAnalogMessage => _analogMessageController.stream;

  /// Stream analog mapping
  Stream<List<int>> get onAnalogMapping => _analogMappingController.stream;

  /// Stream capability
  Stream<Map<int, List<int>>> get onCapability => _capabilityController.stream;

  /// Stream pinState
  Stream<PinState> get onPinState => _pinStateController.stream;

  /// Stream pinState
  Stream<I2CResponse> get onI2CReply => _i2cReplyController.stream;

}
