import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

/// API service for communicating with the Loya backend
class ApiService {
  static const String _baseUrl =
      'https://api-v4xex7aj3a-uc.a.run.app';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get the current user's ID token for authentication
  Future<String?> _getToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  /// Make an authenticated GET request
  Future<Map<String, dynamic>?> _get(String path,
      {Map<String, String>? queryParams}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Make an authenticated POST request
  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Make an authenticated PATCH request
  Future<Map<String, dynamic>> _patch(
      String path, Map<String, dynamic> body) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  /// Make an authenticated DELETE request
  Future<void> _delete(String path) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.delete(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }

  // ==================== Business ====================

  /// Get the current user's business
  Future<Map<String, dynamic>?> getBusiness() async {
    return _get('/api/business');
  }

  /// Create a new business
  Future<Map<String, dynamic>> createBusiness({
    required String nameEn,
    String? nameAr,
    required String phone,
    String? email,
    String? address,
  }) async {
    return _post('/api/business', {
      'nameEn': nameEn,
      'nameAr': nameAr,
      'phone': phone,
      'email': email,
      'address': address,
    });
  }

  /// Update business details
  Future<void> updateBusiness(
      String businessId, Map<String, dynamic> data) async {
    await _patch('/api/business/$businessId', data);
  }

  // ==================== Programs ====================

  /// Get all programs for the business
  Future<List<Map<String, dynamic>>> getPrograms() async {
    final response = await _get('/api/programs');
    if (response == null) return [];
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Create a new program
  Future<Map<String, dynamic>> createProgram({
    required String name,
    String? description,
    required String rewardDescription,
    required int stampsRequired,
    required String color,
    required String icon,
  }) async {
    return _post('/api/programs', {
      'name': name,
      'description': description,
      'rewardDescription': rewardDescription,
      'stampsRequired': stampsRequired,
      'color': color,
      'icon': icon,
    });
  }

  /// Update a program
  Future<void> updateProgram(
      String programId, Map<String, dynamic> data) async {
    await _patch('/api/programs/$programId', data);
  }

  /// Delete a program
  Future<void> deleteProgram(String programId) async {
    await _delete('/api/programs/$programId');
  }

  // ==================== Customers ====================

  /// Get all customers for the business
  Future<List<Map<String, dynamic>>> getCustomers(
      {int limit = 50, String? search}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (search != null) {
      queryParams['search'] = search;
    }

    final response = await _get('/api/customers', queryParams: queryParams);
    if (response == null) return [];
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Create or find a customer by phone
  Future<Map<String, dynamic>> findOrCreateCustomer({
    required String phone,
    String? name,
    String? notes,
  }) async {
    return _post('/api/customers', {
      'phone': phone,
      'name': name,
      'notes': notes,
    });
  }

  /// Get a specific customer with their progress
  Future<Map<String, dynamic>?> getCustomer(String customerId) async {
    return _get('/api/customers/$customerId');
  }

  /// Update a customer
  Future<void> updateCustomer(
      String customerId, Map<String, dynamic> data) async {
    await _patch('/api/customers/$customerId', data);
  }

  // ==================== Stamps ====================

  /// Add a stamp to a customer's program
  Future<Map<String, dynamic>> addStamp({
    required String customerId,
    required String programId,
  }) async {
    return _post('/api/stamp', {
      'customerId': customerId,
      'programId': programId,
    });
  }

  // ==================== Activity ====================

  /// Get activity feed
  Future<List<Map<String, dynamic>>> getActivity(
      {int limit = 50, String? type}) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (type != null) {
      queryParams['type'] = type;
    }

    final response = await _get('/api/activity', queryParams: queryParams);
    if (response == null) return [];
    return List<Map<String, dynamic>>.from(response as List);
  }

  // ==================== Analytics ====================

  /// Get analytics for the business
  Future<Map<String, dynamic>?> getAnalytics({int days = 7}) async {
    return _get('/api/analytics', queryParams: {'days': days.toString()});
  }

  // ==================== Wallet Pass ====================

  /// Create or update a wallet pass for a customer
  Future<Map<String, dynamic>> createWalletPass({
    required String customerId,
    required String programId,
  }) async {
    return _post('/createWalletPass', {
      'customerId': customerId,
      'programId': programId,
    });
  }

  // ==================== Messaging ====================

  /// Broadcast a message to all pass holders of a program
  Future<Map<String, dynamic>> broadcastMessage({
    required String programId,
    required String message,
    String? title,
  }) async {
    return _post('/api/broadcastMessage', {
      'program_id': programId,
      'message': message,
      if (title != null && title.isNotEmpty) 'title': title,
    });
  }

  // ==================== Pass Management ====================

  /// Refresh all passes for a program (regenerate with latest branding)
  Future<Map<String, dynamic>> refreshProgramPasses({
    required String programId,
  }) async {
    return _post('/refreshProgramPasses', {
      'program_id': programId,
    });
  }

  /// Refresh all passes for all programs of a business
  Future<Map<String, dynamic>> refreshBusinessPasses({
    required String businessId,
    required List<String> programIds,
  }) async {
    int totalUpdated = 0;
    int totalFailed = 0;
    
    for (final programId in programIds) {
      try {
        final result = await refreshProgramPasses(programId: programId);
        totalUpdated += (result['updated'] ?? 0) as int;
        totalFailed += (result['failed'] ?? 0) as int;
      } catch (e) {
        totalFailed += 1;
      }
    }
    
    return {
      'success': true,
      'updated': totalUpdated,
      'failed': totalFailed,
    };
  }
}
