import 'package:flutter/material.dart';

import 'constants.dart';

class ApplicationToolbar extends StatelessWidget with PreferredSizeWidget{
  ApplicationToolbar({@required this.appbarTitle});
  final String appbarTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      title: Text(appbarTitle,style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 20.0,
          fontFamily: Constants.app_font_bold
      ),),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}