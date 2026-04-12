import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تحميل
    // 🚀 دي البيانات الوهمية اللي كانت في الشاشة، نقلناها هنا عشان تبقى شغل API
    return [
      OrderModel(
        id: '101', pharmacyName: 'MediNear', location: 'Egypt, Cairo', status: 'Completed', date: '2024-05-10',
        items: [OrderItemModel(name: "Panadol Extra", quantity: 2, price: 45.0)],
      ),
      OrderModel(
        id: '102', pharmacyName: 'El-Ezaby', location: 'Giza, Dokki', status: 'Pending', date: '2024-05-12',
        items: [OrderItemModel(name: "Vitamin C", quantity: 1, price: 60.0)],
      ),
    ];
  }
}