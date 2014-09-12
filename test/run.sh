#!/bin/sh

# prepare SerialPort lib
bin/install.sh

dart test/test_firmata.dart
