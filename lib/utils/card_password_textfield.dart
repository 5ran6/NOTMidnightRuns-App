import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import 'constants.dart';

class CardPasswordTextFieldWidget extends StatefulWidget {
  CardPasswordTextFieldWidget({
    @required this.hintText,
    @required this.isPasswordVisible,
    this.textEditingController,
    this.validator,
  });

  String hintText;
  bool isPasswordVisible;
  Function validator;
  final TextEditingController textEditingController;

  @override
  _CardTextFieldWidgetState createState() => _CardTextFieldWidgetState();
}

class _CardTextFieldWidgetState extends State<CardPasswordTextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 25.0,
        ),
        child: TextFormField(
          validator: widget.validator,
          controller: widget.textEditingController,
          obscureText: widget.isPasswordVisible,
          decoration: InputDecoration(
              hintStyle: TextStyle(color: Color(Constants.color_hint)),
              hintText: widget.hintText,
              suffixIcon: IconButton(
                  icon: SvgPicture.asset(
                    // Based on passwordVisible state choose the icon
                    widget.isPasswordVisible ? 'images/ic_eye_hide.svg' : 'images/ic_eye.svg',
                    height: ScreenUtil().setHeight(15),
                    width: 15,
                    color: Color(Constants.color_theme),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.isPasswordVisible = !widget.isPasswordVisible;
                    });
                  }),
              errorStyle: TextStyle(fontFamily: Constants.app_font_bold, color: Colors.red),
              border: InputBorder.none),
        ),
      ),
    );
  }
}
