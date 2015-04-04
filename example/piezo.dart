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


final BEEPER = 1;
final tones = [261, 277, 294, 311, 330, 349, 370, 392, 415, 440];

main() async {
  print('Diduino start ...');
  Board board = await detect();
  print("connected");
  for(int tone in tones){
    await board.playTone(BEEPER, tone, 1500);
  };
  board.stopTone(BEEPER);
}

