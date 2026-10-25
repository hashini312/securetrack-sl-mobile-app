class ContainerItem {
  final String id;
  final String containerNo;
  final String destination;
  final String currentRoad;
  final String eta;
  final String status; // 'Active', 'Delivered', 'Alert'
  final double distanceLeftKm;
  final double speedKmh;
  final int progressPercent;
  final String sealStatus; // 'Closed & Secure', 'Compromised'
  final String sealId;
  final String weight;
  final String type;
  final String contents;
  final double latitude;
  final double longitude;
  final String transporter;
  final String vehicleNo;
  final String driverName;
  final String rfidTag;

  ContainerItem({
    required this.id,
    required this.containerNo,
    required this.destination,
    required this.currentRoad,
    required this.eta,
    required this.status,
    this.distanceLeftKm = 14.2,
    this.speedKmh = 58.0,
    this.progressPercent = 62,
    this.sealStatus = 'Closed & Secure',
    this.sealId = 'ESEAL-SL-90821',
    this.weight = '24,500 kg',
    this.type = '40ft HC',
    this.contents = 'Industrial Electronics & Machinery',
    this.latitude = 7.0555,
    this.longitude = 79.8797,
    this.transporter = 'Lanka Logistics Ltd',
    this.vehicleNo = 'cp-pt-2943',
    this.driverName = 'Uvindu Bandara (Lic: B-1234567)',
    this.rfidTag = 'TAG-12345',
  });

  factory ContainerItem.fromJson(Map<String, dynamic> json) {
    return ContainerItem(
      id: json['id']?.toString() ?? '1',
      containerNo: json['containerNo'] ?? json['containerId'] ?? 'CONT-LK-001',
      destination: json['destination'] ?? 'Katunayake BOI',
      currentRoad: json['currentRoad'] ?? 'A3 Highway, Ja-Ela',
      eta: json['eta'] ?? '20 mins',
      status: json['status'] ?? 'In Transit',
      distanceLeftKm: (json['distanceLeftKm'] as num?)?.toDouble() ?? 14.2,
      speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 58.0,
      progressPercent: json['progressPercent'] ?? 62,
      sealStatus: json['sealStatus'] ?? 'Closed & Secure',
      sealId: json['sealId'] ?? 'ESEAL-SL-90821',
      weight: json['weight'] ?? '24,500 kg',
      type: json['type'] ?? '40ft HC',
      contents: json['contents'] ?? 'Industrial Electronics & Machinery',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 7.0555,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.8797,
      transporter: json['transporter'] ?? 'Lanka Logistics Ltd',
      vehicleNo: json['vehicleNo'] ?? 'WP-CAD-1234',
      driverName: json['driverName'] ?? 'Sunil Perera (Lic: B-1234567)',
      rfidTag: json['rfidTag'] ?? 'TAG-12345',
    );
  }
}

class AlertNotificationItem {
  final String id;
  final String title;
  final String containerNo;
  final String description;
  final String timeAgo;
  final String type; // 'Critical', 'Warning', 'Info', 'Success'
  final bool isRead;

  AlertNotificationItem({
    required this.id,
    required this.title,
    required this.containerNo,
    required this.description,
    required this.timeAgo,
    required this.type,
    this.isRead = false,
  });
}


class OwnerProfileModel {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String companyName;
  final String phone;
  final List<String> containerNos;

  OwnerProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.companyName,
    required this.phone,
    required this.containerNos,
  });
}
