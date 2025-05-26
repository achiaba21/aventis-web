import 'package:flutter/src/widgets/icon_data.dart';
import 'package:web_flutter/model/residence/commodite/commodite.dart';

class MachineALaver extends Commodite {
  bool? machineALaver;

  MachineALaver({String? nom, String? description, this.machineALaver})
    : super(nom: nom, description: description);

  MachineALaver.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    machineALaver = json['machineALaver'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (machineALaver != null) {
      data['machineALaver'] = machineALaver;
    }
    return data;
  }

  @override
  // TODO: implement icon
  IconData? get icon => throw UnimplementedError();

  @override
  // TODO: implement svgPath
  String? get svgPath => throw UnimplementedError();
}
