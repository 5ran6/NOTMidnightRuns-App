import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/login_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ChangePasswordUser extends StatefulWidget {
  @override
  _ChangePasswordUserState createState() => _ChangePasswordUserState();
}

class _ChangePasswordUserState extends State<ChangePasswordUser> {
  bool _old_passwordVisible = true;
  bool _passwordVisible = true;
  bool _confirm_passwordVisible = true;

  final _old_text_Password = TextEditingController();
  final _text_Password = TextEditingController();
  final _text_confPassword = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  ProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    progressDialog = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      isDismissible: false,
    );

    progressDialog.style(
      message: Languages.of(context).labelpleasewait,
      borderRadius: 5.0,
      backgroundColor: Colors.white,
      progressWidget: SpinKitFadingCircle(color: Color(Constants.color_theme)),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progressTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.app_font),
      messageTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          fontFamily: Constants.app_font),
    );

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
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelChangePassword),
        backgroundColor: Color(0xFFFAFAFA),
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
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.always,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                          child: Image.asset(
                            'images/ic_lock.png',
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              ScreenUtil().setWidth(40), 0.0, ScreenUtil().setWidth(40),
                              ScreenUtil().setHeight(40)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppLableWidget(
                                title: Languages.of(context).labelOldPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _old_text_Password,
                                  validator: OvalidatePassword,
                                  hintText: Languages.of(context).labelEnterOldPassword,
                                  isPasswordVisible: _old_passwordVisible),
                              AppLableWidget(
                                title: Languages.of(context).labelNewPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _text_Password,
                                  validator: kvalidatePassword,
                                  hintText: Languages.of(context)
                                      .labelenterNewPassword,
                                  isPasswordVisible: _passwordVisible),
                              AppLableWidget(
                                title:
                                    Languages.of(context).labelConfirmPassword,
                              ),
                              CardPasswordTextFieldWidget(
                                  textEditingController: _text_confPassword,
                                  validator: validateConfPassword,
                                  hintText: Languages.of(context)
                                      .labelReEnterNewPassword,
                                  isPasswordVisible: _confirm_passwordVisible),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              RoundedCornerAppButton(
                                btn_lable:
                                    Languages.of(context).labelChangePassword,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    Constants.CheckNetwork().whenComplete(
                                        () => callChangePassword());
                                  } else {
                                    setState(() {
                                      // validation error
                                      _autoValidate = true;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String OvalidatePassword(String value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context).labelPasswordvalidation;
    else
      return null;
  }

  String kvalidatePassword(String value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelPasswordRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context).labelPasswordvalidation;
    else
      return null;
  }

  String validateConfPassword(String value) {
    Pattern pattern = r'^(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelPasswordRequired;
    } else if (_text_Password.text != _text_confPassword.text)
      return Languages.of(context).labelPasswordConfPassnotMatch;
    else if (!regex.hasMatch(value))
      return Languages.of(context).labelPasswordvalidation;
    else
      return null;
  }

  void callChangePassword() {
    progressDialog.show();

    Map<String, String> body = {
      'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
      'old_password': _old_text_Password.text,
      'password': _text_Password.text,
      'password_confirmation': _text_confPassword.text,
    };
    RestClient(Retro_Api().Dio_Data()).change_password(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        Navigator.pop(context);
     /*   Navigator.of(context).pushAndRemoveUntil(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
            (Route<dynamic> route) => false);*/
      } else {
        Constants.toastMessage(response.data);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage("code:$responsecode");
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage("code:$responsecode");
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }
}
