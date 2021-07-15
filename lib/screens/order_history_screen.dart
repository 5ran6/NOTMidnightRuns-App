import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:mealup/model/order_history_list_model.dart';
import 'package:mealup/model/order_status.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/dashboard_screen.dart';
import 'package:mealup/screens/order_details_screen.dart';
import 'package:mealup/screens/order_review_screen.dart';
import 'package:mealup/screens/track_your_order_screen_here_map.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool isFromProfile;

  const OrderHistoryScreen({Key key, this.isFromProfile}) : super(key: key);

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isSyncing = false;
  List<OrderHistoryData> _listOrderHistory = [];
  List<OrderStatusData> _listOrderStatus = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Timer timer;
  int counter = 0;
  // Position currentLocation;
  LocationData _locationData;
  Location _location = Location();
  double _currentLatitude;
  double _currentLongitude;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork().whenComplete(() => callGetOrderHistoryList());

    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void dispose() {
    super.dispose();
    if (timer.isActive) {
      timer.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserLocation();
    Constants.CheckNetwork().whenComplete(() => callGetOrderHistoryList());
    timer = Timer.periodic(
        Duration(
            seconds: SharedPreferenceUtil.getInt(
                Constants.appSettingDriverAutoRefresh)), (t) {
      setState(() {
        counter++;
        print("counter++:$counter");

        Constants.CheckNetwork().whenComplete(() => callGetOrderStatus());
      });
    });
  }

  Future<void> getUserLocation() async {
    _locationData = await _location.getLocation();
    if (_locationData != null) {
      _currentLatitude = _locationData.latitude;
      _currentLongitude = _locationData.longitude;
      print('selectedLat $_currentLatitude');
      print('selectedLng $_currentLongitude');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.isFromProfile) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              Transitions(
                transitionType: TransitionType.fade,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: DashboardScreen(3),
              ),
              (Route<dynamic> route) => false);
        }
      },
      child: SafeArea(
        child: Scaffold(
          appBar: ApplicationToolbar_WithClrBtn(
            appbarTitle: Languages.of(context).labelOrderHistory,
            // str_button_title: Languages.of(context).labelClearList,
            str_button_title: "",
            btn_color: Color(Constants.color_like),
            onBtnPress: () {},
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
                    color: Color(Constants.color_screen_backgroud),
                    image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 10),
                  child:
                      _listOrderHistory.length == 0 ||
                              _listOrderHistory.length == null
                          ? !_isSyncing
                              ? Container(
                                  width: ScreenUtil().screenWidth,
                                  height: ScreenUtil().screenHeight,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image(
                                        width: ScreenUtil().setWidth(150),
                                        height: ScreenUtil().setHeight(180),
                                        image: AssetImage(
                                            'images/ic_no_order_history.png'),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(10)),
                                        child: Text(
                                          Languages.of(context)
                                              .labelNoOrderHistory,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(18),
                                            fontFamily:
                                                Constants.app_font_bold,
                                            color:
                                                Color(Constants.color_theme),
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
                                itemCount: _listOrderHistory.length,
                                itemBuilder:
                                    (BuildContext context, int index) => Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 10),
                                              child: Text(
                                                (() {
                                                  if (_listOrderHistory[index]
                                                          .addressId !=
                                                      null) {
                                                    if (_listOrderHistory[index]
                                                            .orderStatus ==
                                                        'PENDING') {
                                                      return '${Languages.of(context).labelOrderedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'ACCEPT') {
                                                      return '${Languages.of(context).labelAcceptedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'APPROVE') {
                                                      return '${Languages.of(context).labelApproveOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'REJECT') {
                                                      return '${Languages.of(context).labelRejectedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'PICKUP') {
                                                      return '${Languages.of(context).labelPickedUpOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'DELIVERED') {
                                                      return '${Languages.of(context).labelDeliveredOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'CANCEL') {
                                                      return '${Languages.of(context).labelCanceledOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'COMPLETE') {
                                                      return '${Languages.of(context).labelDeliveredOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    }
                                                  } else {
                                                    if (_listOrderHistory[index]
                                                            .orderStatus ==
                                                        'PENDING') {
                                                      return '${Languages.of(context).labelOrderedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'ACCEPT') {
                                                      return '${Languages.of(context).labelAcceptedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'APPROVE') {
                                                      return '${Languages.of(context).labelApproveOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'REJECT') {
                                                      return '${Languages.of(context).labelRejectedOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'PREPARE_FOR_ORDER') {
                                                      return '${Languages.of(context).labelPREPARE_FOR_ORDER} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'READY_FOR_ORDER') {
                                                      return '${Languages.of(context).labelREADY_FOR_ORDER} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'CANCEL') {
                                                      return '${Languages.of(context).labelCanceledOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    } else if (_listOrderHistory[
                                                                index]
                                                            .orderStatus ==
                                                        'COMPLETE') {
                                                      return '${Languages.of(context).labelDeliveredOn} ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}';
                                                    }
                                                  }
                                                }()),
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.color_gray),
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize: 12),
                                                textAlign: TextAlign.end,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                print(
                                                    " id is .. ${_listOrderHistory[index].id}");
                                                // Constants.toastMessage(_listOrderHistory[index].id.toString());
                                                Navigator.of(context).push(
                                                    Transitions(
                                                        transitionType:
                                                            TransitionType.fade,
                                                        curve:
                                                            Curves.bounceInOut,
                                                        reverseCurve: Curves
                                                            .fastLinearToSlowEaseIn,
                                                        widget:
                                                            OrderDetailsScreen(
                                                          orderId:
                                                              _listOrderHistory[
                                                                      index]
                                                                  .id,
                                                          orderDate:
                                                              _listOrderHistory[
                                                                      index]
                                                                  .date,
                                                          orderTime:
                                                              _listOrderHistory[
                                                                      index]
                                                                  .time,
                                                        )));
                                              },
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                margin: EdgeInsets.only(
                                                    top: 5,
                                                    right: 5,
                                                    bottom: 20),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15.0),
                                                            child:
                                                                CachedNetworkImage(
                                                              height:
                                                                  ScreenUtil()
                                                                      .setHeight(
                                                                          70),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          70),
                                                              imageUrl:
                                                                  _listOrderHistory[
                                                                          index]
                                                                      .vendor
                                                                      .image,
                                                              fit: BoxFit.cover,
                                                              placeholder: (context,
                                                                      url) =>
                                                                  SpinKitFadingCircle(
                                                                      color: Color(
                                                                          Constants
                                                                              .color_theme)),
                                                              errorWidget:
                                                                  (context, url,
                                                                          error) =>
                                                                      Container(
                                                                child: Center(
                                                                    child: Image
                                                                        .network(
                                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        _listOrderHistory[index]
                                                                            .vendor
                                                                            .name,
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.app_font_bold,
                                                                            fontSize: 16),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 3,
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            5),
                                                                child: Text(
                                                                  _listOrderHistory[
                                                                          index]
                                                                      .vendor
                                                                      .mapAddress,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          Constants
                                                                              .app_font,
                                                                      color: Color(
                                                                          Constants
                                                                              .color_gray),
                                                                      fontSize:
                                                                          13),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    ScreenUtil()
                                                                        .setHeight(
                                                                            10),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol) +
                                                                            '${_listOrderHistory[index].amount}',
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.app_font,
                                                                            fontSize: 14),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        top: 10,
                                                                        right:
                                                                            20),
                                                                    child:
                                                                        RichText(
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          WidgetSpan(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(right: 5),
                                                                              child: SvgPicture.asset(
                                                                                (() {
                                                                                  if (_listOrderHistory[index].addressId != null) {
                                                                                    if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                      return 'images/ic_pending.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                      return 'images/ic_pickup.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    }
                                                                                  } else {
                                                                                    if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                      return 'images/ic_pending.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                      return 'images/ic_accept.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                      return 'images/ic_pickup.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                      return 'images/ic_cancel.svg';
                                                                                    } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                      return 'images/ic_completed.svg';
                                                                                    }
                                                                                  }
                                                                                }()),
                                                                                color: (() {
                                                                                  // your code here
                                                                                  // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                                                                  if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                    return Color(Constants.color_orderPending);
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                    return Color(Constants.color_black);
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                    return Color(Constants.color_orderPickup);
                                                                                  }
                                                                                }()),
                                                                                width: 15,
                                                                                height: ScreenUtil().setHeight(15),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                              text: (() {
                                                                                if (_listOrderHistory[index].addressId != null) {
                                                                                  if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                    return Languages.of(context).labelOrderPending;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                    return Languages.of(context).labelOrderAccepted;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                    return Languages.of(context).labelOrderAccepted;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                    return Languages.of(context).labelOrderRejected;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                    return Languages.of(context).labelOrderPickedUp;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                    return Languages.of(context).labelDeliveredSuccess;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                    return Languages.of(context).labelOrderCanceled;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                    return Languages.of(context).labelOrderCompleted;
                                                                                  }
                                                                                } else {
                                                                                  if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                    return Languages.of(context).labelOrderPending;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                    return Languages.of(context).labelOrderAccepted;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                    return Languages.of(context).labelOrderAccepted;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                    return Languages.of(context).labelPREPARE_FOR_ORDER;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                    return Languages.of(context).labelREADY_FOR_ORDER;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                    return Languages.of(context).labelOrderRejected;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                    return Languages.of(context).labelOrderCompleted;
                                                                                  } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                    return Languages.of(context).labelOrderCanceled;
                                                                                  }
                                                                                }
                                                                              }()),
                                                                              style: TextStyle(
                                                                                  color: (() {
                                                                                    if (_listOrderHistory[index].addressId != null) {
                                                                                      if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                        return Color(Constants.color_orderPending);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                        return Color(Constants.color_black);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                        return Color(Constants.color_black);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                        return Color(Constants.color_like);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'PICKUP') {
                                                                                        return Color(Constants.color_orderPickup);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'DELIVERED') {
                                                                                        return Color(Constants.color_theme);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                        return Color(Constants.color_like);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                        return Color(Constants.color_theme);
                                                                                      }
                                                                                    } else {
                                                                                      if (_listOrderHistory[index].orderStatus == 'PENDING') {
                                                                                        return Color(Constants.color_orderPending);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'APPROVE') {
                                                                                        return Color(Constants.color_black);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'ACCEPT') {
                                                                                        return Color(Constants.color_black);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'REJECT') {
                                                                                        return Color(Constants.color_like);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'PREPARE_FOR_ORDER') {
                                                                                        return Color(Constants.color_orderPickup);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'READY_FOR_ORDER') {
                                                                                        return Color(Constants.color_theme);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'CANCEL') {
                                                                                        return Color(Constants.color_like);
                                                                                      } else if (_listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                        return Color(Constants.color_theme);
                                                                                      }
                                                                                    }
                                                                                  }()),
                                                                                  fontFamily: Constants.app_font,
                                                                                  fontSize: 12)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5,
                                                              top: 20),
                                                      child: DottedLine(
                                                        dashColor:
                                                            Color(0xffcccccc),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 5,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .stretch,
                                                              children: [
                                                                ListView
                                                                    .builder(
                                                                  physics:
                                                                      ClampingScrollPhysics(),
                                                                  shrinkWrap:
                                                                      true,
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  itemCount: _listOrderHistory[
                                                                          index]
                                                                      .orderItems
                                                                      .length,
                                                                  itemBuilder:
                                                                      (BuildContext context,
                                                                              int innerindex) =>
                                                                          Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        top:
                                                                            20),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              _listOrderHistory[index].orderItems[innerindex].itemName.toString(),
                                                                              style: TextStyle(fontFamily: Constants.app_font, fontSize: 12),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 5),
                                                                              child: Text(
                                                                                  (() {
                                                                                    String qty = '';
                                                                                    if (_listOrderHistory[index].orderItems.length > 0 && _listOrderHistory[index].orderItems != null) {
                                                                                      // for (int i = 0; i < _listOrderHistory[index].orderItems.length; i++) {
                                                                                      qty = ' X ${_listOrderHistory[index].orderItems[innerindex].qty.toString()}';
                                                                                      // }
                                                                                      return qty;
                                                                                    } else {
                                                                                      return '';
                                                                                    }
                                                                                  }()),
                                                                                  style: TextStyle(color: Color(Constants.color_theme), fontFamily: Constants.app_font, fontSize: 12)),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: ScreenUtil()
                                                                      .setHeight(
                                                                          10),
                                                                ),
                                                                (() {
                                                                  if (_listOrderHistory[index]
                                                                              .orderStatus ==
                                                                          'CANCEL' ||
                                                                      _listOrderHistory[index]
                                                                              .orderStatus ==
                                                                          'COMPLETE') {
                                                                    return Container(
                                                                      height: ScreenUtil()
                                                                          .setHeight(
                                                                              40),
                                                                      child:
                                                                          RaisedButton(
                                                                        color: Colors
                                                                            .white,
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.of(context).push(Transitions(
                                                                              transitionType: TransitionType.fade,
                                                                              curve: Curves.bounceInOut,
                                                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                                              widget: OrderReviewScreen(
                                                                                orderId: _listOrderHistory[index].id,
                                                                              )));
                                                                        },
                                                                        child:
                                                                            RichText(
                                                                          text:
                                                                              TextSpan(
                                                                            children: [
                                                                              WidgetSpan(
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(right: ScreenUtil().setHeight(10)),
                                                                                  child: SvgPicture.asset(
                                                                                    'images/ic_star.svg',
                                                                                    width: ScreenUtil().setWidth(20),
                                                                                    color: Color(Constants.color_rate),
                                                                                    height: ScreenUtil().setHeight(20),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: (() {
                                                                                  // your code here
                                                                                  // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                                                                  if (_listOrderHistory[index].orderStatus == 'CANCEL' || _listOrderHistory[index].orderStatus == 'COMPLETE') {
                                                                                    return Languages.of(context).labelRateNow;
                                                                                  } else {
                                                                                    return '';
                                                                                  }
                                                                                }()),
                                                                                style: TextStyle(color: Color(Constants.color_rate), fontSize: 18, fontFamily: Constants.app_font),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                                                            side: BorderSide.none),
                                                                      ),
                                                                    );
                                                                  } else if (_listOrderHistory[
                                                                              index]
                                                                          .orderStatus ==
                                                                      'ACCEPT') {
                                                                    return Container(
                                                                      height: ScreenUtil()
                                                                          .setHeight(
                                                                              40),
                                                                      child:
                                                                          RaisedButton(
                                                                        color: Color(
                                                                            0xff132229),
                                                                        onPressed:
                                                                            () async {
                                                                          await getUserLocation();
                                                                          if (_currentLatitude != null &&
                                                                              _currentLongitude != null) {
                                                                            Navigator.of(context).push(Transitions(
                                                                                transitionType: TransitionType.fade,
                                                                                curve: Curves.bounceInOut,
                                                                                reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                                                widget: TrackYourOrderScreen(
                                                                                  vendorName: _listOrderHistory[index].deliveryPerson.name,
                                                                                  vendorNumber: _listOrderHistory[index].deliveryPerson.contact,
                                                                                  vendorImage: _listOrderHistory[index].deliveryPerson.image,
                                                                                  orderId: _listOrderHistory[index].id,
                                                                                  orderTime: _listOrderHistory[index].time,
                                                                                  orderDate: _listOrderHistory[index].date,
                                                                                  shopLat: double.parse(_listOrderHistory[index].vendor.lat.toString()),
                                                                                  shopLong: double.parse(_listOrderHistory[index].vendor.lang.toString()),
                                                                                  currentLat: _currentLatitude,
                                                                                  currentLong: _currentLongitude,
                                                                                )));
                                                                          } else {
                                                                            await getUserLocation();
                                                                          }
                                                                        },
                                                                        child:
                                                                            Text(
                                                                          (() {
                                                                            // your code here
                                                                            // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                                                            if (_listOrderHistory[index].orderStatus ==
                                                                                'PENDING') {
                                                                              return '';
                                                                            }
                                                                            if (_listOrderHistory[index].orderStatus == 'ACCEPT' &&
                                                                                _listOrderHistory[index].vendor.vendor_own_driver == 0) {
                                                                              return Languages.of(context).labelTrackOrder;
                                                                            } else {
                                                                              return '';
                                                                            }
                                                                          }()),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 18,
                                                                              fontFamily: Constants.app_font),
                                                                        ),
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                                                                            side: BorderSide.none),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return Container();
                                                                  }
                                                                }()),
                                                              ],
                                                            )),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callSetState() {
    setState(
        () {}); // it can be called without parameters. It will redraw based on changes done in _SecondWidgetState
  }

  callGetOrderHistoryList() {
    _listOrderHistory.clear();
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).show_order().then((response) {
      print(response.success);
      setState(() {
        _isSyncing = false;
      });

      if (response.success) {
        setState(() {
          _listOrderHistory.addAll(response.data);
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

  callGetOrderStatus() {
    RestClient(Retro_Api().Dio_Data()).user_order_status().then((response) {
      print(response.success);

      if (response.success) {
        if (response.data.length > 0) {
          setState(() {
            _listOrderStatus.clear();
            _listOrderStatus.addAll(response.data);
            getOrderStatusText();
          });
        } else {
          if (timer.isActive) {
            timer.cancel();
          }
        }
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

  String getOrderStatusText() {
    if (_listOrderStatus.length > 0) {
      for (int j = 0; j < _listOrderHistory.length; j++) {
        for (int i = 0; i < _listOrderStatus.length; i++) {
          if (_listOrderHistory[j].id == _listOrderStatus[i].id) {
            setState(() {
              _listOrderHistory[j].orderStatus =
                  _listOrderStatus[i].orderStatus;
            });
          }
        }
      }
    }
  }
}
