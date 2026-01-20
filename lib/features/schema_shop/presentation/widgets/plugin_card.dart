import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PluginCard extends StatelessWidget {
  final PluginManifest plugin;
  final VoidCallback onInstall;
  final bool isInstalling;
  final bool isInstalled;

  const PluginCard({
    super.key,
    required this.plugin,
    required this.onInstall,
    this.isInstalling = false,
    this.isInstalled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LamiBox(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: isInstalled
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isInstalled
                      ? LucideIcons.checkCircle
                      : (plugin.isBasePlugin
                            ? LucideIcons.layers
                            : LucideIcons.package),
                  color: isInstalled
                      ? theme.colorScheme.tertiary
                      : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plugin.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v${plugin.plugin.pluginVersion} by ${plugin.plugin.pluginAuthor}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInstalled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "INSTALLED",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            plugin.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sector: ${plugin.plugin.sector}',
                    style: theme.textTheme.labelSmall,
                  ),
                  if (plugin.application != null)
                    Text(
                      'Target: ${plugin.application!.appName} v${plugin.application!.appVersion}',
                      style: theme.textTheme.labelSmall,
                    ),
                ],
              ),
              if (isInstalling)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isInstalled)
                LamiButton(
                  icon: LucideIcons.check,
                  label: "Update",
                  onPressed: onInstall,
                )
              else
                LamiButton(
                  icon: LucideIcons.download,
                  label: "Install",
                  onPressed: onInstall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
