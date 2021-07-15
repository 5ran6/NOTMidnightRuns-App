import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/model/cartmodel.dart';
import 'package:mealup/model/customization_item_model.dart';
import 'package:mealup/model/single_restaurants_details_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/dashboard_screen.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/database_helper.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scoped_model/scoped_model.dart';

final dbHelper = DatabaseHelper.instance;
List<Product> _listCart = [];

double totalCartAmount = 0;
int totalQty = 0;
List<bool> _listFinalCustomizationCheck = [];

class Restaurants_DetailsScreen extends StatefulWidget {
  final int restaurantId;
  final bool isFav;

  const Restaurants_DetailsScreen(
      {Key key, @required this.restaurantId, this.isFav})
      : super(key: key);

  @override
  _Restaurants_DetailsScreenState createState() =>
      _Restaurants_DetailsScreenState();
}

class _Restaurants_DetailsScreenState extends State<Restaurants_DetailsScreen> {
  bool _keyboardIsVisible() {
    return !(MediaQuery.of(context).viewInsets.bottom == 0.0);
  }

  bool isNotSearch = true;
  TextEditingController search_controller = new TextEditingController();
  bool _isSyncing = false;
  String strRestaurantsName = '',
      strRestaurantsAddress = '',
      strRestaurantsRate = '',
      strRestaurantsForTwoPerson = '',
      strRestaurantsType = '',
      strRestaurantsReview = '',
      strRestaurantImage =
          'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png';
  List<RestaurantsDetailsMenuListData> _listRestaurantsMenu = [];
  List<RestaurantsDetailsMenuListData> _searchlistRestaurantsMenu = [];
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isfavorite;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void callSetState() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    Constants.CheckNetwork()
        .whenComplete(() => callGetRestaurantsDetails(widget.restaurantId));
    if (widget.isFav != null) {
      isfavorite = widget.isFav;
    }

    _queryFirst(context);
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

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        bottomNavigationBar: Visibility(
          visible: ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                      .cart
                      .length !=
                  0
              ? true
              : false,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                Transitions(
                  transitionType: TransitionType.slideUp,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  widget: DashboardScreen(2),
                ),
              );
            },
            child: Container(
              height: ScreenUtil().setHeight(50),
              color: Color(Constants.color_black),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(25)),
                    child: Text(
                      '${Languages.of(context).labelTotalItem} $totalQty' +
                          " : ${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} " +
                          totalCartAmount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: Constants.app_font,
                        fontSize: ScreenUtil().setSp(16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: Languages.of(context).labelContinue,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: Constants.app_font,
                                fontSize: ScreenUtil().setSp(18)),
                          ),
                          WidgetSpan(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setHeight(10)),
                              child: SvgPicture.asset(
                                'images/ic_green_arrow.svg',
                                width: ScreenUtil().setWidth(18),
                                color: Color(Constants.color_theme),
                                height: ScreenUtil().setHeight(18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(Transitions(
                      transitionType: TransitionType.slideUp,
                      curve: Curves.bounceInOut,
                      reverseCurve: Curves.fastLinearToSlowEaseIn,
                      widget: OfferScreen(
                        restaurantId: widget.restaurantId,
                      )));
                },
                child: SvgPicture.asset(
                  'images/offers.svg',
                  width: 18,
                  height: ScreenUtil().setHeight(18),
                ),
              ),
            ),
            widget.isFav != null
                ? GestureDetector(
                    onTap: () {
                      if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                        callAddRemoveFavorite(widget.restaurantId);
                      } else {
                        Constants.toastMessage(Languages.of(context)
                            .labelPleaseLoginToAddFavorite);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: SvgPicture.asset(
                        isfavorite
                            ? 'images/ic_filled_heart.svg'
                            : 'images/ic_heart.svg',
                        height: ScreenUtil().setHeight(20),
                        width: ScreenUtil().setWidth(20),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _isSyncing,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage('images/ic_background_image.png'),
              fit: BoxFit.cover,
            )),
            child: Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(15),
                  right: ScreenUtil().setWidth(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: !_keyboardIsVisible(),
                    child: ListView(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        Container(
                          height: ScreenUtil().setHeight(100),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: CachedNetworkImage(
                                  height: ScreenUtil().setHeight(70),
                                  width: ScreenUtil().setWidth(70),
                                  imageUrl: strRestaurantImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      SpinKitFadingCircle(
                                          color: Color(Constants.color_theme)),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    child: Center(
                                        child: Image.network(
                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        strRestaurantsName,
                                        style: TextStyle(
                                            fontFamily: Constants.app_font_bold,
                                            fontSize: ScreenUtil().setSp(16)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: ScreenUtil().setHeight(2),
                                            bottom: ScreenUtil().setHeight(2)),
                                        child: Text(
                                          strRestaurantsAddress,
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color:
                                                  Color(Constants.color_black),
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ),
                                      Text(
                                        '',
                                        style: TextStyle(
                                            fontFamily: Constants.app_font,
                                            color: Color(Constants.color_gray),
                                            fontSize: ScreenUtil().setSp(12)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(15),
                        ),
                        DottedLine(
                          dashColor: Color(0xffcccccc),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(10),
                                          bottom: ScreenUtil().setHeight(5)),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            WidgetSpan(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil()
                                                        .setWidth(5)),
                                                child: SvgPicture.asset(
                                                  'images/ic_star.svg',
                                                  width:
                                                      ScreenUtil().setWidth(15),
                                                  height: ScreenUtil()
                                                      .setHeight(15),
                                                ),
                                              ),
                                            ),
                                            TextSpan(
                                                text: strRestaurantsReview,
                                                style: TextStyle(
                                                    color: Color(
                                                        Constants.color_black),
                                                    fontFamily:
                                                        Constants.app_font_bold,
                                                    fontSize: ScreenUtil()
                                                        .setSp(14))),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$strRestaurantsRate+ ${Languages.of(context).labelRatings}',
                                      style: TextStyle(
                                          fontFamily: Constants.app_font,
                                          color: Color(Constants.color_gray),
                                          fontSize: ScreenUtil().setSp(12)),
                                    ),
                                  ],
                                ),
                              ),
                              DottedLine(
                                dashColor: Color(0xffcccccc),
                                direction: Axis.vertical,
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(5),
                                          bottom: ScreenUtil().setHeight(5)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            SharedPreferenceUtil.getString(
                                                Constants
                                                    .appSettingCurrencySymbol),
                                            style: TextStyle(
                                                fontFamily: Constants.app_font,
                                                color: Color(
                                                    Constants.color_theme),
                                                fontSize:
                                                    ScreenUtil().setSp(18)),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: ScreenUtil().setWidth(5)),
                                            child: Text(
                                              strRestaurantsForTwoPerson,
                                              style: TextStyle(
                                                  fontFamily:
                                                      Constants.app_font,
                                                  color: Color(
                                                      Constants.color_black),
                                                  fontSize:
                                                      ScreenUtil().setSp(16)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Languages.of(context).labelFor2Persons,
                                      style: TextStyle(
                                          fontFamily: Constants.app_font,
                                          color: Color(Constants.color_gray),
                                          fontSize: ScreenUtil().setSp(12)),
                                    ),
                                  ],
                                ),
                              ),
                              DottedLine(
                                dashColor: Color(0xffcccccc),
                                direction: Axis.vertical,
                              ),
                              (() {
                                if (strRestaurantsType == 'veg') {
                                  return Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(5)),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right:
                                                    ScreenUtil().setWidth(5)),
                                            child: SvgPicture.asset(
                                              'images/ic_veg.svg',
                                              width: ScreenUtil().setWidth(15),
                                              height:
                                                  ScreenUtil().setHeight(15),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Veg.',
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color:
                                                  Color(Constants.color_gray),
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (strRestaurantsType == 'non_veg') {
                                  return Expanded(
                                    flex: 1,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(5)),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                right:
                                                    ScreenUtil().setWidth(5)),
                                            child: SvgPicture.asset(
                                              'images/ic_non_veg.svg',
                                              width: ScreenUtil().setWidth(15),
                                              height:
                                                  ScreenUtil().setHeight(15),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Non Veg.',
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color:
                                                  Color(Constants.color_gray),
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (strRestaurantsType == 'all') {
                                  return Expanded(
                                    flex: 1,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              bottom:
                                                  ScreenUtil().setHeight(5)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: ScreenUtil()
                                                        .setWidth(5)),
                                                child: SvgPicture.asset(
                                                  'images/ic_veg.svg',
                                                  width:
                                                      ScreenUtil().setWidth(15),
                                                  height: ScreenUtil()
                                                      .setHeight(15),
                                                ),
                                              ),
                                              SvgPicture.asset(
                                                'images/ic_non_veg.svg',
                                                width:
                                                    ScreenUtil().setWidth(15),
                                                height:
                                                    ScreenUtil().setHeight(15),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'Veg. & Non Veg.',
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color:
                                                  Color(Constants.color_gray),
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              }()),
                            ],
                          ),
                        ),
                        DottedLine(
                          dashColor: Color(0xffcccccc),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10),
                                    top: ScreenUtil().setHeight(2),
                                    bottom: ScreenUtil().setHeight(2)),
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    if (hasFocus) {
                                      setState(() {
                                        isNotSearch = false;
                                      });
                                    } else {
                                      setState(() {
                                        isNotSearch = true;
                                      });
                                    }
                                  },
                                  child: TextField(
                                    controller: search_controller,
                                    onChanged: onSearchTextChanged,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(10)),
                                      suffixIcon: IconButton(
                                        onPressed: () => {},
                                        icon: SvgPicture.asset(
                                          'images/search.svg',
                                          width: ScreenUtil().setWidth(15),
                                          height: ScreenUtil().setHeight(15),
                                          color: Color(Constants.color_black),
                                        ),
                                      ),
                                      hintText: Languages.of(context)
                                          .labelSearchItems,
                                      hintStyle: TextStyle(
                                        fontSize: ScreenUtil().setSp(16),
                                        fontFamily: Constants.app_font,
                                        color: Color(Constants.color_gray),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenUtil().setWidth(55),
                          height: ScreenUtil().setHeight(55),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: SvgPicture.asset(
                                'images/ic_filter.svg',
                                width: ScreenUtil().setWidth(18),
                                height: ScreenUtil().setHeight(18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: _searchlistRestaurantsMenu.length != 0 ||
                              search_controller.text.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: _searchlistRestaurantsMenu.length,
                              itemBuilder: (context, i) {
                                return ExpandedListItem(
                                  restaurantsId: widget.restaurantId,
                                  index: i,
                                  listRestaurantsMenu:
                                      _searchlistRestaurantsMenu,
                                  restaurantsName: strRestaurantsName,
                                  onSetState: callSetState,
                                  restaurantsImage: strRestaurantImage,
                                );
                              },
                            )
                          : ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: _listRestaurantsMenu.length,
                              itemBuilder: (context, i) {
                                return ExpandedListItem(
                                  restaurantsId: widget.restaurantId,
                                  index: i,
                                  listRestaurantsMenu: _listRestaurantsMenu,
                                  restaurantsName: strRestaurantsName,
                                  onSetState: callSetState,
                                  restaurantsImage: strRestaurantImage,
                                );
                              },
                            ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callAddRemoveFavorite(int vegRestId) {
    Map<String, String> body = {
      'id': vegRestId.toString(),
    };
    RestClient(Retro_Api().Dio_Data()).faviroute(body).then((response) {
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        setState(() {
          isfavorite = !isfavorite;
        });
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileUpdate);
      }
    }).catchError((Object obj) {
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

  void callGetRestaurantsDetails(int restaurantId) {
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data())
        .single_vendor(
      restaurantId,
    )
        .then((response) {
      print(response.success);

      if (response.success) {
        setState(() {
          _isSyncing = false;
          strRestaurantsType = response.data.vendor.vendorType;
          strRestaurantsName = response.data.vendor.name;
          strRestaurantsForTwoPerson = response.data.vendor.forTwoPerson;
          strRestaurantsRate = response.data.vendor.rate.toString();
          strRestaurantsReview = response.data.vendor.review.toString();
          strRestaurantsAddress = response.data.vendor.mapAddress;
          _listRestaurantsMenu.addAll(response.data.menu);

          strRestaurantImage = response.data.vendor.image;

          _listCart.addAll(
              ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart);

          if (_listCart.length != null || _listCart.length != 0) {
            for (int i = 0; i < _listCart.length; i++) {
              if (_listRestaurantsMenu.length != null ||
                  _listRestaurantsMenu.length != 0) {
                for (int j = 0; j < _listRestaurantsMenu.length; j++) {
                  for (int k = 0;
                      k < _listRestaurantsMenu[j].submenu.length;
                      k++) {
                    bool isRepeatCustomization;
                    int repeatcustomization =
                        _listCart[i].isRepeatCustomization;
                    if (repeatcustomization == 1) {
                      isRepeatCustomization = true;
                    } else {
                      isRepeatCustomization = false;
                    }
                    if (_listRestaurantsMenu[j].submenu[k].id ==
                        _listCart[i].id) {
                      _listRestaurantsMenu[j].submenu[k].isAdded = true;
                      _listRestaurantsMenu[j].submenu[k].count =
                          _listCart[i].qty;
                      _listRestaurantsMenu[j].submenu[k].isRepeatCustomization =
                          isRepeatCustomization;
                    }
                  }
                }
              }
            }
          }
        });
      } else {
        Constants.toastMessage('Error while getting details');
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

  onSearchTextChanged(String text) async {
    _searchlistRestaurantsMenu.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (int i = 0; i < _listRestaurantsMenu.length; i++) {
      for (int j = 0; j < _listRestaurantsMenu[i].submenu.length; j++) {
        var submenu = _listRestaurantsMenu[i].submenu[j];
        var item = _listRestaurantsMenu[i];

        if (item.name.toLowerCase().contains(text.toLowerCase()) ||
            submenu.name.toLowerCase().contains(text.toLowerCase())) {
          _searchlistRestaurantsMenu.add(item);
          _searchlistRestaurantsMenu.toSet();
        }
      }
    }

    setState(() {});
  }
}

void _queryFirst(BuildContext context) async {
  CartModel model = CartModel();

  double tempTotal1 = 0, tempTotal2 = 0;
  _listCart.clear();
  totalCartAmount = 0;
  totalQty = 0;
  final allRows = await dbHelper.queryAllRows();
  print('query all rows:');
  allRows.forEach((row) => print(row));
  for (int i = 0; i < allRows.length; i++) {
    _listCart.add(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
      tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      itemQty: allRows[i]['itemQty'],
      isCustomization: allRows[i]['isCustomization'],
    ));

    model.addProduct(Product(
      id: allRows[i]['pro_id'],
      restaurantsName: allRows[i]['restName'],
      title: allRows[i]['pro_name'],
      imgUrl: allRows[i]['pro_image'],
      price: double.parse(allRows[i]['pro_price']),
      qty: allRows[i]['pro_qty'],
      restaurantsId: allRows[i]['restId'],
      restaurantImage: allRows[i]['restImage'],
      foodCustomization: allRows[i]['pro_customization'],
      isRepeatCustomization: allRows[i]['isRepeatCustomization'],
    ));
    if (allRows[i]['pro_customization'] == '') {
      totalCartAmount +=
          double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      tempTotal1 +=
          double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
    } else {
      totalCartAmount +=
          double.parse(allRows[i]['pro_price']) + totalCartAmount;
      tempTotal2 += double.parse(allRows[i]['pro_price']);
    }

    print(totalCartAmount);

    print('First cart model cart data' +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .toString());
    print('First cart Listcart array' + _listCart.length.toString());
    print('First cart listcart string' + _listCart.toString());

    totalQty += allRows[i]['pro_qty'];
    print(totalQty);
  }

  print('TempTotal1 $tempTotal1');
  print('TempTotal2 $tempTotal2');
  totalCartAmount = tempTotal1 + tempTotal2;
}

class ExpandedListItem extends StatefulWidget {
  final int index;

  List<RestaurantsDetailsMenuListData> listRestaurantsMenu = [];

  final Function onSetState;
  final int restaurantsId;
  final String restaurantsName;
  final String restaurantsImage;

  List<Product> _products = [];

  int selected = 0;

  ExpandedListItem(
      {Key key,
      this.index,
      this.listRestaurantsMenu,
      this.restaurantsId,
      this.restaurantsName,
      this.onSetState,
      this.restaurantsImage})
      : super(key: key);

  @override
  _ExpandedListItemState createState() => _ExpandedListItemState();
}

class _ExpandedListItemState extends State<ExpandedListItem> {
  @override
  Widget build(BuildContext context) {
    int selected = 0; //attention

    List<SubMenuListData> listItem = widget.listRestaurantsMenu[this.widget.index].submenu;

    final theme =
        Theme.of(context).copyWith(dividerColor: Colors.transparent); //new

    return ScopedModelDescendant<CartModel>(builder: (context, child, model) {
      return Container(
        child: Theme(
          data: theme,
          child: ExpansionTile(
            initiallyExpanded: widget.index == selected,
            onExpansionChanged: (value) {
              if (listItem.length == 0 || listItem.length == null) {
                Constants.toastMessage('No data.');
              }
              if (value) {
                setState(() {
                  Duration(seconds: 20000);
                  selected = widget.index;
                });
              } else {
                selected = -1;
              }
            },
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            trailing: SizedBox.shrink(),
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.listRestaurantsMenu[widget.index].name,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(16),
                        fontWeight: FontWeight.bold,
                        fontFamily: Constants.app_font,
                        color: Color(Constants.color_black)),
                  ),
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SvgPicture.asset(
                        'images/ic_green_arrow.svg',
                        width: 15,
                        height: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            children: <Widget>[
              new Column(
                children: _buildExpandableContent(
                  context,
                  listItem,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  _buildExpandableContent(BuildContext context, List<SubMenuListData> submenu) {
    List<Widget> columnContent = [];

    for (int i = 0; i < submenu.length; i++) {
      SubMenuListData item = submenu[i];

      columnContent.add(
        ScopedModelDescendant<CartModel>(
          builder: (context, child, model) {
            return GestureDetector(
              onTap: () {},
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      right: 10, top: 5, bottom: 5, left: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: CachedNetworkImage(
                          height: ScreenUtil().setHeight(70),
                          width: ScreenUtil().setWidth(70),
                          imageUrl: item.image,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => SpinKitFadingCircle(
                              color: Color(Constants.color_theme)),
                          errorWidget: (context, url, error) => Container(
                            child: Center(
                                child: Image.network(
                                    'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(10),
                                    right: ScreenUtil().setWidth(10),
                                    top: ScreenUtil().setWidth(10),
                                  ),
                                  child: Row(
                                    children: [
                                      item.type == 'veg' ? SvgPicture.asset(
                                    'images/ic_veg.svg',
                                    width: ScreenUtil().setWidth(15),
                                    height: ScreenUtil().setHeight(15),
                                  ) : SvgPicture.asset(
                                        'images/ic_non_veg.svg',
                                        width: ScreenUtil().setWidth(15),
                                        height: ScreenUtil().setHeight(15),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(6),
                                        ),
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                              fontFamily:
                                                  Constants.app_font_bold,
                                              fontSize: ScreenUtil().setSp(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: ScreenUtil().setWidth(170),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(10),
                                        top: ScreenUtil().setWidth(2)),
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                          fontFamily: Constants.app_font,
                                          color: Color(Constants.color_gray),
                                          fontSize: ScreenUtil().setSp(12)),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(10),
                                      top: ScreenUtil().setHeight(10)),
                                  child: Text(
                                    SharedPreferenceUtil.getString(Constants
                                            .appSettingCurrencySymbol) +
                                        item.price.toString(),
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        color: Color(Constants.color_black),
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                                item.custimization.length > 0
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: ScreenUtil().setWidth(10)),
                                        child: Container(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            Languages.of(context)
                                                .labelCustomizable,
                                            style: TextStyle(
                                                fontFamily: Constants.app_font,
                                                fontSize:
                                                    ScreenUtil().setSp(12)),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      item.isAdded
                          ? Expanded(
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (item.custimization.length > 0 &&
                                        item.isRepeatCustomization) {
                                      int isRepeatCustomization =
                                          item.isRepeatCustomization ? 1 : 0;

                                      setState(() {
                                        if (item.count != 1) {
                                          item.count--;
                                        } else {
                                          item.isAdded = false;
                                          item.count = 0;
                                        }
                                      });
                                      await model.updateProduct(
                                          item.id, item.count);
                                      print("Total: \$ " +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .totalCartValue
                                              .toString() +
                                          "");
                                      print("Cart List" +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .cart
                                              .toString() +
                                          "");
                                      var ab;
                                      String finalFoodCustomization, title;
                                      double price, tempPrice;
                                      int qty;

                                      for (int z = 0;
                                          z < model.cart.length;
                                          z++) {
                                        if (item.id == model.cart[z].id) {
                                          ab = json.decode(
                                              model.cart[z].foodCustomization);
                                          finalFoodCustomization =
                                              model.cart[z].foodCustomization;
                                          price = model.cart[z].price;
                                          title = model.cart[z].title;
                                          qty = model.cart[z].qty;
                                          tempPrice = model.cart[z].tempPrice;
                                        }
                                      }
                                      if (qty != null && tempPrice != null) {
                                        price = tempPrice * qty;
                                      } else {
                                        price = 0;
                                      }

                                      _updateForCustomizedFood(
                                          item.id,
                                          item.count,
                                          price.toString(),
                                          item.price,
                                          item.image,
                                          item.name,
                                          widget.restaurantsId,
                                          widget.restaurantsName,
                                          finalFoodCustomization,
                                          widget.onSetState,
                                          isRepeatCustomization,
                                          1);
                                    } else {
                                      setState(() {
                                        if (item.count != 1) {
                                          item.count--;
                                          // ConstantsUtils.removeItem(widget.listRestaurantsMenu[widget.index].name, item,item.id);
                                        } else {
                                          item.isAdded = false;
                                          item.count = 0;
                                        }
                                      });
                                      model.updateProduct(item.id, item.count);
                                      print("Total: \$ " +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .totalCartValue
                                              .toString() +
                                          "");
                                      print("Cart List" +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .cart
                                              .toString() +
                                          "");
                                      _update(
                                          item.id,
                                          item.count,
                                          item.price.toString(),
                                          item.image,
                                          item.name,
                                          widget.restaurantsId,
                                          widget.restaurantsName,
                                          widget.onSetState,
                                          0,
                                          0,
                                          0,
                                          '0');
                                    }
                                  },
                                  child: Container(
                                    height: ScreenUtil().setHeight(21),
                                    width: ScreenUtil().setWidth(36),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                              ScreenUtil().setWidth(10)),
                                          topRight: Radius.circular(
                                              ScreenUtil().setWidth(10))),
                                      color: Color(0xfff1f1f1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '-',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color:
                                                Color(Constants.color_theme)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(5),
                                      bottom: ScreenUtil().setHeight(5)),
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: ScreenUtil().setHeight(21),
                                    width: ScreenUtil().setWidth(36),
                                    child: Text(
                                      '${item.count}',
                                      style: TextStyle(
                                          fontFamily: Constants.app_font),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (item.custimization.length > 0) {
                                      var ab;
                                      String finalFoodCustomization, title;
                                      double price, tempPrice;
                                      int qty;

                                      for (int z = 0;
                                          z < model.cart.length;
                                          z++) {
                                        if (item.id == model.cart[z].id) {
                                          ab = json.decode(
                                              model.cart[z].foodCustomization);
                                          finalFoodCustomization =
                                              model.cart[z].foodCustomization;
                                          price = model.cart[z].price;
                                          title = model.cart[z].title;
                                          qty = model.cart[z].qty;
                                          tempPrice = model.cart[z].tempPrice;
                                        }
                                      }
                                      List<String> nameOfcustomization = [];
                                      for (int i = 0; i < ab.length; i++) {
                                        nameOfcustomization
                                            .add(ab[i]['data']['name']);
                                      }
                                      print('before starting $price');
                                      print(
                                          'before starting tempPrice $tempPrice');
                                      item.isRepeatCustomization = true;

                                      updateCustomizationFoodDataToDB(
                                        finalFoodCustomization,
                                        item,
                                        model,
                                        price += price * qty,
                                      );
                                    } else {
                                      setState(() {
                                        item.count++;
                                      });
                                      model.updateProduct(item.id, item.count);
                                      print("Total: \$ " +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .totalCartValue
                                              .toString() +
                                          "");
                                      print("Cart List" +
                                          ScopedModel.of<CartModel>(context,
                                                  rebuildOnChange: true)
                                              .cart
                                              .toString() +
                                          "");
                                      _update(
                                          item.id,
                                          item.count,
                                          item.price.toString(),
                                          item.image,
                                          item.name,
                                          widget.restaurantsId,
                                          widget.restaurantsName,
                                          widget.onSetState,
                                          0,
                                          0,
                                          0,
                                          '0');
                                    }
                                  },
                                  child: Container(
                                    height: ScreenUtil().setHeight(21),
                                    width: ScreenUtil().setWidth(36),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      color: Color(0xfff1f1f1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color:
                                                Color(Constants.color_theme)),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                          : Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (item.custimization.length > 0) {
                                        openFoodCustomizationBottomSheet(
                                            model,
                                            item,
                                            double.parse(item.price.toString()),
                                            totalCartAmount,
                                            totalQty,
                                            item.custimization);
                                      } else {
                                        if (ScopedModel.of<CartModel>(context,
                                                    rebuildOnChange: true)
                                                .cart
                                                .length ==
                                            0) {
                                          setState(() {
                                            item.isAdded = !item.isAdded;
                                            item.count++;
                                          });
                                          widget._products.add(Product(
                                              id: item.id,
                                              qty: item.count,
                                              price: double.parse(
                                                  item.price.toString()),
                                              imgUrl: item.image,
                                              title: item.name,
                                              restaurantsId:
                                                  widget.restaurantsId,
                                              restaurantsName:
                                                  widget.restaurantsName,
                                              restaurantImage:
                                                  widget.restaurantsImage,
                                              foodCustomization: '',
                                              isRepeatCustomization: 0,
                                              isCustomization: 0,
                                              itemQty: 0,
                                              tempPrice: 0));
                                          model.addProduct(Product(
                                              id: item.id,
                                              qty: item.count,
                                              price: double.parse(
                                                  item.price.toString()),
                                              imgUrl: item.image,
                                              title: item.name,
                                              restaurantsId:
                                                  widget.restaurantsId,
                                              restaurantsName:
                                                  widget.restaurantsName,
                                              restaurantImage:
                                                  widget.restaurantsImage,
                                              foodCustomization: '',
                                              isRepeatCustomization: 0,
                                              isCustomization: 0,
                                              itemQty: 0,
                                              tempPrice: 0));
                                          print("Total: \$ " +
                                              ScopedModel.of<CartModel>(context,
                                                      rebuildOnChange: true)
                                                  .totalCartValue
                                                  .toString() +
                                              "");
                                          _insert(
                                              item.id,
                                              item.count,
                                              item.price.toString(),
                                              '0',
                                              item.image,
                                              item.name,
                                              widget.restaurantsId,
                                              widget.restaurantsName,
                                              widget.restaurantsImage,
                                              '',
                                              widget.onSetState,
                                              0,
                                              0,
                                              0,
                                              0);
                                        } else {
                                          print(widget.restaurantsId);
                                          print(ScopedModel.of<CartModel>(
                                                  context,
                                                  rebuildOnChange: true)
                                              .getRestId());
                                          if (widget.restaurantsId !=
                                              ScopedModel.of<CartModel>(context,
                                                      rebuildOnChange: true)
                                                  .getRestId()) {
                                            showdialogRemoveCart(
                                                ScopedModel.of<CartModel>(
                                                        context,
                                                        rebuildOnChange: true)
                                                    .getRestName(),
                                                widget.restaurantsName);
                                          } else {
                                            setState(() {
                                              item.isAdded = !item.isAdded;
                                              item.count++;
                                            });
                                            widget._products.add(Product(
                                                id: item.id,
                                                qty: item.count,
                                                price: double.parse(
                                                    item.price.toString()),
                                                imgUrl: item.image,
                                                title: item.name,
                                                restaurantsId:
                                                    widget.restaurantsId,
                                                restaurantsName:
                                                    widget.restaurantsName,
                                                restaurantImage:
                                                    widget.restaurantsImage,
                                                foodCustomization: '',
                                                isCustomization: 0,
                                                isRepeatCustomization: 0,
                                                itemQty: 0,
                                                tempPrice: 0));
                                            model.addProduct(Product(
                                                id: item.id,
                                                qty: item.count,
                                                price: double.parse(
                                                    item.price.toString()),
                                                imgUrl: item.image,
                                                title: item.name,
                                                restaurantsId:
                                                    widget.restaurantsId,
                                                restaurantsName:
                                                    widget.restaurantsName,
                                                restaurantImage:
                                                    widget.restaurantsImage,
                                                foodCustomization: '',
                                                isRepeatCustomization: 0,
                                                isCustomization: 0,
                                                itemQty: 0,
                                                tempPrice: 0));
                                            print("Total: \$ " +
                                                ScopedModel.of<CartModel>(
                                                        context,
                                                        rebuildOnChange: true)
                                                    .totalCartValue
                                                    .toString() +
                                                "");
                                            _insert(
                                                item.id,
                                                item.count,
                                                item.price.toString(),
                                                '0',
                                                item.image,
                                                item.name,
                                                widget.restaurantsId,
                                                widget.restaurantsName,
                                                widget.restaurantsImage,
                                                '',
                                                widget.onSetState,
                                                0,
                                                0,
                                                0,
                                                0);
                                          }
                                        }
                                      }
                                    },
                                    child: Container(
                                      width: ScreenUtil().setWidth(36),
                                      height: ScreenUtil().setWidth(65),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        color: Color(0xfff1f1f1),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color:
                                                  Color(Constants.color_theme)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return columnContent;
  }

  showdialogRemoveCart(String restName, String currentRestName) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 0, top: 10),
              child: Container(
                height: ScreenUtil().setHeight(170),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context).labelRemoveCartItem,
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
                      height: ScreenUtil().setHeight(5),
                    ),
                    Divider(
                      thickness: 1,
                      color: Color(0xffcccccc),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(70),
                          child: Text(
                            '${Languages.of(context).labelYourCartContainsDishesFrom} $restName. ${Languages.of(context).labelYourCartContains1} $currentRestName?',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(14),
                                fontFamily: Constants.app_font,
                                color: Color(Constants.color_black)),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(5),
                        ),
                        Divider(
                          thickness: 1,
                          color: Color(0xffcccccc),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(20),
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
                                    Navigator.pop(context);
                                    ScopedModel.of<CartModel>(context,
                                            rebuildOnChange: true)
                                        .clearCart();
                                    _deleteTable();
                                    setState(() {
                                      totalQty = 0;
                                      totalCartAmount = 0;
                                    });
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

  void _insert(
      int proId,
      int proQty,
      String proPrice,
      String currentPriceWithoutCustomization,
      String proImage,
      String proName,
      int restId,
      String restName,
      String restImage,
      String customization,
      Function onSetState,
      int isRepeatCustomization,
      int isCustomization,
      int itemQty,
      double tempPrice) async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnRestImage: restImage,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnisRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnisCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItem_tempPrice: tempPrice,
      DatabaseHelper.columncurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
    _query(widget.onSetState);
  }

  void _updateForCustomizedFood(
      int proId,
      int proQty,
      String proPrice,
      String currentPriceWithoutCustomization,
      String proImage,
      String proName,
      int restId,
      String restName,
      String customization,
      Function onSetState,
      int isRepeatCustomization,
      int isCustomization) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnProCustomization: customization,
      DatabaseHelper.columnisRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnisCustomization: isRepeatCustomization,
      DatabaseHelper.columncurrentPriceWithoutCustomization:
          currentPriceWithoutCustomization,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    _query(onSetState);
  }

  void _update(
      int proId,
      int proQty,
      String proPrice,
      String proImage,
      String proName,
      int restId,
      String restName,
      Function onSetState,
      int isRepeatCustomization,
      int isCustomization,
      int itemQty,
      String customizationTempPrice) async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnProId: proId,
      DatabaseHelper.columnProImageUrl: proImage,
      DatabaseHelper.columnProName: proName,
      DatabaseHelper.columnProPrice: proPrice,
      DatabaseHelper.columnProQty: proQty,
      DatabaseHelper.columnRestId: restId,
      DatabaseHelper.columnRestName: restName,
      DatabaseHelper.columnisRepeatCustomization: isRepeatCustomization,
      DatabaseHelper.columnisCustomization: isCustomization,
      DatabaseHelper.columnItemQty: itemQty,
      DatabaseHelper.columnItem_tempPrice: customizationTempPrice,
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');

    _query(onSetState);
  }

  void _query(Function onSetState) async {
    double tempTotal1 = 0, tempTotal2 = 0;
    _listCart.clear();
    totalCartAmount = 0;
    totalQty = 0;
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
    for (int i = 0; i < allRows.length; i++) {
      _listCart.add(Product(
        id: allRows[i]['pro_id'],
        restaurantsName: allRows[i]['restName'],
        title: allRows[i]['pro_name'],
        imgUrl: allRows[i]['pro_image'],
        price: double.parse(allRows[i]['pro_price']),
        qty: allRows[i]['pro_qty'],
        restaurantsId: allRows[i]['restId'],
        restaurantImage: allRows[i]['restImage'],
        foodCustomization: allRows[i]['pro_customization'],
        isCustomization: allRows[i]['isCustomization'],
        isRepeatCustomization: allRows[i]['isRepeatCustomization'],
        itemQty: allRows[i]['itemQty'],
        tempPrice: double.parse(allRows[i]['itemTempPrice'].toString()),
      ));
      if (allRows[i]['pro_customization'] == '') {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
        tempTotal1 +=
            double.parse(allRows[i]['pro_price']) * allRows[i]['pro_qty'];
      } else {
        totalCartAmount +=
            double.parse(allRows[i]['pro_price']) + totalCartAmount;
        tempTotal2 += double.parse(allRows[i]['pro_price']);
      }

      print(totalCartAmount);

      totalQty += allRows[i]['pro_qty'];
      print(totalQty);
    }

    print('TempTotal1 $tempTotal1');
    print('TempTotal2 $tempTotal2');
    totalCartAmount = tempTotal1 + tempTotal2;
    onSetState();
  }

  void _deleteTable() async {
    final table = await dbHelper.deleteTable();
    print('table deleted $table');
  }

  void openFoodCustomizationBottomSheet(
    CartModel cartModel,
    SubMenuListData item,
    double currentFoodItemPrice,
    double totalCartAmount,
    int totalQty,
    List<Custimization> custimization,
  ) {
    print('open $currentFoodItemPrice');
    double tempPrice = 0;

    List<String> _listForAPI = [];

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    _listFinalCustomizationCheck.clear();
    for (int i = 0; i < custimization.length; i++) {
      String myJSON = custimization[i].custimazationItem;
      if (custimization[i].custimazationItem != null) {
        _listFinalCustomizationCheck.add(true);
      } else {
        _listFinalCustomizationCheck.add(false);
      }
      if (custimization[i].custimazationItem != null) {
        var json = jsonDecode(myJSON);

        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          if (_listFinalCustomization[i].list[k].isDefault == 1) {
            _listFinalCustomization[i].list[k].isSelected = true;
            _radioButtonFlagList.add(k);
            /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

            tempPrice += double.parse(_listFinalCustomization[i].list[k].price);
            _listForAPI.add(
                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
          } else {
            _listFinalCustomization[i].list[k].isSelected = false;
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));
        continue;
      }

      // _listCustomizationItem.add(CustomizationItemModel(json[i]['name'], json[i]['price'], json[i]['isDefault'], json[i]['status']));
    }

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
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
                                color: Color(Constants.color_black),
                                child: Center(
                                  child: Text(
                                    '${Languages.of(context).labelItem} ${totalQty + 1}' +
                                        '  |  '
                                            '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${currentFoodItemPrice + tempPrice}',
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // ic_green_arrow.svg
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                print(
                                    '===================Continue with List Data=================');
                                print(_listForAPI.toString());

                                addCustomizationFoodDataToDB(
                                    _listForAPI.toString(),
                                    item,
                                    cartModel,
                                    currentFoodItemPrice + tempPrice,
                                    currentFoodItemPrice,
                                    false,
                                    0,
                                    0);
                              },
                              child: Container(
                                color: Color(Constants.color_black),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: Languages.of(context)
                                              .labelContinue,
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'images/ic_green_arrow.svg',
                                              width: 15,
                                              height:
                                                  ScreenUtil().setHeight(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: ListView.builder(
                      itemBuilder: (context, outerIndex) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20),
                                  left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: Constants.app_font_bold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.length > 0
                                ? _listFinalCustomizationCheck[outerIndex] ==
                                        true
                                    ? ListView.builder(
                                        itemBuilder: (context, innerIndex) {
                                          print(
                                              "print the index of inner loop $innerIndex outter index is $outerIndex");
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(10),
                                                  left: ScreenUtil()
                                                      .setWidth(20)),
                                              child: InkWell(
                                                onTap: () {
                                                  // changeIndex(index);
                                                  print({
                                                    'On Tap tempPrice : ' +
                                                        tempPrice.toString()
                                                  });

                                                  if (!_listFinalCustomization[
                                                          outerIndex]
                                                      .list[innerIndex]
                                                      .isSelected) {
                                                    tempPrice = 0;
                                                    _listForAPI.clear();
                                                    setState(() {
                                                      _radioButtonFlagList[
                                                              outerIndex] =
                                                          innerIndex;

                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list
                                                          .forEach((element) =>
                                                              element.isSelected =
                                                                  false);
                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list[innerIndex]
                                                          .isSelected = true;

                                                      for (int i = 0;
                                                          i <
                                                              _listFinalCustomization
                                                                  .length;
                                                          i++) {
                                                        for (int j = 0;
                                                            j <
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list
                                                                    .length;
                                                            j++) {
                                                          if (_listFinalCustomization[
                                                                  i]
                                                              .list[j]
                                                              .isSelected) {
                                                            tempPrice +=
                                                                double.parse(
                                                                    _listFinalCustomization[
                                                                            i]
                                                                        .list[j]
                                                                        .price);

                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .title);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .name);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .isDefault);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .isSelected);
                                                            print(
                                                                _listFinalCustomization[
                                                                        i]
                                                                    .list[j]
                                                                    .price);

                                                            _listForAPI.add(
                                                                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                            print(_listForAPI
                                                                .toString());
                                                          }
                                                        }
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _listFinalCustomization[
                                                                  outerIndex]
                                                              .list[innerIndex]
                                                              .name,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .app_font,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                        Text(
                                                          SharedPreferenceUtil
                                                                  .getString(
                                                                      Constants
                                                                          .appSettingCurrencySymbol) +
                                                              ' ' +
                                                              _listFinalCustomization[
                                                                      outerIndex]
                                                                  .list[
                                                                      innerIndex]
                                                                  .price,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  Constants
                                                                      .app_font,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          14)),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right: ScreenUtil()
                                                              .setWidth(20)),
                                                      child: _radioButtonFlagList[
                                                                  outerIndex] ==
                                                              innerIndex
                                                          ? getChecked()
                                                          : getunChecked(),
                                                    ),
                                                  ],
                                                ),
                                              ));
                                        },
                                        itemCount:
                                            _listFinalCustomization[outerIndex]
                                                .list
                                                .length,
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                      )
                                    : Container(
                                        height: ScreenUtil().setHeight(100),
                                        child: Center(
                                          child: Text(
                                            'No Customization Data Avaialble.',
                                            style: TextStyle(
                                                fontFamily:
                                                    Constants.app_font_bold,
                                                fontSize:
                                                    ScreenUtil().setSp(18)),
                                          ),
                                        ),
                                      )
                                : Container(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        'No Customization Data Avaialble.',
                                        style: TextStyle(
                                            fontFamily: Constants.app_font_bold,
                                            fontSize: ScreenUtil().setSp(18)),
                                      ),
                                    ),
                                  )
                          ],
                        );
                      },
                      itemCount: _listFinalCustomization.length,
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  void openUpdateFoodCustomizationBottomSheet(
      CartModel cartModel,
      SubMenuListData item,
      double currentFoodItemPrice,
      double totalCartAmount,
      int totalQty,
      List<Custimization> custimization,
      int isRepeat) {
    print(currentFoodItemPrice);
    double tempPrice = 0;

    List<String> _listForAPI = [];

    List<CustomizationItemModel> _listCustomizationItem = [];
    List<int> _radioButtonFlagList = [];
    List<CustomModel> _listFinalCustomization = [];
    for (int i = 0; i < custimization.length; i++) {
      String myJSON = custimization[i].custimazationItem;
      if (custimization[i].custimazationItem != null) {
        var json = jsonDecode(myJSON);

        _listCustomizationItem = (json as List)
            .map((i) => CustomizationItemModel.fromJson(i))
            .toList();

        for (int j = 0; j < _listCustomizationItem.length; j++) {
          print(_listCustomizationItem[j].name);
        }
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));

        for (int k = 0; k < _listFinalCustomization[i].list.length; k++) {
          if (_listFinalCustomization[i].list[k].isDefault == 1) {
            _listFinalCustomization[i].list[k].isSelected = true;
            _radioButtonFlagList.add(k);
            /*       currentFoodItemPrice +=
                double.parse(_listFinalCustomization[i].list[k].price);*/

            tempPrice += double.parse(_listFinalCustomization[i].list[k].price);
            _listForAPI.add(
                '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[k].name}","price":"${_listFinalCustomization[i].list[k].price}"}}');
          } else {
            _listFinalCustomization[i].list[k].isSelected = false;
          }
        }
        print(_listFinalCustomization.length);
        print('temp ' + tempPrice.toString());
      } else {
        _listFinalCustomization
            .add(CustomModel(custimization[i].name, _listCustomizationItem));
        continue;
      }

      // _listCustomizationItem.add(CustomizationItemModel(json[i]['name'], json[i]['price'], json[i]['isDefault'], json[i]['status']));
    }

    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
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
                                color: Color(Constants.color_black),
                                child: Center(
                                  child: Text(
                                    'Item ${totalQty + 1}' +
                                        '  |  '
                                            '${SharedPreferenceUtil.getString(Constants.appSettingCurrencySymbol)} ${currentFoodItemPrice + tempPrice}',
                                    style: TextStyle(
                                        fontFamily: Constants.app_font,
                                        color: Colors.white,
                                        fontSize: ScreenUtil().setSp(16)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            // ic_green_arrow.svg
                            child: InkWell(
                              onTap: () {
                                // item.itemQty = item.count + item.itemQty;
                                item.itemQty = item.itemQty + 1;
                                Navigator.pop(context);
                                print(
                                    '=================== Continue with List Data =================');
                                print(_listForAPI.toString());
                                addCustomizationFoodDataToDB(
                                    _listForAPI.toString(),
                                    item,
                                    cartModel,
                                    currentFoodItemPrice + tempPrice,
                                    currentFoodItemPrice,
                                    true,
                                    isRepeat,
                                    item.itemQty);
                              },
                              child: Container(
                                color: Color(Constants.color_black),
                                child: Center(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Continue',
                                          style: TextStyle(
                                              fontFamily: Constants.app_font,
                                              color: Colors.white,
                                              fontSize: ScreenUtil().setSp(16)),
                                        ),
                                        WidgetSpan(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: SvgPicture.asset(
                                              'images/ic_green_arrow.svg',
                                              width: 15,
                                              height:
                                                  ScreenUtil().setHeight(15),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    body: ListView.builder(
                      itemBuilder: (context, outerIndex) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setHeight(20),
                                  left: ScreenUtil().setWidth(10)),
                              child: Text(
                                _listFinalCustomization[outerIndex].title,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: Constants.app_font_bold),
                              ),
                            ),
                            _listFinalCustomization[outerIndex].list.length != 0
                                ? ListView.builder(
                                    itemBuilder: (context, innerIndex) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10),
                                              left: ScreenUtil().setWidth(20)),
                                          child: InkWell(
                                            onTap: () {
                                              // changeIndex(index);
                                              print({
                                                'On Tap tempPrice : ' +
                                                    tempPrice.toString()
                                              });

                                              if (!_listFinalCustomization[
                                                      outerIndex]
                                                  .list[innerIndex]
                                                  .isSelected) {
                                                tempPrice = 0;
                                                _listForAPI.clear();
                                                setState(() {
                                                  _radioButtonFlagList[
                                                      outerIndex] = innerIndex;

                                                  _listFinalCustomization[
                                                          outerIndex]
                                                      .list
                                                      .forEach((element) =>
                                                          element.isSelected =
                                                              false);
                                                  _listFinalCustomization[
                                                          outerIndex]
                                                      .list[innerIndex]
                                                      .isSelected = true;

                                                  for (int i = 0;
                                                      i <
                                                          _listFinalCustomization
                                                              .length;
                                                      i++) {
                                                    for (int j = 0;
                                                        j <
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list
                                                                .length;
                                                        j++) {
                                                      if (_listFinalCustomization[
                                                              i]
                                                          .list[j]
                                                          .isSelected) {
                                                        tempPrice += double.parse(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .price);

                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .title);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .name);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .isDefault);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .isSelected);
                                                        print(
                                                            _listFinalCustomization[
                                                                    i]
                                                                .list[j]
                                                                .price);

                                                        _listForAPI.add(
                                                            '{"main_menu":"${_listFinalCustomization[i].title}","data":{"name":"${_listFinalCustomization[i].list[j].name}","price":"${_listFinalCustomization[i].list[j].price}"}}');
                                                        print(_listForAPI
                                                            .toString());
                                                      }
                                                    }
                                                  }
                                                });
                                              }
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _listFinalCustomization[
                                                              outerIndex]
                                                          .list[innerIndex]
                                                          .name,
                                                      style: TextStyle(
                                                          fontFamily: Constants
                                                              .app_font,
                                                          fontSize: ScreenUtil()
                                                              .setSp(14)),
                                                    ),
                                                    Text(
                                                      SharedPreferenceUtil
                                                              .getString(Constants
                                                                  .appSettingCurrencySymbol) +
                                                          ' ' +
                                                          _listFinalCustomization[
                                                                  outerIndex]
                                                              .list[innerIndex]
                                                              .price,
                                                      style: TextStyle(
                                                          fontFamily: Constants
                                                              .app_font,
                                                          fontSize: ScreenUtil()
                                                              .setSp(14)),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: ScreenUtil()
                                                          .setWidth(20)),
                                                  child: _radioButtonFlagList[
                                                              outerIndex] ==
                                                          innerIndex
                                                      ? getChecked()
                                                      : getunChecked(),
                                                ),
                                              ],
                                            ),
                                          ));
                                    },
                                    itemCount:
                                        _listFinalCustomization[outerIndex]
                                            .list
                                            .length,
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                  )
                                : Container(
                                    height: ScreenUtil().setHeight(100),
                                    child: Center(
                                      child: Text(
                                        'No Customization Data Avaialble.',
                                        style: TextStyle(
                                            fontFamily: Constants.app_font_bold,
                                            fontSize: ScreenUtil().setSp(18)),
                                      ),
                                    ),
                                  )
                          ],
                        );
                      },
                      itemCount: _listFinalCustomization.length,
                    ),
                  ),
                ),
              );
            },
          );
        });
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

  void addCustomizationFoodDataToDB(
      String customization,
      SubMenuListData item,
      CartModel model,
      double cartPrice,
      double currentPriceWithoutCustomization,
      bool isFromAddRepeatCustomization,
      int iRepeat,
      int itemQty) {
    int isRepeat = iRepeat;

    if (ScopedModel.of<CartModel>(context, rebuildOnChange: true).cart.length ==
        0) {
      setState(() {
        if (!isFromAddRepeatCustomization) {
          item.isAdded = !item.isAdded;
        }
        item.count++;
      });
      widget._products.add(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          title: item.name,
          restaurantsId: widget.restaurantsId,
          restaurantsName: widget.restaurantsName,
          restaurantImage: widget.restaurantsImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          itemQty: itemQty,
          tempPrice: cartPrice));
      model.addProduct(Product(
          id: item.id,
          qty: item.count,
          price: cartPrice,
          imgUrl: item.image,
          title: item.name,
          restaurantsId: widget.restaurantsId,
          restaurantsName: widget.restaurantsName,
          restaurantImage: widget.restaurantsImage,
          foodCustomization: customization,
          isCustomization: 1,
          isRepeatCustomization: isRepeat,
          tempPrice: cartPrice,
          itemQty: item.itemQty));
      print("Total: \$ " +
          ScopedModel.of<CartModel>(context, rebuildOnChange: true)
              .totalCartValue
              .toString() +
          "");
      _insert(
        item.id,
        item.count,
        cartPrice.toString(),
        currentPriceWithoutCustomization.toString(),
        item.image,
        item.name,
        widget.restaurantsId,
        widget.restaurantsName,
        widget.restaurantsImage,
        customization,
        widget.onSetState,
        isRepeat,
        1,
        item.itemQty,
        cartPrice,
      );
    } else {
      print(widget.restaurantsId);
      print(ScopedModel.of<CartModel>(context, rebuildOnChange: true)
          .getRestId());
      if (widget.restaurantsId !=
          ScopedModel.of<CartModel>(context, rebuildOnChange: true)
              .getRestId()) {
        showdialogRemoveCart(
            ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .getRestName(),
            widget.restaurantsName);
      } else {
        setState(() {
          if (!isFromAddRepeatCustomization) {
            item.isAdded = !item.isAdded;
          }
          item.count++;
        });
        widget._products.add(Product(
            id: item.id,
            qty: item.count,
            price: cartPrice,
            imgUrl: item.image,
            title: item.name,
            restaurantsId: widget.restaurantsId,
            restaurantsName: widget.restaurantsName,
            restaurantImage: widget.restaurantsImage,
            foodCustomization: customization,
            isCustomization: 1,
            isRepeatCustomization: isRepeat,
            tempPrice: cartPrice,
            itemQty: itemQty));
        model.addProduct(Product(
            id: item.id,
            qty: item.count,
            price: cartPrice,
            imgUrl: item.image,
            title: item.name,
            restaurantsId: widget.restaurantsId,
            restaurantsName: widget.restaurantsName,
            restaurantImage: widget.restaurantsImage,
            foodCustomization: customization,
            isCustomization: 1,
            isRepeatCustomization: isRepeat,
            tempPrice: cartPrice,
            itemQty: itemQty));
        print("Total: \$ " +
            ScopedModel.of<CartModel>(context, rebuildOnChange: true)
                .totalCartValue
                .toString() +
            "");
        _insert(
          item.id,
          item.count,
          cartPrice.toString(),
          currentPriceWithoutCustomization.toString(),
          item.image,
          item.name,
          widget.restaurantsId,
          widget.restaurantsName,
          widget.restaurantsImage,
          customization,
          widget.onSetState,
          isRepeat,
          1,
          item.itemQty,
          cartPrice,
        );
      }
    }
  }

  void updateCustomizationFoodDataToDB(String customization,
      SubMenuListData item, CartModel model, double cartPrice) {
    setState(() {
      item.count++;
      // ConstantsUtils.addCartItem(widget.listRestaurantsMenu[widget.index].name, item,item.count,int.parse(item.price));
      /*              ConstantsUtils.allItems
                                      .add(Cart(widget.listRestaurantsMenu[widget.index].name, submenu));*/
    });
    model.updateProduct(item.id, item.count);
    print("Total: \$ " +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .totalCartValue
            .toString() +
        "");
    print("Cart List" +
        ScopedModel.of<CartModel>(context, rebuildOnChange: true)
            .cart
            .toString() +
        "");
    int isRepeatCustomization = item.isRepeatCustomization ? 1 : 0;
    _updateForCustomizedFood(
        item.id,
        item.count,
        cartPrice.toString(),
        item.price,
        item.image,
        item.name,
        widget.restaurantsId,
        widget.restaurantsName,
        customization,
        widget.onSetState,
        isRepeatCustomization,
        1);
  }
}

class CustomModel {
  List<CustomizationItemModel> list = [];
  final String title;

  CustomModel(this.title, this.list);
}

class FoodItem {
  final String title;
  List<String> contents = [];

  FoodItem(
    this.title,
    this.contents,
  );
}

List<FoodItem> foodItem = [
  new FoodItem(
    'Pizzas',
    ['Vehicle no. 1'],
  ),
];
