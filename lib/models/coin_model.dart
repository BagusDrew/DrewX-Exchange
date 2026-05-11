class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double priceChangePercentage24h;
  final double high24h;
  final double low24h;
  final List<double>? sparklineIn7d;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.priceChangePercentage24h,
    required this.high24h,
    required this.low24h,
    this.sparklineIn7d,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] ?? 0).toDouble(),
      marketCap: (json['market_cap'] ?? 0).toDouble(),
      marketCapRank: json['market_cap_rank'] ?? 0,
      totalVolume: (json['total_volume'] ?? 0).toDouble(),
      priceChangePercentage24h: (json['price_change_percentage_24h'] ?? 0).toDouble(),
      high24h: (json['high_24h'] ?? 0).toDouble(),
      low24h: (json['low_24h'] ?? 0).toDouble(),
      sparklineIn7d: json['sparkline_in_7d'] != null
          ? List<double>.from(
              (json['sparkline_in_7d']['price'] as List).map((e) => (e ?? 0).toDouble()))
          : null,
    );
  }

  bool get isPriceUp => priceChangePercentage24h >= 0;
}
