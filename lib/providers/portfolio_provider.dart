import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_model.dart';

class PortfolioProvider extends ChangeNotifier {
  List<PortfolioItem> _items = [];
  bool _isLoading = false;
  double _totalBalance = 10000.0;

  List<PortfolioItem> get items => _items;
  bool get isLoading => _isLoading;
  double get totalBalance => _totalBalance;
  double get totalPortfolioValue =>
      _items.fold(0, (sum, item) => sum + item.totalValue);
  double get totalProfitLoss =>
      _items.fold(0, (sum, item) => sum + item.profitLoss);

  PortfolioProvider() {
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final portfolioJson = prefs.getString('portfolio');
    final balance = prefs.getDouble('cash_balance');

    if (portfolioJson != null) {
      final List<dynamic> decoded = json.decode(portfolioJson);
      _items = decoded.map((item) => PortfolioItem.fromJson(item)).toList();
    }

    if (balance != null) {
      _totalBalance = balance;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _savePortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_items.map((item) => item.toJson()).toList());
    await prefs.setString('portfolio', encoded);
    await prefs.setDouble('cash_balance', _totalBalance);
  }

  Future<void> buyCoin({
    required String coinId,
    required String symbol,
    required String name,
    required String image,
    required double amount,
    required double price,
  }) async {
    final cost = amount * price;
    if (cost > _totalBalance) {
      throw Exception('Insufficient balance');
    }

    _totalBalance -= cost;

    // Check if already holding this coin
    final existingIndex = _items.indexWhere((item) => item.coinId == coinId);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      final newAmount = existing.amount + amount;
      final newAvgPrice =
          ((existing.amount * existing.avgBuyPrice) + (amount * price)) / newAmount;
      _items[existingIndex] = PortfolioItem(
        coinId: coinId,
        symbol: symbol,
        name: name,
        image: image,
        amount: newAmount,
        avgBuyPrice: newAvgPrice,
        currentPrice: price,
      );
    } else {
      _items.add(PortfolioItem(
        coinId: coinId,
        symbol: symbol,
        name: name,
        image: image,
        amount: amount,
        avgBuyPrice: price,
        currentPrice: price,
      ));
    }

    await _savePortfolio();
    notifyListeners();
  }

  Future<void> sellCoin({
    required String coinId,
    required double amount,
    required double price,
  }) async {
    final existingIndex = _items.indexWhere((item) => item.coinId == coinId);
    if (existingIndex < 0) {
      throw Exception('Coin not found in portfolio');
    }

    final existing = _items[existingIndex];
    if (amount > existing.amount) {
      throw Exception('Insufficient coin amount');
    }

    _totalBalance += amount * price;

    if (amount == existing.amount) {
      _items.removeAt(existingIndex);
    } else {
      _items[existingIndex] = PortfolioItem(
        coinId: existing.coinId,
        symbol: existing.symbol,
        name: existing.name,
        image: existing.image,
        amount: existing.amount - amount,
        avgBuyPrice: existing.avgBuyPrice,
        currentPrice: price,
      );
    }

    await _savePortfolio();
    notifyListeners();
  }

  void updatePrices(Map<String, double> prices) {
    for (int i = 0; i < _items.length; i++) {
      if (prices.containsKey(_items[i].coinId)) {
        _items[i].currentPrice = prices[_items[i].coinId]!;
      }
    }
    notifyListeners();
  }
}
