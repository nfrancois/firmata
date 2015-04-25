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
import 'package:mockito/mockito.dart';
import 'dart:async';

final CONNEXION_BYTES =  [0xF9, 0x02, 0x03, 0xf0, 0x79, 0x02, 0x03, 0x53, 0x00, 0x74, 0x00, 0x61, 0x00, 0x6E,
0x00, 0x64, 0x00, 0x61, 0x00, 0x72, 0x00, 0x64, 0x00, 0x46, 0x00, 0x69, 0x00, 0x72, 0x00, 0x6D, 0x00, 0x61, 0x00,
0x74, 0x00, 0x61, 0x00, 0x2E, 0x00, 0x69, 0x00, 0x6e, 0x00, 0x6F, 0x00, 0xF7];

final FIRMWARE_QUERY_RESPONSE_BYTES = [0xF0, 0x79, 0x02, 0x03, 0x53, 0x00, 0x74, 0x00, 0x61, 0x00, 0x6e, 0x00,
0x64, 0x00, 0x61, 0x00, 0x72, 0x00, 0x64, 0x00, 0x46, 0x00, 0x69, 0x00, 0x72, 0x00, 0x6d, 0x00, 0x61, 0x00, 0x74,
0x00, 0x61, 0x00, 0x2E, 0x00, 0x69, 0x00, 0x6E, 0x00, 0x6F, 0x00, 0xF7];

// Mock adapter for test
class AdapterMock extends Mock implements SerialPortAdapter{

  final StreamController readController = new StreamController<List<int>>();

  Stream<List<int>> get onRead => readController.stream;

}

void main() {

  group('Board', (){

    Board board;
    AdapterMock adapterMock;

    setUp(() {
        // Init tested class and mock
        adapterMock = new AdapterMock();
        board = new BoardImpl(adapterMock);
    });

    test('Close', () async {
        // When
        await board.close();

        // Then
        verify(adapterMock.close());
        verifyNoMoreInteractions(adapterMock);
    });

   test('Open', () async {
       // Given
       adapterMock.readController.add(CONNEXION_BYTES);

        // When
        await board.open();

        // Then
        expect(board.firmware, new FirmataVersion("StandardFirmata.ino", 2, 3));
        verify(adapterMock.open());
        for(int i=0xC0; i<=0xDF; i++){
          verify(adapterMock.write([i, 1]));
        }
        verifyNoMoreInteractions(adapterMock);
    });

   test('Pin mode', () async {
        // When
        await board.pinMode(13, PinModes.OUTPUT);

        // Then
        verify(adapterMock.write([244, 13, 1]));
        verifyNoMoreInteractions(adapterMock);
    });

    test('Query Firmware', () async {
      // Given
      adapterMock.readController.add(FIRMWARE_QUERY_RESPONSE_BYTES);

      // When
      final firmware = await board.queryFirmware();

      // Then
      expect(firmware, new FirmataVersion("StandardFirmata.ino", 2, 3));
      verify(adapterMock.write([0xF0, 0x79, 0xF7]));
      verifyNoMoreInteractions(adapterMock);
    });

    test('Reset', () async {
      // When
      final firmware = await board.reset();

      // Then
      verify(adapterMock.write([0xFF]));
      verifyNoMoreInteractions(adapterMock);
    });

  });

}
