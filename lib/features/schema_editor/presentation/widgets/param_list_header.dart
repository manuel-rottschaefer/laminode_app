import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';

class ParamListHeader extends ConsumerWidget {
  final bool isSearchVisible;
  final VoidCallback onToggleSearch;

  const ParamListHeader({
    super.key,
    required this.isSearchVisible,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schemaEditorProvider);
    final allParameters = state.schema.availableParameters;
    final categories = state.schema.categories;
    final showHidden = state.showHiddenParameters;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Parameters', style: Theme.of(context).textTheme.titleSmall),
        Row(
          children: [
            IconButton(
              icon: Icon(
                isSearchVisible ? LucideIcons.searchCode : LucideIcons.search,
                size: 16,
              ),
              onPressed: onToggleSearch,
              constraints: const BoxConstraints(),
              splashRadius: 20,
              color: isSearchVisible
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            IconButton(
              icon: Icon(
                showHidden ? LucideIcons.filter : LucideIcons.filterX,
                size: 16,
              ),
              onPressed: () {
                ref
                    .read(schemaEditorProvider.notifier)
                    .toggleShowHiddenParameters();
              },
              constraints: const BoxConstraints(),
              splashRadius: 20,
              color: !showHidden ? Theme.of(context).colorScheme.primary : null,
              tooltip: showHidden ? "Hide invisible" : "Show all",
            ),
            IconButton(
              icon: const Icon(LucideIcons.plus, size: 16),
              onPressed: () {
                final defaultCat = categories.firstWhere(
                  (c) => c.categoryName == 'default',
                  orElse: () => categories.first,
                );

                final newParam = CamParamEntry(
                  paramName: 'new_param_${allParameters.length + 1}',
                  paramTitle: 'New Parameter',
                  paramDescription: '',
                  quantity: const ParamQuantity(
                    quantityName: 'generic',
                    quantityUnit: '',
                    quantitySymbol: '',
                    quantityType: QuantityType.numeric,
                  ),
                  category: defaultCat,
                  value: 0,
                );
                ref.read(schemaEditorProvider.notifier).addParameter(newParam);
                ref
                    .read(schemaEditorProvider.notifier)
                    .selectParameter(newParam);
              },
              constraints: const BoxConstraints(),
              splashRadius: 20,
            ),
          ],
        ),
      ],
    );
  }
}
