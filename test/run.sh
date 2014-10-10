#!/bin/sh

# prepare SerialPort lib
bin/install.sh

dart test/test_sysex_parser.dart
