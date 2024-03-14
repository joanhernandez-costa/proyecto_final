
import 'dart:convert';

import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/SunPositionService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';

class MapService {
  GoogleMapController? mapController;
  CameraPosition? currentCameraPosition;

  LatLngBounds? visibleRegion;
  Set<Marker> markers = Set<Marker>();
  List<String> currentSymbolIds = [];

  Function(Set<Marker>) onMarkersUpdated;
  Function(Restaurant)? onMarkerTapped;

  MapService({required this.onMarkersUpdated});

  void setMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void updateCameraPosition(CameraPosition newCameraPosition) {
    currentCameraPosition = newCameraPosition;
  }
  
  // Mover el mapa a una nueva posición
  void move(LatLng newPosition) {
    mapController?.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
  }

  // Agregar un marcador de Punto de Interés (POI)
  Future<void> addPOIMarker(Restaurant restaurant) async {
    LatLng restaurantPosition = LatLng(restaurant.latitude, restaurant.longitude);
    bool isInSunLight = await SunPositionService.isRestaurantInSunLight(restaurantPosition, DateTime.now()); 

    final String markerIdVal = 'marker_${restaurant.latitude}_${restaurant.longitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: restaurantPosition,
      icon: BitmapDescriptor.defaultMarkerWithHue(isInSunLight ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueBlue),
      onTap: () {
        if (onMarkerTapped != null) {
          onMarkerTapped!(restaurant);
        }
      }
    );

    markers.add(marker);
    onMarkersUpdated(markers);
  }

  void onCameraIdle() async {
    // Obtiene el zoom del mapa
    var zoom = await mapController?.getZoomLevel();   

    if (zoom! > 7) { 
      loadMarkers();
    } else {
      // Eliminar los marcadores si el zoom es demasiado bajo
      removeMarkers();
    }
  }

  // Cargar marcadores basados en la posición central del mapa
  void loadMarkers() async {
    markers.clear();

    LatLngBounds? visibleRegion = await mapController?.getVisibleRegion();
    if (visibleRegion == null) return;

    for (var restaurant in Restaurant.restaurants) {
      LatLng restaurantLocation = LatLng(restaurant.latitude, restaurant.longitude);

      if (visibleRegion.contains(restaurantLocation)) {
        await addPOIMarker(restaurant);
      }
    }

    onMarkersUpdated(markers);
  }

  void removeMarkers() {
    markers.clear();
    onMarkersUpdated(markers);
  }

  void enable3DView() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentCameraPosition!.target,
          zoom: currentCameraPosition!.zoom,
          tilt: 45.0, // Inclinación en grados para la vista 3D
        ),
      ),
    );
  }

  // Deshabilitar la vista en 3D y volver a la vista normal
  void disable3DView() {
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentCameraPosition!.target,
          zoom: currentCameraPosition!.zoom,
          tilt: 0.0, // Inclinación en grados para la vista normal
        ),
      ),
    );
  }

  void toggle3DView() {
    if (currentCameraPosition?.tilt == 0) {
      enable3DView();
    } else {
      disable3DView();
    }
  }

}

