import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get baseUrl {
    return dotenv.get('BASE_URL', fallback: 'http://192.168.1.16:5000');
  }

  // For development (iOS simulator)
  // static const String baseUrl = 'http://localhost:5000/api';

  // For production (your live server)
  // static const String baseUrl = 'https://your-api-domain.com/api';

  // Add other constants as needed
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
}
