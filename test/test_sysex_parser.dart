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

    // Tested object
    SysexParser parser;

    test('Report version', (){
        // given
        parser = new SysexParser();

        // then
        parser.onReportVersion.first.then(expectAsync((FirmataVersion version){
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
      parser.onAnaloglMessage.first.then(expectAsync((Map<int, int> pinState){
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
      parser.onAnaloglMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 1);
        expect(pinState[15], 148);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      // when
      parser.append([0xEF, 0x14, 0x01]);
    });

  });
}
