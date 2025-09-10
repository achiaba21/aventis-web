import 'package:flutter/material.dart';
import 'package:web_flutter/widget/input/input_field.dart';

class InputDateField extends StatefulWidget {
  const InputDateField({
    super.key,
    this.libelle,
    this.controller,
    this.placeHolder,
    this.onDateSelected,
  });

  final String? libelle;
  final TextEditingController? controller;
  final String? placeHolder;
  final Function(DateTime)? onDateSelected;

  @override
  State<InputDateField> createState() => _InputDateFieldState();
}

class _InputDateFieldState extends State<InputDateField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted = "${picked.day}/${picked.month}/${picked.year}";
      _controller.text = formatted;
      widget.onDateSelected?.call(picked);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickDate(context),
      child: AbsorbPointer(
        child: InputField(
          libelle: widget.libelle,
          controller: _controller,
          placeHolder: widget.placeHolder ?? "Sélectionner une date",
          rightIcon: const Icon(Icons.calendar_today),
        ),
      ),
    );
  }
}
