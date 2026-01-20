import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ApplicationGroupCard extends ConsumerStatefulWidget {
  final ApplicationGroup group;
  final Function(PluginManifest, String) onInstall;
  final Function(String) onRemove;

  const ApplicationGroupCard({
    super.key,
    required this.group,
    required this.onInstall,
    required this.onRemove,
  });

  @override
  ConsumerState<ApplicationGroupCard> createState() =>
      _ApplicationGroupCardState();
}

class _ApplicationGroupCardState extends ConsumerState<ApplicationGroupCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(schemaShopProvider);

    return LamiBox(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.appName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Vendor: ${widget.group.vendor}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.group.appVersions.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            widget.group.appVersions.first.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  LamiColoredBadge(
                    color: Colors.grey.withValues(alpha: 0.8),
                    label: widget.group.sector,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Icon(
                    _isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
            ),
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.group.appVersions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
              ),
              itemBuilder: (context, index) {
                final plugin = widget.group.appVersions[index];
                final isInstalled = state.installedPlugins.any(
                  (p) => p.plugin.pluginID == plugin.plugin.pluginID,
                );
                final appVersion = plugin.application!.appVersion;

                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: LamiColoredBadge(
                            color: theme.colorScheme.primary,
                            label: appVersion,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Plugin Author: ${plugin.plugin.pluginAuthor}",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                "Plugin Version: ${plugin.plugin.pluginVersion}",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isInstalled)
                          Align(
                            alignment: Alignment.center,
                            child: LamiButton(
                              icon: LucideIcons.trash2,
                              label: "Remove",
                              onPressed: () =>
                                  widget.onRemove(plugin.plugin.pluginID),
                            ),
                          )
                        else
                          Align(
                            alignment: Alignment.center,
                            child: LamiButton(
                              icon: LucideIcons.download,
                              label: "Install",
                              onPressed: () {
                                if (plugin.schemas.isEmpty) return;
                                if (plugin.schemas.length == 1) {
                                  widget.onInstall(
                                    plugin,
                                    plugin.schemas.first.id,
                                  );
                                } else {
                                  // Show menu if multiple schemas
                                  showMenu(
                                    context: context,
                                    position: const RelativeRect.fromLTRB(
                                      100,
                                      100,
                                      100,
                                      100,
                                    ),
                                    items: plugin.schemas
                                        .map(
                                          (s) => PopupMenuItem(
                                            value: s.id,
                                            child: Text(
                                              'v${s.version} (${s.releaseDate})',
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ).then((schemaId) {
                                    if (schemaId != null) {
                                      widget.onInstall(plugin, schemaId);
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
