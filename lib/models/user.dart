import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: _parseString(json['id'], 'user_${DateTime.now().millisecondsSinceEpoch}'),
        name: _parseString(json['name'], 'Usuario'),
        email: _parseString(json['email'], ''),
        phone: json['phone'] as String?,
        createdAt: _parseDateTime(json['createdAt'], DateTime.now()),
      );
    } catch (e) {
      debugPrint('Error parsing User JSON: $e');
      return User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Usuario',
        email: '',
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get initials {
    if (name.isEmpty) return 'U';
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0][0].toUpperCase();
    }
    return '${names[0][0]}${names[1][0]}'.toUpperCase();
  }

  bool get isComplete {
    return name.isNotEmpty && email.isNotEmpty && email.contains('@');
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, phone: $phone, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }

  static String _parseString(dynamic value, String defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value, DateTime defaultValue) {
    if (value == null) return defaultValue;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return defaultValue;
      }
    }
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}