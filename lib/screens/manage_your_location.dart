import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/add_address_screen.dart';
import 'package:mealup/screens/edit_address_screen.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ManageYourLocation extends StatefulWidget {
  @override
  _ManageYourLocationState createState() => _ManageYourLocationState();
}

class _ManageYourLocationState extends State<ManageYourLocation> {
  ProgressDialog progressDialog;
  List<UserAddressListData> _userAddressList = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isSyncing = false;
  Position currentLocation;
  double _currentLatitude;
  double _currentLongitude;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork().whenComplete(() => callGetUserAddresses());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();

    Constants.CheckNetwork().whenComplete(() => callGetUserAddresses());
    getUserLocation();
  }

  getUserLocation() async {
    currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentLatitude = currentLocation.latitude;
    _currentLongitude = currentLocation.longitude;
    print('selectedLat $_currentLatitude');
    print('selectedLng $_currentLongitude');
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
        appBar: ApplicationToolbar_WithClrBtn(
          appbarTitle: Languages.of(context).labelManageYourLocation,
          str_button_title: '+ ${Languages.of(context).labelAddAddress}',
          btn_color: Color(Constants.color_theme),
          onBtnPress: () {
            Navigator.pop(context);
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.fade,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                // widget: HereMapDemo())
                widget: AddAddressScreen(
                  isFromAddAddress: true,
                  currentLat: _currentLatitude,
                  currentLong: _currentLongitude,
                )));
          },
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isSyncing,
          child: SmartRefresher(
            enablePullDown: true,
            header: MaterialClassicHeader(
              backgroundColor: Color(Constants.color_theme),
              color: Colors.white,
            ),
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: LayoutBuilder(
                builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 10, left: 15, right: 10),
                      child: _userAddressList.length == 0 ||
                              _userAddressList.length == null
                          ? !_isSyncing
                              ? Container(
                                  width: ScreenUtil().screenWidth,
                                  height: ScreenUtil().screenHeight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        width: ScreenUtil().setWidth(100),
                                        height: ScreenUtil().setHeight(100),
                                        image: AssetImage('images/ic_no_rest.png'),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                        child: Text(
                                          Languages.of(context).labelNodata,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(18),
                                            fontFamily: Constants.app_font_bold,
                                            color: Color(Constants.color_theme),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container()
                          : SingleChildScrollView(
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _userAddressList.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 30, bottom: 8),
                                      child: Text(
                                        _userAddressList[index].type != null
                                            ? _userAddressList[index].type
                                            : '',
                                        style: TextStyle(
                                            fontFamily: Constants.app_font_bold,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'images/ic_map.svg',
                                          width: 18,
                                          height: 18,
                                          color: Color(Constants.color_theme),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, top: 2),
                                            child: Text(
                                              _userAddressList[index].address,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily:
                                                      Constants.app_font,
                                                  color: Color(
                                                      Constants.color_black)),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 10),
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context)
                                                  .push(Transitions(
                                                transitionType:
                                                    TransitionType.fade,
                                                curve: Curves.bounceInOut,
                                                reverseCurve: Curves
                                                    .fastLinearToSlowEaseIn,
                                                // widget: HereMapDemo())
                                                widget: EditAddressScreen(
                                                  addressId:
                                                      _userAddressList[index]
                                                          .id,
                                                  latitude:
                                                      _userAddressList[index]
                                                          .lat,
                                                  longitude:
                                                      _userAddressList[index]
                                                          .lang,
                                                  strAddress:
                                                      _userAddressList[index]
                                                          .address,
                                                  strAddressType:
                                                      _userAddressList[index]
                                                          .type,
                                                  userId:
                                                      _userAddressList[index]
                                                          .userId,
                                                ),
                                              ));
                                            },
                                            child: Text(
                                              Languages.of(context)
                                                  .labelEditAddress,
                                              style: TextStyle(
                                                  color: Color(
                                                      Constants.color_blue),
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize: 12),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 50),
                                            child: GestureDetector(
                                              onTap: () {
                                                showRemoveAddressdialog(
                                                    _userAddressList[index].id,
                                                    _userAddressList[index]
                                                        .address,
                                                    _userAddressList[index]
                                                        .type);
                                              },
                                              child: Text(
                                                Languages.of(context)
                                                    .labelRemoveThisAddress,
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.color_like),
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Divider(
                                      thickness: 1,
                                      color: Color(0xffcccccc),
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
          ),
        ),
      ),
    );
  }

  showRemoveAddressdialog(int id, String address, String type) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 20),
              child: Container(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context).labelRemoveAddress,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontFamily: Constants.app_font_bold,
                          ),
                        ),
                        GestureDetector(
                          child: Icon(Icons.close),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, left: 30, bottom: 8),
                          child: Text(
                            type,
                            style: TextStyle(
                                fontFamily: Constants.app_font_bold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'images/ic_map.svg',
                              width: 18,
                              height: 18,
                              color: Color(Constants.color_theme),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 2),
                                child: Text(
                                  address,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: Constants.app_font,
                                      color: Color(Constants.color_black)),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  Languages.of(context).labelNoGoBack,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: Constants.app_font_bold,
                                      color: Color(Constants.color_gray)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    callRemoveAddress(id);
                                  },
                                  child: Text(
                                    Languages.of(context).labelYesRemoveIt,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: Constants.app_font_bold,
                                        color: Color(Constants.color_blue)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  void callGetUserAddresses() {
    _userAddressList.clear();
    setState(() {
      _isSyncing = true;
    });
    RestClient(Retro_Api().Dio_Data()).user_address().then((response) {
      print(response.success);
      setState(() {
        _isSyncing = false;
      });

      if (response.success) {
        setState(() {
          _userAddressList.addAll(response.data);
        });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      setState(() {
        _isSyncing = false;
      });
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

  void callRemoveAddress(int id) {
    progressDialog.show();

    RestClient(Retro_Api().Dio_Data())
        .remove_address(
      id,
    )
        .then((response) {
      print(response.success);
      progressDialog.hide();
      if (response.success) {
        Navigator.pop(context);
        callGetUserAddresses();
      } else {
        Constants.toastMessage('Error while remove address');
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
