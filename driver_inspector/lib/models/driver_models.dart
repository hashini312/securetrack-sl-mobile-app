class DriverTripModel {
  final String tripId;
  final String containerNo;
  final String status; // 'On Route', 'Deviated', 'Completed'
  final String destination;
  final String startLocation;
  final String distanceLeft;
  final String eta;
  final int progressPercent;
  final String weight;
  final String type;
  final String sealStatus;
  final double currentLat;
  final double currentLng;

  DriverTripModel({
    required this.tripId,
    required this.containerNo,
    required this.status,
    required this.destination,
    required this.startLocation,
    required this.distanceLeft,
    required this.eta,
    required this.progressPercent,
    required this.weight,
    required this.type,
    required this.sealStatus,
    required this.currentLat,
    required this.currentLng,
  });

  DriverTripModel copyWith({
    String? status,
    String? eta,
    double? currentLat,
    double? currentLng,
  }) {
    return DriverTripModel(
      tripId: tripId,
      containerNo: containerNo,
      status: status ?? this.status,
      destination: destination,
      startLocation: startLocation,
      distanceLeft: distanceLeft,
      eta: eta ?? this.eta,
      progressPercent: progressPercent,
      weight: weight,
      type: type,
      sealStatus: sealStatus,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
    );
  }
}

class DriverNotificationModel {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String type; // 'deviation', 'weather', 'checkpoint', 'traffic'

  DriverNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.type,
  });
}


class DriverProfileModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phone;
  final String licenseNo;
  final String vehicleNo;
  final String company;
  final String rating;
  final String experience;
  final DriverTripModel assignedTrip;

  DriverProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.licenseNo,
    required this.vehicleNo,
    required this.company,
    this.rating = '4.9',
    this.experience = '8 Years',
    required this.assignedTrip,
  });
}

class InspectorProfileModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String badgeNo;
  final String dutyStation;
  final String phone;
  final String role;

  InspectorProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.badgeNo,
    required this.dutyStation,
    required this.phone,
    this.role = 'Customs Field Inspector',
  });
}
