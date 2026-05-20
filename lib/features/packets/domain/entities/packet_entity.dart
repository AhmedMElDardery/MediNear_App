class PacketEntity {
  final String id;
  final String name;
  final String colorHex;
  final int itemCount;
  final DateTime createdAt;

  PacketEntity({
    required this.id,
    required this.name,
    this.colorHex = "#2196F3",
    this.itemCount = 0,
    required this.createdAt,
  });

  PacketEntity copyWith({
    String? name,
    String? colorHex,
    int? itemCount,
  }) {
    return PacketEntity(
      id: id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      itemCount: itemCount ?? this.itemCount,
      createdAt: createdAt,
    );
  }
}
