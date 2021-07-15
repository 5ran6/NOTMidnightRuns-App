import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/about_app_screen.dart';
import 'package:mealup/screens/about_company_screen.dart';
import 'package:mealup/screens/change_password_1.dart';
import 'package:mealup/screens/change_password_user.dart';
import 'package:mealup/screens/feedback_and_support_screen.dart';
import 'package:mealup/screens/languages_screen.dart';
import 'package:mealup/screens/privacy_policy_screen.dart';
import 'package:mealup/screens/terms_of_use_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/localization/model/language_data.dart';
import 'edit_personal_information.dart';
import 'login_screen.dart';
import 'manage_your_location.dart';
import 'sliverlist_demo.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context).screenSetting,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: EditProfileInformation()));
                            },
                            str_menuName:
                                Languages.of(context).labelEditPersonalInfo),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ManageYourLocation()));
                            },
                            str_menuName:
                                Languages.of(context).labelManageYourLocation),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: ChangePasswordUser()));
                            },
                            str_menuName:
                                Languages.of(context).labelChangePassword),
                        SettingMenuWidget(
                            onClick: () {
                              // _showDialog(context);
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: LanguagesScreen()));
                            },
                            str_menuName: Languages.of(context).labelLanguage),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutApp()));
                            },
                            str_menuName: Languages.of(context).labelAboutApp),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: AboutCompanyScreen()));
                            },
                            str_menuName:
                                Languages.of(context).labelAboutCompany),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: PrivacyPolicyScreen()));
                            },
                            str_menuName:
                                Languages.of(context).labelPrivacyPolicy),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: TermsOfUseScreen()));
                            },
                            str_menuName: Languages.of(context).labelTermofuse),
                        SettingMenuWidget(
                            onClick: () {
                              Navigator.of(context).push(Transitions(
                                  transitionType: TransitionType.fade,
                                  curve: Curves.bounceInOut,
                                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                                  widget: FeedbackAndSupportScreen()));
                            },
                            str_menuName:
                                Languages.of(context).labelFeedbacknSup),
                        InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(Languages.of(context).labelConfirmLogout),
                                    content: Text(Languages.of(context).labelAreYouSureLogout),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text(Languages.of(context).labelYES),
                                        onPressed: () {
                                          SharedPreferenceUtil.putBool(Constants.isLoggedIn, false);
                                          SharedPreferenceUtil.clear();
                                          Navigator.of(context).pushAndRemoveUntil(Transitions(
                                            transitionType: TransitionType.fade,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: LoginScreen(),
                                          ), (Route<dynamic> route) => false);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(Languages.of(context).labelNO),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            height: 40,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15, left: 20, right: 20),
                                    child: Container(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        Languages.of(context).labelLogout,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: Constants.app_font),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 30, bottom: 50),
                          child: Text(
                            Languages.of(context).labelMealupAppVersion +
                                SharedPreferenceUtil.getString(Constants
                                    .appSetting_android_customer_version),
                            style: TextStyle(
                                color: Color(Constants.color_gray),
                                fontSize: ScreenUtil().setSp(12),
                                fontFamily: Constants.app_font),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

  Future _showDialog(context) async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: 80,
                child: Column(children: <Widget>[
                  Text(
                    Languages.of(context).labelSelectLanguage,
                    style: TextStyle(fontFamily: Constants.app_font_bold),
                  ),
                  //your code dropdown button here
                  _createLanguageDropDown(),
                ]),
              );
            },
          ),
        );
      },
    );
  }

  _createLanguageDropDown() {
    return DropdownButton<LanguageData>(
      iconSize: 30,
      hint: Text(
        Languages.of(context).labelSelectLanguage,
        style: TextStyle(fontFamily: Constants.app_font),
      ),
      onChanged: (LanguageData language) {
        Navigator.pop(context);
        changeLanguage(context, language.languageCode);
      },
      items: LanguageData.languageList()
          .map<DropdownMenuItem<LanguageData>>(
            (e) => DropdownMenuItem<LanguageData>(
              value: e,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text(
                    e.flag,
                    style: TextStyle(fontSize: 30),
                  ),
                  Text(
                    e.name,
                    style: TextStyle(fontFamily: Constants.app_font),
                  )
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class SettingMenuWidget extends StatelessWidget {
  Function onClick;
  String str_ImagePath, str_menuName;

  SettingMenuWidget({@required this.onClick, @required this.str_menuName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  str_menuName,
                  style:
                      TextStyle(fontSize: 16, fontFamily: Constants.app_font),
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Divider(
                  thickness: 1,
                  color: Color(0xffcccccc),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
