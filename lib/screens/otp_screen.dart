import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/login_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:dio/dio.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'change_password_1.dart';

class OTPScreen extends StatefulWidget {
  final bool isFromRegistration;
  final String emailForOTP;

  const OTPScreen(
      {Key key, @required this.isFromRegistration, this.emailForOTP})
      : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  int _start = 60;
  Timer _timer;

  int getOTP;
  ProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    startTimer();
    _focusNode.addListener(() {
      print("Has focus: ${_focusNode.hasFocus}");
    });

    getOTP = SharedPreferenceUtil.getInt(Constants.registrationOTP);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(() {
              if (_start < 1) {
                timer.cancel();
              } else {
                _start = _start - 1;
              }
            }));
  }

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
        appBar: ApplicationToolbar(appbarTitle: Languages.of(context).labelOTP),
        backgroundColor: Color(0xFFF9F9F9),
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
                      HeroImage(),
                      Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(40)),
                        child: Image.asset(
                          'images/ic_otp.png',
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            right: ScreenUtil().setWidth(20)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppLableWidget(
                                  title: Languages.of(context).labelEnterOTP,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: ScreenUtil().setWidth(30)),
                                  child: Text(
                                    '00 : $_start',
                                    style: TextStyle(
                                        fontFamily: Constants.app_font),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              children: [
                                OTP_TextField(
                                  editingController: textEditingController1,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTP_TextField(
                                  editingController: textEditingController2,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTP_TextField(
                                  editingController: textEditingController3,
                                  textInputAction: TextInputAction.next,
                                  focus: (v) {
                                    FocusScope.of(context).nextFocus();
                                  },
                                ),
                                OTP_TextField(
                                  editingController: textEditingController4,
                                  textInputAction: TextInputAction.done,
                                  focus: (v) {
                                    FocusScope.of(context).dispose();
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(20),
                            ),
                            RoundedCornerAppButton(
                                btn_lable: Languages.of(context).labelVerifyNow,
                                onPressed: () {
                                  String one = textEditingController1.text +
                                      textEditingController2.text +
                                      textEditingController3.text +
                                      textEditingController4.text;
                                  int enteredOTP = int.parse(one);
                                  print(one);
                                  if (widget.isFromRegistration) {
                                    // if(enteredOTP == getOTP){
                                    if (one == '0000') {
                                      callVerifyOTP(one);
                                    }
                                  } else {
                                    if (one == '0000') {
                                      callForgotPasswordVerifyOTP(one);
                                    }
                                  }
                                }),
                            SizedBox(
                              height: ScreenUtil().setHeight(15),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  Languages.of(context).labelDontReceiveCode,
                                  style:
                                      TextStyle(fontFamily: Constants.app_font),
                                ),
                                InkWell(
                                  onTap: () {
                                    callSendOTP();
                                  },
                                  child: Text(
                                    Languages.of(context).labelResendAgain,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.app_font),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(ScreenUtil().setWidth(25)),
                        child: Text(
                          Languages.of(context).labelOTPBottomLine,
                          style: TextStyle(
                            color: Color(Constants.color_gray),
                            fontSize: ScreenUtil().setSp(10),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void callSendOTP() {
    progressDialog.show();

    Map<String, String> body = {
      'email_id': widget.emailForOTP,
    };
    RestClient(Retro_Api().Dio_Data()).send_otp(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage('OTP Sent');

        SharedPreferenceUtil.putString(
            Constants.loginUserId, response.data.id.toString());
      } else {
        Constants.toastMessage('Error while sending OTP.');
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
      }
    });
  }

  void callVerifyOTP(String enteredOTP) {
    print('=======' + SharedPreferenceUtil.getString('userId'));
    print(enteredOTP);
    progressDialog.show();

    Map<String, String> body = {
      'user_id': SharedPreferenceUtil.getString(Constants.registrationUserId),
      'otp': enteredOTP,
      'where': 'register',
    };
    RestClient(Retro_Api().Dio_Data()).check_otp(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.msg);

        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: LoginScreen(),
          ),
        );
      } else {
        Constants.toastMessage(response.msg);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(Languages.of(context).labelInvalidData);
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

  void callForgotPasswordVerifyOTP(String enteredOTP) {
    print('=======' + SharedPreferenceUtil.getString('userId'));
    print(enteredOTP);
    progressDialog.show();

    Map<String, String> body = {
      'user_id': SharedPreferenceUtil.getString(Constants.loginUserId),
      'otp': enteredOTP,
      'where': 'change_password',
    };
    RestClient(Retro_Api().Dio_Data())
        .check_otp_forForgotPassowrd(body)
        .then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.msg);

        Navigator.of(context).push(Transitions(
            transitionType: TransitionType.fade,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ChangePassword_1()));
      } else {
        Constants.toastMessage(response.msg);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(Languages.of(context).labelInvalidData);
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

class OTP_TextField extends StatelessWidget {
  TextEditingController editingController = TextEditingController();
  TextInputAction textInputAction;
  Function focus;

  OTP_TextField(
      {@required this.editingController,
      @required this.textInputAction,
      @required this.focus});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        width: ScreenUtil().setWidth(30),
        height: ScreenUtil().setHeight(70),
        margin: EdgeInsets.all(2.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 2.0,
          child: Center(
            child: TextFormField(
              onFieldSubmitted: focus,
              controller: editingController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: textInputAction,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
              ],
              onChanged: (str) {
                if (str.length == 1) {
                  FocusScope.of(context).nextFocus();
                } else {
                  FocusScope.of(context).previousFocus();
                }
              },
              style: TextStyle(
                  fontFamily: Constants.app_font,
                  fontSize: ScreenUtil().setSp(25),
                  color: Color(Constants.color_gray)),
              decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Color(Constants.color_hint),
                  ),
                  border: InputBorder.none),
            ),
          ),
        ),
      ),
    );
  }
}
