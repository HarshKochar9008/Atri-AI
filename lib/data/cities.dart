import 'dart:math' as math;

/// A city entry with its coordinates and timezone offset (hours from UTC).
///
/// Used to give users an accurate-yet-friendly birth place picker
/// (Mumbai, Delhi, Goa…) instead of asking them to type raw lat/long.
class City {
  final String name;
  final String country;
  final String? region;
  final double latitude;
  final double longitude;

  /// Timezone offset in hours from UTC (e.g. 5.5 for IST).
  final double timezoneOffsetHours;

  const City({
    required this.name,
    required this.country,
    this.region,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffsetHours,
  });

  String get displayName => region == null || region!.isEmpty
      ? '$name, $country'
      : '$name, $region, $country';

  /// For ranking in the autocomplete — lower is better.
  /// Prefix matches rank above contains matches.
  int matchScore(String query) {
    if (query.isEmpty) return 0;
    final q = query.toLowerCase();
    final n = name.toLowerCase();
    final d = displayName.toLowerCase();
    if (n == q) return 0;
    if (n.startsWith(q)) return 1;
    if (d.startsWith(q)) return 2;
    if (n.contains(q)) return 3;
    if (d.contains(q)) return 4;
    return 999;
  }
}

class CityDatabase {
  CityDatabase._();

  /// Returns top [limit] cities matching the query, ranked.
  /// Empty query returns the first [limit] cities (popular Indian cities first).
  static List<City> search(String query, {int limit = 12}) {
    if (query.trim().isEmpty) {
      return cities.take(limit).toList();
    }
    final q = query.trim();
    final scored = <MapEntry<int, City>>[];
    for (final c in cities) {
      final s = c.matchScore(q);
      if (s < 999) scored.add(MapEntry(s, c));
    }
    scored.sort((a, b) => a.key.compareTo(b.key));
    return scored.take(limit).map((e) => e.value).toList();
  }

  /// Returns the nearest city to the given coordinates using the
  /// haversine distance. Useful for reverse-resolving a GPS fix
  /// (latitude/longitude) into a friendly city name from our list.
  static City? nearest(double latitude, double longitude) {
    if (cities.isEmpty) return null;
    City? best;
    double bestDist = double.infinity;
    for (final c in cities) {
      final d = _haversineKm(latitude, longitude, c.latitude, c.longitude);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;

  /// Curated list. Heavy on India (the primary audience) plus
  /// major world cities. Add more as needed.
  static const List<City> cities = [
    // ----- India (major metros & state capitals) -----
    City(name: 'Mumbai', country: 'India', region: 'Maharashtra', latitude: 19.0760, longitude: 72.8777, timezoneOffsetHours: 5.5),
    City(name: 'Delhi', country: 'India', region: 'Delhi', latitude: 28.7041, longitude: 77.1025, timezoneOffsetHours: 5.5),
    City(name: 'New Delhi', country: 'India', region: 'Delhi', latitude: 28.6139, longitude: 77.2090, timezoneOffsetHours: 5.5),
    City(name: 'Bangalore', country: 'India', region: 'Karnataka', latitude: 12.9716, longitude: 77.5946, timezoneOffsetHours: 5.5),
    City(name: 'Bengaluru', country: 'India', region: 'Karnataka', latitude: 12.9716, longitude: 77.5946, timezoneOffsetHours: 5.5),
    City(name: 'Chennai', country: 'India', region: 'Tamil Nadu', latitude: 13.0827, longitude: 80.2707, timezoneOffsetHours: 5.5),
    City(name: 'Kolkata', country: 'India', region: 'West Bengal', latitude: 22.5726, longitude: 88.3639, timezoneOffsetHours: 5.5),
    City(name: 'Hyderabad', country: 'India', region: 'Telangana', latitude: 17.3850, longitude: 78.4867, timezoneOffsetHours: 5.5),
    City(name: 'Pune', country: 'India', region: 'Maharashtra', latitude: 18.5204, longitude: 73.8567, timezoneOffsetHours: 5.5),
    City(name: 'Ahmedabad', country: 'India', region: 'Gujarat', latitude: 23.0225, longitude: 72.5714, timezoneOffsetHours: 5.5),
    City(name: 'Surat', country: 'India', region: 'Gujarat', latitude: 21.1702, longitude: 72.8311, timezoneOffsetHours: 5.5),
    City(name: 'Jaipur', country: 'India', region: 'Rajasthan', latitude: 26.9124, longitude: 75.7873, timezoneOffsetHours: 5.5),
    City(name: 'Lucknow', country: 'India', region: 'Uttar Pradesh', latitude: 26.8467, longitude: 80.9462, timezoneOffsetHours: 5.5),
    City(name: 'Kanpur', country: 'India', region: 'Uttar Pradesh', latitude: 26.4499, longitude: 80.3319, timezoneOffsetHours: 5.5),
    City(name: 'Nagpur', country: 'India', region: 'Maharashtra', latitude: 21.1458, longitude: 79.0882, timezoneOffsetHours: 5.5),
    City(name: 'Indore', country: 'India', region: 'Madhya Pradesh', latitude: 22.7196, longitude: 75.8577, timezoneOffsetHours: 5.5),
    City(name: 'Bhopal', country: 'India', region: 'Madhya Pradesh', latitude: 23.2599, longitude: 77.4126, timezoneOffsetHours: 5.5),
    City(name: 'Visakhapatnam', country: 'India', region: 'Andhra Pradesh', latitude: 17.6868, longitude: 83.2185, timezoneOffsetHours: 5.5),
    City(name: 'Patna', country: 'India', region: 'Bihar', latitude: 25.5941, longitude: 85.1376, timezoneOffsetHours: 5.5),
    City(name: 'Vadodara', country: 'India', region: 'Gujarat', latitude: 22.3072, longitude: 73.1812, timezoneOffsetHours: 5.5),
    City(name: 'Ludhiana', country: 'India', region: 'Punjab', latitude: 30.9010, longitude: 75.8573, timezoneOffsetHours: 5.5),
    City(name: 'Agra', country: 'India', region: 'Uttar Pradesh', latitude: 27.1767, longitude: 78.0081, timezoneOffsetHours: 5.5),
    City(name: 'Nashik', country: 'India', region: 'Maharashtra', latitude: 19.9975, longitude: 73.7898, timezoneOffsetHours: 5.5),
    City(name: 'Varanasi', country: 'India', region: 'Uttar Pradesh', latitude: 25.3176, longitude: 82.9739, timezoneOffsetHours: 5.5),
    City(name: 'Srinagar', country: 'India', region: 'Jammu & Kashmir', latitude: 34.0837, longitude: 74.7973, timezoneOffsetHours: 5.5),
    City(name: 'Amritsar', country: 'India', region: 'Punjab', latitude: 31.6340, longitude: 74.8723, timezoneOffsetHours: 5.5),
    City(name: 'Allahabad', country: 'India', region: 'Uttar Pradesh', latitude: 25.4358, longitude: 81.8463, timezoneOffsetHours: 5.5),
    City(name: 'Prayagraj', country: 'India', region: 'Uttar Pradesh', latitude: 25.4358, longitude: 81.8463, timezoneOffsetHours: 5.5),
    City(name: 'Ranchi', country: 'India', region: 'Jharkhand', latitude: 23.3441, longitude: 85.3096, timezoneOffsetHours: 5.5),
    City(name: 'Gwalior', country: 'India', region: 'Madhya Pradesh', latitude: 26.2183, longitude: 78.1828, timezoneOffsetHours: 5.5),
    City(name: 'Jabalpur', country: 'India', region: 'Madhya Pradesh', latitude: 23.1815, longitude: 79.9864, timezoneOffsetHours: 5.5),
    City(name: 'Coimbatore', country: 'India', region: 'Tamil Nadu', latitude: 11.0168, longitude: 76.9558, timezoneOffsetHours: 5.5),
    City(name: 'Vijayawada', country: 'India', region: 'Andhra Pradesh', latitude: 16.5062, longitude: 80.6480, timezoneOffsetHours: 5.5),
    City(name: 'Jodhpur', country: 'India', region: 'Rajasthan', latitude: 26.2389, longitude: 73.0243, timezoneOffsetHours: 5.5),
    City(name: 'Madurai', country: 'India', region: 'Tamil Nadu', latitude: 9.9252, longitude: 78.1198, timezoneOffsetHours: 5.5),
    City(name: 'Raipur', country: 'India', region: 'Chhattisgarh', latitude: 21.2514, longitude: 81.6296, timezoneOffsetHours: 5.5),
    City(name: 'Kota', country: 'India', region: 'Rajasthan', latitude: 25.2138, longitude: 75.8648, timezoneOffsetHours: 5.5),
    City(name: 'Guwahati', country: 'India', region: 'Assam', latitude: 26.1445, longitude: 91.7362, timezoneOffsetHours: 5.5),
    City(name: 'Chandigarh', country: 'India', region: 'Chandigarh', latitude: 30.7333, longitude: 76.7794, timezoneOffsetHours: 5.5),
    City(name: 'Mysore', country: 'India', region: 'Karnataka', latitude: 12.2958, longitude: 76.6394, timezoneOffsetHours: 5.5),
    City(name: 'Mysuru', country: 'India', region: 'Karnataka', latitude: 12.2958, longitude: 76.6394, timezoneOffsetHours: 5.5),
    City(name: 'Gurgaon', country: 'India', region: 'Haryana', latitude: 28.4595, longitude: 77.0266, timezoneOffsetHours: 5.5),
    City(name: 'Gurugram', country: 'India', region: 'Haryana', latitude: 28.4595, longitude: 77.0266, timezoneOffsetHours: 5.5),
    City(name: 'Noida', country: 'India', region: 'Uttar Pradesh', latitude: 28.5355, longitude: 77.3910, timezoneOffsetHours: 5.5),
    City(name: 'Jalandhar', country: 'India', region: 'Punjab', latitude: 31.3260, longitude: 75.5762, timezoneOffsetHours: 5.5),
    City(name: 'Bhubaneswar', country: 'India', region: 'Odisha', latitude: 20.2961, longitude: 85.8245, timezoneOffsetHours: 5.5),
    City(name: 'Thiruvananthapuram', country: 'India', region: 'Kerala', latitude: 8.5241, longitude: 76.9366, timezoneOffsetHours: 5.5),
    City(name: 'Trivandrum', country: 'India', region: 'Kerala', latitude: 8.5241, longitude: 76.9366, timezoneOffsetHours: 5.5),
    City(name: 'Jamshedpur', country: 'India', region: 'Jharkhand', latitude: 22.8046, longitude: 86.2029, timezoneOffsetHours: 5.5),
    City(name: 'Kochi', country: 'India', region: 'Kerala', latitude: 9.9312, longitude: 76.2673, timezoneOffsetHours: 5.5),
    City(name: 'Cochin', country: 'India', region: 'Kerala', latitude: 9.9312, longitude: 76.2673, timezoneOffsetHours: 5.5),
    City(name: 'Dehradun', country: 'India', region: 'Uttarakhand', latitude: 30.3165, longitude: 78.0322, timezoneOffsetHours: 5.5),
    City(name: 'Ajmer', country: 'India', region: 'Rajasthan', latitude: 26.4499, longitude: 74.6399, timezoneOffsetHours: 5.5),
    City(name: 'Jammu', country: 'India', region: 'Jammu & Kashmir', latitude: 32.7266, longitude: 74.8570, timezoneOffsetHours: 5.5),
    City(name: 'Mangalore', country: 'India', region: 'Karnataka', latitude: 12.9141, longitude: 74.8560, timezoneOffsetHours: 5.5),
    City(name: 'Udaipur', country: 'India', region: 'Rajasthan', latitude: 24.5854, longitude: 73.7125, timezoneOffsetHours: 5.5),
    City(name: 'Tirupati', country: 'India', region: 'Andhra Pradesh', latitude: 13.6288, longitude: 79.4192, timezoneOffsetHours: 5.5),
    City(name: 'Kozhikode', country: 'India', region: 'Kerala', latitude: 11.2588, longitude: 75.7804, timezoneOffsetHours: 5.5),
    City(name: 'Calicut', country: 'India', region: 'Kerala', latitude: 11.2588, longitude: 75.7804, timezoneOffsetHours: 5.5),
    City(name: 'Thrissur', country: 'India', region: 'Kerala', latitude: 10.5276, longitude: 76.2144, timezoneOffsetHours: 5.5),
    City(name: 'Shimla', country: 'India', region: 'Himachal Pradesh', latitude: 31.1048, longitude: 77.1734, timezoneOffsetHours: 5.5),
    City(name: 'Gangtok', country: 'India', region: 'Sikkim', latitude: 27.3389, longitude: 88.6065, timezoneOffsetHours: 5.5),
    City(name: 'Itanagar', country: 'India', region: 'Arunachal Pradesh', latitude: 27.0844, longitude: 93.6053, timezoneOffsetHours: 5.5),
    City(name: 'Imphal', country: 'India', region: 'Manipur', latitude: 24.8170, longitude: 93.9368, timezoneOffsetHours: 5.5),
    City(name: 'Shillong', country: 'India', region: 'Meghalaya', latitude: 25.5788, longitude: 91.8933, timezoneOffsetHours: 5.5),
    City(name: 'Aizawl', country: 'India', region: 'Mizoram', latitude: 23.7271, longitude: 92.7176, timezoneOffsetHours: 5.5),
    City(name: 'Kohima', country: 'India', region: 'Nagaland', latitude: 25.6701, longitude: 94.1077, timezoneOffsetHours: 5.5),
    City(name: 'Agartala', country: 'India', region: 'Tripura', latitude: 23.8315, longitude: 91.2868, timezoneOffsetHours: 5.5),
    City(name: 'Dispur', country: 'India', region: 'Assam', latitude: 26.1433, longitude: 91.7898, timezoneOffsetHours: 5.5),
    City(name: 'Puducherry', country: 'India', region: 'Puducherry', latitude: 11.9416, longitude: 79.8083, timezoneOffsetHours: 5.5),
    City(name: 'Pondicherry', country: 'India', region: 'Puducherry', latitude: 11.9416, longitude: 79.8083, timezoneOffsetHours: 5.5),
    City(name: 'Port Blair', country: 'India', region: 'Andaman & Nicobar', latitude: 11.6234, longitude: 92.7265, timezoneOffsetHours: 5.5),
    City(name: 'Faridabad', country: 'India', region: 'Haryana', latitude: 28.4089, longitude: 77.3178, timezoneOffsetHours: 5.5),
    City(name: 'Ghaziabad', country: 'India', region: 'Uttar Pradesh', latitude: 28.6692, longitude: 77.4538, timezoneOffsetHours: 5.5),
    City(name: 'Meerut', country: 'India', region: 'Uttar Pradesh', latitude: 28.9845, longitude: 77.7064, timezoneOffsetHours: 5.5),
    City(name: 'Rajkot', country: 'India', region: 'Gujarat', latitude: 22.3039, longitude: 70.8022, timezoneOffsetHours: 5.5),
    City(name: 'Aurangabad', country: 'India', region: 'Maharashtra', latitude: 19.8762, longitude: 75.3433, timezoneOffsetHours: 5.5),
    City(name: 'Dhanbad', country: 'India', region: 'Jharkhand', latitude: 23.7957, longitude: 86.4304, timezoneOffsetHours: 5.5),
    City(name: 'Solapur', country: 'India', region: 'Maharashtra', latitude: 17.6599, longitude: 75.9064, timezoneOffsetHours: 5.5),
    City(name: 'Hubli', country: 'India', region: 'Karnataka', latitude: 15.3647, longitude: 75.1240, timezoneOffsetHours: 5.5),
    City(name: 'Salem', country: 'India', region: 'Tamil Nadu', latitude: 11.6643, longitude: 78.1460, timezoneOffsetHours: 5.5),
    City(name: 'Tiruchirappalli', country: 'India', region: 'Tamil Nadu', latitude: 10.7905, longitude: 78.7047, timezoneOffsetHours: 5.5),
    City(name: 'Tirunelveli', country: 'India', region: 'Tamil Nadu', latitude: 8.7139, longitude: 77.7567, timezoneOffsetHours: 5.5),
    City(name: 'Howrah', country: 'India', region: 'West Bengal', latitude: 22.5958, longitude: 88.2636, timezoneOffsetHours: 5.5),
    City(name: 'Durgapur', country: 'India', region: 'West Bengal', latitude: 23.5204, longitude: 87.3119, timezoneOffsetHours: 5.5),
    City(name: 'Asansol', country: 'India', region: 'West Bengal', latitude: 23.6739, longitude: 86.9524, timezoneOffsetHours: 5.5),
    City(name: 'Siliguri', country: 'India', region: 'West Bengal', latitude: 26.7271, longitude: 88.3953, timezoneOffsetHours: 5.5),
    City(name: 'Darjeeling', country: 'India', region: 'West Bengal', latitude: 27.0410, longitude: 88.2663, timezoneOffsetHours: 5.5),

    // Goa
    City(name: 'Panaji', country: 'India', region: 'Goa', latitude: 15.4909, longitude: 73.8278, timezoneOffsetHours: 5.5),
    City(name: 'Margao', country: 'India', region: 'Goa', latitude: 15.2832, longitude: 73.9862, timezoneOffsetHours: 5.5),
    City(name: 'Vasco da Gama', country: 'India', region: 'Goa', latitude: 15.3957, longitude: 73.8124, timezoneOffsetHours: 5.5),
    City(name: 'Goa', country: 'India', region: 'Goa', latitude: 15.2993, longitude: 74.1240, timezoneOffsetHours: 5.5),

    // Spiritual / pilgrimage hubs
    City(name: 'Haridwar', country: 'India', region: 'Uttarakhand', latitude: 29.9457, longitude: 78.1642, timezoneOffsetHours: 5.5),
    City(name: 'Rishikesh', country: 'India', region: 'Uttarakhand', latitude: 30.0869, longitude: 78.2676, timezoneOffsetHours: 5.5),
    City(name: 'Mathura', country: 'India', region: 'Uttarakhand', latitude: 27.4924, longitude: 77.6737, timezoneOffsetHours: 5.5),
    City(name: 'Vrindavan', country: 'India', region: 'Uttar Pradesh', latitude: 27.5650, longitude: 77.6593, timezoneOffsetHours: 5.5),
    City(name: 'Ujjain', country: 'India', region: 'Madhya Pradesh', latitude: 23.1765, longitude: 75.7885, timezoneOffsetHours: 5.5),
    City(name: 'Pushkar', country: 'India', region: 'Rajasthan', latitude: 26.4895, longitude: 74.5511, timezoneOffsetHours: 5.5),
    City(name: 'Bodh Gaya', country: 'India', region: 'Bihar', latitude: 24.6960, longitude: 84.9914, timezoneOffsetHours: 5.5),
    City(name: 'Puri', country: 'India', region: 'Odisha', latitude: 19.8135, longitude: 85.8312, timezoneOffsetHours: 5.5),
    City(name: 'Dwarka', country: 'India', region: 'Gujarat', latitude: 22.2394, longitude: 68.9678, timezoneOffsetHours: 5.5),
    City(name: 'Rameshwaram', country: 'India', region: 'Tamil Nadu', latitude: 9.2876, longitude: 79.3129, timezoneOffsetHours: 5.5),
    City(name: 'Tirupati', country: 'India', region: 'Andhra Pradesh', latitude: 13.6288, longitude: 79.4192, timezoneOffsetHours: 5.5),
    City(name: 'Shirdi', country: 'India', region: 'Maharashtra', latitude: 19.7645, longitude: 74.4769, timezoneOffsetHours: 5.5),

    // ----- World cities -----
    // North America
    City(name: 'New York', country: 'USA', region: 'NY', latitude: 40.7128, longitude: -74.0060, timezoneOffsetHours: -5.0),
    City(name: 'Los Angeles', country: 'USA', region: 'CA', latitude: 34.0522, longitude: -118.2437, timezoneOffsetHours: -8.0),
    City(name: 'San Francisco', country: 'USA', region: 'CA', latitude: 37.7749, longitude: -122.4194, timezoneOffsetHours: -8.0),
    City(name: 'Chicago', country: 'USA', region: 'IL', latitude: 41.8781, longitude: -87.6298, timezoneOffsetHours: -6.0),
    City(name: 'Houston', country: 'USA', region: 'TX', latitude: 29.7604, longitude: -95.3698, timezoneOffsetHours: -6.0),
    City(name: 'Seattle', country: 'USA', region: 'WA', latitude: 47.6062, longitude: -122.3321, timezoneOffsetHours: -8.0),
    City(name: 'Boston', country: 'USA', region: 'MA', latitude: 42.3601, longitude: -71.0589, timezoneOffsetHours: -5.0),
    City(name: 'Washington DC', country: 'USA', latitude: 38.9072, longitude: -77.0369, timezoneOffsetHours: -5.0),
    City(name: 'Toronto', country: 'Canada', region: 'ON', latitude: 43.6532, longitude: -79.3832, timezoneOffsetHours: -5.0),
    City(name: 'Vancouver', country: 'Canada', region: 'BC', latitude: 49.2827, longitude: -123.1207, timezoneOffsetHours: -8.0),
    City(name: 'Mexico City', country: 'Mexico', latitude: 19.4326, longitude: -99.1332, timezoneOffsetHours: -6.0),

    // Europe
    City(name: 'London', country: 'UK', latitude: 51.5074, longitude: -0.1278, timezoneOffsetHours: 0.0),
    City(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522, timezoneOffsetHours: 1.0),
    City(name: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050, timezoneOffsetHours: 1.0),
    City(name: 'Madrid', country: 'Spain', latitude: 40.4168, longitude: -3.7038, timezoneOffsetHours: 1.0),
    City(name: 'Rome', country: 'Italy', latitude: 41.9028, longitude: 12.4964, timezoneOffsetHours: 1.0),
    City(name: 'Amsterdam', country: 'Netherlands', latitude: 52.3676, longitude: 4.9041, timezoneOffsetHours: 1.0),
    City(name: 'Moscow', country: 'Russia', latitude: 55.7558, longitude: 37.6173, timezoneOffsetHours: 3.0),
    City(name: 'Istanbul', country: 'Turkey', latitude: 41.0082, longitude: 28.9784, timezoneOffsetHours: 3.0),
    City(name: 'Athens', country: 'Greece', latitude: 37.9838, longitude: 23.7275, timezoneOffsetHours: 2.0),
    City(name: 'Lisbon', country: 'Portugal', latitude: 38.7223, longitude: -9.1393, timezoneOffsetHours: 0.0),
    City(name: 'Dublin', country: 'Ireland', latitude: 53.3498, longitude: -6.2603, timezoneOffsetHours: 0.0),
    City(name: 'Zurich', country: 'Switzerland', latitude: 47.3769, longitude: 8.5417, timezoneOffsetHours: 1.0),
    City(name: 'Vienna', country: 'Austria', latitude: 48.2082, longitude: 16.3738, timezoneOffsetHours: 1.0),
    City(name: 'Prague', country: 'Czech Republic', latitude: 50.0755, longitude: 14.4378, timezoneOffsetHours: 1.0),
    City(name: 'Warsaw', country: 'Poland', latitude: 52.2297, longitude: 21.0122, timezoneOffsetHours: 1.0),
    City(name: 'Stockholm', country: 'Sweden', latitude: 59.3293, longitude: 18.0686, timezoneOffsetHours: 1.0),
    City(name: 'Oslo', country: 'Norway', latitude: 59.9139, longitude: 10.7522, timezoneOffsetHours: 1.0),

    // Middle East
    City(name: 'Dubai', country: 'UAE', latitude: 25.2048, longitude: 55.2708, timezoneOffsetHours: 4.0),
    City(name: 'Abu Dhabi', country: 'UAE', latitude: 24.4539, longitude: 54.3773, timezoneOffsetHours: 4.0),
    City(name: 'Doha', country: 'Qatar', latitude: 25.2854, longitude: 51.5310, timezoneOffsetHours: 3.0),
    City(name: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753, timezoneOffsetHours: 3.0),
    City(name: 'Tehran', country: 'Iran', latitude: 35.6892, longitude: 51.3890, timezoneOffsetHours: 3.5),
    City(name: 'Tel Aviv', country: 'Israel', latitude: 32.0853, longitude: 34.7818, timezoneOffsetHours: 2.0),

    // Asia
    City(name: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, timezoneOffsetHours: 9.0),
    City(name: 'Osaka', country: 'Japan', latitude: 34.6937, longitude: 135.5023, timezoneOffsetHours: 9.0),
    City(name: 'Seoul', country: 'South Korea', latitude: 37.5665, longitude: 126.9780, timezoneOffsetHours: 9.0),
    City(name: 'Beijing', country: 'China', latitude: 39.9042, longitude: 116.4074, timezoneOffsetHours: 8.0),
    City(name: 'Shanghai', country: 'China', latitude: 31.2304, longitude: 121.4737, timezoneOffsetHours: 8.0),
    City(name: 'Hong Kong', country: 'China', latitude: 22.3193, longitude: 114.1694, timezoneOffsetHours: 8.0),
    City(name: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198, timezoneOffsetHours: 8.0),
    City(name: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869, timezoneOffsetHours: 8.0),
    City(name: 'Bangkok', country: 'Thailand', latitude: 13.7563, longitude: 100.5018, timezoneOffsetHours: 7.0),
    City(name: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456, timezoneOffsetHours: 7.0),
    City(name: 'Manila', country: 'Philippines', latitude: 14.5995, longitude: 120.9842, timezoneOffsetHours: 8.0),
    City(name: 'Karachi', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011, timezoneOffsetHours: 5.0),
    City(name: 'Lahore', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587, timezoneOffsetHours: 5.0),
    City(name: 'Islamabad', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479, timezoneOffsetHours: 5.0),
    City(name: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125, timezoneOffsetHours: 6.0),
    City(name: 'Kathmandu', country: 'Nepal', latitude: 27.7172, longitude: 85.3240, timezoneOffsetHours: 5.75),
    City(name: 'Colombo', country: 'Sri Lanka', latitude: 6.9271, longitude: 79.8612, timezoneOffsetHours: 5.5),
    City(name: 'Thimphu', country: 'Bhutan', latitude: 27.4728, longitude: 89.6390, timezoneOffsetHours: 6.0),
    City(name: 'Yangon', country: 'Myanmar', latitude: 16.8409, longitude: 96.1735, timezoneOffsetHours: 6.5),
    City(name: 'Hanoi', country: 'Vietnam', latitude: 21.0285, longitude: 105.8542, timezoneOffsetHours: 7.0),
    City(name: 'Ho Chi Minh City', country: 'Vietnam', latitude: 10.8231, longitude: 106.6297, timezoneOffsetHours: 7.0),

    // Africa
    City(name: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357, timezoneOffsetHours: 2.0),
    City(name: 'Lagos', country: 'Nigeria', latitude: 6.5244, longitude: 3.3792, timezoneOffsetHours: 1.0),
    City(name: 'Nairobi', country: 'Kenya', latitude: -1.2921, longitude: 36.8219, timezoneOffsetHours: 3.0),
    City(name: 'Johannesburg', country: 'South Africa', latitude: -26.2041, longitude: 28.0473, timezoneOffsetHours: 2.0),
    City(name: 'Cape Town', country: 'South Africa', latitude: -33.9249, longitude: 18.4241, timezoneOffsetHours: 2.0),
    City(name: 'Casablanca', country: 'Morocco', latitude: 33.5731, longitude: -7.5898, timezoneOffsetHours: 1.0),

    // Oceania / South America
    City(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093, timezoneOffsetHours: 10.0),
    City(name: 'Melbourne', country: 'Australia', latitude: -37.8136, longitude: 144.9631, timezoneOffsetHours: 10.0),
    City(name: 'Brisbane', country: 'Australia', latitude: -27.4698, longitude: 153.0251, timezoneOffsetHours: 10.0),
    City(name: 'Perth', country: 'Australia', latitude: -31.9505, longitude: 115.8605, timezoneOffsetHours: 8.0),
    City(name: 'Auckland', country: 'New Zealand', latitude: -36.8485, longitude: 174.7633, timezoneOffsetHours: 12.0),
    City(name: 'São Paulo', country: 'Brazil', latitude: -23.5505, longitude: -46.6333, timezoneOffsetHours: -3.0),
    City(name: 'Rio de Janeiro', country: 'Brazil', latitude: -22.9068, longitude: -43.1729, timezoneOffsetHours: -3.0),
    City(name: 'Buenos Aires', country: 'Argentina', latitude: -34.6037, longitude: -58.3816, timezoneOffsetHours: -3.0),
    City(name: 'Santiago', country: 'Chile', latitude: -33.4489, longitude: -70.6693, timezoneOffsetHours: -4.0),
  ];
}
