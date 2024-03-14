import 'dart:async';

import 'package:app_final/models/Restaurant.dart';
import 'package:flutter/material.dart';

class RestaurantSearchWidget extends StatefulWidget {
  final List<Restaurant> allRestaurants;
  final void Function(Restaurant) onSelected;

  const RestaurantSearchWidget({Key? key, required this.allRestaurants, required this.onSelected}) : super(key: key);

  @override
  State<RestaurantSearchWidget> createState() => RestaurantSearchWidgetState();
}

class RestaurantSearchWidgetState extends State<RestaurantSearchWidget> {
  TextEditingController searchController = TextEditingController();
  List<Restaurant> filteredRestaurants = [];
  Timer? debounce;

  @override
  void initState() {
    super.initState();

    filteredRestaurants = widget.allRestaurants;
    searchController.addListener(filterRestaurants);
  }

  void onSearchChanged() {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      filterRestaurants();
    });
  }

  void filterRestaurants() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredRestaurants = widget.allRestaurants.where((restaurant) {
        return restaurant.local_name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Buscar',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRestaurants.length,
            itemBuilder: (context, index) {
              final restaurant = filteredRestaurants[index];
              return ListTile(
                title: Text(restaurant.local_name),
                onTap: () {
                  searchController.text = restaurant.local_name;
                  widget.onSelected(restaurant);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }
}