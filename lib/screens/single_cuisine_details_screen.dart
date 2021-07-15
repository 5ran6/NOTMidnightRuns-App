import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/cuisine_vendor_details_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rating_bar/rating_bar.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';

class SingleCuisineDetailsScreen extends StatefulWidget {
  final cuisineId, strCuisineName;

  const SingleCuisineDetailsScreen(
      {Key key, this.cuisineId, this.strCuisineName})
      : super(key: key);

  @override
  _SingleCuisineDetailsScreenState createState() =>
      _SingleCuisineDetailsScreenState();
}

class _SingleCuisineDetailsScreenState
    extends State<SingleCuisineDetailsScreen> {
  List<CuisineVendorDetailsListData> _listCuisineVendorRestaurants = [];
  List<String> exploreRestaurantsFood = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.CheckNetwork()
        .whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork()
        .whenComplete(() => getCallSingleCuisineDetails(widget.cuisineId));
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: ApplicationToolbar(
        appbarTitle: widget.strCuisineName,
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
          child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 10, top: 10),
              child:
                  _listCuisineVendorRestaurants.length == 0 ||
                          _listCuisineVendorRestaurants.length == null
                      ? !_isSyncing
                          ? Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    width: ScreenUtil().setWidth(150),
                                    height: ScreenUtil().setHeight(180),
                                    image: AssetImage('images/ic_no_rest.png'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: ScreenUtil().setHeight(10)),
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
                      : ListView.builder(
                          physics: ClampingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.vertical,
                          itemCount: _listCuisineVendorRestaurants.length,
                          itemBuilder:
                              (BuildContext context, int index) =>
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve:
                                              Curves.fastLinearToSlowEaseIn,
                                          widget: Restaurants_DetailsScreen(
                                            restaurantId:
                                                _listCuisineVendorRestaurants[
                                                        index]
                                                    .id,
                                            isFav: null,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15.0),
                                            child: CachedNetworkImage(
                                              height:
                                                  ScreenUtil().setHeight(100),
                                              width: ScreenUtil().setWidth(100),
                                              imageUrl:
                                                  _listCuisineVendorRestaurants[
                                                          index]
                                                      .image,
                                              fit: BoxFit.fill,
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
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                            right: 10,
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                _listCuisineVendorRestaurants[
                                                                        index]
                                                                    .name,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Constants
                                                                            .app_font_bold,
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            16.0)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              getExploreRestaurantsFood(
                                                                  index),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      Constants
                                                                          .app_font,
                                                                  color: Color(
                                                                      Constants
                                                                          .color_gray),
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              12.0)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        top: ScreenUtil()
                                                            .setHeight(10)),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar
                                                                          .readOnly(
                                                                        initialRating: _listCuisineVendorRestaurants[index]
                                                                            .rate
                                                                            .toDouble(),
                                                                        size: ScreenUtil()
                                                                            .setWidth(15.0),
                                                                        isHalfAllowed:
                                                                            true,
                                                                        halfFilledColor:
                                                                            Color(0xFFffc107),
                                                                        halfFilledIcon:
                                                                            Icons.star_half,
                                                                        filledIcon:
                                                                            Icons.star,
                                                                        emptyIcon:
                                                                            Icons.star_border,
                                                                        emptyColor:
                                                                            Color(Constants.color_gray),
                                                                        filledColor:
                                                                            Color(0xFFffc107),
                                                                      ),
                                                                      Text(
                                                                        '(${_listCuisineVendorRestaurants[index].review})',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              ScreenUtil().setSp(12.0),
                                                                          fontFamily:
                                                                              Constants.app_font,
                                                                          color:
                                                                              Color(0xFF132229),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.only(
                                                                      right: ScreenUtil()
                                                                          .setWidth(
                                                                              10)),
                                                                  child: (() {
                                                                    if (_listCuisineVendorRestaurants[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil().setHeight(10.0),
                                                                              width: ScreenUtil().setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_listCuisineVendorRestaurants[index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil().setHeight(10.0),
                                                                              width: ScreenUtil().setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_listCuisineVendorRestaurants[index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(right: ScreenUtil().setWidth(5)),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil().setHeight(10.0),
                                                                              width: ScreenUtil().setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                          SvgPicture
                                                                              .asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height:
                                                                                ScreenUtil().setHeight(10.0),
                                                                            width:
                                                                                ScreenUtil().setHeight(10.0),
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                  }()),
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ))),
        ),
      ),
    ));
  }

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_listCuisineVendorRestaurants.isNotEmpty) {
      for (int j = 0;
          j < _listCuisineVendorRestaurants[index].cuisine.length;
          j++) {
        exploreRestaurantsFood
            .add(_listCuisineVendorRestaurants[index].cuisine[j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" , ");
  }

  void getCallSingleCuisineDetails(cuisineId) {
    _listCuisineVendorRestaurants.clear();
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).cuisine_vendor(cuisineId,).then((response) {
      setState(() {
        _isSyncing = false;
        _listCuisineVendorRestaurants.addAll(response.data);
      });
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
}
