Command-line Kraken Crypto API wrapper written in Dart. Inspired by the Python `clikraken` project.

**This is my first Dart project, used to learn the language. Keep that in mind! :-D**

# Links / Credit

- https://github.com/zertrin/clikraken - primary inspiration
- https://github.com/veox/python3-krakenex - used by clikraken
- https://github.com/Dimibe/kraken_api - additional inspiration

# Usage

For now, the clikraken key file is used. This has to be available at `~/.config/clikraken/kraken.key` and contain the
public and private Kraken API keys in two lines. You can use the `-k` (`--keyfile`) option to specify a different
location.

Use `dart run bin/krok.dart -h` to see the available command line options. Besides `-k` for the keyfile path and `-l` to
change the log level, there is a semi-working `-c` option to auto-cache results from the public Kraken API endpoints.
Auto-caching is always on for now. But applies only to public, parameterless API calls. This probably needs to be
revisited.

Besides these options, everything else is driven by 'commands'. Please use `-h` after a command to get more information.

Some basic usage examples implemented so far:

## Asset Pairs

```shell
dart run bin/krok.dart ap -c cost_decimals,ordermin,status | grep USD
| pair      | cost_decimals | ordermin | status      |
------------------------------------------------------
| 1INCHEUR  | 5             | 11       | online      |
| 1INCHUSD  | 5             | 11       | online      |
| AAVEETH   | 10            | 0.05     | online      |
| AAVEEUR   | 5             | 0.05     | online      |
| AAVEGBP   | 5             | 0.05     | online      |
| AAVEUSD   | 5             | 0.05     | online      |
...
```

## Assets

```shell
dart run bin/krok.dart a
| pair      | aclass   | altname   | decimals | display_decimals | status  | collateral_value |
-----------------------------------------------------------------------------------------------
| 1INCH     | currency | 1INCH     | 10       | 5                | enabled | null             |
| AAVE      | currency | AAVE      | 10       | 5                | enabled | null             |
| ACA       | currency | ACA       | 10       | 5                | enabled | null             |
| ACH       | currency | ACH       | 10       | 5                | enabled | null             |
| ADA       | currency | ADA       | 8        | 6                | enabled | 0.9              |
...
```

## Ticker

```shell
dart run bin/krok.dart t | head
| pair      | a              | b              | c              | v                   | p              | t     | l              | h              | o              |
------------------------------------------------------------------------------------------------------------------------------------------------------------------
| 1INCHEUR  | 0.52700        | 0.52600        | 0.52900        | 73.85599325         | 0.52860        | 4     | 0.52600        | 0.52900        | 0.52600        |
| 1INCHUSD  | 0.57000        | 0.56900        | 0.57200        | 22902.59597987      | 0.56893        | 28    | 0.56600        | 0.57300        | 0.56600        |
| AAVEETH   | 0.03620        | 0.03610        | 0.03630        | 13.84197784         | 0.03655        | 21    | 0.03610        | 0.03670        | 0.03610        |
| AAVEEUR   | 115.90000      | 115.83000      | 116.00000      | 67.95210235         | 116.29878      | 53    | 115.00000      | 117.42000      | 115.33000      |
| AAVEGBP   | 99.46000       | 99.38000       | 99.94000       | 3.44096121          | 99.99908       | 12    | 98.75000       | 100.70000      | 98.75000       |
| AAVEUSD   | 125.40000      | 125.39000      | 125.46000      | 1752.80161737       | 125.40680      | 649   | 123.97000      | 127.14000      | 124.85000      |
...
```

Note: By default only the first values of columns containing 'lists' are shown. The `--full` option will show
everything.

## Open Orders

```shell
dart run bin/krok.dart oo -c descr -d order
| txid                | _order                                                           |
------------------------------------------------------------------------------------------
| OZOSD7-7YEGF-ZDOVUX | sell 1892.64687153 TVKUSD @ take profit 0.41646 -> limit 0.40177 |
...
```

Note: `-c descr` will hide all columns except the 'descr' column. But `-d order` transforms the 'descr' column by
removing all parts except the order.

## More

At the time of this writing, these commands are available:

```
  assetpairs        Retrieve asset pairs. Alias: [ap]
  assets            Retrieve asset information. Alias: [a]
  balance           Retrieve account balance data. Alias: [b]
  cancelallorders   Cancel all orders. Alias: [ca, cao, cancelall]
  cancelorder       Cancel order via txid. Alias: [c, cancel]
  closedorders      Retrieve closed orders. Alias: [co, closed]
  limitorder        Add basic limit order. Alias: [lo, limit]
  marketorder       Add basic market order. Alias: [mo, market]
  ohlc              Retrieve ohlc data. Alias: [o]
  openorders        Retrieve open orders. Alias: [oo, open]
  queryorders       Retrieve order data via txid. Alias: [q, qo, query]
  spread            Retrieve spread data. Alias: [sp]
  status            Retrieve Kraken system status. Alias: [s]
  ticker            Retrieve ticker data. Alias: [t]
  tradebalance      Retrieve trade balance data. Alias: [tb, tbal]
  tradevolume       Retrieve trade volume data. Alias: [tv, tvol]
```

Run "krok help <command>" for more information about a command.

# DSL

Because adding the order and cancel commands shown above felt weird, I decided to provide three "DSL style" commands:

`buy`, `sell` and `cancel`.

These allow "clear text" commands like these:

```
cancel SOME-ORDER-TXID
cancel SOME-ORDER-TXID,MORE-ORDER-TXIDS...
cancel all

krok sell "8.0 CFGUSD @ take profit 1.0 -> limit 1.0"
krok buy "8.0 CFGUSD @ take profit 1.0 -> limit 1.0" --expire 10s
```

This feels like the right approach. I'll probably remove the "options-based" commands at some point.

# The name?

I have no idea.

# Does it work?

Yes, I guess. But it is probably aligned with my use cases too much to be generally useful.

# Why?

As I said, to learn Dart.

My actual goal is to get a little bit into Flutter to understand if this will work for me.

I've been an Android developer for a very long time. And switching from Kotlin to Dart is really hard. Not that Dart is
too difficult to learn. But coming from Kotlin, you realize how awkward and overly complex Dart feels. But I'm new to
it. Maybe some 'Aha!' moments await. We'll see.

Anyway, doesn't hurt to learn something new now and then, does it? And there is the Flutter Flame game engine I want to
take a look at. So there's that...

This being said, I probably won't invest too much time into this project.

# Gotchas

For now this probably only works on Linux and maybe macOS because of the secret/key handling. This is fine for me.
Maybe I'll extend support for reading or passing secret/key at some point.

# Some To Dos

- [ ] TODO add key file option to pass keys instead of reading from file

- [ ] TODO how to handle price/volume decimals?
- [ ] TODO use a wrapper around the asset info to create prices?
- [ ] TODO what about volume?

- [ ] TODO apply column selection after column expansion
- [ ] TODO auto-select descr if mode != hide and columns selected

- [ ] TODO batch order/cancel
- [ ] TODO add userref support
