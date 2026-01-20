import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

enum ParamItemState { schema, search }

class ParamPanelItem {
  final CamParamEntry param;
  final ParamItemState state;

  const ParamPanelItem({required this.param, required this.state});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParamPanelItem &&
          runtimeType == other.runtimeType &&
          param.paramName == other.param.paramName &&
          state == other.state;

  @override
  int get hashCode => param.paramName.hashCode ^ state.hashCode;
}
