import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_list_item.dart';

class ParamListWidget extends ConsumerStatefulWidget {
  const ParamListWidget({super.key});

  @override
  ConsumerState<ParamListWidget> createState() => _ParamListWidgetState();
}

class _ParamListWidgetState extends ConsumerState<ParamListWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaEditorProvider);
    final allParameters = state.schema.availableParameters;
    final categories = state.schema.categories;
    final selectedParameter = state.selectedParameter;
    final searchQuery = state.parameterSearchQuery.toLowerCase();
    final showHidden = state.showHiddenParameters;
    final filterByCategories = state.filterByCategories;

    final visibleCategoryNames = categories
        .where((c) => c.isVisible)
        .map((c) => c.categoryName)
        .toSet();

    final parameters = allParameters.where((p) {
      final matchesSearch =
          p.paramTitle.toLowerCase().contains(searchQuery) ||
          p.paramName.toLowerCase().contains(searchQuery);
      final matchesVisibility = showHidden || p.isVisible;
      final matchesCategory =
          !filterByCategories ||
          visibleCategoryNames.contains(p.category.categoryName);

      return matchesSearch && matchesVisibility && matchesCategory;
    }).toList();

    return LamiBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: LamiSearch(
              controller: _searchController,
              hintText: "Search parameters...",
              onChanged: (val) {
                ref
                    .read(schemaEditorProvider.notifier)
                    .setParameterSearchQuery(val);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Expanded(
            child: parameters.isEmpty
                ? Center(
                    child: Text(
                      "No parameters found",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : ListView.separated(
                    itemCount: parameters.length,
                    separatorBuilder: (c, i) =>
                        const SizedBox(height: AppSpacing.s),
                    itemBuilder: (context, index) {
                      final param = parameters[index];
                      final isSelected =
                          param.paramName == selectedParameter?.paramName;

                      return ParamListItem(
                        param: param,
                        isSelected: isSelected,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
