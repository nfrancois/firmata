#!/bin/sh

# prepare SerialPort lib
bin/install.sh

dart test/test_board.dart
dart test/test_byte_helper.dart
dart test/test_sysex_parser.dart
