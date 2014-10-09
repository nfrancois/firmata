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

## Samples

* Blink

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

* Play with buttons and leds.

```dart

import 'package:firmata/firmata.dart';
import 'dart:async';

final P1 = 2;
final P2 = 3;
final L1 = 4;
final L2 = 5;
final L3 = 6;
final L4 = 7;

main() {
  print('Diduino start ...');
  final board = new Board('/dev/tty.usbserial-A92TDN3B');
  board.open().then((_) {

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    board.pinMode(L1, Modes.OUTPUT);
    board.pinMode(L2, Modes.OUTPUT);
    board.pinMode(L3, Modes.OUTPUT);
    board.pinMode(L4, Modes.OUTPUT);
    board.pinMode(P1, Modes.INPUT);
    board.pinMode(P2, Modes.INPUT);

    board.onDigitalRead.listen((pinState){
      if(pinState.pin == P1){
        board.digitalWrite(L1, pinState.value);
        board.digitalWrite(L2, pinState.value);
      } else {
        board.digitalWrite(L3, pinState.value);
        board.digitalWrite(L4, pinState.value);
      }
    });

  }).catchError((error) => print("Cannot connect $error"));
}


```

* Analog Write

```dart

import 'package:firmata/firmata.dart';
import 'dart:async';
import 'dart:math';

// sample from https://github.com/shokai/node-arduino-firmata/blob/master/samples/analog_write.js

final L2 = 5;

main() {
  final board = new Board('/dev/tty.usbserial-A92TDN3B');
  board.open().then((_) {

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    board.pinMode(L2, Modes.OUTPUT);

    final alea = new Random();

    new Timer.periodic(new Duration(milliseconds: 500), (_) {
      final value = alea.nextInt(255);
      print("analog write pin : $value");
      board.analogWrite(L2, value);
    });


  }).catchError((error) => print("Cannot connect $error"));
}



```
