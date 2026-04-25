import 'package:flutter/material.dart';

class MedicineModel {
  final String name;
  final String price;
  final String discount;
  final IconData image;

  MedicineModel({
    required this.name,
    required this.price,
    required this.discount,
    required this.image,
  });
}
