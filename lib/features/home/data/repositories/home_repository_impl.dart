import 'package:medinear_app/features/home/data/datasources/home_remote_data_source.dart';
import 'package:medinear_app/features/home/domain/entities/ad_entity.dart';
import 'package:medinear_app/features/home/domain/entities/medicine_entity.dart';
import 'package:medinear_app/features/home/domain/entities/pharmacy_entity.dart';
import 'package:medinear_app/features/home/domain/entities/category_entity.dart';
import 'package:medinear_app/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<List<AdEntity>> getAds() async {
    final data = await remote.getAds();
    return data.map((e) {
      // 1. Get raw image and icon values
      final rawImg = e["image"]?.toString() ?? '';
      final rawIcon = e["icon"]?.toString() ?? e["logo"]?.toString() ?? rawImg;
      
      // 2. Safely parse full URLs
      final fullImg = (rawImg.isNotEmpty && !rawImg.startsWith('http')) 
          ? 'https://medinear-eg.com/storage/$rawImg' : rawImg;
          
      final fullIcon = (rawIcon.isNotEmpty && !rawIcon.startsWith('http')) 
          ? 'https://medinear-eg.com/storage/$rawIcon' : rawIcon;

      // 3. Robust Coupon Parser
      String? couponCode;
      if (e["coupon_code"] != null) {
        couponCode = e["coupon_code"].toString();
      } else if (e["coupon"] is Map) {
        couponCode = e["coupon"]["code"]?.toString() ?? e["coupon"]["coupon_code"]?.toString();
      } else if (e["coupon"] != null && e["coupon"].toString().isNotEmpty) {
        couponCode = e["coupon"].toString();
      }

      return AdEntity(
        id: e["id"]?.toString() ?? '',
        imageUrl: fullImg,
        title: e["title"]?.toString() ?? '',
        redirectUrl: e["link"]?.toString() ?? e["url"]?.toString() ?? '',
        description: e["description"]?.toString() ?? e["desc"]?.toString(),
        backgroundColor: e["color"]?.toString() ?? e["background_color"]?.toString() ?? e["bg_color"]?.toString(),
        iconUrl: fullIcon,
        coupon: couponCode,
      );
    }).toList();
  }

  @override
  Future<List<PharmacyEntity>> getNearbyPharmacies(
      double lat, double lng) async {
    final data = await remote.getNearbyPharmacies(lat, lng);
    return data.map((e) {
      final img = e["logo"]?.toString() ??
          e["image"]?.toString() ??
          e["pharmacy_logo"]?.toString() ??
          e["pharmacy_image"]?.toString();
      final fullImg = (img != null && img.isNotEmpty)
          ? (img.startsWith('http')
              ? img
              : 'https://medinear-eg.com/storage/$img')
          : '';

      return PharmacyEntity(
        id: e["id"]?.toString() ?? '',
        name: e["pharmacy_name"]?.toString() ?? 'Unknown',
        image: fullImg,
        address: e['address']?.toString() ?? '',
        phone: e['phone']?.toString(),
        workingHours: e['working_hours']?.toString(),
        distance: e['distance'] != null
            ? "${double.tryParse(e['distance'].toString())?.toStringAsFixed(2) ?? e['distance']} km"
            : null,
      );
    }).toList();
  }

  @override
  Future<List<MedicineEntity>> getNearbyMedicines(
      double lat, double lng) async {
    final data = await remote.getNearbyMedicines(lat, lng);
    return data.map((e) {
      final img = e["image"]?.toString();
      final fullImg = (img != null && img.isNotEmpty)
          ? (img.startsWith('http')
              ? img
              : 'https://medinear-eg.com/storage/$img')
          : '';

      final pivotPrice =
          e["pivot"] != null ? e["pivot"]["price"]?.toString() : null;
      final officialPrice = e["official_price"]?.toString();
      final finalPriceStr = pivotPrice ?? officialPrice ?? '0';

      return MedicineEntity(
        id: e["id"]?.toString() ?? '', // ✅ int → String
        name: e["name"]?.toString() ?? 'Unknown',
        imageUrl: fullImg,
        price: num.tryParse(finalPriceStr)?.toDouble() ?? 0.0,
        description: e["description"]?.toString() ?? e["desc"]?.toString() ?? "يستخدم لتخفيف الألم الخفيف إلى المتوسط مثل الصداع، ألم الأسنان، آلام الدورة الشهرية، وآلام الجسم. كما يساعد على خفض الحرارة.",
        composition: e["composition"]?.toString() ?? "باراسيتامول 500 مجم\nكافيين 65 مجم",
        dosageForm: e["dosage_form"]?.toString() ?? "أقراص",
        packageSize: e["package_size"]?.toString() ?? e["package"]?.toString() ?? "20 قرص",
        usageInstructions: e["usage_instructions"]?.toString() ?? e["usage"]?.toString() ?? "قرص كل 6 ساعات عند الحاجة.\nلا تتجاوز 8 أقراص في اليوم.",
        gallery: e["gallery"] != null ? List<String>.from(e["gallery"]) : (fullImg.isNotEmpty ? [fullImg, fullImg, fullImg] : []),
      );
    }).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategories(int page, int perPage) async {
    final rawData = await remote.getCategories(page, perPage);
    return rawData.map((e) {
      String rawImg = e["image"]?.toString() ?? e["icon"]?.toString() ?? e["logo"]?.toString() ?? '';
      final fullImg = (rawImg.isNotEmpty && !rawImg.startsWith('http')) 
          ? 'https://medinear-eg.com/storage/$rawImg' : rawImg;
          
      return CategoryEntity(
        id: e["id"]?.toString() ?? '',
        name: e["name"]?.toString() ?? '',
        image: fullImg,
      );
    }).toList();
  }
}
