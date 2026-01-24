import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ShopEmptyState extends StatelessWidget {
  final bool isSearch;
  final SchemaShopState state;
  final VoidCallback onRetry;

  const ShopEmptyState({
    super.key,
    required this.isSearch,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnectionError = state.hasConnectionError;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnectionError
                  ? LucideIcons.wifiOff
                  : (isSearch ? LucideIcons.search : LucideIcons.packageOpen),
              size: 32,
              color: isConnectionError
                  ? theme.colorScheme.error.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              isConnectionError
                  ? "Unable to connect to LamiNode"
                  : (isSearch
                        ? "No matching plugins found"
                        : "No plugins available yet"),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              isConnectionError
                  ? "Please check your backend connection or internet access."
                  : (isSearch
                        ? "Try adjusting your search terms or sector filters."
                        : "The plugin store is currently empty. Check back later!"),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (state.hasError && !isConnectionError) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
            if (isConnectionError) ...[
              const SizedBox(height: AppSpacing.l),
              LamiButton(
                icon: LucideIcons.refreshCw,
                label: "Try Again",
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
