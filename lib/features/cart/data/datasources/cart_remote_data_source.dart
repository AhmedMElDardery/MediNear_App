import '../models/cart_item_model.dart';

class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      CartItemModel(
          id: '1',
          name: "Panadol Extra",
          price: 80.0,
          quantity: 1,
          pharmacyName: "Elborg Pharmacy",
          pharmacyLocation: "Cairo, Egypt"),
      CartItemModel(
          id: '2',
          name: "Vitamin C",
          price: 60.0,
          quantity: 2,
          pharmacyName: "Elborg Pharmacy",
          pharmacyLocation: "Cairo, Egypt"),
      CartItemModel(
          id: '3',
          name: "Omega 3",
          price: 150.0,
          quantity: 1,
          pharmacyName: "Seif Pharmacy",
          pharmacyLocation: "Giza, Dokki"),
      CartItemModel(
          id: '4',
          name: "Mask Pack",
          price: 25.0,
          quantity: 5,
          pharmacyName: "Seif Pharmacy",
          pharmacyLocation: "Giza, Dokki"),
    ];
  }
}
