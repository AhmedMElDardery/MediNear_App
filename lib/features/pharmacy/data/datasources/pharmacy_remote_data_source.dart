import '../models/pharmacy_models.dart';

class PharmacyRemoteDataSource {
  Future<Map<String, List<dynamic>>> getPharmacyDetails(String pharmacyName) async {
    await Future.delayed(const Duration(milliseconds: 600)); // محاكاة الـ API

    final medicines = [
      {'id': 1, 'name': 'valtaren Emulgel', 'oldPrice': 300.0, 'price': 250.0, 'discount': 20, 'rating': 4.5, 'inStock': true, 'notifyAvailable': false, 'isSaved': false, 'image': 'assets/images/medicine_2.jpg'},
      {'id': 2, 'name': 'Hypooeh', 'oldPrice': 320.0, 'price': 220.0, 'discount': 30, 'rating': 4.8, 'inStock': false, 'notifyAvailable': true, 'isSaved': false, 'image': 'assets/images/medicine_6.jpg'},
      {'id': 3, 'name': 'Aspirin 100mg', 'oldPrice': 300.0, 'price': 250.0, 'discount': 15, 'rating': 4.3, 'inStock': true, 'notifyAvailable': false, 'isSaved': false, 'image': 'assets/images/medicine_4.jpg'},
      {'id': 4, 'name': 'Kollangel', 'oldPrice': 280.0, 'price': 230.0, 'discount': 18, 'rating': 4.6, 'inStock': true, 'notifyAvailable': false, 'isSaved': false, 'image': 'assets/images/medicine_5.jpg'},
      {'id': 5, 'name': 'Cough Syrup 100ml', 'oldPrice': 150.0, 'price': 120.0, 'discount': 20, 'rating': 4.2, 'inStock': false, 'notifyAvailable': true, 'isSaved': false, 'image': 'assets/images/medicine_1.jpg'},
    ];

    final doctors = [
      {'id': 1, 'name': 'Dr. Amany Mohamed', 'specialty': 'Cardiologist', 'rating': 4.8, 'isSaved': false, 'image': 'assets/images/dr1.jpg'},
      {'id': 2, 'name': 'Dr. Ahmed Hassan', 'specialty': 'Dermatologist', 'rating': 4.6, 'isSaved': false, 'image': 'assets/images/dr4.jpg'},
      {'id': 3, 'name': 'Dr. Sara Mahmoud', 'specialty': 'Pediatrician', 'rating': 4.7, 'isSaved': false, 'image': 'assets/images/dr3.jpg'},
    ];

    final services = [
      {'id': 1, 'name': 'Blood Pressure Check', 'price': 50.0, 'duration': '15 min', 'isSaved': false, 'image': 'assets/images/blood.jpg'},
      {'id': 2, 'name': 'Diabetes Test', 'price': 100.0, 'duration': '20 min', 'isSaved': false, 'image': 'assets/images/diabetes.jpg'},
      {'id': 3, 'name': 'Cholesterol Test', 'price': 120.0, 'duration': '25 min', 'isSaved': false, 'image': 'assets/images/cholesterol.jpg'},
    ];

    return {
      'medicines': medicines.map((e) => PharmacyMedicineModel.fromJson(e)).toList(),
      'doctors': doctors.map((e) => PharmacyDoctorModel.fromJson(e)).toList(),
      'services': services.map((e) => PharmacyServiceModel.fromJson(e)).toList(),
    };
  }
}