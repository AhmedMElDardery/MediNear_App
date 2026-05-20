import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:medinear_app/core/theme/app_colors.dart';
import '../view_models/alarm_view_model.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/core/di/global_providers.dart';

class AlarmView extends ConsumerStatefulWidget {
  const AlarmView({super.key});

  @override
  ConsumerState<AlarmView> createState() => _AlarmViewState();
}

class _AlarmViewState extends ConsumerState<AlarmView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alarmViewModelProvider).fetchMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(alarmViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        backgroundColor: bgColor,
        title: viewModel.editingAlarmId != null ? 'Edit Reminder' : 'New Reminder',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroSection(context, viewModel, isDarkMode),
            const SizedBox(height: 24),
            _buildUnifiedSettings(context, viewModel, isDarkMode),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16.0, 
          right: 16.0, 
          bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : MediaQuery.of(context).padding.bottom + 16,
          top: 16,
        ),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => viewModel.saveReminder(context),
            child: const Text(
              'Save Reminder',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, AlarmViewModel viewModel, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medication_liquid_rounded,
                    color: Theme.of(context).primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Medication Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          viewModel.isLoadingMedicines
              ? const Center(child: CircularProgressIndicator())
              : Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return viewModel.availableMedicines
                        .map((e) => e as Map<String, dynamic>)
                        .where((Map<String, dynamic> option) {
                      final name = option['name']?.toString().toLowerCase() ?? '';
                      return name.contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['name']?.toString() ?? '',
                  onSelected: (Map<String, dynamic> selection) {
                    viewModel.updateMedicationName(selection['name']?.toString() ?? '');
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    if (viewModel.medication.medicationName.isNotEmpty &&
                        textEditingController.text.isEmpty) {
                      textEditingController.text =
                          viewModel.medication.medicationName;
                    }
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      onChanged: (val) => viewModel.updateMedicationName(val),
                      decoration: InputDecoration(
                        hintText: 'Search Medication...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? Colors.grey.shade900
                            : Colors.grey.shade50,
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: viewModel.medication.dosageInfo,
            onChanged: (val) => viewModel.updateDosageInfo(val),
            decoration: InputDecoration(
              hintText: 'Dosage Instruction (e.g. 1 pill after lunch)',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.edit_note_rounded,
                  color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedSettings(BuildContext context, AlarmViewModel viewModel, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // TIME SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: Colors.grey.shade400),
                    const SizedBox(width: 12),
                    const Text('Schedule Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          if(context.mounted) viewModel.addTime(picked.format(context));
                        }
                      },
                      icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor, size: 28),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (viewModel.times.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.times.asMap().entries.map((entry) {
                      final index = entry.key;
                      final time = entry.value;
                      final isMuted = viewModel.isMuted(index);
                      return GestureDetector(
                        onTap: () => viewModel.toggleVolume(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isMuted ? Colors.grey.shade200 : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(time, style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMuted ? Colors.grey.shade500 : Theme.of(context).primaryColor,
                              )),
                              if (viewModel.medication.medicationName.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text('- ${viewModel.medication.medicationName} (${viewModel.doseCount})', 
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isMuted ? Colors.grey.shade500 : Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                              const SizedBox(width: 6),
                              Icon(isMuted ? Icons.notifications_off_rounded : Icons.notifications_active_rounded, 
                                size: 16, 
                                color: isMuted ? Colors.grey.shade500 : Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                   const SizedBox(height: 12),
                   Text("No times scheduled yet.", style: TextStyle(color: Colors.grey.shade400)),
                ]
              ],
            ),
          ),
          
          Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),

          // START DATE SECTION
          ListTile(
            leading: Icon(Icons.calendar_month_rounded, color: Colors.grey.shade400),
            title: const Text('Start Date', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(viewModel.startDate, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                viewModel.updateStartDate("${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}");
              }
            },
          ),

          Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),

          // REPEAT SECTION
          ListTile(
            leading: Icon(Icons.repeat_rounded, color: Colors.grey.shade400),
            title: const Text('Repeat', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(viewModel.selectedFrequency, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
            onTap: () {
              _showRepeatBottomSheet(context, viewModel, isDarkMode);
            },
          ),
          
          if (viewModel.selectedFrequency == 'Weekly') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
                  int dayIndex = entry.key + 1; // 1 to 7
                  bool isSelected = viewModel.selectedDays.contains(dayIndex);
                  return GestureDetector(
                    onTap: () => viewModel.toggleDay(dayIndex),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade500,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          Divider(height: 1, color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),

          // DOSE COUNT SECTION
          ListTile(
            leading: Icon(Icons.pie_chart_rounded, color: Colors.grey.shade400),
            title: const Text('Dose Count', style: TextStyle(fontWeight: FontWeight.w600)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => viewModel.decrementDose(),
                  icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).primaryColor),
                ),
                Text('${viewModel.doseCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => viewModel.incrementDose(),
                  icon: Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showRepeatBottomSheet(BuildContext context, AlarmViewModel viewModel, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Frequency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...viewModel.frequencies.map((freq) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(freq, style: const TextStyle(fontSize: 16)),
                  trailing: viewModel.selectedFrequency == freq
                      ? Icon(Icons.check_circle_rounded, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () {
                    viewModel.updateFrequency(freq);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
