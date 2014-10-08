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
