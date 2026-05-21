import '../model/restaurant.dart';

class RestaurantViewModel {
  List<Restaurant> getRestaurants() {
    return [
      Restaurant(
        name: "Parrillada Rivera",
        type: "Parrilla",
        lat: -30.9060,
        lng: -55.5515,
    ),
      Restaurant(
        name: "Pizza Norte",
        type: "Pizzería",
        lat: -30.9045,
        lng: -55.5490,
    ),
      Restaurant(
        name: "Sushi Rivera",
        type: "Sushi",
        lat: -30.9058,
        lng: -55.5520,
    ),
    ];
  }
}