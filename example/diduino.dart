import 'package:firmata/firmata.dart';
import 'dart:async';

final P1 = 2;
final P2 = 3;
final L1 = 4;
final L2 = 5;
final L3 = 6;
final L4 = 7;

// Sample for this board : http://www.didel.com/DiduinoPub.pdf

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
