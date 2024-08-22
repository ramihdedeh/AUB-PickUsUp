import 'package:aub_pickusup/main.dart';
import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String labelText;
  final bool obscureText;
  final IconData specIcon;
  final TextEditingController controller1;
  final TextInputType? inputType;
  final FormFieldValidator validatorCustom;
  final EdgeInsetsGeometry formPadding;

  const MyTextFormField(
      {super.key,
      required this.obscureText,
      required this.specIcon,
      required this.controller1,
      required this.labelText,
      this.inputType,
      required this.validatorCustom,
      required this.formPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: formPadding,
      child: TextFormField(
        controller: controller1,
        obscureText: obscureText,
        keyboardType: inputType,
        decoration: InputDecoration(
          errorStyle: const TextStyle(
            color: aubBlue,
            fontSize: 10,
            height: 0.5,
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            borderSide: BorderSide(
              color: aubBlue,
              width: 2,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(
              width: 2,
              color: aubBlue,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            borderSide: BorderSide(width: 0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            borderSide: BorderSide(
              color: aubGrey,
              width: 2,
            ),
          ),
          labelText: labelText,
          fillColor: aubRed,
          filled: true,
          labelStyle: const TextStyle(
            color: aubGrey,
          ),
          prefixIcon: Icon(
            specIcon,
            color: Colors.white,
            size: 22,
          ),
          counterText: '',
        ),
        validator: validatorCustom,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
