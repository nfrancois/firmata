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

// Mock adapter for test 
class AdapterMock extends Mock implements SerialPortAdapter{
    
  final Controller readController = new StreamController<List<int>>();
    
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

   
    
  });
    
}