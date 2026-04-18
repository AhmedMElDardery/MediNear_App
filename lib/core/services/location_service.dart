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
      // 🚀 أضفنا تأخير بسيط هنا عشان لو اليوزر لسه مسجل دخول والصفحة بتفتح،
      // الانيميشن بتاع الصفحة ميمنعش ظهور نافذة الصلاحيات في الأندرويد
      await Future.delayed(const Duration(milliseconds: 500));

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
    Position? lastPosition;
    try {
      lastPosition = await Geolocator.getLastKnownPosition()
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      lastPosition = null;
    }
    
    if (lastPosition != null) {
      // شغل بحث دقيق في الخلفية للمرات الجاية بس رجع ده دلوقتي للسرعة
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      return lastPosition;
    }

    // 4. لو مفيش، دي أول مرة نطلب الموقع فلازم نستنى قراية جديدة
    // هنخلي الدقة low عشان الموبايل يلقط الإشارة بسرعة من أبراج الاتصال أو الواي فاي ومياخدش وقت،
    // وهندي الموبايل فرصة 15 ثانية بدل 5 عشان الأندرويد أحيانا بياخد وقت يصحى الـ GPS
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 15),
      ).timeout(const Duration(seconds: 16));
    } catch (_) {
      throw Exception('تعذر الحصول على الموقع الحالي بسرعة. تأكد من جودة الـ GPS.');
    }
  }
}