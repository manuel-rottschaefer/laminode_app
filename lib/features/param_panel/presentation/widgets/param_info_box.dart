import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_info.dart';

class ParamInfoBox extends StatelessWidget {
  final CamParamEntry param;
  final String? description;

  const ParamInfoBox({super.key, required this.param, this.description});

  @override
  Widget build(BuildContext context) {
    return LamiBox(
      backgroundColor: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: ParamInfo(param: param, description: description),
    );
  }
}
