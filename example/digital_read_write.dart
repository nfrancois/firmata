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

import 'package:firmata/firmata.dart';

final P1 = 2;
final P2 = 3;
final L1 = 4;
final L2 = 5;
final L3 = 6;
final L4 = 7;

main() async {
  print('Diduino start ...');
  final board = await detect();

  print("connected");
  print(board.firmware);

  await board.pinMode(L1, PinModes.OUTPUT);
  await board.pinMode(L2, PinModes.OUTPUT);
  await board.pinMode(L3, PinModes.OUTPUT);
  await board.pinMode(L4, PinModes.OUTPUT);
  await board.pinMode(P1, PinModes.INPUT);
  await board.pinMode(P2, PinModes.INPUT);

  board.onDigitalRead.listen((pinState) async {
    if(pinState.pin == P1){
      await board.digitalWrite(L1, pinState.value);
      await board.digitalWrite(L2, pinState.value);
    } else {
      await board.digitalWrite(L3, pinState.value);
      await board.digitalWrite(L4, pinState.value);
    }
  });

}
