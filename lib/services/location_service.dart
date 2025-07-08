import 'package:geolocator/geolocator.dart';
import 'package:solo_leveling/core/constants.dart';

/// Service for handling location-related functionality
class LocationService {
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  // Add distance filter (10 meters) and accuracy
  Stream<double> trackDistance(Position startPosition) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        distanceFilter: 10, // 10 meter minimum change
        accuracy: LocationAccuracy.best,
      ),
    ).map((position) {
      final meters = Geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        position.latitude,
        position.longitude,
      );
      return (meters / AppConstants.milesToMeters); // Convert to miles with 2 decimal precision
    }).map((miles) => double.parse(miles.toStringAsFixed(2)));
  }
}