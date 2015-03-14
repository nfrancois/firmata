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

part of firmata_chrome;

/// Try to detect a arduino board
Future<Board> detect() {
  final completer = new Completer<Board>();
  serial.getDevices().then((List<DeviceInfo> ports) {
    runtime.getPlatformInfo().then((PlatformInfo info){
      final portNames = ports.map((port) => port.path);
      final available = info.os == "mac" ? portNames.where(_isMacPortName).toList() : portNames;
      if (available.isEmpty) {
        completer.completeError("Impossible to detect Arduino board on usb.");
      } else {
        final adapter = new ChromeSerialPortAdapter(available.first);
        final board = new BoardImpl(adapter);
        board.open().then((_) => completer.complete(board));
      }
    });
  });
  return completer.future;
}

bool _isMacPortName(String name) => name.startsWith("/dev/tty") && name.contains("usb");

/// Find a arduino board from the port name.
Future<Board> fromPortName(String portName) {
  final completer = new Completer<Board>();
  final adapter = new ChromeSerialPortAdapter(portName);
  final board = new BoardImpl(adapter);
  board.open().then((_) => completer.complete(board));
  return completer.future;
}

/// Chrome implementation for SerialPortAdapter
class ChromeSerialPortAdapter implements SerialPortAdapter {

  String _portName;
  int _id;

  ChromeSerialPortAdapter(String portName){
    this._portName = portName;
  }

  Future open() {
    final completer = new Completer();
    serial.connect(_portName, new ConnectionOptions(bitrate: 57600)).then((ConnectionInfo conn){
      _id = conn.connectionId;
      completer.complete();
    });
    return completer.future;
  }

  Future close() => serial.disconnect(_id);

  Future write(List<int> bytes) => serial.send(_id, new ArrayBuffer.fromBytes(bytes));

  Stream<List<int>> get onRead =>
    serial.onReceive.where((info) => info.connectionId == _id).map((info) => info.data.getBytes());

}
