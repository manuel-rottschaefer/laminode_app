import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin SchemaEditorCategoryManager on Notifier<SchemaEditorState> {
  void addCategory(CamCategoryEntry category) {
    final updatedCategories = [...state.schema.categories, category];
    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: updatedCategories,
        availableParameters: state.schema.availableParameters,
      ),
    );
  }

  void updateCategory(String oldName, CamCategoryEntry newCategory) {
    final updatedCategories = state.schema.categories.map((c) {
      return c.categoryName == oldName ? newCategory : c;
    }).toList();

    // Update parameters that used this category
    final updatedParams = state.schema.availableParameters.map((p) {
      if (p.category.categoryName == oldName) {
        return p.copyWith(category: newCategory);
      }
      return p;
    }).toList();

    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: updatedCategories,
        availableParameters: updatedParams,
      ),
    );
  }

  void deleteCategory(String name) {
    final updatedCategories = state.schema.categories
        .where((c) => c.categoryName != name)
        .toList();

    // Find default category
    final defaultCat = updatedCategories.firstWhere(
      (c) => c.categoryName == 'default',
      orElse: () => updatedCategories.isNotEmpty
          ? updatedCategories.first
          : CamCategoryEntry(
              categoryName: 'default',
              categoryTitle: 'Default',
              categoryColorName: 'blue',
            ),
    );

    final updatedParams = state.schema.availableParameters.map((p) {
      if (p.category.categoryName == name) {
        return p.copyWith(category: defaultCat);
      }
      return p;
    }).toList();

    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: updatedCategories,
        availableParameters: updatedParams,
      ),
      clearSelectedCategory: state.selectedCategory?.categoryName == name,
    );
  }

  void toggleCategoryVisibility(String name) {
    final updatedCategories = state.schema.categories.map((c) {
      if (c.categoryName == name) {
        return c.copyWith(isVisible: !c.isVisible);
      }
      return c;
    }).toList();

    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: updatedCategories,
        availableParameters: state.schema.availableParameters,
      ),
    );
  }

  void setAllCategoriesVisibility(bool isVisible) {
    final updatedCategories = state.schema.categories.map((c) {
      return c.copyWith(isVisible: isVisible);
    }).toList();

    state = state.copyWith(
      schema: CamSchemaEntry(
        schemaName: state.schema.schemaName,
        categories: updatedCategories,
        availableParameters: state.schema.availableParameters,
      ),
    );
  }

  void selectCategory(CamCategoryEntry? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null,
    );
  }
}
