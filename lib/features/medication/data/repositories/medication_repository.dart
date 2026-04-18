import '../datasources/medication_local_data_source.dart';
import '../datasources/medication_remote_data_source.dart';

// العقد الخاص بمستودع بيانات الأدوية
abstract class MedicationRepository {
  Future<List<dynamic>> getMedications();
}

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<dynamic>> getMedications() async {
    try {
      final remoteMeds = await remoteDataSource.fetchPrescriptions();
      await localDataSource.cacheMedications(remoteMeds);
      return remoteMeds;
    } catch (e) {
      return await localDataSource.getCachedMedications();
    }
  }
}