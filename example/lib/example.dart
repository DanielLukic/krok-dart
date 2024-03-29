import 'package:cli_util/cli_util.dart';
import 'package:krok/krok.dart';
import 'package:path/path.dart';

main() async {
  final api = KrakenApi.fromFile(
      join(applicationConfigHome("clikraken"), "kraken.key"));

  try {
    await retrieveAssetPairs(api);
    await placeOrder(api);

    // see the existing commands in `lib/cli/command/` for more examples of
    // what else you can do...

    // if you don't do this, the program won't exit:
  } finally {
    api.close();
  }
}

Future<void> retrieveAssetPairs(KrakenApi api) async {
  // call the Kraken API:
  final pairs = await api.retrieve(KrakenRequest.assetPairs());

  // do something with the received data...

  // for this example, only printing the keys:
  print(pairs.keys);
}

Future<void> placeOrder(KrakenApi api) async {
  final resultWithTxid = await api.retrieve(KrakenRequest.addOrder(
    orderType: OrderType.takeProfitLimit,
    direction: OrderDirection.sell,
    volume: 8,
    pair: "CFGUSD",
    price: KrakenPrice.fromString("1.0", trailingStop: false),
    price2: KrakenPrice.fromString("-1%", trailingStop: false),

    // forOrderPlacement allows the "+<seconds>" variant evaluated on the
    // exchange:
    expireTime: KrakenTime.forOrderPlacement("+5"),

    // this in contrast would evaluate here in the client and may cause time
    // drift issues:
    //expireTime: KrakenTime.forOrderPlacement("5s"),
  ));
  print(resultWithTxid);
}
