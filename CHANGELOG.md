## 0.0.5

- fix `mapValues` to be generic
- use minilog 0.0.2

## 0.0.4

- export extensions.dart for toKrakenDateTime
- fix stop-loss-limit order type
- exit immediately after command completion

## 0.0.3

- use minilog package
- add log file option

## 0.0.2

Fix pub.dev related issues:

- move example into example/lib
- fix github url
- add some more public api documentation
- provide single package:krok/api.dart for easy import

## 0.0.1

Initial release. Basic functionality is implemented:

- basic authentication with Kraken API keys
- retrieve basic market data (assets, asset pairs and ticker)
- retrieve account balances and trade volumes
- retrieve open and closes orders
- market and limit order placement
- cancel and edit open orders
- order dsl using Kraken API "syntax"

Noteworthy missing functionality:

- no userref support (TODO)
- order batch for example, and everything NFT (WON'T DO)
