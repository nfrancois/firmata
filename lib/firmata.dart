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

library firmata_native;

import 'dart:io';
import 'dart:async';
import 'src/firmata_internal.dart';
import 'package:serial_port/serial_port.dart';

export 'src/firmata_internal.dart' show PinModes, PinValue, Board, FirmataVersion;
export 'package:gpio_commons/gpio_commons.dart';

part 'src/native/adapter.dart';
