import 'package:grinder/grinder.dart';

main(args) => grind(args);

@Task('Run tests')
test() =>  new TestRunner().test(files : ['test/all.dart']);

@Task('Calculate test coverage')
coverage() => new PubApp.local('dart_coveralls').run(['report', '--exclude-test-files', 'test/all.dart',
                                                      r'--token $FIRMATA_COVERALLS_TOKEN']);

@Task("Analyze lib source code")
analyse() => Analyzer.analyzeFiles(["lib/firmata.dart", "lib/firmata_chrome.dart"], fatalWarnings: true);

@Task('Generate dartdoc')
doc() => new PubApp.local('dartdoc');

@DefaultTask('Combine tasks for continous integration')
@Depends('test', 'analyse')
make(){
  // Nothing to declare here
}

