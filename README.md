# DrewX Exchange

A modern cryptocurrency trading app built with Flutter & Dart. Features real-time market data, interactive trading charts, order book visualization, and portfolio management.

## Features

- **Market / Harga Crypto** - Real-time crypto prices from CoinGecko API with search functionality
- **Trading Chart** - Interactive price charts (24H, 7D, 1M, 3M, 1Y) with buy/sell trading
- **Order Book** - Real-time order book from Binance API with depth visualization
- **Portfolio / Wallet** - Track holdings, P/L, and cash balance with demo $10,000
- **Login & Auth** - Local authentication with registration system

## Tech Stack

- **Framework:** Flutter 3.x / Dart 3.x
- **State Management:** Provider
- **APIs:** CoinGecko (market data), Binance (order book & WebSocket)
- **Charts:** fl_chart
- **Storage:** SharedPreferences (local auth & portfolio)
- **UI:** Material Design 3, Google Fonts, Dark Theme

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── coin_model.dart          # Crypto coin data model
│   ├── orderbook_model.dart     # Order book bids/asks model
│   ├── portfolio_model.dart     # Portfolio holdings model
│   └── user_model.dart          # User auth model
├── services/
│   ├── auth_service.dart        # Local authentication service
│   ├── binance_service.dart     # Binance REST & WebSocket API
│   └── coingecko_service.dart   # CoinGecko market data API
├── providers/
│   ├── auth_provider.dart       # Auth state management
│   ├── market_provider.dart     # Market data state
│   ├── orderbook_provider.dart  # Order book state
│   └── portfolio_provider.dart  # Portfolio state
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Login page
│   │   └── register_screen.dart # Registration page
│   ├── market/
│   │   └── market_screen.dart   # Crypto market list
│   ├── trading/
│   │   └── trading_screen.dart  # Chart + Buy/Sell
│   ├── orderbook/
│   │   └── orderbook_screen.dart # Real-time order book
│   ├── portfolio/
│   │   └── portfolio_screen.dart # Wallet & Holdings
│   └── home_screen.dart         # Bottom navigation
├── widgets/
│   └── coin_list_tile.dart      # Reusable coin list item
└── utils/
    ├── constants.dart           # Colors, API URLs, Strings
    ├── formatters.dart          # Currency & number formatters
    └── theme.dart               # App dark theme
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0+ installed
- Android Studio or VS Code with Flutter extension
- Android device/emulator

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/BagusDrew/DrewX-Exchange.git
   cd DrewX-Exchange
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run on Android:**
   ```bash
   flutter run
   ```

### First Run

1. Open the app → you'll see the **Login** screen
2. Tap **Register** to create a new account
3. You'll get a **$10,000 demo balance** to practice trading
4. Browse the **Market** tab for real-time crypto prices
5. Tap any coin to view its **Trading Chart** and place buy/sell orders
6. Check the **Order Book** tab for real-time Binance order depth
7. Track your trades in the **Portfolio** tab

## API Information

| API | Usage | Key Required |
|-----|-------|:---:|
| CoinGecko | Market prices, charts, coin data | No (free tier) |
| Binance | Order book, klines (REST + WebSocket) | No (public endpoints) |

> **Note:** CoinGecko free tier has rate limits (~10-30 calls/min). The app auto-refreshes every 30 seconds.

## Screenshots

The app features a sleek dark theme with:
- Green (#00C853) for profit/buy
- Red (#FF5252) for loss/sell
- Teal (#00D4AA) as primary accent

## Future Enhancements

- [ ] Firebase Authentication
- [ ] Push notifications for price alerts
- [ ] More chart indicators (RSI, MACD, Bollinger)
- [ ] Multi-language support (ID/EN)
- [ ] Real exchange integration for live trading
- [ ] Watchlist / Favorites

## License

This project is for educational purposes.

---

**Built with Flutter by DrewX**
