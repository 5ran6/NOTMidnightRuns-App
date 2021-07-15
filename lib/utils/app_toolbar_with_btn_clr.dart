import 'package:flutter/material.dart';

import 'constants.dart';

class ApplicationToolbar_WithClrBtn extends StatelessWidget with PreferredSizeWidget {
  ApplicationToolbar_WithClrBtn({@required this.appbarTitle,@required this.str_button_title,@required this.btn_color,@required this.onBtnPress});

  final String appbarTitle,str_button_title;
  final Color btn_color;
  final Function onBtnPress;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: Text(
        appbarTitle,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
            fontFamily: Constants.app_font_bold),
      ),
      actions: [
        GestureDetector(
          onTap: onBtnPress,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(str_button_title,
              style: TextStyle(
                fontSize: 14,
                color: btn_color
              ),),
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
