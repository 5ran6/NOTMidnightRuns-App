import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/otp_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _text_Email = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  ProgressDialog progressDialog;
  bool _autoValidate = false;

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

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelForgotPassword1),
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
                        HeroImage(),
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Image.asset(
                            'images/ic_email.png',
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppLableWidget(
                                title: Languages.of(context).labelEmail,
                              ),
                              CardTextFieldWidget(
                                focus: (v) {
                                  FocusScope.of(context).nextFocus();
                                },
                                textInputAction: TextInputAction.done,
                                hintText:
                                    Languages.of(context).labelEnterYourEmailID,
                                textInputType: TextInputType.emailAddress,
                                textEditingController: _text_Email,
                                validator: kvalidateEmail,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              RoundedCornerAppButton(
                                btn_lable:
                                    Languages.of(context).labelSubmitThis,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    callSendOTP();
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
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Text(
                            Languages.of(context).labelChangePasswordBottomline,
                            style: TextStyle(
                              color: Color(Constants.color_gray),
                              fontSize: 10.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
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

  String kvalidateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.length == 0) {
      return Languages.of(context).labelEmailRequired;
    } else if (!regex.hasMatch(value))
      return Languages.of(context).labelEnterValidEmail;
    else
      return null;
  }

  void callSendOTP() {
    progressDialog.show();

    Map<String, String> body = {
      'email_id': _text_Email.text,
    };
    RestClient(Retro_Api().Dio_Data()).send_otp(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage('OTP Sent');
        SharedPreferenceUtil.putString(
            Constants.loginUserId, response.data.id.toString());
        Navigator.of(context).push(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: OTPScreen(
              isFromRegistration: false,
              emailForOTP: _text_Email.text,
            ),
          ),
        );
      } else {
        Constants.toastMessage(response.data.toString());
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('Error $responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('Error $responsecode');
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(
                Languages.of(context).labelInternalServerError);
          }
          break;
        default:
          Constants.toastMessage('User Not Found');
      }
    });
  }
}
