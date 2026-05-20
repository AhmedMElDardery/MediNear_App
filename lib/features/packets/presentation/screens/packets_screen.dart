import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/routes/routes.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/features/packets/presentation/widgets/folder_card_widget.dart';

class PacketsScreen extends ConsumerStatefulWidget {
  const PacketsScreen({super.key});

  @override
  ConsumerState<PacketsScreen> createState() => _PacketsScreenState();
}

class _PacketsScreenState extends ConsumerState<PacketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packetsProvider).fetchPackets();
    });
  }

  void _showCreateFolderDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedColor = "#2196F3"; // Default Blue

    final List<String> colorOptions = [
      "#2196F3", "#4CAF50", "#FF5252", "#9C27B0", "#FF9800", "#607D8B"
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create New Folder",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Folder Name (e.g. Chronic Meds)",
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.folder_rounded, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Choose Color",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: colorOptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final hex = colorOptions[index];
                        final color = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                        final isSelected = hex == selectedColor;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedColor = hex;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected ? Border.all(color: Theme.of(context).textTheme.bodyLarge!.color!, width: 3) : null,
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (nameController.text.trim().isNotEmpty) {
                          final navigator = Navigator.of(context);
                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                          try {
                            await ref.read(packetsProvider).createPacket(nameController.text.trim(), selectedColor);
                            navigator.pop();
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(content: Text('Folder created successfully!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                            );
                          } catch (e) {
                            navigator.pop();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Create Folder",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(packetsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Medical Packets",
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFolderDialog,
        icon: const Icon(Icons.create_new_folder_rounded, color: Colors.white),
        label: const Text("New Packet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: provider.isLoadingPackets
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search packets...",
                        prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                        suffixIcon: const Icon(Icons.mic_rounded, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildFilterChip("All", true),
                      const SizedBox(width: 8),
                      _buildFilterChip("Recent", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("Favorites", false),
                      const SizedBox(width: 8),
                      _buildFilterChip("Shared", false),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: provider.packets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.folder_off_rounded, size: 80, color: Theme.of(context).dividerColor),
                              const SizedBox(height: 16),
                              Text("No folders yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color)),
                              const SizedBox(height: 8),
                              Text("Create your first medical packet to start organizing.", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: provider.packets.length,
                          itemBuilder: (context, index) {
                            final packet = provider.packets[index];
                            return Dismissible(
                              key: Key(packet.id),
                              direction: DismissDirection.up,
                              background: Container(
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.bottomCenter,
                                padding: const EdgeInsets.only(bottom: 20),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 32),
                              ),
                              onDismissed: (direction) {
                                ref.read(packetsProvider).deletePacket(packet.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Folder deleted successfully!'), behavior: SnackBarBehavior.floating),
                                );
                              },
                              child: FolderCardWidget(
                                packet: packet,
                                onTap: () {
                                  context.push(AppRoutes.packetDetails, extra: packet);
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
