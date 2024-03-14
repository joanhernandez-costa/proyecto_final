

import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/MapService/MapService.dart';
import 'package:app_final/widgets/CustomMapBuilder.dart';
import 'package:app_final/widgets/CustomSearchWidget.dart';
import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  final MapService mapService;

  MapScreen({
    required this.mapService,
  });

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

  bool is3DView = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomMapBuilder(mapService: widget.mapService,),
        // Positioned(
        //   top: 20,
        //   left: MediaQuery.of(context).size.width * 0.1,
        //   right: MediaQuery.of(context).size.width * 0.1,
        //   child: RestaurantSearchWidget(
        //     allRestaurants: Restaurant.restaurants,
        //     onSelected: (restaurant) {
        //       widget.mapService.move(LatLng(restaurant.latitude, restaurant.longitude));
        //     },
        //   ),
        // ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            backgroundColor: ColorService.secondary,
            
            child: Text(
              is3DView ? '3D' : '2D',
              style: const TextStyle(
                decorationThickness: 20.0,
                color: ColorService.textOnPrimary
              ),
            ),
            onPressed: () {
              setState(() {
                is3DView = !is3DView;
                widget.mapService.toggle3DView();
              });
            },
          ),
        ),
      ],
    );
  }
}