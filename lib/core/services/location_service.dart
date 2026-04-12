import 'package:geolocator/geolocator.dart';

class LocationService {

  // 🚀 الدالة دي بتجيب الموقع أو بترمي إيرور لو في مشكلة
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. نتأكد إن الـ GPS (اللوكيشن) شغال في الموبايل أصلاً
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // لو مقفول، هنرمي إيرور عشان الشاشة تطلع رسالة لليوزر يفتحه
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    // 2. نتأكد من صلاحيات التطبيق (Permissions)
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // لو لسه متوافقش عليها، نطلبها من اليوزر
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // لو اليوزر عمل رفض دائم (Don't ask again)
      throw Exception('Location permissions are permanently denied. Please enable them from settings.');
    }

    // 3. نحاول نجيب اخر مكان معروف بسرعة عشان التحميل ମيتاخرش
    Position? lastPosition = await Geolocator.getLastKnownPosition();
    if (lastPosition != null) {
      // شغل بحث دقيق في الخلفية للمرات الجاية بس رجع ده دلوقتي للسرعة
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return lastPosition;
    }

    // 4. لو مفيش، نستنى قراية جديدة بس اخره 5 ثواني عشان الصفحة متفضلش تحمل
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      throw Exception('تعذر الحصول على الموقع الحالي بسرعة. تأكد من جودة الـ GPS.');
    }
  }
}