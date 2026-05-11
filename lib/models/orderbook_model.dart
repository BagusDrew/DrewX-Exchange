class OrderBookEntry {
  final double price;
  final double quantity;

  OrderBookEntry({
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  factory OrderBookEntry.fromList(List<dynamic> data) {
    return OrderBookEntry(
      price: double.parse(data[0].toString()),
      quantity: double.parse(data[1].toString()),
    );
  }
}

class OrderBookModel {
  final List<OrderBookEntry> bids;
  final List<OrderBookEntry> asks;
  final int lastUpdateId;

  OrderBookModel({
    required this.bids,
    required this.asks,
    required this.lastUpdateId,
  });

  factory OrderBookModel.fromJson(Map<String, dynamic> json) {
    return OrderBookModel(
      bids: (json['bids'] as List?)
              ?.map((e) => OrderBookEntry.fromList(e))
              .toList() ??
          [],
      asks: (json['asks'] as List?)
              ?.map((e) => OrderBookEntry.fromList(e))
              .toList() ??
          [],
      lastUpdateId: json['lastUpdateId'] ?? 0,
    );
  }
}
