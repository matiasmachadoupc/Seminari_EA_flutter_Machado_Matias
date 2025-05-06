import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/UserService.dart';

class UserProvider with ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  User? _loggedInUser;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get loggedInUser => _loggedInUser;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    _setError(null);

    try {
      _users = await UserService.getUsers();
    } catch (e) {
      _setError('Error loading users: $e');
      _users = [];
    } finally {
      _setLoading(false);
    }
  }

  void setLoggedInUser(Map<String, dynamic> userData) {
    _loggedInUser = User.fromJson(userData); // Asegúrate de que 'id' se asigna correctamente
    print("Usuario establecido en UserProvider: ${_loggedInUser?.id}"); // Log para verificar
    notifyListeners();
  }

  void clearLoggedInUser() {
    _loggedInUser = null;
    notifyListeners();
  }

  Future<bool> updateUser(User updatedUser) async {
    _setLoading(true);
    _setError(null);

    try {
      final updateData = {
        'name': updatedUser.name,
        'age': updatedUser.age,
        'email': updatedUser.email,
      }; // Excluye campos innecesarios o nulos

      final success = await UserService.updateUser(updatedUser.id!, updateData);
      if (success) {
        _loggedInUser = updatedUser;
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error updating user: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarUsuariPerId(String id) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await UserService.deleteUser(id);
      if (success) {
        _users.removeWhere((user) => user.id == id);
        notifyListeners();
      }
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error deleting user: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> changePassword(String userId, String newPassword) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await UserService.changePassword(userId, newPassword);
      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Error changing password: $e');
      _setLoading(false);
      return false;
    }
  }
}
