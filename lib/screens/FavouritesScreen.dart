import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/screens/RestaurantDetailScreen.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:app_final/services/NavigationService.dart';
import 'package:app_final/services/UserService.dart';
import 'package:flutter/material.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  FavouritesScreenState createState() => FavouritesScreenState();
}

class FavouritesScreenState extends State<FavouritesScreen> {
  List<Restaurant> favoriteRestaurants = [];
  List<String> restaurantRatings = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteRestaurantsAndRatings();
  }

  void loadFavoriteRestaurantsAndRatings() async {
    try {
      var restaurants = await ApiService.getFavoriteRestaurants(UserService.currentUser.value!.id);
      List<String> ratings = [];
     
      for (Restaurant restaurant in restaurants) {
        print('Obteniendo valoración del restaurante ${restaurant.id}');
        num rating = await ApiService.getAverageRating(restaurant.id);
        ratings.add(rating.toString());
      }

      // Actualiza el estado con los nuevos valores
      setState(() {
        favoriteRestaurants = restaurants;
        restaurantRatings = ratings;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favoriteRestaurants.length,
      itemBuilder: (context, index) {

        final restaurant = favoriteRestaurants[index];
        final rating = restaurantRatings[index];

        return InkWell(
          onTap: () => {
            NavigationService.replaceScreen(context, RestaurantDetailScreen(restaurant: restaurant))
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorService.primary, width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        restaurant.restaurant_image_url ?? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/Recurso%2090.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL1JlY3Vyc28gOTAucG5nIiwiaWF0IjoxNzEwMzgyMDMwLCJleHAiOjE3NDE5MTgwMzB9.ncqP-Vw0H1TVk6qJFO2yvby8vDzFmz9khaULF303Hhs&t=2024-03-14T02%3A07%3A09.196Z',
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          restaurant.local_name,
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          restaurant.getParsedAdress(),
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                          ),
                        ),
                        Text(
                          "Valoración: $rating",
                          style: const TextStyle(
                            color: ColorService.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        );
      }, 
    );
  }
}
