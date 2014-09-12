#Firmata

[![Build Status](https://drone.io/github.com/nfrancois/Firmata/status.png)](https://drone.io/github.com/nfrancois/Firmata/latest)

Dart Implementation of [Firmata](https://github.com/firmata/arduino)

Current status : in dev

Currently working :
* Connexion to Arduino
* Digital write
* Digital read

## Install

Firmata needs `serial_port` lib. To install it, easily, just run `bin/install.sh`

## Sample

Blink

```dart


// Example from https://github.com/jgautier/firmata/blob/master/examples/blink.js

import 'package:firmata/firmata.dart';
import 'dart:async';

final ledPin = 13;

main() {
  print('blink start ...');
  final board = new Board('/dev/cu.usbmodem1421');
  board.open().then((_) {

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    var ledOn = true;
    board.pinMode(ledPin, Modes.OUTPUT);

    new Timer.periodic(new Duration(milliseconds: 500), (_) {
      if (ledOn) {
        print("+");
        board.digitalWrite(ledPin, Board.HIGH);
      } else {
        print("-");
        board.digitalWrite(ledPin, Board.LOW);
      }
      ledOn = !ledOn;
    });

  }).catchError((error) => print("Cannot connect $error"));
}

```
