import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/create_new_account.dart';
import 'package:mealup/screens/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'change_password.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isRememberMe = false;
  bool _passwordVisible = true;

  final _text_Email = TextEditingController();
  final _text_Password = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  ProgressDialog progressDialog;

  @override
  void initState() {
    super.initState();
    if (SharedPreferenceUtil.getString(Constants.appPush_oneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }
  }

  @override
  void dispose() {
    super.dispose();
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeroImage(),
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
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
                                  textInputAction: TextInputAction.next,
                                  hintText: Languages.of(context).labelEnterYourEmailID,
                                  textInputType: TextInputType.emailAddress,
                                  textEditingController: _text_Email,
                                  validator: kvalidateEmail,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppLableWidget(
                                      title: Languages.of(context).labelPassword,
                                    ),
                                  ],
                                ),
                                CardPasswordTextFieldWidget(
                                    textEditingController: _text_Password,
                                    validator: kvalidatePassword,
                                    hintText: Languages.of(context).labelEnterYourPassword,
                                    isPasswordVisible: _passwordVisible),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: ClipRRect(
                                            clipBehavior: Clip.hardEdge,
                                            borderRadius: BorderRadius.all(Radius.circular(5)),
                                            child: SizedBox(
                                              width: 40.0,
                                              height: ScreenUtil().setHeight(40),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Container(
                                                  child: Theme(
                                                    data: ThemeData(
                                                      unselectedWidgetColor: Colors.transparent,
                                                    ),
                                                    child: Checkbox(
                                                      value: isRememberMe,
                                                      onChanged: (state) =>
                                                          setState(() => isRememberMe = !isRememberMe),
                                                      activeColor: Colors.transparent,
                                                      checkColor: Color(Constants.color_theme),
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize.padded,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Languages.of(context).labelRememberMe,
                                          style:
                                              TextStyle(fontSize: 14.0, fontFamily: Constants.app_font),
                                        ),

                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10.0),
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: ChangePassword()));
                                        },
                                        child: Text(
                                          Languages.of(context).labelForgotPassword,
                                          style:
                                          TextStyle(fontSize: 14.0, fontFamily: Constants.app_font),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: RoundedCornerAppButton(
                                    onPressed: () {
                                      if (_formKey.currentState.validate()) {
                                        // if (SharedPreferenceUtil.getString(
                                        //         Constants
                                        //             .appPush_oneSingleToken)
                                        //     .isEmpty) {
                                        //   getOneSingleToken(SharedPreferenceUtil
                                        //       .getString(Constants
                                        //           .appSettingCustomerAppId));
                                        // } else {
                                        // }
                                        Constants.CheckNetwork().whenComplete(() => callUserLogin());
                                      } else {
                                        setState(() {
                                          // validation error
                                          _autoValidate = true;
                                        });
                                      }
                                    },
                                    btn_lable: Languages.of(context).labelLogin,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(Transitions(
                                        transitionType: TransitionType.slideUp,
                                        curve: Curves.bounceInOut,
                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                        widget: CreateNewAccount()));
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        Languages.of(context).labelDonthaveAcc,
                                        style: TextStyle(fontFamily: Constants.app_font),
                                      ),
                                      Text(
                                        Languages.of(context).labelCreateNow,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: Constants.app_font),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MaterialButton(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                      elevation: 5.0,
                                      minWidth: 100.0,
                                      height: 40,
                                      splashColor: Colors.green.withAlpha(50),
                                      child: Text(
                                        Languages.of(context).labelSkipNow,
                                        style: TextStyle(
                                          color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: Constants.app_font),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(Transitions(
                                            transitionType: TransitionType.slideUp,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: DashboardScreen(0)));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'images/ic_login_page11.png',
                              fit: BoxFit.cover,
                            )
                          ],
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

  getOneSingleToken(String appId) async {
    // String push_token = '';
    String userId = '';
    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    //var status = await OneSignal.shared.getDeviceState();
    await OneSignal.shared.getDeviceState().then(
        (value) => SharedPreferenceUtil.putString(Constants.appPush_oneSingleToken, value.userId));
    // var pushtoken = await status.subscriptionStatus.pushToken;
    // userId = status.userId;
    //print("pushtoken1:$userId");
    // print("pushtoken123456:$pushtoken");
    // push_token = pushtoken;
    //  userId == null ? userId = '' : userId = status.userId;
    //  SharedPreferenceUtil.putString(Constants.appPush_oneSingleToken, userId);

   /* if (SharedPreferenceUtil.getString(Constants.appPush_oneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  void callUserLogin() {
    progressDialog.show();

    Map<String, String> body = {
      'email_id': _text_Email.text,
      'password': _text_Password.text,
      'provider': 'LOCAL',
      'device_token': SharedPreferenceUtil.getString(Constants.appPush_oneSingleToken),
    };
    RestClient(Retro_Api().Dio_Data()).user_login(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(Languages.of(context).labelLoginSuccessfully);
        response.data.otp == null
            ? SharedPreferenceUtil.putInt(Constants.loginOTP, 0)
            : SharedPreferenceUtil.putInt(Constants.loginOTP, response.data.otp);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.data.emailId);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.data.phone);
        SharedPreferenceUtil.putString(Constants.loginUserId, response.data.id.toString());
        SharedPreferenceUtil.putString(Constants.headerToken, response.data.token);
        SharedPreferenceUtil.putString(Constants.loginUserImage, response.data.image);
        SharedPreferenceUtil.putString(Constants.loginUserName, response.data.name);

        response.data.ifsc_code == null
            ? SharedPreferenceUtil.putString(Constants.bank_IFSC, '')
            : SharedPreferenceUtil.putString(Constants.bank_IFSC, response.data.ifsc_code);
        response.data.micr_code == null
            ? SharedPreferenceUtil.putString(Constants.bank_MICR, '')
            : SharedPreferenceUtil.putString(Constants.bank_MICR, response.data.micr_code);
        response.data.account_name == null
            ? SharedPreferenceUtil.putString(Constants.bank_ACC_Name, '')
            : SharedPreferenceUtil.putString(Constants.bank_ACC_Name, response.data.account_name);
        response.data.account_number == null
            ? SharedPreferenceUtil.putString(Constants.bank_ACC_Number, '')
            : SharedPreferenceUtil.putString(
                Constants.bank_ACC_Number, response.data.account_number);

        SharedPreferenceUtil.putBool(Constants.isLoggedIn, true);

        String languageCode = '';
        if (response.data.language == 'english') {
          languageCode = 'en';
        } else {
          languageCode = 'es';
        }

        changeLanguage(context, languageCode);

        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: DashboardScreen(0),
          ),
        );
      } else {
        Constants.toastMessage(Languages.of(context).labelEmailPasswordWrong);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(Languages.of(context).labelEmailPasswordWrong);
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage("code:$responsecode");
          } else if (responsecode == 500) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }
}
