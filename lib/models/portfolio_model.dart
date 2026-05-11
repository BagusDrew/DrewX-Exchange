class PortfolioItem {
  final String coinId;
  final String symbol;
  final String name;
  final String image;
  final double amount;
  final double avgBuyPrice;
  double currentPrice;

  PortfolioItem({
    required this.coinId,
    required this.symbol,
    required this.name,
    required this.image,
    required this.amount,
    required this.avgBuyPrice,
    this.currentPrice = 0,
  });

  double get totalValue => amount * currentPrice;
  double get totalCost => amount * avgBuyPrice;
  double get profitLoss => totalValue - totalCost;
  double get profitLossPercentage =>
      totalCost > 0 ? ((totalValue - totalCost) / totalCost) * 100 : 0;
  bool get isProfit => profitLoss >= 0;

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'symbol': symbol,
      'name': name,
      'image': image,
      'amount': amount,
      'avgBuyPrice': avgBuyPrice,
    };
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      avgBuyPrice: (json['avgBuyPrice'] ?? 0).toDouble(),
    );
  }
}
