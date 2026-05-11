import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin_model.dart';
import '../utils/constants.dart';

class CoinGeckoService {
  final http.Client _client = http.Client();

  /// Fetch top coins by market cap
  Future<List<CoinModel>> getMarketCoins({
    String vsCurrency = 'usd',
    int perPage = 50,
    int page = 1,
    bool sparkline = true,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.coinGeckoBaseUrl}${ApiConstants.marketEndpoint}'
        '?vs_currency=$vsCurrency'
        '&order=market_cap_desc'
        '&per_page=$perPage'
        '&page=$page'
        '&sparkline=$sparkline'
        '&price_change_percentage=24h',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((coin) => CoinModel.fromJson(coin)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load market data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch price chart data for a specific coin
  Future<List<List<double>>> getCoinChart({
    required String coinId,
    String vsCurrency = 'usd',
    int days = 7,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.coinGeckoBaseUrl}/coins/$coinId/market_chart'
        '?vs_currency=$vsCurrency'
        '&days=$days',
      );

      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List;
        return prices
            .map((item) => [
                  (item[0] as num).toDouble(),
                  (item[1] as num).toDouble(),
                ])
            .toList();
      } else {
        throw Exception('Failed to load chart data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Search for coins
  Future<List<CoinModel>> searchCoins(String query) async {
    try {
      final allCoins = await getMarketCoins(perPage: 100);
      return allCoins
          .where((coin) =>
              coin.name.toLowerCase().contains(query.toLowerCase()) ||
              coin.symbol.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
