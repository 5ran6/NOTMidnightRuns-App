import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/single_order_details_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OrderDetailsScreen extends StatefulWidget {
  final int orderId;
  final String orderDate, orderTime;

  const OrderDetailsScreen(
      {Key key, this.orderId, this.orderDate, this.orderTime})
      : super(key: key);

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  ProgressDialog progressDialog;
  String str_orderDate = '',
      str_venderName = '',
      str_venderAddress = '',
      str_userAddress = '',
      str_userName = '',
      str_orderStatus = 'PENDING',
      str_orderInvoiceId = '',
      str_deliveryPerson = '',
      str_deliveryPersonImage = '',
      strDeliveryCharge = '',
      strVendorDiscount = null;

  List<OrderItems> orderItemList = [];
  int subTotal = 0, couponPrice = 0, promocodeId, grandTotalAmount = 0;
  double taxAmount = 0;

  bool isAppliedCoupon = false,
      isPending = false,
      isTaxApplied = false,
      isVendorDiscount = false,
      isCanCancel = false;

  Timer timer;
  int counter = 0;

  TextEditingController _textOrderCancelReason = new TextEditingController();
  TextEditingController _textRaiseRefundRequest = new TextEditingController();

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

    Constants.CheckNetwork()
        .whenComplete(() => callGetSingleOrderDetails(widget.orderId));

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

  showCancelOrderdialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    bottom: 0,
                    top: ScreenUtil().setHeight(20)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context).labelCancelOrder,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
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
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Text(
                        Languages.of(context).labelOrderCancelReason,
                        style: TextStyle(
                            fontFamily: Constants.app_font_bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textOrderCancelReason,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: Languages.of(context)
                                    .labelTypeOrderCancelReason,
                                border: InputBorder.none),
                            maxLines: 5,
                            style: TextStyle(
                                fontFamily: Constants.app_font,
                                fontSize: 16,
                                color: Color(
                                  Constants.color_gray,
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(15)),
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
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.app_font_bold,
                                    color: Color(Constants.color_gray)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(12)),
                              child: GestureDetector(
                                onTap: () {
                                  if (_textOrderCancelReason.text.isNotEmpty) {
                                    Constants.CheckNetwork().whenComplete(() =>
                                        callCancelOrder(widget.orderId,
                                            _textOrderCancelReason.text));
                                  } else {
                                    Constants.toastMessage(Languages.of(context)
                                        .labelPleaseEnterCancelReason);
                                  }
                                },
                                child: Text(
                                  Languages.of(context).labelYesCancelIt,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  showRaiseRefundRequest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(20),
                    right: ScreenUtil().setWidth(20),
                    bottom: 0,
                    top: ScreenUtil().setHeight(20)),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Languages.of(context).labelRaiseRefundRequest,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: ScreenUtil().setSp(18),
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
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Text(
                        Languages.of(context).labelRaiseRefundRequestReason,
                        style: TextStyle(
                            fontFamily: Constants.app_font_bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textRaiseRefundRequest,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                hintText: Languages.of(context)
                                    .labelRaiseRefundRequestReason1,
                                border: InputBorder.none),
                            maxLines: 5,
                            style: TextStyle(
                                fontFamily: Constants.app_font,
                                fontSize: 16,
                                color: Color(
                                  Constants.color_gray,
                                )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(10),
                      ),
                      Divider(
                        thickness: 1,
                        color: Color(0xffcccccc),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(top: ScreenUtil().setHeight(15)),
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
                                    fontSize: ScreenUtil().setSp(14),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: Constants.app_font_bold,
                                    color: Color(Constants.color_gray)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setWidth(12)),
                              child: GestureDetector(
                                onTap: () {
                                  if (_textRaiseRefundRequest.text.isNotEmpty) {
                                    Constants.CheckNetwork().whenComplete(() =>
                                        callRefundRequest(widget.orderId,
                                            _textRaiseRefundRequest.text));
                                  } else {
                                    Constants.toastMessage(Languages.of(context)
                                        .labelPleaseEnterRaiseRefundReq);
                                  }
                                },
                                child: Text(
                                  Languages.of(context).labelYesRaiseIt,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(14),
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
                ),
              ),
            );
          },
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

    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar_WithClrBtn(
          appbarTitle: Languages.of(context).labelOrderDetails,
          str_button_title:
              isCanCancel ? Languages.of(context).labelCancelOrder : '',
          btn_color: Color(Constants.color_like),
          onBtnPress: () {
            showCancelOrderdialog();
            /*Constants.CheckNetwork()
                .whenComplete(() => callCancelOrder(widget.orderId));*/
          },
        ),
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage('images/ic_background_image.png'),
            fit: BoxFit.cover,
          )),
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 20),
                            child: Text(
                              str_orderInvoiceId,
                              style: TextStyle(
                                  fontFamily: Constants.app_font, fontSize: 25),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Text(
                              (() {
                                if (str_userAddress != null) {
                                  if (str_orderStatus == 'PENDING') {
                                    return '${Languages.of(context).labelOrderedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'APPROVE') {
                                    return '${Languages.of(context).labelAcceptedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'ACCEPT') {
                                    return '${Languages.of(context).labelOrderAccepted} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'REJECT') {
                                    return '${Languages.of(context).labelRejectedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'PICKUP') {
                                    return '${Languages.of(context).labelPickedUpOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'DELIVERED') {
                                    return '${Languages.of(context).labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}}';
                                  } else if (str_orderStatus == 'CANCEL') {
                                    return '${Languages.of(context).labelCanceledOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'COMPLETE') {
                                    return '${Languages.of(context).labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}';
                                  }
                                } else {
                                  if (str_orderStatus == 'PENDING') {
                                    return '${Languages.of(context).labelOrderedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'APPROVE') {
                                    return '${Languages.of(context).labelAcceptedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'ACCEPT') {
                                    return '${Languages.of(context).labelOrderAccepted} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'REJECT') {
                                    return '${Languages.of(context).labelRejectedOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus ==
                                      'PREPARE_FOR_ORDER') {
                                    return '${Languages.of(context).labelPREPARE_FOR_ORDER} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus ==
                                      'READY_FOR_ORDER') {
                                    return '${Languages.of(context).labelREADY_FOR_ORDER} ${widget.orderDate}, ${widget.orderTime}}';
                                  } else if (str_orderStatus == 'CANCEL') {
                                    return '${Languages.of(context).labelCanceledOn} ${widget.orderDate}, ${widget.orderTime}';
                                  } else if (str_orderStatus == 'COMPLETE') {
                                    return '${Languages.of(context).labelDeliveredOn} ${widget.orderDate}, ${widget.orderTime}';
                                  }
                                }
                              }()),
                              style: TextStyle(
                                  color: Color(Constants.color_gray),
                                  fontFamily: Constants.app_font,
                                  fontSize: 12),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: str_userAddress != null
                                  ? Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15, right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'images/ic_map.svg',
                                                    width: 18,
                                                    height: 18,
                                                    color: Color(
                                                        Constants.color_theme),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    child: Container(
                                                      height: 60,
                                                      child: DottedLine(
                                                        direction:
                                                            Axis.vertical,
                                                        dashColor: Color(
                                                            Constants
                                                                .color_black),
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                    'images/ic_home.svg',
                                                    width: 18,
                                                    height: 18,
                                                    color: Color(
                                                        Constants.color_theme),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(top: 20),
                                                height: 130,
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 65,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              str_venderName,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font_bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 3,
                                                                    left: 10,
                                                                    right: 5),
                                                            child: Text(
                                                              str_venderAddress,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font,
                                                                  color: Color(
                                                                      Constants
                                                                          .color_gray),
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 65,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              str_userName,
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font_bold,
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 3,
                                                                    left: 10,
                                                                    right: 5),
                                                            child: Text(
                                                              str_userAddress,
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
                                                                  fontSize: 13),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(10),
                                          bottom: ScreenUtil().setHeight(10),
                                          left: ScreenUtil().setWidth(10)),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'images/ic_map.svg',
                                            width: 18,
                                            height: 18,
                                            color: Color(Constants.color_theme),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10),
                                                child: Text(
                                                  str_venderName,
                                                  style: TextStyle(
                                                      fontFamily: Constants
                                                          .app_font_bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3, left: 10, right: 5),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.80,
                                                  child: Text(
                                                    str_venderAddress,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.app_font,
                                                        color: Color(Constants
                                                            .color_gray),
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: RichText(
                              textAlign: TextAlign.end,
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: SvgPicture.asset(
                                        (() {
                                          if (str_userAddress != null) {
                                            if (str_orderStatus == 'PENDING') {
                                              return 'images/ic_pending.svg';
                                            } else if (str_orderStatus ==
                                                'APPROVE') {
                                              return 'images/ic_accept.svg';
                                            } else if (str_orderStatus ==
                                                'ACCEPT') {
                                              return 'images/ic_accept.svg';
                                            } else if (str_orderStatus ==
                                                'REJECT') {
                                              return 'images/ic_cancel.svg';
                                            } else if (str_orderStatus ==
                                                'PICKUP') {
                                              return 'images/ic_pickup.svg';
                                            } else if (str_orderStatus ==
                                                'DELIVERED') {
                                              return 'images/ic_completed.svg';
                                            } else if (str_orderStatus ==
                                                'CANCEL') {
                                              return 'images/ic_cancel.svg';
                                            } else if (str_orderStatus ==
                                                'COMPLETE') {
                                              return 'images/ic_completed.svg';
                                            }
                                          } else {
                                            if (str_orderStatus == 'PENDING') {
                                              return 'images/ic_pending.svg';
                                            } else if (str_orderStatus ==
                                                'APPROVE') {
                                              return 'images/ic_accept.svg';
                                            } else if (str_orderStatus ==
                                                'ACCEPT') {
                                              return 'images/ic_accept.svg';
                                            } else if (str_orderStatus ==
                                                'REJECT') {
                                              return 'images/ic_cancel.svg';
                                            } else if (str_orderStatus ==
                                                'PREPARE_FOR_ORDER') {
                                              return 'images/ic_pickup.svg';
                                            } else if (str_orderStatus ==
                                                'READY_FOR_ORDER') {
                                              return 'images/ic_completed.svg';
                                            } else if (str_orderStatus ==
                                                'CANCEL') {
                                              return 'images/ic_cancel.svg';
                                            } else if (str_orderStatus ==
                                                'COMPLETE') {
                                              return 'images/ic_completed.svg';
                                            }
                                          }
                                        }()),
                                        color: (() {
                                          // your code here
                                          // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                          if (str_orderStatus == 'PENDING') {
                                            return Color(
                                                Constants.color_orderPending);
                                          } else if (str_orderStatus ==
                                              'ACCEPT') {
                                            return Color(Constants.color_black);
                                          } else if (str_orderStatus ==
                                              'PICKUP') {
                                            return Color(
                                                Constants.color_orderPickup);
                                          }
                                        }()),
                                        width: 15,
                                        height: ScreenUtil().setHeight(15),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                      text: (() {
                                        // your code here
                                        // _listOrderHistory[index].orderStatus == 'PENDING' ? 'Ordered on ${_listOrderHistory[index].date}, ${_listOrderHistory[index].time}' : 'Delivered on October 10,2020, 09:23pm',
                                        if (str_userAddress != null) {
                                          if (str_orderStatus == 'PENDING') {
                                            return Languages.of(context)
                                                .labelOrderPending;
                                          } else if (str_orderStatus ==
                                              'APPROVE') {
                                            return Languages.of(context)
                                                .labelOrderAccepted;
                                          } else if (str_orderStatus ==
                                              'ACCEPT') {
                                            return Languages.of(context)
                                                .labelOrderAccepted;
                                          } else if (str_orderStatus ==
                                              'REJECT') {
                                            return Languages.of(context)
                                                .labelOrderRejected;
                                          } else if (str_orderStatus ==
                                              'PICKUP') {
                                            return Languages.of(context)
                                                .labelOrderPickedUp;
                                          } else if (str_orderStatus ==
                                              'DELIVERED') {
                                            return Languages.of(context)
                                                .labelDeliveredSuccess;
                                          } else if (str_orderStatus ==
                                              'CANCEL') {
                                            return Languages.of(context)
                                                .labelOrderCanceled;
                                          } else if (str_orderStatus ==
                                              'COMPLETE') {
                                            return Languages.of(context)
                                                .labelOrderCompleted;
                                          }
                                        } else {
                                          if (str_orderStatus == 'PENDING') {
                                            return Languages.of(context)
                                                .labelOrderPending;
                                          } else if (str_orderStatus ==
                                              'APPROVE') {
                                            return Languages.of(context)
                                                .labelOrderAccepted;
                                          } else if (str_orderStatus ==
                                              'ACCEPT') {
                                            return Languages.of(context)
                                                .labelOrderAccepted;
                                          } else if (str_orderStatus ==
                                              'REJECT') {
                                            return Languages.of(context)
                                                .labelOrderRejected;
                                          } else if (str_orderStatus ==
                                              'PREPARE_FOR_ORDER') {
                                            return Languages.of(context)
                                                .labelPREPARE_FOR_ORDER;
                                          } else if (str_orderStatus ==
                                              'READY_FOR_ORDER') {
                                            return Languages.of(context)
                                                .labelREADY_FOR_ORDER;
                                          } else if (str_orderStatus ==
                                              'CANCEL') {
                                            return Languages.of(context)
                                                .labelOrderCanceled;
                                          } else if (str_orderStatus ==
                                              'COMPLETE') {
                                            return Languages.of(context)
                                                .labelOrderCompleted;
                                          }
                                        }
                                      }()),
                                      style: TextStyle(
                                          color: (() {
                                            // your code here
                                            if (str_userAddress != null) {
                                              if (str_orderStatus ==
                                                  'PENDING') {
                                                return Color(Constants
                                                    .color_orderPending);
                                              } else if (str_orderStatus ==
                                                  'APPROVE') {
                                                return Color(
                                                    Constants.color_black);
                                              } else if (str_orderStatus ==
                                                  'ACCEPT') {
                                                return Color(
                                                    Constants.color_black);
                                              } else if (str_orderStatus ==
                                                  'REJECT') {
                                                return Color(
                                                    Constants.color_like);
                                              } else if (str_orderStatus ==
                                                  'DELIVERED') {
                                                return Color(
                                                    Constants.color_theme);
                                              } else if (str_orderStatus ==
                                                  'PICKUP') {
                                                return Color(Constants
                                                    .color_orderPickup);
                                              } else if (str_orderStatus ==
                                                  'CANCEL') {
                                                return Color(
                                                    Constants.color_like);
                                              } else if (str_orderStatus ==
                                                  'COMPLETE') {
                                                return Color(
                                                    Constants.color_theme);
                                              }
                                            } else {
                                              if (str_orderStatus ==
                                                  'PENDING') {
                                                return Color(Constants
                                                    .color_orderPending);
                                              } else if (str_orderStatus ==
                                                  'APPROVE') {
                                                return Color(
                                                    Constants.color_black);
                                              } else if (str_orderStatus ==
                                                  'ACCEPT') {
                                                return Color(
                                                    Constants.color_black);
                                              } else if (str_orderStatus ==
                                                  'REJECT') {
                                                return Color(
                                                    Constants.color_like);
                                              } else if (str_orderStatus ==
                                                  'PREPARE_FOR_ORDER') {
                                                return Color(
                                                    Constants.color_theme);
                                              } else if (str_orderStatus ==
                                                  'READY_FOR_ORDER') {
                                                return Color(Constants
                                                    .color_orderPickup);
                                              } else if (str_orderStatus ==
                                                  'CANCEL') {
                                                return Color(
                                                    Constants.color_like);
                                              } else if (str_orderStatus ==
                                                  'COMPLETE') {
                                                return Color(
                                                    Constants.color_theme);
                                              }
                                            }
                                          }()),
                                          fontFamily: Constants.app_font,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          isPending
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: Container(
                                      height: 100,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Languages.of(context)
                                                      .labelDeliveredBy,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: Constants
                                                          .app_font_bold,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                                Text(
                                                  str_deliveryPerson,
                                                  style: TextStyle(
                                                      color: Color(
                                                          Constants.color_gray),
                                                      fontFamily:
                                                          Constants.app_font),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                  right:
                                                      ScreenUtil().setWidth(15),
                                                  bottom: ScreenUtil()
                                                      .setHeight(15)),
                                              child: Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                  child: CachedNetworkImage(
                                                    height: ScreenUtil()
                                                        .setHeight(50),
                                                    width: ScreenUtil()
                                                        .setWidth(50),
                                                    imageUrl:
                                                        str_deliveryPersonImage,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        SpinKitFadingCircle(
                                                            color: Color(Constants
                                                                .color_theme)),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Container(
                                                      child: Center(
                                                          child: Image.asset(
                                                              'images/noimage.png')),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListView.builder(
                                  itemCount: orderItemList.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, position) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15, bottom: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    orderItemList[position]
                                                        .itemName,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.app_font,
                                                        fontSize: ScreenUtil()
                                                            .setSp(16)),
                                                  ),
                                                  Text(
                                                    ' X ' +
                                                        orderItemList[position]
                                                            .qty
                                                            .toString(),
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.app_font,
                                                        color: Color(Constants
                                                            .color_theme),
                                                        fontSize: ScreenUtil()
                                                            .setSp(14)),
                                                  ),
                                                ],
                                              ),
                                              orderItemList[position]
                                                              .custimization !=
                                                          null &&
                                                      orderItemList[position]
                                                              .custimization
                                                              .length >
                                                          0
                                                  ? Container(
                                                      child: Text(
                                                        Languages.of(context)
                                                            .labelCustomizable,
                                                        style: TextStyle(
                                                            color: Color(Constants
                                                                .color_theme),
                                                            fontFamily:
                                                                Constants
                                                                    .app_font),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Text(
                                                SharedPreferenceUtil.getString(
                                                        Constants
                                                            .appSettingCurrencySymbol) +
                                                    orderItemList[position]
                                                        .price
                                                        .toString(),
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize: 14)),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Color(Constants.color_gray),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context).labelSubtotal,
                                      style: TextStyle(
                                          fontFamily: Constants.app_font,
                                          fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        SharedPreferenceUtil.getString(Constants
                                                .appSettingCurrencySymbol) +
                                            subTotal.toString(),
                                        style: TextStyle(
                                            fontFamily: Constants.app_font,
                                            fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Color(Constants.color_gray),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context).labelDeliveryCharge,
                                      style: TextStyle(
                                          fontFamily: Constants.app_font,
                                          fontSize: 16),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Text(
                                        '+ ' +
                                            SharedPreferenceUtil.getString(
                                                Constants
                                                    .appSettingCurrencySymbol) +
                                            strDeliveryCharge,
                                        style: TextStyle(
                                            fontFamily: Constants.app_font,
                                            fontSize: 14),
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: DottedLine(
                                    direction: Axis.horizontal,
                                    dashColor: Color(Constants.color_gray),
                                  ),
                                ),
                                isAppliedCoupon
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    Languages.of(context)
                                                        .labelAppliedCoupon,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.app_font,
                                                        fontSize: 16),
                                                  ),
                                                  Text(
                                                    '',
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontFamily:
                                                            Constants.app_font,
                                                        color: Color(Constants
                                                            .color_theme),
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Text(
                                                  '- ' +
                                                      SharedPreferenceUtil
                                                          .getString(Constants
                                                              .appSettingCurrencySymbol) +
                                                      ' ' +
                                                      couponPrice.toString(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.app_font,
                                                      color: Color(
                                                          Constants.color_like),
                                                      fontSize: 14),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 20, bottom: 20),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor:
                                                  Color(Constants.color_gray),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                isTaxApplied
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context).labelTax,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(16)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  "+ ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                      taxAmount
                                                          .toInt()
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(20),
                                                bottom:
                                                    ScreenUtil().setHeight(20)),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor:
                                                  Color(Constants.color_gray),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                isVendorDiscount
                                    ? Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)
                                                    .labelVendorDiscount,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(16)),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  "- ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                                                      strVendorDiscount,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: ScreenUtil().setHeight(20),
                                                bottom:
                                                    ScreenUtil().setHeight(20)),
                                            child: DottedLine(
                                              direction: Axis.horizontal,
                                              dashColor:
                                                  Color(Constants.color_gray),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context).labelGrandTotal,
                                        style: TextStyle(
                                            fontFamily: Constants.app_font,
                                            color: Color(Constants.color_theme),
                                            fontSize: 16),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Text(
                                          SharedPreferenceUtil.getString(Constants
                                                  .appSettingCurrencySymbol) +
                                              grandTotalAmount.toString(),
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color:
                                                  Color(Constants.color_theme),
                                              fontSize: 14),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      str_orderStatus == 'CANCEL' ||
                              str_orderStatus == 'COMPLETE'
                          ? Padding(
                              padding: EdgeInsets.all(15.0),
                              child: RoundedCornerAppButton(
                                onPressed: () {
                                  showRaiseRefundRequest();
                                },
                                btn_lable: Languages.of(context)
                                    .labelRaiseRefundRequest,
                              ),
                            )
                          : Container(),
                      SizedBox(
                        height: ScreenUtil().setHeight(15),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  callGetOrderStatus() {
    RestClient(Retro_Api().Dio_Data()).user_order_status().then((response) {
      print(response.success);

      if (response.success) {
        if (response.data.length > 0) {
          setState(() {
            for (int i = 0; i < response.data.length; i++) {
              if (widget.orderId == response.data[i].id) {
                setState(() {
                  str_orderStatus = response.data[i].orderStatus;
                });
              }
            }
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

  callGetSingleOrderDetails(int orderId) {
    progressDialog.show();

    RestClient(Retro_Api().Dio_Data()).single_order(orderId).then((response) {
      print('single order ${response.success}');
      progressDialog.hide();
      setState(() {
        if (response.data.userAddress != null) {
          str_userAddress = response.data.userAddress.address;
        } else {
          str_userAddress = null;
        }

        str_userName = response.data.user.name;
        str_orderInvoiceId = response.data.orderId;

        str_venderName = response.data.vendor.name;
        str_venderAddress = response.data.vendor.mapAddress;
        str_orderStatus = response.data.orderStatus;

        orderItemList.addAll(response.data.orderItems);
        promocodeId = response.data.promocodeId;
        strDeliveryCharge = response.data.delivery_charge.toString();

        if (response.data.vendorDiscountPrice != null) {
          strVendorDiscount = response.data.vendorDiscountPrice.toString();
          isVendorDiscount = true;
        } else {
          strVendorDiscount = '0.0';
        }

        for (int i = 0; i < orderItemList.length; i++) {
          subTotal += orderItemList[i].price;
        }

        if (response.data.vendor.tax.isNotEmpty &&
            response.data.vendor.tax != null) {
          if (subTotal != 0) {
            taxAmount = double.parse(response.data.tax.toString());
            isTaxApplied = true;
          }
        }

        if (response.data.delivery_charge == null) {
          strDeliveryCharge = '0';
        } else {
          strDeliveryCharge = response.data.delivery_charge.toString();
        }

        grandTotalAmount = response.data.amount;
        if (promocodeId != null) {
          isAppliedCoupon = true;
          couponPrice = response.data.promocodePrice;
        } else {
          isAppliedCoupon = false;
        }

        if (str_orderStatus == 'CANCEL' ||
            str_orderStatus == 'COMPLETE' ||
            str_orderStatus == 'DELIVERED') {
          isCanCancel = false;
        } else {
          isCanCancel = true;
        }

        if (response.data.deliveryPerson != null) {
          isPending = false;
          str_deliveryPerson = response.data.deliveryPerson.firstName +
              ' ' +
              response.data.deliveryPerson.lastName;
          str_deliveryPersonImage = response.data.deliveryPerson.image;
        } else {
          isPending = true;
        }
      });
    }).catchError((Object obj) {
      progressDialog.hide();
      print('error is ${obj.toString()}');
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

  void callRefundRequest(int orderId, String refundRequestReason) {
    progressDialog.show();

    Map<String, String> body = {
      'order_id': orderId.toString(),
      'refund_reason': refundRequestReason,
    };

    RestClient(Retro_Api().Dio_Data()).refund(body).then((response) {
      progressDialog.hide();
      if (response.success) {
        Navigator.pop(context);
        Constants.toastMessage(response.data);
        Constants.CheckNetwork()
            .whenComplete(() => callGetSingleOrderDetails(widget.orderId));
      } else {
        Navigator.pop(context);
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

  void callCancelOrder(int orderId, String cancelReason) {
    progressDialog.show();

    Map<String, String> body = {
      'id': orderId.toString(),
      'cancel_reason': cancelReason,
    };

    RestClient(Retro_Api().Dio_Data()).cancel_order(body).then((response) {
      progressDialog.hide();
      if (response.success) {
        Constants.toastMessage(response.data);
        Constants.CheckNetwork()
            .whenComplete(() => callGetSingleOrderDetails(widget.orderId));
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
