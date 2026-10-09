import '../entities/home_dashboard.dart';

/// Loads the Home dashboard. GPS is optional; when absent the backend simply
/// returns `nearbyTemples: null`.
abstract interface class HomeRepository {
  Future<HomeDashboard> loadDashboard({double? latitude, double? longitude});
}
