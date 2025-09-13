import '../core/api/api_service.dart';

class AuthLogic {
  static Future<bool> signIn(String email, String password) async {
    final response = await ApiService.post('auth/signin', {
      'email': email,
      'password': password,
    });
    return response['success'] ?? false;
  }
}
