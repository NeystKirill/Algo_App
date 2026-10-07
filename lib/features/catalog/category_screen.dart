import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/models/algorithm_info.dart';
import '../algorithms/algorithms_provider.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key, required this.category});

  final AlgoCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final algorithms = ref.watch(algorithmsProvider).where((a) => a.category == category).toList();

    return Scaffold(
      appBar: AppBar(title: Text(category.label)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: algorithms.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final algorithm = algorithms[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => context.push('/topic/${algorithm.id}'),
              title: Text(
                algorithm.title,
                style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.w600),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Chip(
                  label: Text(algorithm.difficulty.label),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
