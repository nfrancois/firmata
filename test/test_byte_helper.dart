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

import 'package:unittest/unittest.dart';
import 'package:firmata/src/firmata_internal.dart';
import 'dart:async';

void main() {

  group('Byte helper', () {

    test('lsb with value < 0x7F', () {
      expect(lsb(0x10), 0x10);
    });

    test('lsb with value = 0x7F', () {
      expect(lsb(0x80), 0x00);
    });

    test('lsb with value > 0x7F', () {
      expect(lsb(0xFF), 0x7F);
    });

    test('msb with value < 0x7F', () {
      expect(msb(0x10), 0x00);
    });

    test('msb with value = 0x7F', () {
      expect(msb(0x80), 0x01);
    });

    test('msb with value = 130', () {
      expect(msb(130), 0x01);
    });

    test('msb with value = 0xFF', () {
      expect(msb(0xFF), 0x01);
    });
  });

}
