import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Local authentication service using SharedPreferences
/// In production, replace with Firebase Auth or custom backend
class AuthService {
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';

  /// Register a new user
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing users
    final usersJson = prefs.getString(_usersKey);
    Map<String, dynamic> users = {};
    if (usersJson != null) {
      users = json.decode(usersJson);
    }

    // Check if user already exists
    if (users.containsKey(email)) {
      throw Exception('User with this email already exists');
    }

    // Create new user
    final user = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      displayName: displayName,
      balance: 10000.0, // Starting demo balance
      createdAt: DateTime.now(),
    );

    // Save user with password
    users[email] = {
      'user': user.toJson(),
      'password': password,
    };

    await prefs.setString(_usersKey, json.encode(users));
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));

    return user;
  }

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) {
      throw Exception('No registered users found');
    }

    final users = json.decode(usersJson) as Map<String, dynamic>;

    if (!users.containsKey(email)) {
      throw Exception('User not found');
    }

    final userData = users[email];
    if (userData['password'] != password) {
      throw Exception('Invalid password');
    }

    final user = UserModel.fromJson(userData['user']);
    await prefs.setString(_currentUserKey, json.encode(user.toJson()));

    return user;
  }

  /// Check if user is logged in
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);

    if (userJson != null) {
      return UserModel.fromJson(json.decode(userJson));
    }
    return null;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  /// Update user balance
  Future<void> updateBalance(String email, double newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson != null) {
      final users = json.decode(usersJson) as Map<String, dynamic>;
      if (users.containsKey(email)) {
        users[email]['user']['balance'] = newBalance;
        await prefs.setString(_usersKey, json.encode(users));

        final currentUser = await getCurrentUser();
        if (currentUser != null && currentUser.email == email) {
          final updatedUser = UserModel(
            id: currentUser.id,
            email: currentUser.email,
            displayName: currentUser.displayName,
            balance: newBalance,
            createdAt: currentUser.createdAt,
          );
          await prefs.setString(_currentUserKey, json.encode(updatedUser.toJson()));
        }
      }
    }
  }
}
