import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orderbook_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class OrderBookScreen extends StatefulWidget {
  const OrderBookScreen({super.key});

  @override
  State<OrderBookScreen> createState() => _OrderBookScreenState();
}

class _OrderBookScreenState extends State<OrderBookScreen> {
  final List<String> _symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'XRPUSDT'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderBookProvider>(context, listen: false)
          .startAutoRefresh('BTCUSDT');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Book'),
      ),
      body: Column(
        children: [
          // Symbol selector
          _buildSymbolSelector(),
          const SizedBox(height: 8),
          // Column headers
          _buildHeaders(),
          const Divider(color: AppColors.border, height: 1),
          // Order book data
          Expanded(
            child: Consumer<OrderBookProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.orderBook == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (provider.error != null && provider.orderBook == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchOrderBook(provider.currentSymbol),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final orderBook = provider.orderBook;
                if (orderBook == null) return const SizedBox.shrink();

                return Row(
                  children: [
                    // Bids (Buy orders - green)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Text(
                              'BIDS',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: orderBook.bids.length,
                              itemBuilder: (context, index) {
                                final bid = orderBook.bids[index];
                                final maxQty = orderBook.bids
                                    .map((e) => e.quantity)
                                    .reduce((a, b) => a > b ? a : b);
                                final ratio = bid.quantity / maxQty;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 1),
                                  child: Stack(
                                    children: [
                                      FractionallySizedBox(
                                        widthFactor: ratio,
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 28,
                                          color: AppColors.green.withAlpha(25),
                                        ),
                                      ),
                                      Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatCurrency(bid.price),
                                              style: const TextStyle(
                                                color: AppColors.green,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              formatQuantity(bid.quantity),
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, color: AppColors.border),
                    // Asks (Sell orders - red)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: const Text(
                              'ASKS',
                              style: TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: orderBook.asks.length,
                              itemBuilder: (context, index) {
                                final ask = orderBook.asks[index];
                                final maxQty = orderBook.asks
                                    .map((e) => e.quantity)
                                    .reduce((a, b) => a > b ? a : b);
                                final ratio = ask.quantity / maxQty;

                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 1),
                                  child: Stack(
                                    children: [
                                      FractionallySizedBox(
                                        widthFactor: ratio,
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          height: 28,
                                          color: AppColors.red.withAlpha(25),
                                        ),
                                      ),
                                      Container(
                                        height: 28,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatCurrency(ask.price),
                                              style: const TextStyle(
                                                color: AppColors.red,
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              formatQuantity(ask.quantity),
                                              style: const TextStyle(
                                                color: AppColors.textPrimary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolSelector() {
    return Consumer<OrderBookProvider>(
      builder: (context, provider, _) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _symbols.length,
            itemBuilder: (context, index) {
              final symbol = _symbols[index];
              final isSelected = symbol == provider.currentSymbol;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: GestureDetector(
                  onTap: () => provider.changeSymbol(symbol),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withAlpha(51)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      symbol.replaceAll('USDT', '/USDT'),
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeaders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                Text('Qty', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                Text('Qty', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
