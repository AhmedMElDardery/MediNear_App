abstract class VisualSearchRemoteDataSource {
  Future<Map<String, dynamic>?> searchMedication(String query);
}

class VisualSearchRemoteDataSourceImpl implements VisualSearchRemoteDataSource {
  @override
  Future<Map<String, dynamic>?> searchMedication(String query) async {
    // Mock API Call
    await Future.delayed(const Duration(seconds: 2));

    return {
      "id": "mock_id_123",
      "name": query.length > 2 ? query : "Panadol Extra",
      "description": "This is a mocked result for the visual search.",
    };
  }
}
