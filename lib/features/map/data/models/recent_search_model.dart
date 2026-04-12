import '../../domain/entities/recent_search_entity.dart';
class RecentSearchModel extends RecentSearchEntity {
  RecentSearchModel({required super.searchType, super.searchQuery, super.medicineId, required super.displayText, required super.timeAgo});
  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      searchType: json['search_type']?.toString() ?? 'medicine',
      searchQuery: json['search_query']?.toString(),
      medicineId: json['medicine_id'] is int ? json['medicine_id'] : int.tryParse(json['medicine_id']?.toString() ?? ''),
      displayText: json['display_text']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }
}