import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/promocode_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';

class OfferScreen extends StatefulWidget {
  final double orderAmount;
  final int restaurantId;

  const OfferScreen({Key key, this.orderAmount, this.restaurantId})
      : super(key: key);

  @override
  _OfferScreenState createState() => _OfferScreenState();
}

class _OfferScreenState extends State<OfferScreen> {
  ProgressDialog progressDialog;

  List<PromoCodeListData> _listPromocode = [];
  List<PromoCodeListData> _searchlistPromocode = [];
  TextEditingController search_controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    Constants.CheckNetwork()
        .whenComplete(() => callGetPromocodeListData(widget.restaurantId));
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
        appbarTitle: Languages.of(context).labelFoodOfferCoupons,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: viewportConstraints.maxHeight),
            child: Container(
              color: Color(0xfff6f6f6),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20),
                          top: ScreenUtil().setHeight(10)),
                      child: TextField(
                        controller: search_controller,
                        onChanged: onSearchTextChanged,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                          suffixIcon: IconButton(
                            onPressed: () => {},
                            icon: SvgPicture.asset(
                              'images/search.svg',
                              width: ScreenUtil().setWidth(20),
                              height: ScreenUtil().setHeight(20),
                              color: Color(Constants.color_gray),
                            ),
                          ),
                          hintText:
                              Languages.of(context).labelSearchRestOrCoupon,
                          hintStyle: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
                            fontFamily: Constants.app_font,
                            color: Color(Constants.color_gray),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFeeeeee),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: _listPromocode.length != 0
                        ? GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.85,
                            padding: EdgeInsets.all(10),
                            children: _searchlistPromocode.length != 0 ||
                                    search_controller.text.isNotEmpty
                                ? List.generate(_searchlistPromocode.length,
                                    (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _searchlistPromocode[
                                                              index]
                                                          .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants
                                                              .color_theme)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _searchlistPromocode[index]
                                                    .name,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _searchlistPromocode[index]
                                                    .promoCode,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _searchlistPromocode[index]
                                                  .displayText,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Color(
                                                      Constants.color_theme)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                '${Languages.of(context).labelValidUpTo} ${_searchlistPromocode[index].startEndDate.substring(_searchlistPromocode[index].startEndDate.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.color_gray),
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  })
                                : List.generate(_listPromocode.length, (index) {
                                    return Container(
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil()
                                                      .setHeight(70),
                                                  width:
                                                      ScreenUtil().setWidth(70),
                                                  imageUrl:
                                                      _listPromocode[index]
                                                          .image,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants
                                                              .color_theme)),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _listPromocode[index].name,
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                _listPromocode[index].promoCode,
                                                style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _listPromocode[index].displayText,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  fontSize:
                                                      ScreenUtil().setSp(12),
                                                  color: Color(
                                                      Constants.color_theme)),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(12)),
                                              child: Text(
                                                '${Languages.of(context).labelValidUpTo} ${_listPromocode[index].startEndDate.substring(_listPromocode[index].startEndDate.indexOf(" - ") + 1)}',
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.color_gray),
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(12)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                          )
                        : Container(
                            width: ScreenUtil().screenWidth,
                            height: ScreenUtil().screenHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image(
                                  width: ScreenUtil().setWidth(150),
                                  height: ScreenUtil().setHeight(180),
                                  image: AssetImage('images/ic_no_offer.png'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10)),
                                  child: Text(
                                    Languages.of(context).labelNoOffer,
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
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ));
  }

  callGetPromocodeListData(int restaurantId) {
    progressDialog.show();

    RestClient(Retro_Api().Dio_Data())
        .promo_code(
      restaurantId,
    )
        .then((response) {
      print(response.success);
      progressDialog.hide();
      if (response.success) {
        setState(() {
          _listPromocode.addAll(response.data);
        });
      } else {
        Constants.toastMessage('Error while remove address');
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

  void calculateDiscount(String discountType, int discount, int flatDiscount,
      int isFlat, double orderAmount) {
    double tempDisc = 0;
    if (discountType == 'percentage') {
      tempDisc = orderAmount * discount / 100;
      print('Temp Discount $tempDisc');
      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
        print('after flat disc add $tempDisc');
      }

      print('Grand Total = ${orderAmount - tempDisc}');
    } else {
      tempDisc = tempDisc + discount;

      if (isFlat == 1) {
        tempDisc = tempDisc + flatDiscount;
      }
   print('Grand Total = ${orderAmount - tempDisc}');
    }

    Navigator.pop(context);
  }

  onSearchTextChanged(String text) async {
    _searchlistPromocode.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _listPromocode.length; i++) {
      var item = _listPromocode[i];

      if (item.name.toLowerCase().contains(text.toLowerCase())) {
        _searchlistPromocode.add(item);
        _searchlistPromocode.toSet();
      }
    }

    setState(() {});
  }
}