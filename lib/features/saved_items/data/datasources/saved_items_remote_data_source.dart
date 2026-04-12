import '../models/saved_item_models.dart';

class SavedItemsRemoteDataSource {
  Future<Map<String, List<dynamic>>> getSavedItems() async {
    // محاكاة تأخير الـ API
    await Future.delayed(const Duration(milliseconds: 500)); 

    // نفس الداتا اللي كانت في الكود القديم
    final pharmacies = [
      {'name': 'Al-Noor Pharmacy', 'location': 'egypt,salah salem', 'products': '434 Products', 'image': 'assets/images/dr1.jpg', 'isSaved': true},
      {'name': 'El-Seha Pharmacy', 'location': 'egypt,Fayoum', 'products': '123 Products', 'image': 'assets/images/dr2.jpg', 'isSaved': true},
      {'name': 'El-Hayaa Pharmacy', 'location': 'egypt,Alexandria', 'products': '765 Products', 'image': 'assets/images/dr3.jpg', 'isSaved': true},
      {'name': 'Dr. Samir Pharmacy', 'location': 'egypt,Beni_suef', 'products': '156 Products', 'image': 'assets/images/dr4.jpg', 'isSaved': true},
      {'name': 'Dr. Mohamed Pharmacy', 'location': 'egypt,Al-Absiri', 'products': '841 Products', 'image': 'assets/images/dr5.jpg', 'isSaved': true},
    ];

    final medications = [
      {'name': 'Voltaren Emulgel', 'price': '90 EGP', 'available': false, 'image': 'assets/images/medicine_2.png', 'isSaved': true},
      {'name': 'Hypooeh', 'price': '110 EGP', 'available': false, 'image': 'assets/images/medicine_1.png', 'isSaved': true},
      {'name': 'Aspirin 100mg', 'price': '180 EGP', 'available': false, 'image': 'assets/images/medicine_3.png', 'isSaved': true},
      {'name': 'Kollangel', 'price': '200 EGP', 'available': false, 'image': 'assets/images/medicine_4.png', 'isSaved': true},
    ];

    return {
      'pharmacies': pharmacies.map((e) => SavedPharmacyModel.fromJson(e)).toList(),
      'medications': medications.map((e) => SavedMedicationModel.fromJson(e)).toList(),
    };
  }
}