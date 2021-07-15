import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/login_screen.dart';
import 'package:mealup/screens/otp_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/card_password_textfield.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/hero_image_app_logo.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewAccount extends StatefulWidget {
  @override
  _CreateNewAccountState createState() => _CreateNewAccountState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _CreateNewAccountState extends State<CreateNewAccount> {
  bool _passwordVisible = true;
  bool _confirmpasswordVisible = true;

  Item selectedUser;
  List<Item> users = <Item>[
    const Item(
        'Android',
        Icon(
          Icons.android,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Flutter',
        Icon(
          Icons.flag,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'ReactNative',
        Icon(
          Icons.format_indent_decrease,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'iOS',
        Icon(
          Icons.mobile_screen_share,
          color: const Color(0xFF167F67),
        )),
  ];

  final _text_fullName = TextEditingController();
  final _text_Email = TextEditingController();
  final _text_Password = TextEditingController();
  final _text_confPassword = TextEditingController();
  final _text_contactNo = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;
  String strCountryCode = '+91';
  ProgressDialog progressDialog;
  String strLanguage = '';

  List<String> _listLanguages = [];

  int radioindex;

  void changeIndex(int index) {
    setState(() {
      radioindex = index;
    });
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecoration_checked(false, Color(Constants.color_theme)),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecoration_checked(true, Colors.white),
    );
  }

  BoxDecoration myBoxDecoration_checked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(
          Radius.circular(8.0) //                 <--- border radius here
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    getLanguageList();
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
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelCreateNewAccount),
        backgroundColor: Color(0xFFFAFAFA),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HeroImage(),
              SizedBox(
                height: ScreenUtil().setHeight(10),
              ),
              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('images/ic_background_image.png'),
                  fit: BoxFit.cover,
                )),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(30),
                      ScreenUtil().setHeight(30), ScreenUtil().setWidth(30), 0),
                  child: Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AppLableWidget(
                          title: Languages.of(context).labelFullName,
                        ),
                        CardTextFieldWidget(
                          focus: (v) {
                            FocusScope.of(context).nextFocus();
                          },
                          textInputAction: TextInputAction.next,
                          hintText:
                              Languages.of(context).labelEnterYourFullName,
                          textInputType: TextInputType.text,
                          textEditingController: _text_fullName,
                          validator: kvalidateFullName,
                        ),
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
                        AppLableWidget(
                          title: Languages.of(context).labelContactNumber,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5.0,
                                child: Container(
                                  height: ScreenUtil().setHeight(50),
                                  child: CountryCodePicker(
                                    onChanged: (c) {
                                      setState(() {
                                        strCountryCode = c.dialCode;
                                      });
                                    },
                                    // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                    initialSelection: 'IN',
                                    favorite: ['+91', 'IN'],
                                    hideMainText: true,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 5.0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(15)),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Text(strCountryCode),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              0,
                                              ScreenUtil().setHeight(10),
                                              ScreenUtil().setWidth(10),
                                              ScreenUtil().setHeight(10)),
                                          child: VerticalDivider(
                                            color: Colors.black54,
                                            width: ScreenUtil().setWidth(5),
                                            thickness: 1.0,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: TextFormField(
                                            textInputAction:
                                                TextInputAction.next,
                                            controller: _text_contactNo,
                                            validator: kvalidateCotactNum,
                                            keyboardType: TextInputType.number,
                                            onFieldSubmitted: (v) {
                                              FocusScope.of(context)
                                                  .nextFocus();
                                            },
                                            decoration: InputDecoration(
                                                errorStyle: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font_bold,
                                                    color: Colors.red),
                                                hintText: '000 000 000',
                                                hintStyle: TextStyle(
                                                    color: Color(
                                                        Constants.color_hint)),
                                                border: InputBorder.none),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        AppLableWidget(
                          title: Languages.of(context).labelPassword,
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _text_Password,
                            validator: kvalidatePassword,
                            hintText:
                                Languages.of(context).labelEnterYourPassword,
                            isPasswordVisible: _passwordVisible),
                        AppLableWidget(
                          title: Languages.of(context).labelConfirmPassword,
                        ),
                        CardPasswordTextFieldWidget(
                            textEditingController: _text_confPassword,
                            validator: validateConfPassword,
                            hintText:
                                Languages.of(context).labelReEnterPassword,
                            isPasswordVisible: _confirmpasswordVisible),
                        AppLableWidget(
                          title: Languages.of(context).labelLanguage,
                        ),
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _listLanguages.length,
                            itemBuilder: (BuildContext context, int index) =>
                                InkWell(
                                  onTap: () {
                                    changeIndex(index);
                                    String languageCode = '';
                                    if (index == 0) {
                                      languageCode = 'en';
                                    } else {
                                      languageCode = 'es';
                                    }
                                    changeLanguage(context, languageCode);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(20),
                                        bottom: ScreenUtil().setHeight(10),
                                        top: ScreenUtil().setHeight(10)),
                                    child: Row(
                                      children: [
                                        radioindex == index
                                            ? getChecked()
                                            : getunChecked(),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(10)),
                                          child: Text(
                                            _listLanguages[index],
                                            style: TextStyle(
                                                fontFamily: Constants.app_font,
                                                fontWeight: FontWeight.w900,
                                                fontSize:
                                                    ScreenUtil().setSp(14)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
                        ),
                        Padding(
                          padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
                          child: RoundedCornerAppButton(
                            onPressed: () {
                              if (_formKey.currentState.validate()) {
                                if (radioindex == 0) {
                                  strLanguage = 'english';
                                } else if (radioindex == 1) {
                                  strLanguage = 'spanish';
                                }
                                print('selected Language' + strLanguage);
                                callRegisterAPI(strLanguage);
                              } else {
                                setState(() {
                                  // validation error
                                  _autoValidate = true;
                                });
                              }
                            },
                            btn_lable:
                                Languages.of(context).labelCreateNewAccount,
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(10),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Languages.of(context).labelAlreadyHaveAccount,
                                style:
                                    TextStyle(fontFamily: Constants.app_font),
                              ),
                              Text(
                                Languages.of(context).labelLogin,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.app_font),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(30),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

  String kvalidateFullName(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelFullNameRequired;
    } else
      return null;
  }

  String kvalidateCotactNum(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context).labelContactNumberNotValid;
    } else
      return null;
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

  void callRegisterAPI(String strLanguage) {
    progressDialog.show();

    Map<String, String> body = {
      'name': _text_fullName.text,
      'email_id': _text_Email.text,
      'password': _text_confPassword.text,
      'phone': _text_contactNo.text,
      'phone_code': strCountryCode,
      'language': strLanguage,
    };
    RestClient(Retro_Api().Dio_Data())
        // .register1('dev test', 'devtest@gmail.com', 'devtest@123', '+919876543210')
        .register(body)
        .then((response) {
      progressDialog.hide();
      print(response.success);

      if (response.success) {
        Constants.toastMessage(response.msg);
        SharedPreferenceUtil.putInt(
            Constants.registrationOTP, response.data.otp);
        SharedPreferenceUtil.putString(
            Constants.registrationEmail, response.data.emailId);
        SharedPreferenceUtil.putString(
            Constants.registrationPhone, response.data.phone);
        SharedPreferenceUtil.putString(
            Constants.registrationUserId, response.data.id.toString());

        if (response.data.isVerified == 0) {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.slideUp,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: OTPScreen(
                isFromRegistration: true,
              ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            Transitions(
              transitionType: TransitionType.fade,
              curve: Curves.bounceInOut,
              reverseCurve: Curves.fastLinearToSlowEaseIn,
              widget: LoginScreen(),
            ),
          );
        }
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
            Constants.toastMessage(
                Languages.of(context).labelEmailIdAlreadyTaken);
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

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    _listLanguages.add('Spanish');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioindex = 0;
      } else if (languageCode == 'es') {
        radioindex = 1;
      } else {
        radioindex = 1;
      }
    });
  }
}
