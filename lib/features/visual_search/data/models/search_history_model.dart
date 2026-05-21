import 'package:hive/hive.dart';

class SearchHistoryModel extends HiveObject {
  final String text;
  final String imagePath;
  final DateTime timestamp;
  final String? metadata;

  SearchHistoryModel({
    required this.text,
    required this.imagePath,
    required this.timestamp,
    this.metadata,
  });
}

class SearchHistoryModelAdapter extends TypeAdapter<SearchHistoryModel> {
  @override
  final int typeId = 4; // Ensure this is unique in the app

  @override
  SearchHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryModel(
      text: fields[0] as String,
      imagePath: fields[1] as String,
      timestamp: fields[2] as DateTime,
      metadata: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.metadata);
  }
}
