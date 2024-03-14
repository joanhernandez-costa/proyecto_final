import 'dart:convert';
import 'package:app_final/models/AppUser.dart';
import 'package:app_final/models/Favorite.dart';
import 'package:app_final/models/Restaurant.dart';
import 'package:app_final/models/Review.dart';
import 'package:http/http.dart' as http;
import 'package:app_final/services/TimeService.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Número máximo de intentos para la lógica de reintentos.
  static const int maxRetries = 3;
  // URL base de la API de Supabase, obtenida de las variables de entorno.
  static final String baseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  // Token del usuario para la autorización, puede ser null si no está autenticado.
  static String? userToken;

  /// Función para obtener todos los elementos de una tabla específica.
  // 'T' es el tipo de dato (modelo) que se espera obtener.
  // 'fromJson' es la función que convierte el mapa JSON en una instancia de 'T'.
  static Future<List<T>> getAllItems<T>({int retries = 0, required T Function(Map<String, dynamic>) fromJson}) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';

    Uri uri = Uri.parse('$baseUrl$tableUrl?select=*');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo $T...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('$T obtenidos correctamente. ${response.body}');
        List<T> items = (json.decode(response.body) as List)
          .map((itemJson) => fromJson(itemJson as Map<String, dynamic>))
          .toList();
        return items;
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        return await retryGettingItems(retries, fromJson);
      }
    } catch (e) {
      print('Excepción al obtener $T: $e');
      return await retryGettingItems(retries, fromJson);
    }
  }

  // Función para obtener un elemento específico de una tabla por su identificador.
  static Future<T?> getItem<T>(String itemId, T Function(Map<String, dynamic>) fromJson) async {    
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';
    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$itemId');
    
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY']}',
    };

    print('Obteniendo $T...');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print('$T obtenido correctamente. Respuesta: ${response.body}');
        final data = jsonDecode(response.body);
        return data.length <= 0 ? null : fromJson(data[0]);   
      } else {
        throw Exception('Error al obtener $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Función para eliminar un elemento específico de una tabla por su identificador.
  static Future<void> deleteItem<T>(String itemId) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';
    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$itemId');

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer $userToken',
    };

    print('Eliminando $T...');

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('$T eliminado correctamente.');
      } else {
        throw Exception('Error al eliminar $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Inserta un registro en una tabla cualquiera. Especificar tipo 'T'. (Solo acepta tipos que tengan una tabla en SupaBase)
  static Future<void> postItem<T>(T item, {int retries = 0, required Map<String, dynamic> Function(T) toJson}) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';

    Uri uri = Uri.parse('$baseUrl$tableUrl');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${userToken ?? dotenv.env['SUPABASE_SUPERKEY']}',
    };
    final jsonBody = jsonEncode(toJson(item));

    print('Enviando: $jsonBody');
    
    try {
      final response = await http.post(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 201) {
        print('$T enviado correctamente. ${response.body}');
      } else {
        print('Error: ${response.statusCode}. Respuesta: ${response.body}');
        retryPostingItem(item, toJson, retries);
      }
    } catch (e) {
      print('Excepción al enviar $T: $e');
      retryPostingItem(item, toJson, retries);
    }
  }

  // Reintento de conexión Post a tabla genérica.
  static void retryPostingItem<T>(T item, Map<String, dynamic> Function(T) toJson, int retries) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      await postItem(item, retries: retries + 1, toJson: toJson);
    } else {
      print('No se pudo enviar el elemento después de $maxRetries intentos.');
    }
  }

  // Reintento de conexión Get a tabla genérica.
  static Future<List<T>> retryGettingItems<T>(int retries, T Function(Map<String, dynamic>) fromJson) async {
    if (retries < maxRetries) {
      print('Reintento ${retries + 1} de $maxRetries...');
      await TimeService.waitForSeconds(2);
      return await getAllItems(retries: retries + 1, fromJson: fromJson);
    } else {
      print('No se pudo obtener los elementos después de $maxRetries intentos.');
      List<T> emptyList = [];
      return emptyList;
    }
  }

  // Método para actualizar un registro genérico de una tabla genérica.
  static Future<void> updateItem<T>(T updatedItem, String updatedItemId) async {
    var tableData = typeToTableData[T] ?? {};
    String tableUrl = tableData['url'] ?? '';
    String primaryKey = tableData['primaryKey'] ?? 'id';

    Uri uri = Uri.parse('$baseUrl$tableUrl?$primaryKey=eq.$updatedItemId');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer $userToken',
    };
    final jsonBody = jsonEncode(updatedItem);

    print('Actualizando $T a: $jsonBody');

    try {
      final response = await http.patch(uri, headers: headers, body: jsonBody);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('$T actualizado correctamente.');
      } else {
        print('Error al actualizar $T: ${response.statusCode}. Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Excepción al actualizar $T: $e');
    }
  }

  static Future<List<Restaurant>> getFavoriteRestaurants(String user_id) async {
    Uri uri = Uri.parse('$baseUrl/rest/v1/favorites?favorite_user_id=eq.$user_id');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    print('Obteniendo restaurantes favoritos...');

    try {
      final firstResponse = await http.get(uri, headers: headers);

      if (firstResponse.statusCode == 200) {
        List<Favorite> favorites = (json.decode(firstResponse.body) as List)
          .map((itemJson) => Favorite.fromJson(itemJson as Map<String, dynamic>))
          .toList();
        List<Restaurant> favoriteRestaurants = [];

        print('Restaurantes favoritos obtenidos: longitud = ${favorites.length}');

        for (Favorite favorite in favorites) {
          Restaurant? restaurant = await getItem(favorite.favorite_restaurant_id, Restaurant.fromJson);

          if (restaurant != null) {
            favoriteRestaurants.add(restaurant);
          }
        }
        return favoriteRestaurants;
      } else {
        throw Exception('Error al cargar restaurantes favoritos. ${firstResponse.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<double> getAverageRating(String restaurant_id) async {
    Uri uri = Uri.parse('$baseUrl/rest/v1/reviews?review_restaurant_id=eq.$restaurant_id');
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': dotenv.env['SUPABASE_KEY'] ?? '',
      'Authorization': 'Bearer ${dotenv.env['SUPABASE_KEY'] ?? ''}',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        print(response.body);
        List<Review> reviews = (json.decode(response.body) as List)
        .map((itemJson) => Review.fromJson(itemJson as Map<String, dynamic>))
        .toList();

        if (reviews.isNotEmpty) {
          double totalRating = 0;

          for (Review review in reviews) {
            totalRating += review.rating as double;
          }
          print('media calculada');
          return totalRating / reviews.length;
        } else { 
          return 0;
        }
      } else {
        throw Exception('Error al obtener valoración. ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  // Mapea: tipo 'T' => URL de la tabla que almacena T en la base de datos y el nombre de su clave primaria.
  static const Map<Type, Map<String, String>> typeToTableData = {
    AppUser: {
      'url': '/rest/v1/users',
      'primaryKey': 'user_id'
    },
    Restaurant: {
      'url': '/rest/v1/restaurant',
      'primaryKey': 'restaurant_id'
    },
    Review: {
      'url': '/rest/v1/reviews',
      'primaryKey': 'review_id'
    },
    Favorite: {
      'url': '/rest/v1/favorites',
      'primaryKey': 'favorite_id'
    },
  };
}

