class CheckoutSummaryModel {
  final int? pharmacyId;
  final int? totalItems;
  final double subTotal;
  final double deliveryFee;
  final double taxAmount;
  final double grandTotal;
  
  // Coupon related
  final String? couponCode;
  final String? couponTitle;
  final double? originalSubtotal;
  final double? discountAmount;
  final double? newSubtotal;

  CheckoutSummaryModel({
    this.pharmacyId,
    this.totalItems,
    required this.subTotal,
    required this.deliveryFee,
    required this.taxAmount,
    required this.grandTotal,
    this.couponCode,
    this.couponTitle,
    this.originalSubtotal,
    this.discountAmount,
    this.newSubtotal,
  });

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryModel(
      pharmacyId: json['pharmacy_id'],
      totalItems: json['total_items'],
      subTotal: double.tryParse(json['sub_total']?.toString() ?? json['new_subtotal']?.toString() ?? '0') ?? 0.0,
      deliveryFee: double.tryParse(json['delivery_fee']?.toString() ?? '0') ?? 0.0,
      taxAmount: double.tryParse(json['tax_amount']?.toString() ?? '0') ?? 0.0,
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0') ?? 0.0,
      
      // If the response is from apply-coupon, it has different fields:
      couponCode: json['coupon_code'],
      couponTitle: json['coupon_title'],
      originalSubtotal: json['original_subtotal'] != null ? double.tryParse(json['original_subtotal'].toString()) : null,
      discountAmount: json['discount_amount'] != null ? double.tryParse(json['discount_amount'].toString()) : null,
      newSubtotal: json['new_subtotal'] != null ? double.tryParse(json['new_subtotal'].toString()) : null,
    );
  }
}
