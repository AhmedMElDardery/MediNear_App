// هذا الملف ضروري عشان CheckoutProvider يشتغل
class CheckoutRemoteDataSource {
  
  Future<bool> placeOrder(Map<String, dynamic> orderData) async {
    // محاكاة الاتصال بالسيرفر
    await Future.delayed(const Duration(seconds: 2));
    
    // اطبع الداتا عشان تتأكد إنها واصلة صح
    print("Order Placed: $orderData");
    
    return true; // العملية نجحت
  }
}