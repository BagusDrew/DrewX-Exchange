import 'dart:async';
import 'package:flutter/material.dart';
import '../models/orderbook_model.dart';
import '../services/binance_service.dart';

class OrderBookProvider extends ChangeNotifier {
  final BinanceService _binanceService = BinanceService();

  OrderBookModel? _orderBook;
  bool _isLoading = false;
  String? _error;
  String _currentSymbol = 'BTCUSDT';
  Timer? _refreshTimer;

  OrderBookModel? get orderBook => _orderBook;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentSymbol => _currentSymbol;

  Future<void> fetchOrderBook(String symbol) async {
    _currentSymbol = symbol;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orderBook = await _binanceService.getOrderBook(symbol);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void startAutoRefresh(String symbol) {
    _refreshTimer?.cancel();
    fetchOrderBook(symbol);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => fetchOrderBook(symbol),
    );
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
  }

  void changeSymbol(String symbol) {
    _currentSymbol = symbol;
    stopAutoRefresh();
    startAutoRefresh(symbol);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _binanceService.dispose();
    super.dispose();
  }
}
