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

import 'package:test/test.dart';
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
    
    Timer timeOut(int seconds) =>  
      new Timer(new Duration(seconds: seconds), () {
        fail('event not fired in time');
      });

    test('Report version only connexion', () async {
        // Given
        parser = new SysexParser();
        final t = timeOut(1);
        
        // When
        parser.append(CONNEXION_BYTES);
        FirmataVersion version = await parser.onFirmataVersion.first;

        // Then        
        expect(version.major, 2);
        expect(version.minor, 3);
        expect(version.name, 'StandardFirmata.ino');
        
        t.cancel();
    });

    test('Report version full version', () async {
        // Given
        parser = new SysexParser();
        final t = timeOut(1);
        
        // When
        parser.append(FIRMWARE_QUERY_RESPONSE_BYTES);
        FirmataVersion version = await parser.onFirmataVersion.first;

        // Then        
        expect(version.major, 2);
        expect(version.minor, 3);
        expect(version.name, 'StandardFirmata.ino');
        
        t.cancel();
    });

    test('Digital message', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append([0x90, 0x0C, 0x00]);
      Map<int, int> pinState = await parser.onDigitalMessage.first;
      
      // Then
      expect(pinState.length, 8);
      expect(pinState[0], 0);
      expect(pinState[1], 0);
      expect(pinState[2], 1);
      expect(pinState[3], 1);
      expect(pinState[4], 0);
      expect(pinState[5], 0);
      expect(pinState[6], 0);
      expect(pinState[7], 0);

      t.cancel();
      
    });

    test('Digital message other pins', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append([0x90, 0x0C, 0x01]);
      Map<int, int> pinState = await parser.onDigitalMessage.first;
      
      // Then
      expect(pinState.length, 8);
      expect(pinState[8], 0);
      expect(pinState[9], 0);
      expect(pinState[10], 1);
      expect(pinState[11], 1);
      expect(pinState[12], 0);
      expect(pinState[13], 0);
      expect(pinState[14], 0);
      expect(pinState[15], 0);

      t.cancel();
    });

    test('Analog message on pin', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);

      // When
      parser.append([0xE1, 0x14, 0x01]);
      Map<int, int> pinState = await parser.onAnalogMessage.first;
      
      // Then
      expect(pinState.length, 1);
      expect(pinState[1], 148);
      
      t.cancel();
    });

    test('Analog message on last pin', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append([0xEF, 0x14, 0x01]);
      Map<int, int> pinState = await parser.onAnalogMessage.first;
      
      // Then
      expect(pinState.length, 1);
      expect(pinState[15], 148);

      t.cancel();
    });

    test('Analog query response', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append(ANALOG_MAPPING_RESPONSE_BYTES);
      List<int> analogPins = await parser.onAnalogMapping.first;

      // Then
      expect(analogPins, [0, 1, 2, 3, 4, 5]);

      t.cancel();
    });

    test('Capability query response', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append(CAPABILITY_QUERY_RESPONSE_BYTES);
      Map<int, List<int>> capabilities = await parser.onCapability.first;

      // Then
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
  
      t.cancel();
    });

    test('Pin State response pin 13 is off', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);
      
      // When
      parser.append([0xF0, 0x6E, 0x0D, 0x01, 0x00, 0xF7]);
      PinState pinState = await parser.onPinState.first;

      // Then
      expect(pinState.pin, 13);
      //expect(pinState.mode, PinModes.INPUT);
      expect(pinState.value, PinValue.LOW);

      t.cancel();
    });

    test('Pin State response pin 13 is on', () async {
      // Given
      parser = new SysexParser(true);
      final t = timeOut(1);

      // When
      parser.append([0xF0, 0x6E, 0x0D, 0x01, 0x01, 0xF7]);
      PinState pinState = await parser.onPinState.first;

      // Then
      expect(pinState.pin, 13);
      //expect(pinState.mode, PinModes.INPUT);
      expect(pinState.value, PinValue.HIGH);

      t.cancel();
    });

    // TODO analog pinState + unknow pinState

  });
}
