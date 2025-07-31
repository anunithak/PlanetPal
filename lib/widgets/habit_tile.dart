import 'package:flutter/material.dart';

class HabitTile extends StatefulWidget {
  final String title;
  final Function(bool)? onChanged;

  const HabitTile({super.key, required this.title, this.onChanged});

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  bool isChecked = false;

  void _toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value!;
    });
    if (widget.onChanged != null) {
      widget.onChanged!(isChecked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: isChecked,
      onChanged: _toggleCheckbox,
    );
  }
}
