// Copyright (c) 2014, Nicolas François
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of firmata_native;

/// Try to detect a arduino board
Future<Board> detect() {
  final completer = new Completer<Board>();
  SerialPort.avaiblePortNames.then((List<String> portNames) {
    final avaibles = Platform.isMacOS ? portNames.where(_isMacPortName).toList() :
    portNames;
    if (avaibles.isEmpty) {
      completer.completeError("Impossible to detect Arduino board on usb.");
    } else {
      final adapter = new NativeSerialPortAdapter(avaibles.first);
      final board = new Board(adapter);
      board.open().then((_) => completer.complete(board));
    }
  });
  return completer.future;
}

bool _isMacPortName(String name) => name.startsWith("/dev/tty") && name.contains("usb");

/// Find a arduino board from the port name.
Future<Board> fromPortName(String portName) {
  final completer = new Completer<Board>();
  final adapter = new NativeSerialPortAdapter(portName);
  final board = new Board(adapter);
  board.open().then((_) => completer.complete(board));
  return completer.future;
}

/// Native Implementation for SerialPortAdapter
class NativeSerialPortAdapter extends SerialPort implements SerialPortAdapter {

  NativeSerialPortAdapter(String portName) : super(portName, baudrate: 57600);

}
