import 'dart:convert';
import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_lable_widget.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:dio/dio.dart';

class FeedbackAndSupportScreen extends StatefulWidget {
  @override
  _FeedbackAndSupportScreenState createState() =>
      _FeedbackAndSupportScreenState();
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}

class _FeedbackAndSupportScreenState extends State<FeedbackAndSupportScreen> {
  /// 😠 😕 😐 ☺ 😍
  int radioindex = -1;

  String strCountryCode = '+91';

  bool isFirst = true, isSecond = false, isThird = false, isAllAdded = false;

  final picker = ImagePicker();

  final _text_contactNo = TextEditingController();
  final _text_comment = TextEditingController();

  List<File> _imageList = [];
  final _formKey = new GlobalKey<FormState>();
  List<String> _listBase64String = [];

  @override
  Widget build(BuildContext context) {
    _text_contactNo.text = SharedPreferenceUtil.getString(Constants.loginPhone);
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context).labelFeedbacknSup,
        ),
        backgroundColor: Color(0xFFFAFAFA),
        body: Container(
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
                  constraints:
                      BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/ic_background_image.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        radioindex = 0;
                                      });
                                    },
                                    child: SvgPicture.asset(radioindex == 0
                                        ? 'images/ic_yellow1.svg'
                                        : 'images/ic_gray1.svg')),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        radioindex = 1;
                                      });
                                    },
                                    child: SvgPicture.asset(radioindex == 1
                                        ? 'images/ic_yellow2.svg'
                                        : 'images/ic_gray2.svg')),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        radioindex = 2;
                                      });
                                    },
                                    child: SvgPicture.asset(radioindex == 2
                                        ? 'images/ic_yellow3.svg'
                                        : 'images/ic_gray3.svg')),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        radioindex = 3;
                                      });
                                    },
                                    child: SvgPicture.asset(radioindex == 3
                                        ? 'images/ic_yellow4.svg'
                                        : 'images/ic_gray4.svg')),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        radioindex = 4;
                                      });
                                    },
                                    child: SvgPicture.asset(radioindex == 4
                                        ? 'images/ic_yellow5.svg'
                                        : 'images/ic_gray5.svg')),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Container(
                            child: Form(
                              key: _formKey,
                              autovalidateMode: AutovalidateMode.always,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, bottom: 5),
                                    child: Text(
                                      Languages.of(context)
                                          .labelAddYourExperience,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    height: ScreenUtil().setHeight(150),
                                    child: Card(
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _text_comment,
                                          keyboardType: TextInputType.text,
                                          validator: kvalidateFeedbackComment,
                                          decoration: InputDecoration(
                                              hintText: Languages.of(context)
                                                  .labelAddYourExperienceHere,
                                              errorStyle: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font_bold,
                                                  color: Colors.red),
                                              border: InputBorder.none),
                                          maxLines: 6,
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              fontSize: 16,
                                              color: Color(
                                                Constants.color_gray,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        children: [
                                          Container(
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setHeight(80),
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: _imageList != null &&
                                                      _imageList.length > 0
                                                  ? Image.file(
                                                      _imageList[0],
                                                      width: ScreenUtil()
                                                          .setWidth(100),
                                                      height: ScreenUtil()
                                                          .setHeight(100),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(),
                                            ),
                                          ),
                                          Container(
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setHeight(80),
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: _imageList != null &&
                                                      _imageList.length > 1
                                                  ? Image.file(
                                                      _imageList[1],
                                                      width: ScreenUtil()
                                                          .setWidth(100),
                                                      height: ScreenUtil()
                                                          .setHeight(100),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(),
                                            ),
                                          ),
                                          Container(
                                            width: ScreenUtil().setWidth(80),
                                            height: ScreenUtil().setHeight(80),
                                            child: Card(
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: _imageList != null &&
                                                      _imageList.length > 2
                                                  ? Image.file(
                                                      _imageList[2],
                                                      width: ScreenUtil()
                                                          .setWidth(100),
                                                      height: ScreenUtil()
                                                          .setHeight(100),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Container(),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              if (!isAllAdded) {
                                                if (isFirst) {
                                                  _showPicker(context, 0);
                                                } else if (isSecond) {
                                                  _showPicker(context, 1);
                                                } else if (isThird) {
                                                  _showPicker(context, 2);
                                                }
                                              } else {
                                                Constants.toastMessage(
                                                    Languages.of(context)
                                                        .labelMax3Image);
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(left: 5),
                                              child: DottedBorder(
                                                borderType: BorderType.RRect,
                                                radius: Radius.circular(16),
                                                strokeWidth: 2,
                                                dashPattern: [8, 4],
                                                color: Color(0xffdddddd),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                                  child: Container(
                                                    height: ScreenUtil().setHeight(70),
                                                    width: ScreenUtil().setWidth(70),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(20.0),
                                                      child: SvgPicture.asset(
                                                        'images/ic_plus1.svg',
                                                        color: Color(0xffdddddd),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: RoundedCornerAppButton(
                                      onPressed: () {
                                        if (_formKey.currentState.validate()) {
                                          print(_listBase64String.toString());
                                          print(radioindex);

                                          if (radioindex != -1) {
                                            int rate = radioindex + 1;
                                            callShareAppFeedback(rate);
                                          } else {
                                            Constants.toastMessage(
                                                Languages.of(context)
                                                    .labelPleaseSelectemoji);
                                          }
                                        } else {
                                          setState(() {
                                            // validation error
                                          });
                                        }
                                      },
                                      btn_lable: Languages.of(context)
                                          .labelShareFeedback,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  String kvalidateCotactNum(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelContactNumberRequired;
    } else if (value.length > 10) {
      return Languages.of(context).labelContactNumberNotValid;
    } else
      return null;
  }

  String kvalidateFeedbackComment(String value) {
    if (value.length == 0) {
      return Languages.of(context).labelFeedbackCommentRequired;
    } else
      return null;
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }

  _imgFromGallery(int pos) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));

        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImage(int pos) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _imageList.add(File(pickedFile.path));
        List<int> imageBytes = _imageList[pos].readAsBytesSync();
        _listBase64String.add(base64Encode(imageBytes));
        if (pos == 0) {
          isFirst = false;
          isSecond = true;
        } else if (pos == 1) {
          isSecond = false;
          isThird = true;
        } else if (pos == 2) {
          isThird = false;
          isAllAdded = true;
        }
      } else {
        print('No image selected.');
      }
    });
  }

  void _showPicker(context, int pos) {
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
                      Languages.of(context).labelPhotoLibrary,
                      style: TextStyle(fontFamily: Constants.app_font),
                    ),
                    onTap: () {
                      _imgFromGallery(pos);
                      Navigator.of(context).pop();
                    }),
                new ListTile(
                  leading: new Icon(Icons.photo_camera),
                  title: new Text(
                    Languages.of(context).labelCamera,
                    style: TextStyle(fontFamily: Constants.app_font),
                  ),
                  onTap: () {
                    getImage(pos);
                    Navigator.of(context).pop();
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.close),
                  title: new Text(
                    Languages.of(context).labelCancel,
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

  void callShareAppFeedback(int rate) {
    Map body = {
      'rate': rate.toString(),
      'comment': _text_comment.text,
      'image': _listBase64String,
    };
    RestClient(Retro_Api().Dio_Data()).add_feedback(body).then((response) {
      print(response.success);
      // progressDialog.hide();
      if (response.success) {
        Constants.toastMessage(response.data);
        Navigator.pop(context);
      } else {
        Constants.toastMessage('error while giving feedback.');
      }
    }).catchError((Object obj) {
      // progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('$responsecode');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('$responsecode');
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
