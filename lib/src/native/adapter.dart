// Copyright (c) 2014-2015, Nicolas François
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
  SerialPort.availablePortNames.then((List<String> portNames) {
    final available = Platform.isMacOS ? portNames.where(isMacPortName).toList() :
    portNames;
    if (available.isEmpty) {
      completer.completeError("Impossible to detect Arduino board on usb.");
    } else {
      final adapter = new NativeSerialPortAdapter(available.first);
      final board = new BoardImpl(adapter);
      board.open().then((_) => completer.complete(board));
    }
  });
  return completer.future;
}



/// Find a arduino board from the port name.
Future<Board> fromPortName(String portName) {
  final completer = new Completer<Board>();
  final adapter = new NativeSerialPortAdapter(portName);
  final board = new BoardImpl(adapter);
  board.open().then((_) => completer.complete(board));
  return completer.future;
}

/// Native Implementation for SerialPortAdapter
class NativeSerialPortAdapter extends SerialPort implements SerialPortAdapter {

  NativeSerialPortAdapter(String portName) : super(portName, baudrate: 57600);

}
