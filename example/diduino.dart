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

    board.onPinStateChange.listen((pinState){
      if(pinState.pin == P1){
        board.digitalWrite(L1, pinState.state);
        board.digitalWrite(L2, pinState.state);
      } else {
        board.digitalWrite(L3, pinState.state);
        board.digitalWrite(L4, pinState.state);
      }
    });

  }).catchError((error) => print("Cannot connect $error"));
}
