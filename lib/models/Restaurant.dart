// ignore_for_file: non_constant_identifier_names

import 'package:app_final/services/ApiService.dart';

class Restaurant {
  final String id;
  final String local_name;
  final double latitude;
  final double longitude;
  final String street_type;
  final String adress;
  final String door_number;
  final String? opening_time_LJ;
  final String? closing_time_LJ;
  final String? opening_time_VS;
  final String? closing_time_VS;
  final String? telephone;
  final String? web_page;
  final String? restaurant_image_url;
  final int? n_favorites;

  static List<Restaurant> restaurants = [];

  Restaurant({
    required this.id,
    required this.local_name,
    required this.latitude,
    required this.longitude,
    required this.street_type,
    required this.adress,
    required this.door_number,
    this.opening_time_LJ,
    this.closing_time_LJ,
    this.opening_time_VS,
    this.closing_time_VS,
    this.telephone,
    this.web_page,
    this.restaurant_image_url,
    this.n_favorites,
  });

  static Map<String, dynamic> toJson(Restaurant restaurant) {
    return {
      'restaurant_id': restaurant.id,
      'local_name': restaurant.local_name,
      'latitude': restaurant.latitude,
      'longitude': restaurant.longitude,            
      'street_type': restaurant.street_type,
      'adress': restaurant.adress,
      'door_number': restaurant.door_number,
      'opening_time_LJ': restaurant.opening_time_LJ,
      'closing_time_LJ': restaurant.closing_time_LJ,
      'opening_time_VS': restaurant.opening_time_VS,     
      'closing_time_VS': restaurant.closing_time_VS,
      'telephone': restaurant.telephone,
      'web_page': restaurant.web_page,
      'restaurant_image_url': restaurant.restaurant_image_url,
      'n_favorites': restaurant.n_favorites,
    };
  }

  static Restaurant fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['restaurant_id'] as String,
      local_name: json['local_name'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      street_type: json['street_type'] as String? ?? 'Desconocido',
      adress: json['adress'] as String? ?? 'Desconocido',
      door_number: json['door_number'] as String? ?? 'Desconocido',
      opening_time_LJ: json['opening_time_LJ'] as String? ?? 'Desconocido',
      closing_time_LJ: json['closing_time_LJ'] as String? ?? 'Desconocido',
      opening_time_VS: json['opening_time_VS'] as String? ?? 'Desconocido',
      closing_time_VS: json['closing_time_VS'] as String? ?? 'Desconocido',
      telephone: json['telephone'] as String? ?? 'Desconocido',
      web_page: json['web_page'] as String? ?? 'Desconocido',
      restaurant_image_url: json['restaurant_image_url'] as String?,
      n_favorites: json['n_favorites'] as int? ?? 0,
    );
  }

  String getParsedAdress() {
    String trimmedStreetType = street_type.trim();
    String trimmedAdress = adress.trim();

    return '${toTitleCase(trimmedStreetType)} ${toTitleCase(trimmedAdress)}, $door_number';
  }

  String toTitleCase(String str) {
    return str
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }

  Future<double> getRating() async {
    double rating = await ApiService.getAverageRating(id);
    return rating;
  }
}