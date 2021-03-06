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

final L1 = 4;
final L2 = 5;

main() async {
  final board = await detect();

  print("connected");
  print(board.firmware);

  await board.pinMode(L1, PinModes.OUTPUT);
  await board.pinMode(L2, PinModes.OUTPUT);

  board.onAnalogRead.listen((PinState state) async {
    if(state.pin == 0){
      final value = state.value;
        if(value < 256){
          await board.digitalWrite(L1, PinValue.LOW);
          await board.digitalWrite(L2, PinValue.LOW);
        } else if(value < 512){
          await board.digitalWrite(L1, PinValue.HIGH);
          await board.digitalWrite(L2, PinValue.LOW);
        } else  if(value < 767){
          await board.digitalWrite(L1, PinValue.LOW);
          await board.digitalWrite(L2, PinValue.HIGH);
        } else {
          await board.digitalWrite(L1, PinValue.HIGH);
          await board.digitalWrite(L2, PinValue.HIGH);
        }
    }
  });

}
