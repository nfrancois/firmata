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

import 'dart:async';
import 'package:firmata/src/firmata_internal.dart';
import 'package:unittest/unittest.dart';
import 'package:mockito/mockito.dart';

main(){
  group("Board", (){

    Board board;
    SerialPortAdapter adapterMock;


    setUp((){
      adapterMock = new SerialPortAdapterMock();
      board = new BoardImpl(adapterMock);
    });

    test("Open connection", (){
      when(adapterMock.open()).thenReturn(new Completer().complete(true)); //.thenReturn(new Future.value([true]));

      board.open().then(expectAsync((_){

      }));


      /*
      when(adapterMock.onRead).thenReturn(readController.stream);
      when(adapterMock.onReportVersion).thenReturn(reportVersionController.stream);
      reportVersionController.add(new FirmataVersion("mock firmaware", 2, 3));
      */
    });

  });
}

// Mock adapter
class SerialPortAdapterMock extends Mock implements SerialPortAdapter {

  Future open() => new Future.value([true]);

  StreamController readController = new StreamController();

  Stream get onRead => readController.stream;

}
