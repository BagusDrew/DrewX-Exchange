import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/orderbook_model.dart';
import '../utils/constants.dart';

class BinanceService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _streamController;
  bool _isConnected = false;

  /// Connect to Binance WebSocket for real-time ticker
  Stream<Map<String, dynamic>> connectToTicker(String symbol) {
    _streamController = StreamController<Map<String, dynamic>>.broadcast();
    final wsUrl = '${ApiConstants.binanceWsBaseUrl}/${symbol.toLowerCase()}@ticker';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          final decoded = json.decode(data);
          _streamController?.add(decoded);
        },
        onError: (error) {
          _streamController?.addError(error);
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _streamController?.addError(e);
    }

    return _streamController!.stream;
  }

  /// Connect to Binance WebSocket for real-time kline/candlestick
  Stream<Map<String, dynamic>> connectToKline(String symbol, String interval) {
    _streamController = StreamController<Map<String, dynamic>>.broadcast();
    final wsUrl =
        '${ApiConstants.binanceWsBaseUrl}/${symbol.toLowerCase()}@kline_$interval';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          final decoded = json.decode(data);
          _streamController?.add(decoded);
        },
        onError: (error) {
          _streamController?.addError(error);
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (e) {
      _streamController?.addError(e);
    }

    return _streamController!.stream;
  }

  /// Fetch Order Book from Binance REST API
  Future<OrderBookModel> getOrderBook(String symbol, {int limit = 20}) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.binanceApiBaseUrl}/depth?symbol=${symbol.toUpperCase()}&limit=$limit',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderBookModel.fromJson(data);
      } else {
        throw Exception('Failed to load order book: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch Kline/Candlestick data from Binance REST API
  Future<List<List<dynamic>>> getKlines(
    String symbol, {
    String interval = '1h',
    int limit = 100,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.binanceApiBaseUrl}/klines'
        '?symbol=${symbol.toUpperCase()}'
        '&interval=$interval'
        '&limit=$limit',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return List<List<dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load klines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  bool get isConnected => _isConnected;

  void disconnect() {
    _channel?.sink.close();
    _streamController?.close();
    _isConnected = false;
  }

  void dispose() {
    disconnect();
  }
}
