import 'dart:async';
import 'package:flutter/material.dart';
import '../models/coin_model.dart';
import '../services/coingecko_service.dart';

class MarketProvider extends ChangeNotifier {
  final CoinGeckoService _coinGeckoService = CoinGeckoService();

  List<CoinModel> _coins = [];
  List<CoinModel> _filteredCoins = [];
  bool _isLoading = false;
  String? _error;
  Timer? _refreshTimer;
  String _searchQuery = '';

  List<CoinModel> get coins => _searchQuery.isEmpty ? _coins : _filteredCoins;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  MarketProvider() {
    fetchMarketData();
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetchMarketData(showLoading: false),
    );
  }

  Future<void> fetchMarketData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _coins = await _coinGeckoService.getMarketCoins();
      _error = null;
      if (_searchQuery.isNotEmpty) {
        _filterCoins();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchCoins(String query) {
    _searchQuery = query;
    _filterCoins();
    notifyListeners();
  }

  void _filterCoins() {
    _filteredCoins = _coins
        .where((coin) =>
            coin.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            coin.symbol.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredCoins = [];
    notifyListeners();
  }

  Future<List<List<double>>> getCoinChart(String coinId, {int days = 7}) async {
    return await _coinGeckoService.getCoinChart(coinId: coinId, days: days);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _coinGeckoService.dispose();
    super.dispose();
  }
}
