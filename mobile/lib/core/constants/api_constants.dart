// For Android Emulator use 10.0.2.2. For physical device use your computer's LAN IP (e.g. 192.168.1.x)
const String apiBaseUrl = 'http://10.0.2.2:5000/api';
const String mapApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
const String defaultLanguage = 'en';

// API timeout
const int connectionTimeout = 30000;
const int receiveTimeout = 30000;

// Pagination
const int pageSize = 20;

// Cache keys
const String userCacheKey = 'user_cache';
const String tokenCacheKey = 'token_cache';
const String chargersCacheKey = 'chargers_cache';

// Mock Data
const bool useMockData = true;
