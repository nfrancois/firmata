import 'package:unittest/unittest.dart';
import 'package:firmata/firmata.dart';
import 'dart:async';

void main() {

  group('Sysex Parser', (){

    final CONNEXION_BYTES = [249, 2, 3, 240, 121, 2, 3, 83, 0, 116, 0, 97, 0, 110, 0, 100, 0, 97, 0, 114, 0, 100, 0,
    70, 0, 105, 0, 114, 0, 109, 0, 97, 0, 116, 0, 97, 0, 46, 0, 105, 0, 110, 0, 111, 0, 247];

    // Tested object
    SysexParser parser;

    setUp((){
      parser = new SysexParser();
    });

    test('Report version', (){

        parser.onReportVersion.first.then(expectAsync((FirmataVersion version){
            expect(version.major, 2);
            expect(version.minor, 3);
            //expect(version.name, 'StandardFirmata.in);
        }));

        new Timer(new Duration(seconds: 1), () {
          fail('event not fired in time');
        });

        parser.append(CONNEXION_BYTES);

    });

    test('Digital message', (){

      parser.onDigitalMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 8);
        expect(pinState[0], 0);
        expect(pinState[1], 0);
        expect(pinState[2], 1);
        expect(pinState[3], 1);
        expect(pinState[4], 0);
        expect(pinState[5], 0);
        expect(pinState[6], 0);
        expect(pinState[7], 0);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      parser.append([144, 12, 0]);
    });

    test('Digital message other pins', (){

      parser.onDigitalMessage.first.then(expectAsync((Map<int, int> pinState){
        expect(pinState.length, 8);
        expect(pinState[8], 0);
        expect(pinState[9], 0);
        expect(pinState[10], 1);
        expect(pinState[11], 1);
        expect(pinState[12], 0);
        expect(pinState[13], 0);
        expect(pinState[14], 0);
        expect(pinState[15], 0);
      }));

      new Timer(new Duration(seconds: 1), () {
        fail('event not fired in time');
      });

      parser.append([144, 12, 1]);
    });    


  });
}
