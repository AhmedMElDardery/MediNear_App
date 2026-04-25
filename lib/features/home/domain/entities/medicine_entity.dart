class MedicineEntity {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  
  // New detail fields
  final String? description;
  final String? composition;
  final String? dosageForm;
  final String? packageSize;
  final String? usageInstructions;
  final List<String>? gallery;

  MedicineEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.description,
    this.composition,
    this.dosageForm,
    this.packageSize,
    this.usageInstructions,
    this.gallery,
  });
}
