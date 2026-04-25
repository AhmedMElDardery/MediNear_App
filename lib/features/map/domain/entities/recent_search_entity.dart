class RecentSearchEntity {
  final String searchType;
  final String? searchQuery;
  final int? medicineId;
  final String displayText;
  final String timeAgo;
  RecentSearchEntity(
      {required this.searchType,
      this.searchQuery,
      this.medicineId,
      required this.displayText,
      required this.timeAgo});
}
