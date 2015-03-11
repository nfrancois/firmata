#Firmata

[![pub package](http://img.shields.io/pub/v/firmata.svg)](https://pub.dartlang.org/packages/firmata)
[![Build Status](https://drone.io/github.com/nfrancois/Firmata/status.png)](https://drone.io/github.com/nfrancois/Firmata/latest)
[![Coverage Status](https://img.shields.io/coveralls/nfrancois/firmata.svg)](https://coveralls.io/r/nfrancois/firmata)

Dart Implementation of [Firmata](https://github.com/firmata/arduino)

Inspired by:
* [js-firmata](https://github.com/jgautier/firmata)
* [node-arduino-firmata](https://github.com/shokai/node-arduino-firmata)

Currently working:
* Connexion to Arduino
* Digital read/write
* Analog read/write
* Servo

TODO:
* I2C
* OneWire

Firmata can runs as Chrome App.


## Install

Firmata needs `serial_port` lib. To install it, easily, just run `bin/install.sh`

## Samples

* Blink

```dart


import 'package:firmata/firmata.dart';
import 'dart:async';

final ledPin = 13;

main() {
  print('blink start ...');
  Board.detect().then((board) {

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
  Board.detect().then((board) {

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
  Board.detect().then((board) {

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

* Servomotor

```dart

import 'package:firmata/firmata.dart';
import 'dart:async';

void main() {
  Board.detect().then((board) {

    final pin = 2;

    print("connected");
    print('Firmware: ${board.firmware.name}-${board.firmware.major}.${board.firmware.minor}');

    int angle = 0;

    new Timer.periodic(new Duration(milliseconds: 100), (_) {
      print(angle);
      board.servoWrite(pin, angle);
      angle++;
      angle%=180;
    });

  }).catchError((error) => print("Cannot connect: $error"));
}

```

* Chrome app

```dart
import 'dart:html';
import 'package:firmata/firmata_chrome.dart';


main(){
  ButtonElement led1Button = querySelector("#led1");
  final led1Pin = 4;

  detect().then((board){
    print("Connected");

    bool led1On = false;
    board.pinMode(led1Pin, PinModes.OUTPUT);

    led1Button.onClick.listen((_){
      led1On = !led1On;
      led1Button.text = led1On ? "ON" : "OFF";
      board.digitalWrite(led1Pin, led1On ? PinValue.HIGH : PinValue.LOW);
    }).onError(print);

  });

}
```
