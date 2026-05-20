import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medinear_app/core/di/global_providers.dart';
import 'package:medinear_app/core/widgets/custom_app_bar.dart';
import 'package:medinear_app/features/home/domain/entities/category_entity.dart';
import 'package:medinear_app/features/home/presentation/widgets/medicine_card.dart';

class CategoryMedicinesScreen extends ConsumerStatefulWidget {
  final CategoryEntity category;

  const CategoryMedicinesScreen({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryMedicinesScreen> createState() => _CategoryMedicinesScreenState();
}

class _CategoryMedicinesScreenState extends ConsumerState<CategoryMedicinesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryMedicinesProvider).fetchMedicines(widget.category.id, refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(categoryMedicinesProvider).fetchMedicines(widget.category.id);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(categoryMedicinesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.category.name,
      ),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : provider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(provider.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(categoryMedicinesProvider).fetchMedicines(widget.category.id, refresh: true);
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : provider.medicines.isEmpty
                  ? const Center(child: Text("No medicines found in this category."))
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(categoryMedicinesProvider).fetchMedicines(widget.category.id, refresh: true);
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: provider.medicines.length + (provider.hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.medicines.length) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final medicine = provider.medicines[index];
                          return MedicineCard(
                            medicine: medicine,
                          );
                        },
                      ),
                    ),
    );
  }
}
