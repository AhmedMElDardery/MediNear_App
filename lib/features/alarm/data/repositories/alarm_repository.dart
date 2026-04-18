import '../datasources/alarm_local_data_source.dart';
import '../datasources/alarm_remote_data_source.dart';

// مستودع بيانات المنبه
abstract class AlarmRepository {
  Future<List<dynamic>> fetchAlarms();
  Future<void> addAlarm(dynamic alarm);
}

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDataSource localDataSource;
  final AlarmRemoteDataSource remoteDataSource;

  AlarmRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<dynamic>> fetchAlarms() async {
    // الاعتماد الأساسي هنا على البيانات المحلية لأنها ميزة تعتمد على الجهاز
    return await localDataSource.getSavedAlarms();
  }

  @override
  Future<void> addAlarm(dynamic alarm) async {
    await localDataSource.saveAlarm(alarm);
    // يمكن استدعاء المزامنة السحابية هنا اختيارياً
    // await remoteDataSource.syncAlarms([alarm]);
  }
}