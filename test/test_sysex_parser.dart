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

import 'package:unittest/unittest.dart';
import 'package:firmata/src/firmata_internal.dart';
import 'dart:async';

void main() {

  group('Sysex Parser', (){

    final CONNEXION_BYTES =  [0xF9, 0x02, 0x03, 0xf0, 0x79, 0x02, 0x03, 0x53, 0x00, 0x74, 0x00, 0x61, 0x00, 0x6E,
    0x00, 0x64, 0x00, 0x61, 0x00, 0x72, 0x00, 0x64, 0x00, 0x46, 0x00, 0x69, 0x00, 0x72, 0x00, 0x6D, 0x00, 0x61, 0x00,
    0x74, 0x00, 0x61, 0x00, 0x2E, 0x00, 0x69, 0x00, 0x6e, 0x00, 0x6F, 0x00, 0xF7];

    final ANALOG_MAPPING_RESPONSE_BYTES = [0xF0, 0x6A, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F,
    0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0xF7];

    final FIRMWARE_QUERY_RESPONSE_BYTES = [0xF0, 0x79, 0x02, 0x03, 0x53, 0x00, 0x74, 0x00, 0x61, 0x00, 0x6e, 0x00,
    0x64, 0x00, 0x61, 0x00, 0x72, 0x00, 0x64, 0x00, 0x46, 0x00, 0x69, 0x00, 0x72, 0x00, 0x6d, 0x00, 0x61, 0x00, 0x74,
    0x00, 0x61, 0x00, 0x2E, 0x00, 0x69, 0x00, 0x6E, 0x00, 0x6F, 0x00, 0xF7];

    final CAPABILITY_QUERY_RESPONSE_BYTES = [0xF0, 0x6C, 0x7F, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x04, 0x0E, 0x7F,
    0x00, 0x01, 0x01, 0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01,
    0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01,
    0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F,
    0x00, 0x01, 0x01, 0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x03, 0x08, 0x04, 0x0E, 0x7F, 0x00,
    0x01, 0x01, 0x01, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A,
    0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A, 0x04,
    0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A, 0x04, 0x0E, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A, 0x04, 0x0E,
    0x06, 0x01, 0x7F, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0A, 0x04, 0x0E, 0x06, 0x01, 0x7F, 0xF7];


    // Tested object
    SysexParser parser;

    test('Report version', (){
        // given
        parser = new SysexParser();

        // then
        parser.onFirmataVersion.first.then(expectAsync((FirmataVersion version){
            expect(version.major, 2);
            expect(version.minor, 3);
            expect(version.name, 'StandardFirmata.ino');
        }));

        new Timer(new Duration(seconds: 1), () {
          fail('event not fired in time');
        });

        // when
        parser.append(CONNEXION_BYTES);

    });

    test('Report version', (){
        // given
        parser = new SysexParser();

        // then
        parser.onFirmataVersion.first.then(expectAsync((FirmataVersion version){
            expect(version.major, 2);
            expect(version.minor, 3);
            expect(version.name, 'StandardFirmata.ino');
        }));

        new Timer(new Duration(seconds: 1), () {
          fail('event not fired in time');
        });

        // when
        parser.append(FIRMWARE_QUERY_RESPONSE_BYTES);

    });

    test('Digital message', (){
      // given
      parser = new SysexParser(true);

      // then
      parser.onDigitalMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 8);
        expect(pinState[0], 0);
        expect(pinState[1], 0);
        expect(pinState[2], 1);
        expect(pinState[3], 1);
        expect(pinState[4], 0);
        expect(pinState[5], 0);
        expect(pinState[6], 0);
        expect(pinState[7], 0);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      // when
      parser.append([0x90, 0x0C, 0x00]);
    });

    test('Digital message other pins', (){
      // given
      parser = new SysexParser(true);

      // then
      parser.onDigitalMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 8);
        expect(pinState[8], 0);
        expect(pinState[9], 0);
        expect(pinState[10], 1);
        expect(pinState[11], 1);
        expect(pinState[12], 0);
        expect(pinState[13], 0);
        expect(pinState[14], 0);
        expect(pinState[15], 0);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      // when
      parser.append([0x90, 0x0C, 0x01]);
    });

    test('Analog message on pin', (){
      // given
      parser = new SysexParser(true);

      // then
      parser.onAnalogMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 1);
        expect(pinState[1], 148);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      // when
      parser.append([0xE1, 0x14, 0x01]);
    });

    test('Analog message on last pin', (){
      // given
      parser = new SysexParser(true);

      // then
      parser.onAnalogMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 1);
        expect(pinState[15], 148);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      // when
      parser.append([0xEF, 0x14, 0x01]);
    });

    test('Analog query response', (){
      // given
      parser = new SysexParser(true);

      // then
      parser.onAnalogMapping.first.then(expectAsync((List<int> analogPins){
        expect(analogPins, [0, 1, 2, 3, 4, 5]);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      //
      parser.append(ANALOG_MAPPING_RESPONSE_BYTES);
    });
    
    test('Capability query response', (){
      // given
      parser = new SysexParser(true);      
      
      // then
      parser.onCapability.first.then(expectAsync((Map<int, List<int>> capabilities){
        expect(capabilities.length, 20);
        expect(capabilities[0], []);
        expect(capabilities[1], []);
        expect(capabilities[2], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[3], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[4], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[5], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[6], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[7], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[8], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[9], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[10], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[11], [PinModes.INPUT, PinModes.OUTPUT, PinModes.PWM, PinModes.SERVO]);
        expect(capabilities[12], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[13], [PinModes.INPUT, PinModes.OUTPUT, PinModes.SERVO]);
        expect(capabilities[14], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO]);
        expect(capabilities[15], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO]);
        expect(capabilities[16], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO]);
        expect(capabilities[17], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO]);
        expect(capabilities[18], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO, PinModes.I2C]);
        expect(capabilities[19], [PinModes.INPUT, PinModes.OUTPUT, PinModes.ANALOG, PinModes.SERVO, PinModes.I2C]);
      }));
      
      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });
      
      // when
      parser.append(CAPABILITY_QUERY_RESPONSE_BYTES);
      
    });

  });
}
