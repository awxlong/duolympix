import 'package:geolocator/geolocator.dart';
// import '../core/constants.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition();
  }

  Stream<double> trackDistance(Position startPosition) {
    return Geolocator.getPositionStream().map((position) {
      return Geolocator.distanceBetween(
        startPosition.latitude,
        startPosition.longitude,
        position.latitude,
        position.longitude,
      ) ; // keep it in Km / AppConstants.milesToMeters;
    });
  }
}