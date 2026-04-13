import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../manager/saved_items_provider.dart';
import '../widgets/saved_item_cards.dart';
import 'package:medinear_app/features/pharmacy/presentation/screens/pharmacy_screen.dart';

class SavedItemsScreen extends StatefulWidget {
  const SavedItemsScreen({super.key});

  @override
  State<SavedItemsScreen> createState() => _SavedItemsScreenState();
}

class _SavedItemsScreenState extends State<SavedItemsScreen> {
  int _selectedTab = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SavedItemsProvider>(context, listen: false).fetchSavedItems();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Saved Items',
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SavedItemsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          return Column(
            children: [
              // ----------- Search Bar & Sort Button -----------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: theme.scaffoldBackgroundColor,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => provider.search(val),
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          hintText: _selectedTab == 0 ? "Search pharmacies..." : "Search medications...",
                          hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.search("");
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          provider.isAscending ? Icons.sort_by_alpha : Icons.sort,
                          color: theme.primaryColor,
                        ),
                        onPressed: () => provider.toggleSort(),
                        tooltip: 'Sort',
                      ),
                    ),
                  ],
                ),
              ),

              // ----------- Tab Buttons -----------
              Container(
                color: theme.scaffoldBackgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('Pharmacies (${provider.savedPharmaciesCount})', 0, theme, provider)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTabButton('Medications (${provider.savedMedicationsCount})', 1, theme, provider)),
                  ],
                ),
              ),

              // ----------- Body List -----------
              Expanded(
                child: _selectedTab == 0
                    ? _buildPharmaciesList(provider, theme)
                    : _buildMedicationsList(provider, theme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(String title, int index, ThemeData theme, SavedItemsProvider provider) {
    final isSelected = _selectedTab == index;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _searchController.clear();
          provider.search("");
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? theme.primaryColor : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPharmaciesList(SavedItemsProvider provider, ThemeData theme) {
    final pharmacies = provider.pharmacies;
    if (pharmacies.isEmpty) return _emptyState("No saved pharmacies found", theme);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        return _buildDismissibleItem(
          key: pharmacy.id,
          theme: theme,
          onDismissed: () {
            provider.removePharmacy(pharmacy);
            _showUndoSnackBar(context, '${pharmacy.name} removed from saved items.', theme, () => provider.undoRemovePharmacy(pharmacy));
          },
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PharmacyScreen(
                    pharmacyId: pharmacy.id,
                    pharmacyName: pharmacy.name,
                  ),
                ),
              );
            },
            child: SavedPharmacyCard(
              pharmacy: pharmacy,
              theme: theme,
              onRemove: () {
                provider.removePharmacy(pharmacy);
                _showUndoSnackBar(context, '${pharmacy.name} removed from saved items.', theme, () => provider.undoRemovePharmacy(pharmacy));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicationsList(SavedItemsProvider provider, ThemeData theme) {
    final medications = provider.medications;
    if (medications.isEmpty) return _emptyState("No saved medications found", theme);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medications.length,
      itemBuilder: (context, index) {
        final medication = medications[index];
        return _buildDismissibleItem(
          key: medication.id,
          theme: theme,
          onDismissed: () {
            provider.removeMedication(medication);
            _showUndoSnackBar(context, '${medication.name} removed from saved items.', theme, () => provider.undoRemoveMedication(medication));
          },
          child: SavedMedicationCard(
            medication: medication,
            theme: theme,
            onRemove: () {
              provider.removeMedication(medication);
              _showUndoSnackBar(context, '${medication.name} removed from saved items.', theme, () => provider.undoRemoveMedication(medication));
            },
          ),
        );
      },
    );
  }

  Widget _buildDismissibleItem({required String key, required ThemeData theme, required VoidCallback onDismissed, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(key),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete_outline, color: Colors.white, size: 30),
        ),
        onDismissed: (_) => onDismissed(),
        child: child,
      ),
    );
  }

  Widget _emptyState(String msg, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context, String message, ThemeData theme, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(label: 'Undo', textColor: theme.primaryColor, onPressed: onUndo),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}