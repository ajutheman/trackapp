class ApiEndpoints {
  static const String baseDevelopmentUrl = 'http://10.0.2.2:3000/';
  static const String baseProdRenderUrl = 'https://truck-api-qyew.onrender.com/';
  static const String baseProductionUrl = 'https://api.returncargo.in/';

  // Toggle this to switch between development and production
  static const bool isDevelopment = false;
  static const String baseUrl = isDevelopment ? baseDevelopmentUrl : baseProductionUrl;

  static const String sendOTP = 'api/v1/auth/request-otp';
  static const String verifyOTP = 'api/v1/auth/verify-otp';
  static const String registerProfile = 'api/v1/users/profile';

  // Profile endpoints
  static const String getProfile = 'api/v1/users/profile';
  static const String updateProfile = 'api/v1/users/profile';
  static const String deleteProfile = 'api/v1/users/profile';

  static const String registerVehicle = 'api/v1/vehicles';
  static const String uploadImage = 'api/v1/images/upload';
  static const String uploadDocument = 'api/v1/documents/upload';
  static const String allVehicleBodyTypes = 'api/v1/vehicles/body-types';
  static const String allGoodsAccepted = 'api/v1/vehicles/goods-accepted';
  static const String allVehicleTypes = 'api/v1/vehicles/types';
  static const String getVehicles = 'api/v1/vehicles';

  // Posts/Trips endpoints
  static const String getAllPosts = 'api/v1/trips';
  static const String createPost = 'api/v1/trips';
  static const String getUserPosts = 'api/v1/trips/my';
  static const String getPostById = 'api/v1/posts';
  static const String updatePost = 'api/v1/posts';
  static const String deletePost = 'api/v1/posts';
  static const String updateTripStatus = 'api/v1/posts';

  // Connections/Trips endpoints
  static const String getConnections = 'api/v1/connections';
  static const String createConnection = 'api/v1/connections';
  static const String updateConnectionStatus = 'api/v1/connections';

  // Connect Requests endpoints
  static const String connectRequests = 'api/v1/connect-requests';

  // Token endpoints
  static const String tokenBalance = 'api/v1/tokens/wallet/balance';
  static const String leadTokenUsage = 'api/v1/tokens/usage/lead';
  static const String tokenTransactions = 'api/v1/tokens/transactions';
  static const String tokenPlans = 'api/v1/tokens/plans';
  static const String purchaseTokens = 'api/v1/tokens/purchase';

  // Booking endpoints
  static const String bookings = 'api/v1/bookings';
  static const String bookingStats = 'api/v1/bookings/stats';

  // Customer Request (Post) endpoints
  static const String getAllCustomerRequests = 'api/v1/customer-requests';
  static const String createCustomerRequest = 'api/v1/customer-requests';
  static const String getMyCustomerRequests = 'api/v1/customer-requests/my';
  static const String getCustomerRequestById = 'api/v1/customer-requests';
  static const String updateCustomerRequest = 'api/v1/customer-requests';
  static const String deleteCustomerRequest = 'api/v1/customer-requests';

  // Review endpoints
  static const String createReview = 'api/v1/reviews';
  static const String updateReview = 'api/v1/reviews';
  static const String getReviewById = 'api/v1/reviews';
  static const String getReviewsByBooking = 'api/v1/reviews/booking';
  static const String getReviewsByUser = 'api/v1/reviews/user';
  static const String getReviewSummary = 'api/v1/reviews/summary';
}
