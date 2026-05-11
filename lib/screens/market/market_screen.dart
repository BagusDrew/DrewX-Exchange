import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/coin_model.dart';
import '../../providers/market_provider.dart';
import '../../utils/constants.dart';
import '../trading/trading_screen.dart';
import '../../widgets/coin_list_tile.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MarketProvider>(context, listen: false).fetchMarketData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search coin...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<MarketProvider>(context, listen: false)
                              .clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                Provider.of<MarketProvider>(context, listen: false).searchCoins(value);
                setState(() {});
              },
            ),
          ),

          // Column headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Coin',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Price',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '24h %',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 16),

          // Coin List
          Expanded(
            child: Consumer<MarketProvider>(
              builder: (context, marketProvider, _) {
                if (marketProvider.isLoading && marketProvider.coins.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (marketProvider.error != null && marketProvider.coins.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          marketProvider.error!,
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => marketProvider.fetchMarketData(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => marketProvider.fetchMarketData(),
                  color: AppColors.primary,
                  child: ListView.builder(
                    itemCount: marketProvider.coins.length,
                    itemBuilder: (context, index) {
                      final coin = marketProvider.coins[index];
                      return CoinListTile(
                        coin: coin,
                        onTap: () => _navigateToTrading(coin),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTrading(CoinModel coin) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TradingScreen(coin: coin),
      ),
    );
  }
}
