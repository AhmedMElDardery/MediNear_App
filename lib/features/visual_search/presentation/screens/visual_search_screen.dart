import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medinear_app/core/localization/app_localizations.dart';
import '../providers/visual_search_provider.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../../visual_search_dependency_injection.dart';

class VisualSearchScreen extends ConsumerStatefulWidget {
  const VisualSearchScreen({super.key});

  @override
  ConsumerState<VisualSearchScreen> createState() => _VisualSearchScreenState();
}

class _VisualSearchScreenState extends ConsumerState<VisualSearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(visualSearchChangeNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'vs_title'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: theme.scaffoldBackgroundColor.withValues(alpha: 0.7)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBody(context, provider, isDark, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, VisualSearchProvider provider, bool isDark, ThemeData theme) {
    if (provider.state == VisualSearchState.loading) {
      return _buildLoadingState(context, theme);
    }
    if (provider.state == VisualSearchState.error) {
      return _buildErrorState(context, provider, isDark, theme);
    }
    if (provider.state == VisualSearchState.success) {
      return _buildSuccessState(context, provider, isDark, theme);
    }
    return _buildInitialState(context, provider, isDark, theme);
  }

  Widget _buildInitialState(BuildContext context, VisualSearchProvider provider, bool isDark, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        // Premium Scan Card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                      : [Colors.white, const Color(0xFFF8FBFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      Icon(CupertinoIcons.viewfinder_circle_fill, size: 55, color: theme.colorScheme.primary),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'vs_smart_scan'.tr(context),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textTheme.bodyLarge?.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'vs_choose_type'.tr(context),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grid of 4 options
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildScanOptionCard(
                        context,
                        title: 'vs_scan_box'.tr(context),
                        icon: CupertinoIcons.cube_box_fill,
                        color: theme.colorScheme.primary,
                        onTap: () async {
                          final source = await ImageSourceBottomSheet.show(context);
                          if (source != null) provider.startVisualSearch(source);
                        },
                      ),
                      _buildScanOptionCard(
                        context,
                        title: 'vs_read_rx'.tr(context),
                        icon: CupertinoIcons.doc_text_viewfinder,
                        color: Colors.blueAccent,
                        onTap: () async {
                          final source = await ImageSourceBottomSheet.show(context);
                          if (source != null) provider.startPrescriptionScan(source);
                        },
                      ),
                      _buildScanOptionCard(
                        context,
                        title: 'vs_pill_id'.tr(context),
                        icon: Icons.medication,
                        color: Colors.purpleAccent,
                        onTap: () async {
                          final source = await ImageSourceBottomSheet.show(context);
                          if (source != null) provider.startPillIdentification(source);
                        },
                      ),
                      _buildScanOptionCard(
                        context,
                        title: 'vs_counterfeit'.tr(context),
                        icon: CupertinoIcons.shield_lefthalf_fill,
                        color: Colors.redAccent,
                        onTap: () async {
                          final source = await ImageSourceBottomSheet.show(context);
                          if (source != null) provider.startCounterfeitCheck(source);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Food Interaction Button (Full Width)
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        final source = await ImageSourceBottomSheet.show(context);
                        if (source != null) provider.startFoodInteractionCheck(source);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.orange,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_menu, color: Colors.orange),
                          const SizedBox(width: 10),
                          Text(
                            'vs_food_analyzer'.tr(context),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 10)),

        // History Header
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'vs_history_title'.tr(context),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.translate('vs_history_count',
                        params: {'count': provider.history.length.toString()}),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // History Body
        if (provider.history.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.archivebox, size: 40, color: theme.dividerColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'vs_no_history'.tr(context),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = provider.history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Dismissible(
                      key: Key(item.key.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => provider.deleteHistoryItem(item),
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 28),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.05),
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => provider.openHistoryItem(item),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Hero(
                                    tag: 'image_${item.imagePath}',
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        File(item.imagePath),
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 70,
                                          height: 70,
                                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                          child: Icon(CupertinoIcons.photo,
                                              color: theme.colorScheme.primary, size: 30),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.text,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                            color: theme.textTheme.bodyLarge?.color,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              CupertinoIcons.clock,
                                              size: 14,
                                              color: theme.textTheme.bodyMedium?.color
                                                  ?.withValues(alpha: 0.5),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              DateFormat('MMM dd, hh:mm a').format(item.timestamp),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: theme.textTheme.bodyMedium?.color
                                                    ?.withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(CupertinoIcons.arrow_right,
                                        size: 18, color: theme.colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: provider.history.length,
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildLoadingState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  strokeWidth: 8,
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(CupertinoIcons.viewfinder, size: 30, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'vs_analyzing'.tr(context),
            style: TextStyle(
              fontSize: 20,
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'vs_ai_extracting'.tr(context),
            style: TextStyle(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, VisualSearchProvider provider, bool isDark, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.exclamationmark_square_fill, color: theme.colorScheme.error, size: 55),
            ),
            const SizedBox(height: 28),
            Text(
              'vs_error_title'.tr(context),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 12),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5, color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: provider.reset,
                icon: const Icon(CupertinoIcons.refresh_thick, color: Colors.white),
                label: Text('vs_retry'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  elevation: 0,
                  shadowColor: theme.colorScheme.error.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOptionCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoxResultWithDetails(
    BuildContext context,
    VisualSearchProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    final details = provider.showTranslation
        ? provider.translatedDetails
        : provider.medicineDetails;
    final name = '${provider.searchResult!['name']}';
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Scanned Image ──────────────────────────────────────
        if (provider.currentImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.file(
                  provider.currentImage!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.photo, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text('vs_image_scanned'.tr(context),
                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),

        // ── Medicine Name Header ───────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor.withValues(alpha: 0.15), primaryColor.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.medication_rounded, color: primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (details != null && details['generic_name'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${details['generic_name']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Translate Button ───────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: provider.isTranslating ? null : provider.toggleTranslation,
            icon: provider.isTranslating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                  )
                : Icon(
                    provider.showTranslation ? Icons.language : Icons.translate,
                    color: primaryColor,
                    size: 20,
                  ),
            label: Text(
              provider.isTranslating
                  ? 'vs_translating'.tr(context)
                  : provider.showTranslation
                      ? 'vs_translate_to_en'.tr(context)
                      : 'vs_translate_to_ar'.tr(context),
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Details Section ────────────────────────────────────
        Text(
          'vs_med_details_title'.tr(context),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),

        if (provider.isLoadingDetails)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            child: Column(
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                Text(
                  'vs_med_loading_details'.tr(context),
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          )
        else if (provider.detailsError != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_circle, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.detailsError ?? 'vs_details_error'.tr(context),
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                TextButton(
                  onPressed: provider.retryLoadDetails,
                  child: Text('vs_retry_details'.tr(context),
                      style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        else if (details != null) ...[
          _buildDetailCard(context, isDark, theme,
              icon: Icons.category_rounded,
              color: Colors.blueAccent,
              label: 'vs_med_category'.tr(context),
              value: '${details['category']}'),
          const SizedBox(height: 10),
          _buildDetailCard(context, isDark, theme,
              icon: Icons.medical_information_rounded,
              color: Colors.teal,
              label: 'vs_med_indications'.tr(context),
              value: '${details['indications']}'),
          const SizedBox(height: 10),
          _buildDetailCard(context, isDark, theme,
              icon: Icons.schedule_rounded,
              color: primaryColor,
              label: 'vs_med_dosage'.tr(context),
              value: '${details['dosage']}'),
          const SizedBox(height: 10),
          _buildDetailCard(context, isDark, theme,
              icon: Icons.factory_rounded,
              color: Colors.blueGrey,
              label: 'vs_med_manufacturer'.tr(context),
              value: '${details['manufacturer']}'),
          const SizedBox(height: 10),
          _buildDetailCard(context, isDark, theme,
              icon: Icons.inventory_2_rounded,
              color: Colors.brown,
              label: 'vs_med_storage'.tr(context),
              value: '${details['storage']}'),
          const SizedBox(height: 10),
          _buildDetailCard(context, isDark, theme,
              icon: Icons.block_rounded,
              color: Colors.deepOrange,
              label: 'vs_med_contraindications'.tr(context),
              value: '${details['contraindications']}'),
          const SizedBox(height: 10),
          // Side Effects list
          if (details['side_effects'] is List && (details['side_effects'] as List).isNotEmpty)
            _buildListDetailCard(
              context, isDark, theme,
              icon: CupertinoIcons.exclamationmark_triangle_fill,
              color: Colors.orange,
              label: 'vs_med_side_effects'.tr(context),
              items: List<String>.from(details['side_effects']),
            ),
          const SizedBox(height: 10),
          // Warnings list
          if (details['warnings'] is List && (details['warnings'] as List).isNotEmpty)
            _buildListDetailCard(
              context, isDark, theme,
              icon: CupertinoIcons.shield_fill,
              color: Colors.red,
              label: 'vs_med_warnings'.tr(context),
              items: List<String>.from(details['warnings']),
            ),
          const SizedBox(height: 10),

          // ── NEW FIELDS ───────────────────────────────────────────────────
          if (details['pregnancy_category'] != null && details['pregnancy_category'] != 'Not available') ...[
            _buildDetailCard(context, isDark, theme, 
              icon: Icons.pregnant_woman_rounded, color: Colors.pink, 
              label: 'vs_med_pregnancy_category'.tr(context), value: '${details['pregnancy_category']}'),
            const SizedBox(height: 10),
          ],
          if (details['food_interactions'] != null && details['food_interactions'] != 'Not available') ...[
            _buildDetailCard(context, isDark, theme, 
              icon: Icons.restaurant_rounded, color: Colors.amber.shade700, 
              label: 'vs_med_food_interactions'.tr(context), value: '${details['food_interactions']}'),
            const SizedBox(height: 10),
          ],
          if (details['mechanism_of_action'] != null && details['mechanism_of_action'] != 'Not available') ...[
            _buildDetailCard(context, isDark, theme, 
              icon: Icons.settings_suggest_rounded, color: Colors.indigo, 
              label: 'vs_med_mechanism'.tr(context), value: '${details['mechanism_of_action']}'),
            const SizedBox(height: 10),
          ],
          if (details['overdose'] != null && details['overdose'] != 'Not available') ...[
            _buildDetailCard(context, isDark, theme, 
              icon: Icons.warning_amber_rounded, color: Colors.redAccent, 
              label: 'vs_med_overdose'.tr(context), value: '${details['overdose']}'),
            const SizedBox(height: 10),
          ],
          if (details['prescription_needed'] != null) ...[
            _buildDetailCard(context, isDark, theme, 
              icon: Icons.receipt_long_rounded, color: Colors.purpleAccent, 
              label: 'vs_med_prescription'.tr(context), 
              value: details['prescription_needed'] == true ? 'vs_med_prescription_yes'.tr(context) : 'vs_med_prescription_no'.tr(context)),
            const SizedBox(height: 10),
          ],
          
          // Lists
          if (details['interactions'] is List && (details['interactions'] as List).isNotEmpty) ...[
            _buildListDetailCard(context, isDark, theme, 
              icon: Icons.compare_arrows_rounded, color: Colors.deepOrangeAccent, 
              label: 'vs_med_interactions'.tr(context), items: List<String>.from(details['interactions'])),
            const SizedBox(height: 10),
          ],
          if (details['alternatives'] is List && (details['alternatives'] as List).isNotEmpty) ...[
            _buildListDetailCard(context, isDark, theme, 
              icon: Icons.swap_horiz_rounded, color: Colors.green, 
              label: 'vs_med_alternatives'.tr(context), items: List<String>.from(details['alternatives'])),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.06)),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.5,
                    )),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDetailCard(
    BuildContext context,
    bool isDark,
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String label,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: isDark ? 0.1 : 0.06)),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Text(label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context, VisualSearchProvider provider, bool isDark, ThemeData theme) {

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(CupertinoIcons.checkmark_seal_fill, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 28),
            Text(
              'vs_success_title'.tr(context),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 24),

            // Prescription Result
            if (provider.prescriptionResult != null)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.prescriptionResult!.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final med = provider.prescriptionResult![index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.medication, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${med['name']}',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                              ),
                              if (med['dosage'] != null && med['dosage'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('${med['dosage']}', style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 13)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )

            // Box Result — Rich Details
            else if (provider.searchResult != null)
              _buildBoxResultWithDetails(context, provider, isDark, theme)


            // Pill Result
            else if (provider.pillResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
                        : [Colors.white, const Color(0xFFF3E8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.purple.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.medication, size: 40, color: Colors.purple),
                    const SizedBox(height: 16),
                    Text('${provider.pillResult!['name']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        AppLocalizations.of(context)!.translate('vs_confidence', params: {'value': '${provider.pillResult!['confidence']}'}),
                        style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('${provider.pillResult!['description']}', textAlign: TextAlign.center, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8), height: 1.5)),
                  ],
                ),
              )

            // Counterfeit Result
            else if (provider.counterfeitResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: provider.counterfeitResult!['is_authentic']
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: provider.counterfeitResult!['is_authentic'] ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      provider.counterfeitResult!['is_authentic']
                          ? CupertinoIcons.checkmark_shield_fill
                          : CupertinoIcons.exclamationmark_shield_fill,
                      size: 40,
                      color: provider.counterfeitResult!['is_authentic'] ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.counterfeitResult!['is_authentic']
                          ? 'vs_authentic'.tr(context)
                          : 'vs_counterfeit_warning'.tr(context),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: provider.counterfeitResult!['is_authentic'] ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('${provider.counterfeitResult!['analysis']}', textAlign: TextAlign.center, style: TextStyle(color: theme.textTheme.bodyMedium?.color, height: 1.5)),
                  ],
                ),
              )

            // Food Interaction Result
            else if (provider.foodInteractionResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.restaurant, size: 40, color: Colors.orange),
                    const SizedBox(height: 16),
                    Text('vs_food_analysis_title'.tr(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: theme.textTheme.bodyLarge?.color)),
                    const SizedBox(height: 16),
                    Text('${provider.foodInteractionResult}', style: TextStyle(color: theme.textTheme.bodyMedium?.color, height: 1.6)),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Drug Interactions Check
            if (provider.prescriptionResult != null && provider.prescriptionResult!.length > 1) ...[
              if (provider.interactionsResult != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: provider.interactionsResult!.contains('آمن') || provider.interactionsResult!.toLowerCase().contains('safe')
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.interactionsResult!.contains('آمن') || provider.interactionsResult!.toLowerCase().contains('safe')
                          ? Colors.green.withValues(alpha: 0.3)
                          : Colors.orange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.interactionsResult!.contains('آمن') || provider.interactionsResult!.toLowerCase().contains('safe')
                                ? CupertinoIcons.checkmark_shield_fill
                                : CupertinoIcons.exclamationmark_triangle_fill,
                            color: provider.interactionsResult!.contains('آمن') || provider.interactionsResult!.toLowerCase().contains('safe')
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'vs_interaction_result_title'.tr(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: provider.interactionsResult!.contains('آمن') || provider.interactionsResult!.toLowerCase().contains('safe')
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        provider.interactionsResult!,
                        style: TextStyle(height: 1.5, color: theme.textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isCheckingInteractions ? null : () => provider.checkInteractions(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: provider.isCheckingInteractions
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.exclamationmark_shield_fill, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                'vs_interaction_check_btn'.tr(context),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (provider.prescriptionResult != null && provider.prescriptionResult!.isNotEmpty) {
                    if (provider.prescriptionResult!.length == 1) {
                      provider.showDetailsForMedicine(provider.prescriptionResult![0]['name']);
                    } else {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (ctx) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text('اختر الدواء لعرض تفاصيله وبدائله', 
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                              ),
                              ...provider.prescriptionResult!.map((med) => ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.medication, color: Colors.green),
                                ),
                                title: Text('${med['name']}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                subtitle: med['dosage'] != null ? Text('${med['dosage']}', style: TextStyle(color: theme.textTheme.bodyMedium?.color)) : null,
                                onTap: () {
                                  Navigator.pop(ctx);
                                  provider.showDetailsForMedicine(med['name']);
                                },
                              )),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      );
                    }
                  } else {
                    provider.reset();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 0,
                  shadowColor: Colors.green.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'vs_view_details'.tr(context),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: provider.reset,
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  'vs_scan_another'.tr(context),
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
