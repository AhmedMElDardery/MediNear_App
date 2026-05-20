import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/features/alarm/views/alarm_view.dart';

class AlarmsListScreen extends ConsumerStatefulWidget {
  const AlarmsListScreen({super.key});

  @override
  ConsumerState<AlarmsListScreen> createState() => _AlarmsListScreenState();
}

class _AlarmsListScreenState extends ConsumerState<AlarmsListScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(alarmViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        backgroundColor: bgColor,
        title: 'My Reminders',
      ),
      body: viewModel.savedAlarms.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.only(top: 16, bottom: 100, left: 16, right: 16),
              itemCount: viewModel.savedAlarms.length,
              itemBuilder: (context, index) {
                final alarm = viewModel.savedAlarms[index];
                return _buildAlarmCard(context, alarm, isDarkMode, viewModel);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Clear form before adding a new alarm
          viewModel.clearForm();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlarmView()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm_add_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No reminders yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap the button below to schedule\nyour medication reminders.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, Map<String, dynamic> alarm, bool isDarkMode, dynamic viewModel) {
    List<dynamic> timesList = alarm['times'] ?? [];
    List<dynamic> daysList = alarm['selectedDays'] ?? [];
    String medicationName = alarm['medicationName'] ?? 'Unknown Medication';
    String dosageInfo = alarm['dosageInfo'] ?? '';
    int doseCount = alarm['doseCount'] ?? 1;
    String frequency = alarm['selectedFrequency'] ?? 'Weekly';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.medication_liquid_rounded, color: Theme.of(context).primaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicationName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (dosageInfo.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                dosageInfo,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        viewModel.loadAlarmForEdit(alarm);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AlarmView()),
                        );
                      },
                      icon: Icon(Icons.edit_rounded, color: Colors.blue.shade400),
                    ),
                    IconButton(
                      onPressed: () {
                        viewModel.deleteAlarm(alarm['id']);
                      },
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      timesList.isNotEmpty ? timesList.join(', ') : 'No times set',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    frequency == 'Daily' ? 'Daily' : '${daysList.length} days / week',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.pie_chart_rounded, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  'Dose: $doseCount',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
