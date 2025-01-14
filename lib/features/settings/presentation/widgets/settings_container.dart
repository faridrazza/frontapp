import 'package:flutter/material.dart';
import 'package:frontapp/features/settings/domain/models/settings_item.dart';
import 'package:frontapp/features/settings/presentation/widgets/settings_list_item.dart';

class SettingsContainer extends StatelessWidget {
  final List<SettingsItem> items;

  const SettingsContainer({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) => SettingsListItem(item: item)).toList(),
      ),
    );
  }
}