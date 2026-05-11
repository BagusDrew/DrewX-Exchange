import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/coin_model.dart';
import '../../providers/market_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class TradingScreen extends StatefulWidget {
  final CoinModel coin;

  const TradingScreen({super.key, required this.coin});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen> {
  List<List<double>> _chartData = [];
  bool _isLoadingChart = true;
  int _selectedDays = 7;
  final List<int> _dayOptions = [1, 7, 30, 90, 365];

  @override
  void initState() {
    super.initState();
    _loadChart();
  }

  Future<void> _loadChart() async {
    setState(() => _isLoadingChart = true);
    try {
      final data = await Provider.of<MarketProvider>(context, listen: false)
          .getCoinChart(widget.coin.id, days: _selectedDays);
      setState(() {
        _chartData = data;
        _isLoadingChart = false;
      });
    } catch (e) {
      setState(() => _isLoadingChart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.coin.symbol.toUpperCase()}/USD'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Price header
          _buildPriceHeader(),
          // Chart
          _buildChart(),
          // Day selector
          _buildDaySelector(),
          const Divider(color: AppColors.border),
          // Coin Info
          _buildCoinInfo(),
          const Spacer(),
          // Buy/Sell buttons
          _buildTradeButtons(),
        ],
      ),
    );
  }

  Widget _buildPriceHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatCurrency(widget.coin.currentPrice),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    widget.coin.isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: widget.coin.isPriceUp ? AppColors.green : AppColors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.coin.isPriceUp ? '+' : ''}${widget.coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: widget.coin.isPriceUp ? AppColors.green : AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    '  24h',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (_isLoadingChart) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_chartData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No chart data available', style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final spots = _chartData
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value[1]))
        .toList();

    final isUp = spots.last.y >= spots.first.y;

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) {
                  return spots.map((spot) {
                    return LineTooltipItem(
                      formatCurrency(spot.y),
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  }).toList();
                },
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: isUp ? AppColors.green : AppColors.red,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: (isUp ? AppColors.green : AppColors.red).withAlpha(25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _dayOptions.map((days) {
          final isSelected = days == _selectedDays;
          String label;
          if (days == 1) label = '24H';
          else if (days == 7) label = '7D';
          else if (days == 30) label = '1M';
          else if (days == 90) label = '3M';
          else label = '1Y';

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDays = days);
              _loadChart();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withAlpha(51) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoinInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoRow('Market Cap', formatLargeNumber(widget.coin.marketCap)),
          _infoRow('24h Volume', formatLargeNumber(widget.coin.totalVolume)),
          _infoRow('24h High', formatCurrency(widget.coin.high24h)),
          _infoRow('24h Low', formatCurrency(widget.coin.low24h)),
          _infoRow('Rank', '#${widget.coin.marketCapRank}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTradeButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showTradeDialog(isBuy: true),
              child: const Text('Buy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showTradeDialog(isBuy: false),
              child: const Text('Sell', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTradeDialog({required bool isBuy}) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${isBuy ? 'Buy' : 'Sell'} ${widget.coin.symbol.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ${formatCurrency(widget.coin.currentPrice)}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount (${widget.coin.symbol.toUpperCase()})',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<PortfolioProvider>(
                builder: (context, portfolio, _) {
                  return Text(
                    'Available: ${formatCurrency(portfolio.totalBalance)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBuy ? AppColors.green : AppColors.red,
                ),
                onPressed: () => _executeTrade(
                  isBuy: isBuy,
                  amountStr: amountController.text,
                ),
                child: Text('Confirm ${isBuy ? 'Buy' : 'Sell'}'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _executeTrade({required bool isBuy, required String amountStr}) {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final portfolio = Provider.of<PortfolioProvider>(context, listen: false);

    try {
      if (isBuy) {
        portfolio.buyCoin(
          coinId: widget.coin.id,
          symbol: widget.coin.symbol,
          name: widget.coin.name,
          image: widget.coin.image,
          amount: amount,
          price: widget.coin.currentPrice,
        );
      } else {
        portfolio.sellCoin(
          coinId: widget.coin.id,
          amount: amount,
          price: widget.coin.currentPrice,
        );
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${isBuy ? 'Bought' : 'Sold'} $amount ${widget.coin.symbol.toUpperCase()} successfully!',
          ),
          backgroundColor: isBuy ? AppColors.green : AppColors.red,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }
}
