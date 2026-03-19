
class AppConstants {
  static String get baseUrl {
    // 1. FOR PHYSICAL DEVICE: Use your machine's IP (check with 'ipconfig')
    // Ensure both phone and PC are on the same Wi-Fi.
    return 'http://192.168.1.15:5000/api';

    // 2. FOR ANDROID EMULATOR: Use 10.0.2.2
    // return 'http://10.0.2.2:5000/api';

    // 3. FOR IOS SIMULATOR: Use localhost
    // return 'http://localhost:5000/api';
  }

  // Add other constants as needed
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
}
