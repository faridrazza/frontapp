  //  class AppConfig {
  //    static const String devBaseUrl = 'YOUR_DEV_URL_HERE';
  //    static const String prodBaseUrl = 'YOUR_PROD_URL_HERE';
  //    static const bool isProduction = false; // Set to true for production builds

  //    static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
  //  }


    class AppConfig {
     static const String devBaseUrl = 'https://backendt-english.onrender.com';
     static const String prodBaseUrl = 'https://backendt-english.onrender.com';
     static const bool isProduction = false; // Set to true for production builds

     static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
   }