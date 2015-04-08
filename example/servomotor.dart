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

// Example from https://github.com/jgautier/firmata/blob/master/examples/blink.js

import 'package:firmata/firmata.dart';
import 'dart:async';

void main() async {
  final board = await detect();

  final pin = 2;

  print("connected");
  print(board.firmware);

  int angle = 0;

  new Timer.periodic(new Duration(milliseconds: 100), (_) async {
    print(angle);
    await board.servoWrite(pin, angle);
    angle++;
    angle%=180;
  });

}
