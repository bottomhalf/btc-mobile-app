import 'package:conference/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BtTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final String? Function(String?) onValidate;
  final Function(String?) onChange;
  final bool isNumeric;
  final Color color;
  final Widget? trailingIcon;

  const BtTextField.text({
    super.key,
    required this.placeholder,
    required this.controller,
    required this.onValidate,
    required this.onChange,
    required this.color,
    this.trailingIcon,
  })
      : assert(true),
        isNumeric = false;

  const BtTextField.numeric({
    super.key,
    required this.placeholder,
    required this.color,
    required this.controller,
    required this.onValidate,
    required this.onChange,
    this.trailingIcon,
  })
      : assert(true),
        isNumeric = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      key: key,
      maxLength: 40,
      style: TextStyle(
          color: color,
      ),
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      controller: controller,
      decoration: AppConfig.instance.getTextFieldDecoration(
        placeholder: placeholder,
        trailingIcon: trailingIcon,
      ),
      validator: onValidate,
      onChanged: onChange,
    );
  }
}
