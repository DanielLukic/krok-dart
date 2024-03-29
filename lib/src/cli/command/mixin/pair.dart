part of '../../cli.dart';

mixin Pair {
  late String pair;

  initPairOption(ArgParser argParser) {
    argParser.addOption(
      "pair",
      abbr: "p",
      help: "The pair to get data for.",
      mandatory: true,
      valueHelp: "XBTUSD",
      callback: (it) => pair = it!,
    );
  }
}

mixin Pairs {
  List<String>? pairs;

  initPairsOption(ArgParser argParser) {
    argParser.addMultiOption(
      "pair",
      abbr: "p",
      help: "One ore more pairs to get data for. May query all or no pairs if empty.",
      valueHelp: "XBTUSD,ETHUSD",
      callback: (it) => pairs = it.isNullOrEmpty ? null : it,
    );
  }
}
