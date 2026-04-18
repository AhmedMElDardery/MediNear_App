import 'package:flutter/material.dart';
import 'package:medinear_app/features/medication/data/models/medication_model.dart';
import 'package:medinear_app/features/medication/views/widgets/medication_card.dart';
import 'package:medinear_app/features/wallet/view_models/wallet_view_model.dart';
import 'package:medinear_app/features/wallet/views/widgets/custom_button.dart';
import 'package:provider/provider.dart';


// 🚨 السطر اللي كان ناقص ومسبب كل المشاكل:
class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    // جلب الـ ViewModel
    final viewModel = Provider.of<WalletViewModel>(context);

    return Scaffold(
      // ✅ جعل الخلفية ديناميكية تتبع الثيم (Light/Dark)
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        elevation: 0,
        title: const Text('Wallet'), 
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // زر الإضافة
            CustomButton(
              label: 'Add New', 
              icon: Icons.add, 
              onPressed: () {
                viewModel.addMedication(
                  MedicationModel(
                    id: DateTime.now().toString(),
                    name: 'New Medication',
                    description: 'Take one pill daily.',
                    imagePath: 'assets/med1.png',
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            
            // الفلاتر المتفاعلة (ChoiceChips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: viewModel.filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: viewModel.selectedFilter == filter,
                      selectedColor: Theme.of(context).primaryColor,
                      onSelected: (val) => viewModel.updateFilter(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            
            // القائمة الديناميكية
            Expanded(
              child: viewModel.medications.isEmpty 
                ? const Center(child: Text("No medications added yet.")) 
                : ListView.builder(
                    itemCount: viewModel.medications.length,
                    itemBuilder: (context, index) {
                      final med = viewModel.medications[index];
                      return MedicationCard(
                        medication: med,
                        onDelete: () => viewModel.deleteMedication(med.id),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
} // ✅ إغلاق الكلاس