import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/coins_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/coin_balance.dart';
import 'package:komodo_dex/model/get_send_raw_transaction.dart';
import 'package:komodo_dex/model/get_withdraw.dart';
import 'package:komodo_dex/model/send_raw_transaction_response.dart';
import 'package:komodo_dex/model/withdraw_response.dart';
import 'package:komodo_dex/services/mm.dart';
import 'package:komodo_dex/services/mm_service.dart';
import 'package:komodo_dex/utils/log.dart';
import 'package:komodo_dex/utils/utils.dart';

class RewardsProvider extends ChangeNotifier {
  RewardsProvider() {
    update();
  }

  final AppLocalizations _localizations = AppLocalizations();
  List<RewardsItem> _rewards;
  double _total = 0.0;

  bool claimInProgress = false;
  bool updateInProgress = false;
  String errorMessage;
  String successMessage;

  List<RewardsItem> get rewards => _rewards;
  double get total => _total;

  bool get needClaim {
    if (_rewards == null) return false;

    for (RewardsItem item in _rewards) {
      if (item.stopAt == null) continue;

      final Duration timeLeft = Duration(
        milliseconds:
            item.stopAt * 1000 - DateTime.now().millisecondsSinceEpoch,
      );
      if (timeLeft.inDays < 2 && (item.reward ?? 0) > 0) {
        return true;
      }
    }

    return false;
  }

  Future<void> update() async {
    await _updateInfo();
    await _updateTotal();
  }

  Future<void> _updateTotal() async {
    dynamic res;
    try {
      res = await ApiProvider().postWithdraw(
          MMService().client,
          GetWithdraw(
            userpass: MMService().userpass,
            coin: 'KMD',
            to: _kmdBalance().balance.address,
            max: true,
          ));
    } catch (e) {
      Log('rewards_provider', '_updateTotal] $e');
    }

    if (res is WithdrawResponse) {
      _total = double.parse(res.myBalanceChange);
    } else {
      _total = 0.0;
    }

    notifyListeners();
  }

  Future<void> _updateInfo() async {
    if (updateInProgress) return;
    updateInProgress = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    List<RewardsItem> list;
    try {
      list = await MM.getRewardsInfo();
    } catch (e) {
      updateInProgress = false;
      Log('rewards_provider', '_updateInfo] $e');
      notifyListeners();
      return;
    }

    _rewards = list;
    updateInProgress = false;
    notifyListeners();
  }

  Future<void> receive() async {
    if (claimInProgress) return;
    claimInProgress = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    dynamic res;
    try {
      res = await ApiProvider().postWithdraw(
          MMService().client,
          GetWithdraw(
            userpass: MMService().userpass,
            coin: 'KMD',
            to: _kmdBalance().balance.address,
            max: true,
          ));
    } catch (e) {
      Log('rewards_provider', 'receive/postWithdraw] $e');
      _setError(e);
    }

    if (!(res is WithdrawResponse)) {
      _setError();
      claimInProgress = false;
      return;
    }

    dynamic tx;
    try {
      tx = await ApiProvider().postRawTransaction(MMService().client,
          GetSendRawTransaction(coin: 'KMD', txHex: res.txHex));
    } catch (e) {
      Log('rewards_provider', 'receive/postRawTransaction] $e');
      _setError(e);
    }

    if (!(tx is SendRawTransactionResponse) || tx.txHash.isEmpty) {
      _setError();
      claimInProgress = false;
      return;
    }

    await Future<dynamic>.delayed(const Duration(seconds: 2));
    await update();
    successMessage =
        _localizations.rewardsSuccess(formatPrice(res.myBalanceChange));

    claimInProgress = false;
    notifyListeners();
  }

  void _setError([String e]) {
    errorMessage = _localizations.rewardsError;
    notifyListeners();
  }

  CoinBalance _kmdBalance() {
    return coinsBloc.coinBalance.firstWhere(
        (balance) => balance.coin.abbr == 'KMD',
        orElse: () => null);
  }
}

class RewardsItem {
  RewardsItem({
    this.index,
    this.amount,
    this.reward,
    this.startAt,
    this.stopAt,
    this.error,
  });

  factory RewardsItem.fromJson(Map<String, dynamic> json) {
    final AppLocalizations _localizations = AppLocalizations();

    final double reward = json['accrued_rewards']['Accrued'] != null
        ? double.parse(json['accrued_rewards']['Accrued'])
        : null;

    final String error = json['accrued_rewards']['NotAccruedReason'];
    String errorMessage;
    String errorMessageLong;
    switch (error) {
      case 'UtxoAmountLessThanTen':
        errorMessage = _localizations.rewardsLowAmountShort;
        errorMessageLong = _localizations.rewardsLowAmountLong;
        break;
      case 'TransactionInMempool':
        errorMessage = _localizations.rewardsInProgressShort;
        errorMessageLong = _localizations.rewardsInProgressLong;
        break;
      case 'OneHourNotPassedYet':
        errorMessage = _localizations.rewardsOneHourShort;
        errorMessageLong = _localizations.rewardsOneHourLong;
        break;
      default:
        errorMessage = '?';
        errorMessageLong = error;
    }

    return RewardsItem(
      index: json['output_index'],
      amount: double.parse(json['amount']),
      reward: reward,
      startAt: json['accrue_start_at'],
      stopAt: json['accrue_stop_at'],
      error: {'short': errorMessage, 'long': errorMessageLong},
    );
  }

  int index;
  double amount;
  double reward;
  int startAt;
  int stopAt;
  Map<String, String> error;
}
