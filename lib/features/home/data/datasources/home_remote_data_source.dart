abstract class HomeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAds();

  // 🚀 لازم نستقبل هنا كمان خط الطول والعرض عشان نبعتهم للـ API
  Future<List<Map<String, dynamic>>> getNearbyPharmacies(
      double lat, double lng);

  // 🚀 ونفس الكلام للأدوية عشان ترجع المتاحة في نفس المنطقة بس
  Future<List<Map<String, dynamic>>> getNearbyMedicines(double lat, double lng);

  Future<List<Map<String, dynamic>>> getCategories(int page, int perPage);
}
