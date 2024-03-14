import 'dart:math';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/MapService/Utils.dart';
import 'package:flutter/material.dart';

class ShadowCastService {
  SunPositionService sunService = SunPositionService();

/*
  // Hacer que esta función reciba el id de un edficio y un DateTime, entonces obtener el perímetro
  MapPolygon getShadowProjection(WorldPosition position, DateTime localTime) {
    double solarElevation = sunService.getSunElevation(position, localTime);
    double solarAzimuth = sunService.calculateSolarAzimuth(position, localTime);
    ///////////Obtener perimeterPoints y height de HERE
    List<GeoCoordinates> shadowPerimeter = calculateShadowProjection(perimeterPoints, height, solarAzimuth, solarElevation);
    return createShadowPolygon(shadowPerimeter)!;
  }


  List<GeoCoordinates> calculateShadowProjection(
    List<GeoCoordinates> perimeterPoints,
    double height,
    double solarAzimuth,
    double solarElevation) {
    List<GeoCoordinates> shadowPerimeter = [];

    // Calcula la longitud de la sombra
    double shadowLength = height * tan(Utils.degreesToRadians(90 - solarElevation));

    // Calcula la dirección de la sombra en radianes
    double shadowDirection = Utils.degreesToRadians(solarAzimuth + 180) % (2 * pi);

    // Para cada punto del perímetro, calcula la proyección de la sombra
    for (var point in perimeterPoints) {
      double shadowPointLatitude = point.latitude + shadowLength * cos(shadowDirection);
      double shadowPointLongitude = point.longitude + shadowLength * sin(shadowDirection);

      shadowPerimeter.add(GeoCoordinates(shadowPointLatitude, shadowPointLongitude));
    }

    return shadowPerimeter;
  }

  MapPolygon? createShadowPolygon(List<GeoCoordinates> shadowPerimeter) {
    GeoPolygon geoPolygon;
    try {
      geoPolygon = GeoPolygon(shadowPerimeter);
    } on InstantiationException {
      return null;
    }

    Color fillColor = ColorService.secondary;
    MapPolygon mapPolygon = MapPolygon(geoPolygon, fillColor);

    return mapPolygon;
  }
  */
}
