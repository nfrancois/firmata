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
import 'dart:async';
import 'dart:math';

// sample from https://github.com/shokai/node-arduino-firmata/blob/master/samples/analog_write.js

final L2 = 5;

main() async {
  final board = await detect();

  print("connected");
  print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

  await board.pinMode(L2, PinModes.OUTPUT);

  final alea = new Random();

  new Timer.periodic(new Duration(milliseconds: 500), (_) async {
    final value = alea.nextInt(255);
    print("analog write pin : $value");
    await board.analogWrite(L2, value);
  });

}
