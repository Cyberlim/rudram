import 'dart:async';
import 'package:flutter/material.dart';
import '../models/wallet_transaction_model.dart';
import '../services/firestore_service.dart';

class WalletProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  String? _uid;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  double _walletBalance = 0.0;
  double _cashbackBalance = 0.0;
  int _rewardPoints = 0;
  int _activeGiftVouchers = 0;
  
  double get walletBalance => _walletBalance;
  double get cashbackBalance => _cashbackBalance;
  int get rewardPoints => _rewardPoints;
  int get activeGiftVouchers => _activeGiftVouchers;

  List<WalletTransaction> _transactions = [];
  List<WalletTransaction> get transactions => _transactions;

  StreamSubscription? _balancesSubscription;
  StreamSubscription? _transactionsSubscription;

  void updateUid(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    
    _balancesSubscription?.cancel();
    _transactionsSubscription?.cancel();
    
    if (uid == null) {
      _resetData();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _balancesSubscription = _firestoreService.streamWalletBalances(uid).listen((data) {
      _walletBalance = data['walletBalance'] ?? 0.0;
      _cashbackBalance = data['cashbackBalance'] ?? 0.0;
      _rewardPoints = data['rewardPoints'] ?? 0;
      _activeGiftVouchers = data['activeGiftVouchers'] ?? 0;
      _isLoading = false;
      notifyListeners();
    });

    _transactionsSubscription = _firestoreService.streamWalletTransactions(uid).listen((txs) {
      _transactions = txs;
      notifyListeners();
    });
  }

  void _resetData() {
    _isLoading = false;
    _walletBalance = 0.0;
    _cashbackBalance = 0.0;
    _rewardPoints = 0;
    _activeGiftVouchers = 0;
    _transactions = [];
    notifyListeners();
  }

  Future<void> seedDummyData() async {
    if (_uid != null) {
      await _firestoreService.seedDummyWalletData(_uid!);
    }
  }

  Future<bool> addMoney(double amount) async {
    if (_uid == null || amount <= 0) return false;
    
    try {
      await _firestoreService.processWalletTransaction(
        uid: _uid!,
        amount: amount,
        type: TransactionType.credit,
        category: TransactionCategory.topup,
        title: 'Wallet Top-up',
      );
      return true;
    } catch (e) {
      debugPrint("Error adding money: $e");
      return false;
    }
  }

  Future<bool> sendToBank(double amount) async {
    if (_uid == null || amount <= 0) return false;
    if (amount > _walletBalance) return false;
    
    try {
      await _firestoreService.processWalletTransaction(
        uid: _uid!,
        amount: amount,
        type: TransactionType.debit,
        category: TransactionCategory.refund, // Using refund as a generic withdrawal type for now
        title: 'Transfer to Bank',
      );
      return true;
    } catch (e) {
      debugPrint("Error sending to bank: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _balancesSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
