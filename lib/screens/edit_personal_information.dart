import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/dashboard_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/card_textfield.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/localization/locale_constant.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileInformation extends StatefulWidget {
  @override
  _EditProfileInformationState createState() => _EditProfileInformationState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _EditProfileInformationState extends State<EditProfileInformation>
    with SingleTickerProviderStateMixin {
  final _text_fullName = TextEditingController();
  final _text_Email = TextEditingController();
  final _text_contactNo = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  final _formKeyForBankDetails = new GlobalKey<FormState>();
  bool _autoValidate = false;
  ProgressDialog progressDialog;

  TextEditingController _ifsc_codeController = TextEditingController();
  TextEditingController _micr_codeController = TextEditingController();
  TextEditingController _account_nameController = TextEditingController();
  TextEditingController _account_numberController = TextEditingController();

  bool isValid = false;

  File _image;
  final picker = ImagePicker();
  String str_Imgbash64_profile,
      strCountryCode = '+91',
      _userPhoto =
          'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png';

  Item selectedUser;
  TabController _controller;
  int tabindex = 0;

  List<String> _listLanguages = [];

  int radioindex;

  String strLanguage = '';

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

  Future<void> getLanguageList() async {
    _listLanguages.clear();
    _listLanguages.add('English');
    _listLanguages.add('Spanish');
    _listLanguages.add('Arabic');

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String languageCode = _prefs.getString(prefSelectedLanguageCode);

    setState(() {
      if (languageCode == 'en') {
        radioindex = 0;
      } else if (languageCode == 'es') {
        radioindex = 1;
      }else if (languageCode == 'ar') {
        radioindex = 2;
      } else {
        radioindex = 1;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _text_contactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);
    _text_Email.text = SharedPreferenceUtil.getString(Constants.loginEmail);
    _text_fullName.text =
        SharedPreferenceUtil.getString(Constants.loginUserName);
    _userPhoto = SharedPreferenceUtil.getString(Constants.loginUserImage);

    _controller =
        new TabController(length: 2, vsync: this, initialIndex: tabindex);

    _ifsc_codeController.text =
        SharedPreferenceUtil.getString(Constants.bank_IFSC);
    _micr_codeController.text =
        SharedPreferenceUtil.getString(Constants.bank_MICR);
    _account_nameController.text =
        SharedPreferenceUtil.getString(Constants.bank_ACC_Name);
    _account_numberController.text =
        SharedPreferenceUtil.getString(Constants.bank_ACC_Number);
    getLanguageList();
  }

  _imgFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image.readAsBytesSync();
        str_Imgbash64_profile = base64Encode(imageBytes);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        List<int> imageBytes = _image.readAsBytesSync();
        str_Imgbash64_profile = base64Encode(imageBytes);
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.photo_library),
                    title: new Text(
                      'Photo Library',
                      style: TextStyle(fontFamily: Constants.app_font),
                    ),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    'Camera',
                    style: TextStyle(fontFamily: Constants.app_font),
                  ),
                  onTap: () {
                    getImage();
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(
                    'Cancel',
                    style: TextStyle(fontFamily: Constants.app_font),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            Languages.of(context).labelEditPersonalInfo,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20.0,
                fontFamily: Constants.app_font_bold),
          ),
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 5,
            controller: _controller,
            isScrollable: false,
            physics: NeverScrollableScrollPhysics(),
            indicatorColor: Color(Constants.color_theme),
            labelColor: Color(Constants.color_theme),
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(
              fontFamily: Constants.app_font_bold,
            ),
            tabs: <Widget>[
              Tab(
                text: Languages.of(context).labelPersonalDetails,
              ),
              Tab(
                text: Languages.of(context).labelFinancialDetails,
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _controller,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    width: ScreenUtil().setWidth(200),
                                    height: ScreenUtil().setWidth(150),
                                  ),
                                  Container(
                                      alignment: AlignmentDirectional.topCenter,
                                      width: ScreenUtil().setWidth(120),
                                      height: ScreenUtil().setHeight(120),
                                      child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomEnd,
                                        children: [
                                          ClipOval(
                                            child: _image != null
                                                ? Image.file(
                                                    _image,
                                                    width: ScreenUtil()
                                                        .setWidth(100),
                                                    height: ScreenUtil()
                                                        .setHeight(100),
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    width: ScreenUtil()
                                                        .setWidth(100),
                                                    height: ScreenUtil()
                                                        .setHeight(100),
                                                    imageUrl: _userPhoto,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                  ),
                                          ),
                                          Stack(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 30,
                                                child: RawMaterialButton(
                                                  onPressed: () {
                                                    _showPicker(context);
                                                  },
                                                  elevation: 2.0,
                                                  fillColor: Colors.white,
                                                  child: SvgPicture.asset(
                                                    'images/ic_camera.svg',
                                                    height: ScreenUtil()
                                                        .setHeight(20),
                                                    width: ScreenUtil()
                                                        .setWidth(20),
                                                  ),
                                                  padding: EdgeInsets.all(5.0),
                                                  shape: CircleBorder(
                                                      side: BorderSide(
                                                          color: Colors.black,
                                                          width: 1.5)),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(40)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    RoundedCornerAppButton(
                                      onPressed: () {
                                        callUpdateImage();
                                      },
                                      btn_lable:
                                          Languages.of(context).labelUpdate,
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(20),
                                    right: ScreenUtil().setWidth(20)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AppLableWidget(
                                      title:
                                          Languages.of(context).labelFullName,
                                    ),
                                    CardTextFieldWidget(
                                      focus: (v) {
                                        FocusScope.of(context).nextFocus();
                                      },
                                      textInputAction: TextInputAction.next,
                                      hintText: Languages.of(context)
                                          .labelEnterYourFullName,
                                      textInputType: TextInputType.text,
                                      textEditingController: _text_fullName,
                                      validator: kvalidateFullName,
                                    ),
                                    AppLableWidget(
                                      title: Languages.of(context).labelEmail,
                                    ),
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                      ),
                                      elevation: 5.0,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(15)),
                                        child: TextFormField(
                                          controller: _text_Email,
                                          validator: kvalidateEmail,
                                          textInputAction: TextInputAction.next,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onFieldSubmitted: (v) {
                                            FocusScope.of(context).nextFocus();
                                          },
                                          decoration: InputDecoration(
                                              enabled: false,
                                              errorStyle: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font_bold,
                                                  color: Colors.red),
                                              hintText: Languages.of(context)
                                                  .labelEnterYourEmailID,
                                              hintStyle: TextStyle(
                                                  color: Color(
                                                      Constants.color_hint)),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ),
                                    AppLableWidget(
                                      title: Languages.of(context)
                                          .labelContactNumber,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            elevation: 5.0,
                                            child: Container(
                                              height:
                                              ScreenUtil().setHeight(50),
                                              child: CountryCodePicker(
                                                enabled: false,
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
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                            ),
                                            elevation: 5.0,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setWidth(15)),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        enabled: false,
                                                        decoration: InputDecoration(
                                                            hintText:
                                                                strCountryCode,
                                                            hintStyle: TextStyle(
                                                                color: Color(
                                                                    Constants
                                                                        .color_hint)),
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 10.0, 10.0, 10.0),
                                                      child: VerticalDivider(
                                                        color: Colors.black54,
                                                        width: ScreenUtil()
                                                            .setWidth(5),
                                                        thickness: ScreenUtil()
                                                            .setWidth(1),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: TextFormField(
                                                        controller:
                                                            _text_contactNo,
                                                        validator:
                                                            kvalidateCotactNum,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        decoration: InputDecoration(
                                                            enabled: false,
                                                            errorStyle: TextStyle(
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font_bold,
                                                                color:
                                                                    Colors.red),
                                                            hintText:
                                                                '000 000 000',
                                                            hintStyle: TextStyle(
                                                                color: Color(
                                                                    Constants
                                                                        .color_hint)),
                                                            border: InputBorder
                                                                .none),
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
                                      title:
                                          Languages.of(context).labelLanguage,
                                    ),
                                    ListView.builder(
                                        physics: ClampingScrollPhysics(),
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemCount: _listLanguages.length,
                                        itemBuilder: (BuildContext context,
                                                int index) =>
                                            InkWell(
                                              onTap: () {
                                                changeIndex(index);
                                                String languageCode = '';
                                                if (index == 0) {
                                                  languageCode = 'en';
                                                }else if(index == 1){
                                                  languageCode = 'es';
                                                } else {
                                                  languageCode = 'ar';
                                                }
                                                changeLanguage(
                                                    context, languageCode);
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(20),
                                                    bottom: ScreenUtil()
                                                        .setHeight(10),
                                                    top: ScreenUtil()
                                                        .setHeight(10)),
                                                child: Row(
                                                  children: [
                                                    radioindex == index
                                                        ? getChecked()
                                                        : getunChecked(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: ScreenUtil()
                                                              .setWidth(10)),
                                                      child: Text(
                                                        _listLanguages[index],
                                                        style: TextStyle(
                                                            fontFamily:
                                                                Constants
                                                                    .app_font,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(14)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(40),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                        ScreenUtil().setWidth(20)),
                                    child: RoundedCornerAppButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          if (radioindex == 0) {
                                            strLanguage = 'english';
                                          } else if (radioindex == 1) {
                                            strLanguage = 'spanish';
                                          }
                                          print('selected Language' +
                                              strLanguage);
                                          callUpdateUsername(strLanguage);
                                        } else {
                                          setState(() {
                                            // validation error
                                            _autoValidate = true;
                                          });
                                        }
                                      },
                                      btn_lable: Languages.of(context)
                                          .labelEditPersonalInfo,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: ScreenUtil().setHeight(20),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight),
                        child: Form(
                          key: _formKeyForBankDetails,
                          autovalidateMode: AutovalidateMode.always,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      AppLableWidget(
                                        title: Languages.of(context).IFSC_code,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            Languages.of(context).IFSC_code1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _ifsc_codeController,
                                        validator: validateIFSC,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context).MICR_code,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText:
                                            Languages.of(context).MICR_code1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _micr_codeController,
                                        validator: validateMICR_Code,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context)
                                            .bank_account_name,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.next,
                                        hintText: Languages.of(context)
                                            .bank_account_name1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _account_nameController,
                                        validator: validateAccountname,
                                      ),
                                      AppLableWidget(
                                        title: Languages.of(context)
                                            .bank_account_number,
                                      ),
                                      CardTextFieldWidget(
                                        focus: (v) {
                                          FocusScope.of(context).nextFocus();
                                        },
                                        textInputAction: TextInputAction.done,
                                        hintText: Languages.of(context)
                                            .bank_account_number1,
                                        textInputType: TextInputType.text,
                                        textEditingController:
                                            _account_numberController,
                                        validator: validateAccountNumber,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: RoundedCornerAppButton(
                                          onPressed: () {
                                            if (_formKeyForBankDetails
                                                .currentState
                                                .validate()) {
                                              submitBankDetails();
                                            } else {
                                              setState(() {
                                                // validation error
                                                _autoValidate = true;
                                              });
                                            }
                                          },
                                          btn_lable:
                                              Languages.of(context).labelSubmit,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String validateAccountNumber(String value) {
    if (value.isEmpty) {
      return Languages.of(context).bank_account_number2;
    }
    return null;
  }

  String validateAccountname(String value) {
    if (value.isEmpty) {
      return Languages.of(context).bank_account_name2;
    }
    return null;
  }

  String validateIFSC(String value) {
    if (value.isEmpty) {
      return Languages.of(context).IFSC_code2;
    }
    return null;
  }

  String validateMICR_Code(String value) {
    if (value.isEmpty) {
      return Languages.of(context).MICR_code2;
    }
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

  void callGetUserDetails() {
    RestClient(Retro_Api().Dio_Data()).user().then((response) {
      progressDialog.hide();
      print(response);
      setState(() {
        _text_fullName.text = response.name;
        _text_Email.text = response.emailId;
        _text_contactNo.text = response.phone;
        _userPhoto = response.image;
        SharedPreferenceUtil.putString(Constants.loginUserName, response.name);
        SharedPreferenceUtil.putString(
            Constants.loginUserImage, response.image);
        SharedPreferenceUtil.putString(Constants.loginEmail, response.emailId);
        SharedPreferenceUtil.putString(Constants.loginPhone, response.phone);
      });

      Navigator.of(context).pushReplacement(
        Transitions(
          transitionType: TransitionType.slideUp,
          curve: Curves.bounceInOut,
          reverseCurve: Curves.fastLinearToSlowEaseIn,
          widget: DashboardScreen(3),
        ),
      );
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(responsecode.toString());
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(responsecode.toString());
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

  void callUpdateImage() {
    if (_image != null) {
      progressDialog.show();
      Map<String, String> body = {
        'image': str_Imgbash64_profile,
      };
      RestClient(Retro_Api().Dio_Data()).update_image(body).then((response) {
        progressDialog.hide();
        print(response.success);
        if (response.success) {
          Constants.toastMessage(response.data);
          callGetUserDetails();
        } else {
          Constants.toastMessage('Error while updating image.');
        }
      }).catchError((Object obj) {
        progressDialog.hide();
        switch (obj.runtimeType) {
          case DioError:
            final res = (obj as DioError).response;
            var msg = res.statusMessage;
            var responsecode = res.statusCode;
            if (responsecode == 401) {
              Constants.toastMessage(responsecode.toString());
              print(responsecode);
              print(res.statusMessage);
            } else if (responsecode == 422) {
              print("code:$responsecode");
              print("msg:$msg");
              Constants.toastMessage(responsecode.toString());
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
    } else {
      Constants.toastMessage('Please select image.');
    }
  }

  void callUpdateUsername(String strLanguage) {
    progressDialog.show();
    Map<String, String> body = {
      'name': _text_fullName.text,
      'language': strLanguage,
    };
    RestClient(Retro_Api().Dio_Data()).update_user(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        callGetUserDetails();
      } else {
        Constants.toastMessage('Error while update image.');
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage(responsecode.toString());
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(responsecode.toString());
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

  void submitBankDetails() {
    progressDialog.show();
    Map<String, String> body = {
      'ifsc_code': _ifsc_codeController.text,
      'micr_code': _micr_codeController.text,
      'account_name': _account_nameController.text,
      'account_number': _account_numberController.text,
    };
    RestClient(Retro_Api().Dio_Data()).bank_details(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);

        SharedPreferenceUtil.putString(
            Constants.bank_IFSC, _ifsc_codeController.text);
        SharedPreferenceUtil.putString(
            Constants.bank_MICR, _micr_codeController.text);
        SharedPreferenceUtil.putString(
            Constants.bank_ACC_Name, _account_nameController.text);
        SharedPreferenceUtil.putString(
            Constants.bank_ACC_Number, _account_numberController.text);

        setState(() {
          _ifsc_codeController.text =
              SharedPreferenceUtil.getString(Constants.bank_IFSC);
          _micr_codeController.text =
              SharedPreferenceUtil.getString(Constants.bank_MICR);
          _account_nameController.text =
              SharedPreferenceUtil.getString(Constants.bank_ACC_Name);
          _account_numberController.text =
              SharedPreferenceUtil.getString(Constants.bank_ACC_Number);
        });
      } else {
        Constants.toastMessage('Error while submit bank details.');
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
            Constants.toastMessage(responsecode.toString());
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage(responsecode.toString());
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

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write('  '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length));
  }
}
