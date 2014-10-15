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

import 'package:firmata/firmata.dart';
import 'dart:async';

final P1 = 2;
final P2 = 3;
final L1 = 4;
final L2 = 5;
final L3 = 6;
final L4 = 7;

main() {
  print('Diduino start ...');
  Board.detect().then((board) {

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    board.pinMode(L1, Modes.OUTPUT);
    board.pinMode(L2, Modes.OUTPUT);
    board.pinMode(L3, Modes.OUTPUT);
    board.pinMode(L4, Modes.OUTPUT);
    board.pinMode(P1, Modes.INPUT);
    board.pinMode(P2, Modes.INPUT);

    board.onDigitalRead.listen((pinState){
      if(pinState.pin == P1){
        board.digitalWrite(L1, pinState.value);
        board.digitalWrite(L2, pinState.value);
      } else {
        board.digitalWrite(L3, pinState.value);
        board.digitalWrite(L4, pinState.value);
      }
    });

  }).catchError((error) => print("Cannot connect $error"));
}
