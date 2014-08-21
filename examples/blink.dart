// Example from https://github.com/jgautier/firmata/blob/master/examples/blink.js

import 'package:firmata/firmata.dart';
import 'dart:async';

final ledPin = 13;

main(){
	print('blink start ...');
	final board = new Board('/dev/tty.usbmodem1421');
	board.open().then((_) {
		print("connected");
		//print('Firmware: ${board.firmware.name}-${board.firmware.version.major}.${board.firmware.version.minor}');
		var ledOn = true;
		board.pinMode(ledPin, Modes.OUTPUT);
		new Timer(new Duration(milliseconds: 500), () {
			if(ledOn){
				print("+");
				board.digitalWrite(ledPin, Board.HIGH);
			} else {
				print("+");
				board.digitalWrite(ledPin, Board.LOW);
			}
			ledOn = !ledOn;
		});
	})
	.catchError((error) => print("Cannot connect $error"));
}
