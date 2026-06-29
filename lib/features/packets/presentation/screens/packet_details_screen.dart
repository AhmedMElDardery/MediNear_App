import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_entity.dart';
import 'package:medinear_app/features/packets/domain/entities/packet_item_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PacketDetailsScreen extends ConsumerStatefulWidget {
  final PacketEntity packet;
  const PacketDetailsScreen({super.key, required this.packet});

  @override
  ConsumerState<PacketDetailsScreen> createState() => _PacketDetailsScreenState();
}

class _PacketDetailsScreenState extends ConsumerState<PacketDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  bool _fabOpen = false;
  PacketItemType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(packetsProvider).fetchPacketItems(widget.packet.id);
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
    if (_fabOpen) {
      _fabController.forward();
    } else {
      _fabController.reverse();
    }
  }

  Color get _packetColor {
    try {
      return Color(int.parse(widget.packet.colorHex.replaceAll('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF6C63FF);
    }
  }

  // ─── Filtered items ────────────────────────────────
  List<PacketItemEntity> _filteredItems(List<PacketItemEntity> all) {
    if (_selectedFilter == null) return all;
    return all.where((e) => e.type == _selectedFilter).toList();
  }

  // ─── Stats ─────────────────────────────────────────
  int _countOf(List<PacketItemEntity> items, PacketItemType t) =>
      items.where((e) => e.type == t).length;

  // ─── Add Note ──────────────────────────────────────
  void _showAddNoteDialog() {
    final titleC = TextEditingController();
    final contentC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NoteInputSheet(
        titleController: titleC,
        contentController: contentC,
        onSave: () async {
          if (titleC.text.trim().isEmpty && contentC.text.trim().isEmpty) return;
          final nav = Navigator.of(context);
          final sm = ScaffoldMessenger.of(context);
          nav.pop();
          try {
            await ref.read(packetsProvider).addPacketItem(
              widget.packet.id,
              PacketItemType.note,
              title: titleC.text.trim().isEmpty ? null : titleC.text.trim(),
              content: contentC.text.trim(),
            );
            if (mounted) {
              sm.showSnackBar(_successSnack('packet_add_note'.tr(context)));
            }
          } catch (e) {
            if (mounted) {
              sm.showSnackBar(_errorSnack(e.toString()));
            }
          }
        },
      ),
    );
  }

  // ─── Upload Prescription ───────────────────────────
  Future<void> _uploadPrescription() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SourcePickerSheet(color: _packetColor),
    );
    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1920, maxHeight: 1920);
    if (file == null || !mounted) return;

    final String? noteText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PrescriptionPreviewSheet(imagePath: file.path),
    );
    if (noteText == null || !mounted) return;

    showDialog(context: context, barrierDismissible: false, builder: (_) => const _UploadingDialog());
    final sm = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await ref.read(packetsProvider).addPacketItem(
        widget.packet.id,
        PacketItemType.prescription,
        title: "Prescription".tr(context),
        imagePath: file.path,
      );
      if (noteText.trim().isNotEmpty) {
        await ref.read(packetsProvider).addPacketItem(
          widget.packet.id,
          PacketItemType.note,
          title: "Prescription Note".tr(context),
          content: noteText.trim(),
        );
      }
      nav.pop();
      if (mounted) sm.showSnackBar(_successSnack('packet_rx_uploaded'.tr(context)));
    } catch (e) {
      nav.pop();
      if (mounted) sm.showSnackBar(_errorSnack(e.toString()));
    }
  }

  // ─── Link Medicine ─────────────────────────────────
  void _showLinkMedicineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedicinePickerSheet(
        onMedicineSelected: (id, name) async {
          final sm = ScaffoldMessenger.of(context);
          final successMsg = AppLocalizations.of(context)!.translate('packet_linked', params: {'name': name});
          try {
            await ref.read(packetsProvider).addPacketItem(
              widget.packet.id,
              PacketItemType.medicine,
              title: name,
              medicineId: id,
            );
            if (mounted) sm.showSnackBar(_successSnack(successMsg));
          } catch (e) {
            if (mounted) sm.showSnackBar(_errorSnack(e.toString()));
          }
        },
      ),
    );
  }

  // ─── Delete Item ───────────────────────────────────
  void _deleteItem(PacketItemEntity item) {
    ref.read(packetsProvider).removeItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('packet_item_deleted'.tr(context)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'undo'.tr(context),
          onPressed: () => ref.read(packetsProvider).restoreItem(item),
        ),
      ),
    );
  }

  // ─── View Image Full Screen ────────────────────────
  void _openImageFullScreen(String url, {String? localPath}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _FullScreenImageViewer(imageUrl: url, localPath: localPath),
    ));
  }

  // ─── Helpers ───────────────────────────────────────
  SnackBar _successSnack(String msg) => SnackBar(
    content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(msg))]),
    backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  SnackBar _errorSnack(String msg) => SnackBar(
    content: Row(children: [const Icon(Icons.error_rounded, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text(msg.replaceAll('Exception: ', '')))]),
    backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(packetsProvider);
    final items = provider.currentPacketItems;
    final filtered = _filteredItems(items);
    final color = _packetColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Sliver App Bar ──
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: color,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    ),
                    onPressed: () => ref.read(packetsProvider).fetchPacketItems(widget.packet.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(Icons.folder_rounded, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.packet.name,
                                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                        maxLines: 2, overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'packets_medical_folder'.tr(context),
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stats Row
                            Row(
                              children: [
                                _StatChip(icon: Icons.notes_rounded, label: AppLocalizations.of(context)!.translate('packet_notes_count', params: {'count': _countOf(items, PacketItemType.note).toString()}), color: Colors.amber),
                                const SizedBox(width: 8),
                                _StatChip(icon: Icons.receipt_long_rounded, label: AppLocalizations.of(context)!.translate('packet_rx_count', params: {'count': _countOf(items, PacketItemType.prescription).toString()}), color: Colors.blue),
                                const SizedBox(width: 8),
                                _StatChip(icon: Icons.medication_rounded, label: AppLocalizations.of(context)!.translate('packet_meds_count', params: {'count': _countOf(items, PacketItemType.medicine).toString()}), color: Colors.redAccent),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Filter Chips ──
              SliverToBoxAdapter(
                child: Container(
                  color: isDark ? Colors.transparent : Colors.grey.shade50,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'packet_filter_all'.tr(context),
                          icon: Icons.grid_view_rounded,
                          selected: _selectedFilter == null,
                          color: color,
                          onTap: () => setState(() => _selectedFilter = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'packet_filter_notes'.tr(context),
                          icon: Icons.notes_rounded,
                          selected: _selectedFilter == PacketItemType.note,
                          color: Colors.amber,
                          onTap: () => setState(() => _selectedFilter = _selectedFilter == PacketItemType.note ? null : PacketItemType.note),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'packet_filter_rx'.tr(context),
                          icon: Icons.receipt_long_rounded,
                          selected: _selectedFilter == PacketItemType.prescription,
                          color: Colors.blue,
                          onTap: () => setState(() => _selectedFilter = _selectedFilter == PacketItemType.prescription ? null : PacketItemType.prescription),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'packet_filter_meds'.tr(context),
                          icon: Icons.medication_rounded,
                          selected: _selectedFilter == PacketItemType.medicine,
                          color: Colors.redAccent,
                          onTap: () => setState(() => _selectedFilter = _selectedFilter == PacketItemType.medicine ? null : PacketItemType.medicine),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Body ──
              if (provider.isLoadingItems)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.itemsError != null && items.isEmpty)
                SliverFillRemaining(child: _ErrorWidget(error: provider.itemsError!, onRetry: () => ref.read(packetsProvider).fetchPacketItems(widget.packet.id)))
              else if (filtered.isEmpty)
                SliverFillRemaining(child: _EmptyWidget(filter: _selectedFilter, onAdd: _toggleFab))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildItemCard(filtered[i]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ),

          // ── Expandable FAB ──
          Positioned(
            bottom: 24,
            right: 20,
            child: _ExpandableFab(
              isOpen: _fabOpen,
              controller: _fabController,
              color: color,
              onToggle: _toggleFab,
              onAddNote: () { _toggleFab(); _showAddNoteDialog(); },
              onAddPrescription: () { _toggleFab(); _uploadPrescription(); },
              onLinkMedicine: () { _toggleFab(); _showLinkMedicineSheet(); },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(PacketItemEntity item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('packet_delete_item'.tr(context)),
        content: Text('packet_delete_item_msg'.tr(context)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr(context))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('packet_delete_confirm'.tr(context), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _deleteItem(item);
    }
  }

  // ─── Item Card Builder ──────────────────────────────
  Widget _buildItemCard(PacketItemEntity item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
            const SizedBox(height: 4),
            Text('packet_delete_confirm'.tr(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('packet_delete_item'.tr(context)),
            content: Text('packet_delete_item_msg'.tr(context)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr(context))),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('packet_delete_confirm'.tr(context), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => _deleteItem(item),
      child: _buildCardContent(item),
    );
  }

  Widget _buildCardContent(PacketItemEntity item) {
    switch (item.type) {
      case PacketItemType.note:
        return _NoteCard(item: item, onDelete: () => _confirmAndDelete(item));
      case PacketItemType.prescription:
        return _PrescriptionCard(item: item, onOpenImage: _openImageFullScreen, onDelete: () => _confirmAndDelete(item));
      case PacketItemType.medicine:
        return _MedicineCard(item: item, onDelete: () => _confirmAndDelete(item));
    }
  }
}

// ══════════════════════════════════════════
// � NOTE CARD
// ══════════════════════════════════════════
class _NoteCard extends StatelessWidget {
  final PacketItemEntity item;
  final VoidCallback onDelete;
  const _NoteCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notes_rounded, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title ?? "Note",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy · hh:mm a').format(item.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (item.content != null && item.content!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.content!,
                  style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteDetailSheet(item: item),
    );
  }
}

// ══════════════════════════════════════════
// � PRESCRIPTION CARD
// ══════════════════════════════════════════
class _PrescriptionCard extends StatelessWidget {
  final PacketItemEntity item;
  final void Function(String url, {String? localPath}) onOpenImage;
  final VoidCallback onDelete;
  const _PrescriptionCard({required this.item, required this.onOpenImage, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: hasImage ? () => onOpenImage(item.imageUrl!) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.4)),
          boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.blue, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? "Prescription",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy · hh:mm a').format(item.createdAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (hasImage)
                    GestureDetector(
                      onTap: () => onOpenImage(item.imageUrl!, localPath: !item.imageUrl!.startsWith('http') ? item.imageUrl : null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.zoom_in_rounded, color: Colors.blue, size: 14),
                            SizedBox(width: 4),
                            Text("View", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            // Image
            if (hasImage)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                child: item.imageUrl!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        memCacheWidth: 600,
                        placeholder: (ctx, url) => Container(
                          height: 200,
                          color: Colors.blue.withValues(alpha: 0.05),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          height: 120,
                          color: Colors.blue.withValues(alpha: 0.05),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded, color: Colors.blue, size: 40),
                                SizedBox(height: 8),
                                Text("Image unavailable", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Image.file(
                        File(item.imageUrl!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: 120,
                          color: Colors.blue.withValues(alpha: 0.05),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image_rounded, color: Colors.blue, size: 40),
                                SizedBox(height: 8),
                                Text("Local image unavailable", style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
              )
            else
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2), style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported_rounded, color: Colors.blue, size: 32),
                      SizedBox(height: 6),
                      Text("No image attached", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// � MEDICINE CARD
// ══════════════════════════════════════════
class _MedicineCard extends StatelessWidget {
  final PacketItemEntity item;
  final VoidCallback onDelete;
  const _MedicineCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: Colors.redAccent.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.redAccent.withValues(alpha: 0.2), Colors.redAccent.withValues(alpha: 0.05)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.medication_rounded, color: Colors.redAccent, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? "Medicine",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text("Linked Medicine", style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(item.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// � STAT CHIP (in App Bar)
// ══════════════════════════════════════════
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// � FILTER CHIP
// ══════════════════════════════════════════
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : Colors.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ➕ EXPANDABLE FAB
// ══════════════════════════════════════════
class _ExpandableFab extends StatelessWidget {
  final bool isOpen;
  final AnimationController controller;
  final Color color;
  final VoidCallback onToggle;
  final VoidCallback onAddNote;
  final VoidCallback onAddPrescription;
  final VoidCallback onLinkMedicine;

  const _ExpandableFab({
    required this.isOpen, required this.controller, required this.color,
    required this.onToggle, required this.onAddNote, required this.onAddPrescription, required this.onLinkMedicine,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen) ...[
          _FabItem(icon: Icons.notes_rounded, label: "Add Note", color: Colors.amber, onTap: onAddNote),
          const SizedBox(height: 10),
          _FabItem(icon: Icons.receipt_long_rounded, label: "Upload Prescription", color: Colors.blue, onTap: onAddPrescription),
          const SizedBox(height: 10),
          _FabItem(icon: Icons.medication_rounded, label: "Link Medicine", color: Colors.redAccent, onTap: onLinkMedicine),
          const SizedBox(height: 14),
        ],
        FloatingActionButton(
          onPressed: onToggle,
          backgroundColor: color,
          elevation: 6,
          child: AnimatedBuilder(
            animation: controller,
            builder: (_, __) => Transform.rotate(
              angle: controller.value * 0.785,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }
}

class _FabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FabItem({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// � NOTE INPUT SHEET
// ══════════════════════════════════════════
class _NoteInputSheet extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;
  const _NoteInputSheet({required this.titleController, required this.contentController, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notes_rounded, color: Colors.amber),
                ),
                const SizedBox(width: 10),
                Text("Add a Note", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Title (optional)",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Write your note here...",
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text("Save Note", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// � NOTE DETAIL SHEET
// ══════════════════════════════════════════
class _NoteDetailSheet extends StatelessWidget {
  final PacketItemEntity item;
  const _NoteDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notes_rounded, color: Colors.amber)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item.title ?? "Note", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: "${item.title ?? ''}\n${item.content ?? ''}"));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard!"), behavior: SnackBarBehavior.floating),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(DateFormat('EEEE, MMM dd yyyy · hh:mm a').format(item.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                if (item.content != null && item.content!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
                    ),
                    child: Text(item.content!, style: TextStyle(fontSize: 15, height: 1.6, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// � SOURCE PICKER SHEET
// ══════════════════════════════════════════
class _SourcePickerSheet extends StatelessWidget {
  final Color color;
  const _SourcePickerSheet({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40, height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Text("Upload Prescription", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 8),
          Text("Choose where to upload from", style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.camera_alt_rounded, color: Colors.blue, size: 40),
                      SizedBox(height: 10),
                      Text("Camera", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15)),
                      SizedBox(height: 2),
                      Text("Take a photo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                    ),
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.photo_library_rounded, color: Colors.purple, size: 40),
                      SizedBox(height: 10),
                      Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 15)),
                      SizedBox(height: 2),
                      Text("Pick existing", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════
// � PRESCRIPTION PREVIEW SHEET
// ══════════════════════════════════════════
class _PrescriptionPreviewSheet extends StatefulWidget {
  final String imagePath;
  const _PrescriptionPreviewSheet({required this.imagePath});

  @override
  State<_PrescriptionPreviewSheet> createState() => _PrescriptionPreviewSheetState();
}

class _PrescriptionPreviewSheetState extends State<_PrescriptionPreviewSheet> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                width: 40, height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text("Preview Prescription", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(widget.imagePath), fit: BoxFit.contain, width: double.infinity, height: 320),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Add a note to this prescription (Optional)",
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, null),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text("Retake"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, _noteController.text),
                      icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                      label: const Text("Upload Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ⏳ UPLOADING DIALOG
// ══════════════════════════════════════════
class _UploadingDialog extends StatelessWidget {
  const _UploadingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 5)),
            const SizedBox(height: 20),
            Text("Uploading...", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Text("Please wait while your prescription is uploaded.", textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// � FULL SCREEN IMAGE VIEWER
// ══════════════════════════════════════════
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? localPath;
  const _FullScreenImageViewer({required this.imageUrl, this.localPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Prescription", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Downloading..."), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: localPath != null
              ? Image.file(File(localPath!), fit: BoxFit.contain)
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  memCacheWidth: 800,
                  placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.white, size: 80),
                ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// ❌ ERROR WIDGET
// ══════════════════════════════════════════
class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 80, color: Colors.redAccent.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            Text("Something went wrong", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2))),
              child: Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text("Try Again", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// � EMPTY WIDGET
// ══════════════════════════════════════════
class _EmptyWidget extends StatelessWidget {
  final PacketItemType? filter;
  final VoidCallback onAdd;
  const _EmptyWidget({this.filter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final String title = filter == null ? "Folder is Empty" :
      filter == PacketItemType.note ? "No Notes Yet" :
      filter == PacketItemType.prescription ? "No Prescriptions Yet" : "No Medicines Yet";
    final String subtitle = filter == null ? "Tap the + button to add notes, prescriptions, or medicines." :
      "Switch filter or add a new item.";

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 90, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
            const SizedBox(height: 24),
            if (filter == null)
              ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text("Add Item", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════
// � MEDICINE PICKER SHEET
// ══════════════════════════════════════════
class _MedicinePickerSheet extends ConsumerStatefulWidget {
  final Function(String medicineId, String medicineName) onMedicineSelected;
  const _MedicinePickerSheet({required this.onMedicineSelected});

  @override
  ConsumerState<_MedicinePickerSheet> createState() => _MedicinePickerSheetState();
}

class _MedicinePickerSheetState extends ConsumerState<_MedicinePickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final allMedicines = ref.watch(homeProvider).medicines;
    final filtered = _query.isEmpty ? allMedicines
        : allMedicines.where((m) => m.name.toLowerCase().contains(_query.toLowerCase())).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(10)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medication_rounded, color: Colors.redAccent)),
              const SizedBox(width: 10),
              Text("Link a Medicine", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ]),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: "Search medicines...",
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                suffixIcon: _query.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () => setState(() { _query = ''; _searchController.clear(); })) : null,
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: allMedicines.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.medication_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    const Text("No medicines loaded", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text("Open Home screen first", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ]))
                : filtered.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text("No results for \"$_query\"", style: const TextStyle(color: Colors.grey)),
                      ]))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
                        itemBuilder: (_, i) {
                          final m = filtered[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: m.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(imageUrl: m.imageUrl, width: 52, height: 52, fit: BoxFit.cover, memCacheWidth: 100,
                                      errorWidget: (_, __, ___) => Container(width: 52, height: 52, color: Colors.redAccent.withValues(alpha: 0.1), child: const Icon(Icons.medication_rounded, color: Colors.redAccent)))
                                  : Container(width: 52, height: 52, decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.medication_rounded, color: Colors.redAccent)),
                            ),
                            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            subtitle: Text("${m.price.toStringAsFixed(2)} EGP", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                              child: const Text("Link", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                            ),
                            onTap: () { Navigator.pop(context); widget.onMedicineSelected(m.id, m.name); },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
