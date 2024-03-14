class SunPosition {
  double azimuth;
  double declination;

  SunPosition({
    required this.azimuth,
    required this.declination
  });
}

class SunData {
  String id;
  String idUser;
  DateTime currentTime;
  SunPosition sunPosition;

  SunData({
    required this.id,
    required this.idUser,
    required this.currentTime,
    required this.sunPosition
  });

  static Map<String, dynamic> toJson(SunData sunData) {
    return {
      'id': sunData.id,
      'idUser': sunData.idUser,
      'currentTime': sunData.currentTime,
      'sunPosition': sunData.sunPosition,
    };
  }

  static SunData fromJson(Map<String, dynamic> json) {
    return SunData(id: json["id"],
      idUser: json["idUser"],
      currentTime: json["currentTime"],
      sunPosition: json["sunPosition"]);
  }
}