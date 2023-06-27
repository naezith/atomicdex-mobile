import 'package:hive/hive.dart';

part 'wallet_address.g.dart';

@HiveType(typeId: 0)
class WalletAddress {
  @HiveField(0)
  String walletId;

  @HiveField(1)
  String address;

  @HiveField(2)
  String ticker;

  @HiveField(3)
  double availableBalance;

  @HiveField(4)
  String accountId;

  WalletAddress({
    this.walletId,
    this.address,
    this.ticker,
    this.availableBalance,
    this.accountId,
  });
}
