import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/models/Review.dart';
import 'package:app_final/services/ApiService.dart';
import 'package:app_final/services/ColorService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:uuid/uuid.dart';

class RestaurantDetailScreen extends StatefulWidget {

  final Restaurant restaurant;

  const RestaurantDetailScreen({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => RestaurantDetailScreenState();
}

class RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  double restaurantRating = 0;
  List<UserReview> userReviews = [];
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRestaurantData();
  }

  void loadRestaurantData() async {
    restaurantRating = await widget.restaurant.getRating();
    List<Review> reviews = await ApiService.getAllItems(fromJson: Review.fromJson);

    List<UserReview> tempUserReviews = [];
    for (Review review in reviews) {
      if (review.review_restaurant_id == widget.restaurant.id) {
        AppUser? user = await ApiService.getItem(review.review_user_id!, AppUser.fromJson);
        if (user != null) {
          tempUserReviews.add(UserReview(review, user));
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay comentarios a cerca de este restaurante.')));
          }
        }
      }
    }

    setState(() {
      userReviews = tempUserReviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorService.background,
      appBar: AppBar(
        backgroundColor: ColorService.secondary,
        title: Text(
          widget.restaurant.local_name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  widget.restaurant.restaurant_image_url ?? 'https://nkmqlnfejowcintlfspl.supabase.co/storage/v1/object/sign/logo/logo_recortado.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJsb2dvL2xvZ29fcmVjb3J0YWRvLnBuZyIsImlhdCI6MTcxMDQ0NzQ2MywiZXhwIjoxNzQxOTgzNDYzfQ.bRW_K_YJvI9SKDSSMMBL_Ydgy6WQaanMzbTXAlAcl9k&t=2024-03-14T20%3A17%3A44.147Z',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.restaurant.getParsedAdress(),
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Valoración de los usuarios:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              RatingBar.builder(
                initialRating: restaurantRating,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: ColorService.primary,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    restaurantRating = rating;
                  });
                },
                ignoreGestures: true,
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Comentarios de los usuarios:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userReviews.length,
                itemBuilder: (context, index) {
                  Review restaurantReview = userReviews[index].review;
                  AppUser user = userReviews[index].user;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImageUrl ?? 'URL de imagen por defecto'),
                    ),
                    title: Text(restaurantReview.comment ?? 'Sin comentarios'),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          labelText: 'Deja tu comentario: ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          // Aquí se manejaría el envío del comentario
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserReview {
  final Review review;
  final AppUser user;

  UserReview(this.review, this.user);
}
