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

final L1 = 4;
final L2 = 5;

main() {
  Board.detect().then((board) {

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    board.pinMode(L1, PinModes.OUTPUT);
    board.pinMode(L2, PinModes.OUTPUT);

    board.onAnalogRead.listen((PinState state){
      if(state.pin == 0){
        final value = state.value;
          if(value < 256){
            board.digitalWrite(L1, PinValue.LOW);
            board.digitalWrite(L2, PinValue.LOW);
          } else if(value < 512){
            board.digitalWrite(L1, PinValue.HIGH);
            board.digitalWrite(L2, PinValue.LOW);
          } else  if(value < 767){
            board.digitalWrite(L1, PinValue.LOW);
            board.digitalWrite(L2, PinValue.HIGH);
          } else {
            board.digitalWrite(L1, PinValue.HIGH);
            board.digitalWrite(L2, PinValue.HIGH);
          }
      }
    });

  }).catchError((error) => print("Cannot connect $error"));
}
