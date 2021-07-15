import 'package:flutter/material.dart';

import 'constants.dart';

class CardTextFieldWidget extends StatelessWidget {
  CardTextFieldWidget({
    @required this.hintText,
    @required this.textInputType,
    @required this.textInputAction,
    @required this.textEditingController,
    this.errorText,
    this.validator,
    @required this.focus,
  });

  final String hintText, errorText;
  Function validator, focus;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: TextFormField(
          textInputAction: textInputAction,
          onFieldSubmitted: focus,
          validator: validator,
          keyboardType: textInputType,
          controller: textEditingController,
          decoration: Constants.kTextFieldInputDecoration.copyWith(hintText: hintText, errorText: errorText),
        ),
      ),
    );
  }
}
