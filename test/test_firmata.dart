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

        new Timer(new Duration(seconds: 3), () {
          fail('event not fired in time');
        });

        parser.append(CONNEXION_BYTES);

    });
  });
}
