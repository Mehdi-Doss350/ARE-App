// ignore_for_file: camel_case_types
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class category {
  String name;
  String image;
  String op1, op2, op3, op4, op5;

  category({
    required this.name,
    required this.image,
    required this.op1,
    required this.op2,
    required this.op3,
    required this.op4,
    required this.op5,
  });

  factory category.fromJson(Map<String, dynamic> json) => category(
        name: json['name'] ?? '',
        image: json['image'] ?? '',
        op1: json['op1'] ?? '',
        op2: json['op2'] ?? '',
        op3: json['op3'] ?? '',
        op4: json['op4'] ?? '',
        op5: json['op5'] ?? '',
      );
}

String categoryclick = '';
int productclick = -1;
int indexcategoryclick = -1;

class Material {
  String image;
  String name;
  String type;
  int quantity;
  String detail;
  String op1, op2, op3, op4, op5;
  String category;

  Material({
    required this.image,
    required this.name,
    required this.type,
    required this.quantity,
    required this.detail,
    required this.op1,
    required this.op2,
    required this.op3,
    required this.op4,
    required this.op5,
    required this.category,
  });

  factory Material.fromJson(Map<String, dynamic> json) => Material(
        image: json['image'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? '',
        quantity: json['quantity'] is int
            ? json['quantity']
            : int.tryParse(json['quantity'].toString()) ?? 0,
        detail: json['detail'] ?? '',
        op1: json['op1'] ?? '',
        op2: json['op2'] ?? '',
        op3: json['op3'] ?? '',
        op4: json['op4'] ?? '',
        op5: json['op5'] ?? '',
        category: json['category'] ?? '',
      );
}

Map<String, int> orders = {};
List<Material> orderedItems = [];

class account {
  String imageUrl;
  String name;
  String classname;
  String role;
  String phone;
  String email;

  account({
    required this.imageUrl,
    required this.name,
    required this.classname,
    required this.role,
    required this.phone,
    required this.email,
  });
}

Future<List<category>> fetchCategories() async {
  final response =
      await http.get(Uri.parse('http://192.168.1.16:5000/api/categories'));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => category.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load categories');
  }
}

Future<List<Material>> fetchMaterials([String? category]) async {
  final url = category != null && category.isNotEmpty
      ? 'http://192.168.1.16:5000/api/materials?category=$category'
      : 'http://192.168.1.16:5000/api/materials';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Material.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load materials');
  }
}

Future<account> fetchAccountByEmail(String email) async {
  final response = await http.get(
    Uri.parse('http://192.168.1.16:5000/api/accounts?email=$email'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return account(
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      classname: data['classname'] ?? '',
      role: data['role'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  } else {
    throw Exception('Failed to load account');
  }
}

Future<account> fetchAccountByName(String name) async {
  final response = await http.get(
    Uri.parse('http://192.168.1.16:5000/api/accounts?name=$name'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return account(
      imageUrl: data['imageUrl'] ?? '',
      name: data['name'] ?? '',
      classname: data['classname'] ?? '',
      role: data['role'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  } else {
    throw Exception('Failed to load account');
  }
}

class ReservationService {
  static const String _baseUrl = 'http://192.168.1.16:5000/api';

  static Future<List<dynamic>> getReservations(String userEmail) async {
    try {
      // 1. Print debug information
      debugPrint('Fetching reservations for: $userEmail');
      debugPrint('API URL: $_baseUrl/reservations?email=$userEmail');

      // 2. Make the API call
      final response = await http.get(
        Uri.parse('$_baseUrl/reservations?email=$userEmail'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      // 3. Debug print the raw response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      // 4. Handle response
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        // Ensure the response is a List
        if (decoded is List) {
          return decoded;
        } else {
          debugPrint('Unexpected response format: $decoded');
          return []; // Return empty list if format is wrong
        }
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return []; // Return empty list on API error
      }
    } on TimeoutException {
      debugPrint('Request timed out');
      return [];
    } catch (e) {
      debugPrint('Error in getReservations: $e');
      return []; // Return empty list on any other error
    }
  }

  static Future<void> updateReservation(
    String id,
    String status,
    String adminResponse,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/reservations/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'admin_response': adminResponse,
          'isResponse': true,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update reservation');
      }
    } catch (e) {
      throw Exception('Error updating reservation: $e');
    }
  }
}

account? currentUser;
String? loggedInEmail;
