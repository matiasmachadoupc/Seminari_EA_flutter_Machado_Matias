import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class UserService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users'; // Verifica que el puerto sea correcto
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users'; // Dirección para emulador Android
    } else {
      return 'http://localhost:9000/api/users'; // Dirección para otros entornos
    }
  }

  static Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error en carregar usuaris');
    }
  }

  static Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear usuari: ${response.statusCode}');
    }
  }

  static Future<User> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error a l'obtenir usuari: ${response.statusCode}");
    }
  }

  static Future<bool> updateUser(String id, Map<String, dynamic> updateData) async {
    print('Intentando actualizar usuario...');
    print('URL: $baseUrl/$id'); // Verifica que esta ruta coincida con el backend
    print('Body: ${jsonEncode(updateData)}'); // Verifica los datos enviados

    if (updateData['name'] == null || updateData['age'] == null || updateData['email'] == null) {
      throw Exception('Error: Datos incompletos para actualizar el usuario.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updateData),
    );

    print('Respuesta del servidor: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Usuario actualizado correctamente.');
      return true;
    } else {
      print('Error al actualizar usuario: ${response.body}');
      throw Exception('Error actualizando usuario: ${response.statusCode}');
    }
  }

  static Future<bool> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error eliminant usuari: ${response.statusCode}');
    }
  }

  static Future<bool> changePassword(String userId, String newPassword) async {
    print('Intentando cambiar contraseña...');
    print('URL: $baseUrl/$userId/change-password'); // Verifica que esta ruta coincida con el backend
    print('Body: ${jsonEncode({'newPassword': newPassword})}'); // Verifica los datos enviados

    if (newPassword.isEmpty) {
      throw Exception('Error: La nueva contraseña no puede estar vacía.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/$userId/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': newPassword}),
    );

    print('Respuesta del servidor: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Contraseña cambiada correctamente.');
      return true;
    } else {
      print('Error al cambiar contraseña: ${response.body}');
      throw Exception('Error changing password: ${response.statusCode}');
    }
  }
}
