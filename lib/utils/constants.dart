import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00D4AA);
  static const Color accent = Color(0xFF6C63FF);
  static const Color background = Color(0xFF0D1117);
  static const Color cardBackground = Color(0xFF161B22);
  static const Color border = Color(0xFF30363D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color green = Color(0xFF00C853);
  static const Color red = Color(0xFFFF5252);
  static const Color orange = Color(0xFFFF9800);
}

class ApiConstants {
  // CoinGecko API (Free, no API key needed)
  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String marketEndpoint = '/coins/markets';
  static const String coinDetailEndpoint = '/coins';
  static const String chartEndpoint = '/coins/{id}/market_chart';

  // Binance WebSocket for real-time data
  static const String binanceWsBaseUrl = 'wss://stream.binance.com:9443/ws';
  static const String binanceApiBaseUrl = 'https://api.binance.com/api/v3';
}

class AppStrings {
  static const String appName = 'DrewX Exchange';
  static const String market = 'Market';
  static const String trading = 'Trading';
  static const String orderBook = 'Order Book';
  static const String portfolio = 'Portfolio';
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
}
