// Example from https://github.com/jgautier/firmata/blob/master/examples/blink.js

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

  }).catchError((error) => print("Cannot connect: $error"));
}
