class ApiConfig {
  // ── PICK THE RIGHT URL FOR YOUR SETUP ──────────────────────────────────────
  //
  // Running on Android Emulator (most common):
  static const String baseUrl = 'http://10.0.2.2:8080';
  //
  // Running on iOS Simulator:
  // static const String baseUrl = 'http://localhost:8080';
  //
  // Running on a real phone (WiFi):
  // Find your PC's local IP with 'ipconfig' (Windows) or 'ifconfig' (Mac)
  // static const String baseUrl = 'http://192.168.1.xxx:8080';
  //
  // DO NOT use an ngrok URL unless ngrok is actively running.
  // ────────────────────────────────────────────────────────────────────────────

  static const Duration timeout = Duration(seconds: 15);

  // Auth
  static const String login          = '/api/auth/login';
  static const String register       = '/api/auth/register';
  static const String adminSendOtp   = '/api/auth/admin/send-otp';
  static const String adminVerifyOtp = '/api/auth/admin/verify-otp';

  // Jobs
  static String createJob(int customerId) => '/api/jobs?customerId=$customerId';
  static String jobsByCustomer(int id)    => '/api/jobs/customer/$id';
  static String jobsByProvider(int id)    => '/api/jobs/provider/$id';
  static const String openJobs           = '/api/jobs/open';

  // Bids
  static String bidsForJob(int jobId)              => '/api/jobs/$jobId/bids';
  static String acceptBid(int jobId, int bidId)    => '/api/jobs/$jobId/bids/$bidId/accept';
  static String rejectBid(int jobId, int bidId)    => '/api/jobs/$jobId/bids/$bidId/reject';
  static String counterOffer(int jobId, int bidId) => '/api/jobs/$jobId/bids/$bidId/counter-offer';

  // Bookings
  static String createBooking(int jobId, int bidId) => '/api/bookings?jobId=$jobId&bidId=$bidId';
  static String startJourney(int bookingId)          => '/api/bookings/$bookingId/start-journey';
  static String arrived(int bookingId)               => '/api/bookings/$bookingId/arrived';
  static String completeBooking(int bookingId)       => '/api/bookings/$bookingId/complete';

  // Providers
  static String providerById(int id)                    => '/api/providers/$id';
  static String providersByProfession(String p)         => '/api/providers/profession/$p';

  // Reviews
  static const String submitReview = '/api/customers/reviews';
}
