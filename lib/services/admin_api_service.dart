import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminApiService {
  static const String _projectId = 'admin-panel-app-574a7';
  static const String _region = 'us-central1';
  
  String get _baseUrl => 'https://$_region-$_projectId.cloudfunctions.net';
  
  Future<String> _getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    
    final token = await user.getIdToken(true);
    return token!;
  }
  
  /// Create a new user
  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    String? displayName,
    String role = 'user',
  }) async {
    final token = await _getIdToken();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/createUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'displayName': displayName,
        'role': role,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }
  
  /// Update user profile
  Future<Map<String, dynamic>> updateUser({
    required String uid,
    String? displayName,
    bool? disabled,
  }) async {
    final token = await _getIdToken();
    
    final body = <String, dynamic>{'uid': uid};
    if (displayName != null) body['displayName'] = displayName;
    if (disabled != null) body['disabled'] = disabled;
    
    final response = await http.post(
      Uri.parse('$_baseUrl/updateUser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }
  
  /// Set user role
  Future<Map<String, dynamic>> setUserRole({
    required String uid,
    required String role,
  }) async {
    final token = await _getIdToken();
    
    final response = await http.post(
      Uri.parse('$_baseUrl/setRole'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'uid': uid,
        'role': role,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to set role: ${response.body}');
    }
  }
}