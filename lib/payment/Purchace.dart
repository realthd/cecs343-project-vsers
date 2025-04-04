// Placeholder class representing a purchase or subscription details
class Purchase {
  final String productId;
  final DateTime purchaseDate;
  final String? transactionId; // Optional depending on provider
  final bool isActive; // For subscriptions

  Purchase({
    required this.productId,
    required this.purchaseDate,
    this.transactionId,
    required this.isActive,
  });

// Add methods if needed, e.g., fromJson, toJson
}