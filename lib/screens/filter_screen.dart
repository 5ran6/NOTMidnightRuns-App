import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:dio/dio.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';

class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  List<String> _listSortBy = [];
  List<String> _listQuickFilter = [];

  ProgressDialog progressDialog;
  List<AllCuisineData> _allCuisineListData = [];

  List<String> selectedCuisineListId = [];

  int radioindex;
  int radioQuickFilter;
  int radioCousines;

  @override
  void initState() {
    super.initState();

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

    getSortByList();
    getQuickFilterList();
    Constants.CheckNetwork().whenComplete(() => callAllCuisine());
  }

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
    // ScreenUtil.init(context,designSize: Size(defaultScreenWidth, defaultScreenHeight) ,allowFontScaling: true);


    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(
          height: ScreenUtil().setHeight(50),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    color: Color(0xffeeeeee),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontFamily: Constants.app_font,
                            fontSize: ScreenUtil().setSp(16)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (radioindex == 0) {
                      print('High To Low');
                    } else if (radioindex == 1) {
                      print('Low To High');
                    }
                    if (radioQuickFilter == 0) {
                      print('Veg re');
                    } else if (radioQuickFilter == 1) {
                      print('Non Veg re');
                    } else if (radioQuickFilter == 2) {
                      print('Both Non Veg re');
                    }
                    selectedCuisineListId.clear();
                    for (int i = 0; i < _allCuisineListData.length; i++) {
                      if (_allCuisineListData[i].isChecked) {
                        selectedCuisineListId
                            .add(_allCuisineListData[i].id.toString());
                      }
                    }
                    String commaSeparated = selectedCuisineListId.join(', ');
                    print('Selected cuisine Id : ---' + commaSeparated);
                  },
                  child: Container(
                    color: Color(Constants.color_theme),
                    child: Center(
                      child: Text(
                        'Apply Filter',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: Constants.app_font,
                            fontSize: ScreenUtil().setSp(16)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        appBar: ApplicationToolbar_WithClrBtn(
          appbarTitle: 'Filter',
          str_button_title: 'Clear',
          btn_color: Color(Constants.color_theme),
          onBtnPress: () {
            selectedCuisineListId.clear();
            radioindex = null;
            radioQuickFilter = null;
            Constants.CheckNetwork().whenComplete(() => callAllCuisine());
          },
        ),
        backgroundColor: Color(0xFFFAFAFA),
        body: Padding(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(20),
              right: ScreenUtil().setWidth(10)),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sorting By',
                  style: TextStyle(
                      fontFamily: Constants.app_font,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                  child: Container(
                    height: ScreenUtil().setHeight(60),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 5,
                      mainAxisSpacing: 5,
                      children: List.generate(_listSortBy.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            changeIndex(index);
                          },
                          child: Row(
                            children: [
                              radioindex == index
                                  ? getChecked()
                                  : getunChecked(),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10)),
                                child: Text(
                                  _listSortBy[index],
                                  style: TextStyle(
                                      fontFamily: Constants.app_font,
                                      fontSize: ScreenUtil().setSp(14)),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Text(
                  'Quick Filters',
                  style: TextStyle(
                      fontFamily: Constants.app_font,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                  child: Container(
                    height: ScreenUtil().setHeight(100),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 5,
                      children: List.generate(_listQuickFilter.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            changeQuickFilterIndex(index);
                          },
                          child: Row(
                            children: [
                              radioQuickFilter == index
                                  ? getChecked()
                                  : getunChecked(),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(10)),
                                  child: Text(
                                    _listQuickFilter[index],
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        fontSize: ScreenUtil().setSp(14)),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Text(
                  'Cousines',
                  style: TextStyle(
                      fontFamily: Constants.app_font,
                      fontSize: ScreenUtil().setSp(18)),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(15)),
                    child: Container(
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 5,
                        mainAxisSpacing: 10,
                        children:
                            List.generate(_allCuisineListData.length, (index) {
                          return InkWell(
                            onTap: () {
                              // changeCousinesIndex(index);
                              setState(() {
                                _allCuisineListData[index].isChecked =
                                    !_allCuisineListData[index].isChecked;
                              });
                            },
                            child: Row(
                              children: [
                                _allCuisineListData[index].isChecked
                                    ? getChecked()
                                    : getunChecked(),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(10)),
                                  child: Text(
                                    _allCuisineListData[index].name,
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        fontSize: ScreenUtil().setSp(14)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getChecked() {
    return Container(
      width: 25,
      height: ScreenUtil().setHeight(25),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: ScreenUtil().setHeight(15),
        ),
      ),
      decoration: myBoxDecoration_checked(false, Color(Constants.color_theme)),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: ScreenUtil().setHeight(25),
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

  void changeIndex(int index) {
    setState(() {
      radioindex = index;
    });
  }

  void changeQuickFilterIndex(int index) {
    setState(() {
      radioQuickFilter = index;
    });
  }

  void changeCousinesIndex(int index) {
    setState(() {
      radioCousines = index;
    });
  }

  void getSortByList() {
    _listSortBy.clear();
    _listSortBy.add('High To Low');
    _listSortBy.add('Low To High');
  }

  void getQuickFilterList() {
    _listQuickFilter.clear();
    _listQuickFilter.add('Veg. Restaurant');
    _listQuickFilter.add('Non Veg. Restaurant');
    _listQuickFilter.add('Both Veg. & Non Veg.');
  }

  callAllCuisine() {
    _allCuisineListData.clear();
    progressDialog.show();

    RestClient(Retro_Api().Dio_Data()).allCuisine().then((response) {
      print(response.success);
      progressDialog.hide();
      if (response.success) {
        setState(() {
          _allCuisineListData.addAll(response.data);
        });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
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
