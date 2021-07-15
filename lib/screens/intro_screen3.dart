import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/dashboard_screen.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/preference_utils.dart';

import 'login_screen.dart';

class IntroScreen3 extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: screenWidth,
            maxHeight: screenHeight),
        designSize: Size(360, 690),
        orientation: Orientation.portrait);

    return SafeArea(
      child: Scaffold(
        body:
        Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/ic_background_image.png'),
    fit: BoxFit.cover,)
    ),
    alignment: Alignment.center,
    child:

        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Hero(
                        tag: 'App_logo',
                        child: Image.asset('images/ic_intro_logo.png',
                          width: 140.0,
                          height: ScreenUtil().setHeight(40),),
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(200.0),
                      child: Image.asset('images/ic_intro3.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              Languages.of(context).labelScreenIntro3Line1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: Constants.app_font,
                                color: Color(Constants.color_black),
                                fontSize: 25.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                Languages.of(context).labelScreenIntro3Line2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(Constants.color_gray),
                                    fontFamily: Constants.app_font,
                                    fontSize: 16.0),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_upward,
                            color: Color(Constants.color_theme),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        InkWell(
                          onTap: (){

                            PreferenceUtils.setisIntroDone("isIntroDone", true);
                            Navigator.of(context).pushAndRemoveUntil(
                                Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: DashboardScreen(0),
                                ),
                                    (Route<dynamic> route) => false);

                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'SKIP',
                              style: TextStyle(
                                  letterSpacing: 3.0,
                                  color: Color(Constants.color_theme),
                                  fontFamily: Constants.app_font,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Color(Constants.color_theme),
                          ),
                          onPressed: () {
                            PreferenceUtils.setisIntroDone("isIntroDone", true);
                            Navigator.of(context).pushAndRemoveUntil(
                                Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: LoginScreen(),
                                ),
                                    (Route<dynamic> route) => false);
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ]
          ,
        ),),
      ),
    );
  }
}


