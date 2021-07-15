import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mealup/componants/custom_appbar.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';
import 'package:mealup/model/nonvegRestaurantsModel.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/vegRestaurantsModel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rating_bar/rating_bar.dart';

import '../login_screen.dart';
import '../restaurants_details_screen.dart';
import '../search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AllCuisineData> _allCuisineListData = [];
  List<NearByRestaurantListData> _nearbyListData = [];
  List<VegRestaurantListData> _vegListData = [];
  List<TopRestaurantsListData> _topListData = [];
  List<NonVegRestaurantListData> _nonvegListData = [];
  List<ExploreRestaurantsListData> _exploreResListData = [];
  List<String> restaurantsFood = [];
  List<String> vegRestaurantsFood = [];
  List<String> nonVegRestaurantsFood = [];
  List<String> topRestaurantsFood = [];
  List<String> exploreRestaurantsFood = [];

  LatLng _center;
  bool _isSyncing = false;
  Position currentLocation;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  bool isBusinessAvailable = false;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    if (SharedPreferenceUtil.getInt(Constants.appSettingBusiness_availability) == 1) {
      getUserLocation();

      Constants.CheckNetwork().whenComplete(() => callAllCuisine());
      Constants.CheckNetwork().whenComplete(() => callVegRestaurants());
      Constants.CheckNetwork().whenComplete(() => callTopRestaurants());
      Constants.CheckNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());

    }else{
      Constants.toastMessage('This is a testing app');
    }
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();

  }

  @override
  Future<void> initState() {
    super.initState();

    SharedPreferenceUtil.getInt(Constants.appSettingBusiness_availability) == 1
        ? isBusinessAvailable = false
        : isBusinessAvailable = true;
    if (SharedPreferenceUtil.getString(Constants.appPush_oneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }


    if (SharedPreferenceUtil.getInt(Constants.appSettingBusiness_availability) == 1) {
      getUserLocation();

      Constants.CheckNetwork().whenComplete(() => callAllCuisine());

      Constants.CheckNetwork().whenComplete(() => callVegRestaurants());
      Constants.CheckNetwork().whenComplete(() => callTopRestaurants());
      Constants.CheckNetwork().whenComplete(() => callNonVegRestaurants());
      Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());
    } else {
      Constants.toastMessage('This is a testing app');
    }

  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  getOneSingleToken(String appId) async {
    String userId = '';
    /*var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };*/
    OneSignal.shared.consentGranted(true);
    await OneSignal.shared.setAppId(appId);
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
    OneSignal.shared.promptLocationPermission();
    // OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);
    var status = await OneSignal.shared.getDeviceState();
    // var pushtoken = await status.subscriptionStatus.pushToken;
    userId = status.userId;
    print("pushtoken1:$userId");
    SharedPreferenceUtil.putString(Constants.appPush_oneSingleToken, userId);
   /* if (SharedPreferenceUtil.getString(Constants.appPush_oneSingleToken).isEmpty) {
      getOneSingleToken(SharedPreferenceUtil.getString(Constants.appSettingCustomerAppId));
    }*/
  }

  getUserLocation() async {
    currentLocation = await locateUser();
    if (mounted)
      setState(() {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
      });
    SharedPreferenceUtil.putString('selectedLat', _center.latitude.toString());
    SharedPreferenceUtil.putString('selectedLng', _center.longitude.toString());
    Constants.CheckNetwork().whenComplete(() => callNearByRestaurants());
    print('center $_center');
    print('selectedLat ${_center.latitude}');
    print('selectedLng ${_center.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    dynamic screenWidth = MediaQuery.of(context).size.width;
    dynamic screenHeight = MediaQuery.of(context).size.height;

    ScreenUtil.init(BoxConstraints(maxWidth: screenWidth, maxHeight: screenHeight),
        designSize: Size(360, 690), orientation: Orientation.portrait);
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppbar(
          isFilter: false,
          onOfferTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: OfferScreen()));
          },
          onSearchTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: SearchScreen()));
          },
          onLocationTap: () {
            if (SharedPreferenceUtil.getBool(Constants.isLoggedIn) == true) {
              Navigator.of(context).push(Transitions(
                  transitionType: TransitionType.none,
                  curve: Curves.bounceInOut,
                  reverseCurve: Curves.fastLinearToSlowEaseIn,
                  widget: SetLocationScreen()));
            } else {
              if (!SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                Future.delayed(
                  Duration(seconds: 0),
                  () => Navigator.of(context).pushAndRemoveUntil(
                      Transitions(
                        transitionType: TransitionType.fade,
                        curve: Curves.bounceInOut,
                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                        widget: LoginScreen(),
                      ),
                      (Route<dynamic> route) => false),
                );
              }
            }
          },
          strSelectedAddress: SharedPreferenceUtil.getString(Constants.selectedAddress).isEmpty
              ? ''
              : SharedPreferenceUtil.getString(Constants.selectedAddress),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Visibility(
                        visible: isBusinessAvailable,
                        child: Container(
                          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(15)),
                          decoration: new BoxDecoration(color: Color(Constants.color_likelight)),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'images/ic_information.svg',
                              width: ScreenUtil().setWidth(25),
                              height: ScreenUtil().setHeight(25),
                              color: Color(Constants.color_like),
                            ),
                            title: Transform(
                              transform: Matrix4.translationValues(-20, 0.0, 0.0),
                              child: Text(
                                SharedPreferenceUtil.getString(Constants.appSettingBusiness_message),
                                style: TextStyle(
                                    color: Color(Constants.color_like),
                                    fontSize: ScreenUtil().setSp(14),
                                    fontFamily: Constants.app_font_bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          Languages.of(context).labelExploreTheBestCuisines,
                          style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                        ),
                      ),
                      _allCuisineListData.length == 0 || _allCuisineListData.length == null
                          ? !_isSyncing
                              ? Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                              : Container(
                                  height: ScreenUtil().setHeight(147),
                                )
                          : Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: SizedBox(
                                height: ScreenUtil().setHeight(147),
                                width: ScreenUtil().setWidth(114),
                                child: ListView.builder(
                                  physics: ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _allCuisineListData.length,
                                  itemBuilder: (BuildContext context, int index) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(Transitions(
                                            transitionType: TransitionType.none,
                                            curve: Curves.bounceInOut,
                                            reverseCurve: Curves.fastLinearToSlowEaseIn,
                                            widget: SingleCuisineDetailsScreen(
                                              cuisineId: _allCuisineListData[index].id,
                                              strCuisineName: _allCuisineListData[index].name,
                                            )));
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(15.0),
                                              child: CachedNetworkImage(
                                                height: ScreenUtil().setHeight(100),
                                                width: ScreenUtil().setWidth(100),
                                                imageUrl: _allCuisineListData[index].image,
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
                                            Expanded(
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: ScreenUtil().setWidth(5),
                                                    right: ScreenUtil().setWidth(5),
                                                  ),
                                                  child: Text(
                                                    _allCuisineListData[index].name,
                                                    style: TextStyle(
                                                      fontFamily: Constants.app_font_bold,
                                                      fontSize: ScreenUtil().setSp(16.0),
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
                                ),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              Languages.of(context).labelTopRestaurantsNear,
                              style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset('images/ic_right_arrow.svg',
                              color: Color(Constants.color_theme),
                              height: 25,
                              width: 25,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: ScreenUtil().setHeight(220),
                        child: (() {
                          if (_nearbyListData.length == 0 || _nearbyListData.length == null) {
                            return !_isSyncing
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image(
                                          width: ScreenUtil().setWidth(100),
                                          height: ScreenUtil().setHeight(100),
                                          image: AssetImage('images/ic_no_rest.png'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: ScreenUtil().setHeight(10)),
                                          child: Text(
                                            Languages.of(context).labelNoRestNear,
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
                                : Container();
                          } else {
                            return GridView.count(
                              // childAspectRatio: 0.35,
                              childAspectRatio: ScreenUtil().screenWidth / (ScreenUtil().screenHeight + 250 ),
                              crossAxisCount: 2,
                              scrollDirection: Axis.horizontal,
                              mainAxisSpacing: ScreenUtil().setWidth(10),
                              children: List.generate(_nearbyListData.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 15),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        Transitions(
                                          transitionType: TransitionType.fade,
                                          curve: Curves.bounceInOut,
                                          reverseCurve: Curves.fastLinearToSlowEaseIn,
                                          widget: Restaurants_DetailsScreen(
                                            restaurantId: _nearbyListData[index].id,
                                            isFav: _nearbyListData[index].like,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      margin: EdgeInsets.only(bottom: 20),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(15.0),
                                            child: CachedNetworkImage(
                                              height: ScreenUtil().setHeight(100),
                                              width: ScreenUtil().setWidth(100),
                                              imageUrl: _nearbyListData[index].image,
                                              fit: BoxFit.fill,
                                              placeholder: (context, url) => SpinKitFadingCircle(
                                                  color: Color(Constants.color_theme)),
                                              errorWidget: (context, url, error) => Container(
                                                child: Center(
                                                    child: Image.network('https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: ScreenUtil().screenWidth/2,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10,right: 5),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                  _nearbyListData[index].name,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          Constants.app_font_bold,
                                                                      fontSize: ScreenUtil()
                                                                          .setSp(16.0)),
                                                                ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                                                  Constants.CheckNetwork().whenComplete(() => callAddRemoveFavorite(_nearbyListData[index].id));
                                                                } else {
                                                                  Constants.toastMessage(Languages.of(context).labelPleaseLoginToAddFavorite);
                                                                }
                                                              },
                                                              child: Container(
                                                                child: _nearbyListData[index].like ? SvgPicture.asset(
                                                                        'images/ic_filled_heart.svg',
                                                                        color: Color(Constants.color_like),
                                                                        height: ScreenUtil().setHeight(20.0),
                                                                        width: ScreenUtil().setWidth(20.0),
                                                                      )
                                                                    : SvgPicture.asset('images/ic_heart.svg',
                                                                        height: ScreenUtil().setHeight(20.0),
                                                                        width: ScreenUtil().setWidth(20.0),
                                                                      ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment.topLeft,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            getRestaurantsFood(index),
                                                            style: TextStyle(
                                                                fontFamily: Constants.app_font,
                                                                color: Color(Constants.color_gray),
                                                                fontSize: ScreenUtil().setSp(12.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  alignment: Alignment.topLeft,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 10,right: 5),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              RatingBar.readOnly(
                                                                initialRating:
                                                                    _nearbyListData[index]
                                                                        .rate
                                                                        .toDouble(),
                                                                size: ScreenUtil()
                                                                    .setWidth(15.0),
                                                                isHalfAllowed: true,
                                                                halfFilledColor:
                                                                    Color(0xFFffc107),
                                                                halfFilledIcon:
                                                                    Icons.star_half,
                                                                filledIcon: Icons.star,
                                                                emptyIcon:
                                                                    Icons.star_border,
                                                                emptyColor: Color(
                                                                    Constants.color_gray),
                                                                filledColor:
                                                                    Color(0xFFffc107),
                                                              ),
                                                              Text(
                                                                '(${_nearbyListData[index].review})',
                                                                style: TextStyle(
                                                                  fontSize: ScreenUtil()
                                                                      .setSp(12.0),
                                                                  fontFamily:
                                                                      Constants.app_font,
                                                                  color: Color(0xFF132229),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          child: (() {
                                                            if (_nearbyListData[index]
                                                                    .vendorType ==
                                                                'veg') {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(right: 2),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_veg.svg',
                                                                      height: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                      width: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            } else if (_nearbyListData[
                                                                        index]
                                                                    .vendorType ==
                                                                'non_veg') {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(right: 2),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_non_veg.svg',
                                                                      height: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                      width: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            } else if (_nearbyListData[
                                                                        index]
                                                                    .vendorType ==
                                                                'all') {
                                                              return Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(right: 2),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_veg.svg',
                                                                      height: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                      width: ScreenUtil()
                                                                          .setHeight(10.0),
                                                                    ),
                                                                  ),
                                                                  SvgPicture.asset(
                                                                    'images/ic_non_veg.svg',
                                                                    height: ScreenUtil()
                                                                        .setHeight(10.0),
                                                                    width: ScreenUtil()
                                                                        .setHeight(10.0),
                                                                  )
                                                                ],
                                                              );
                                                            }
                                                          }()),
                                                        )
                                                      ],
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
                              }),
                            );
                          }
                        }()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              Languages.of(context).labelTopRest,
                              style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'images/ic_right_arrow.svg',
                              color: Color(Constants.color_theme),
                              height: 25,
                              width: 25,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: ScreenUtil().setHeight(220),
                        child: _topListData.length == 0 || _topListData.length == null
                            ? !_isSyncing
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                            : GridView.count(
                               // childAspectRatio: 0.35,
                          childAspectRatio: ScreenUtil().screenWidth / (ScreenUtil().screenHeight + 250 ),
                          crossAxisCount: 2,
                                scrollDirection: Axis.horizontal,
                                mainAxisSpacing: ScreenUtil().setWidth(10),
                                children: List.generate(_topListData.length, (index) {
                                  return Container(
                                    width: ScreenUtil().setWidth(220),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: Restaurants_DetailsScreen(
                                                restaurantId: _topListData[index].id,
                                                isFav: _topListData[index].like,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil().setHeight(100),
                                                  width: ScreenUtil().setWidth(100),
                                                  imageUrl: _topListData[index].image,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants.color_theme)),
                                                  errorWidget: (context, url, error) => Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil().screenWidth/2,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 10,),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width:
                                                                      ScreenUtil().setWidth(130),
                                                                  child: Text(
                                                                    _topListData[index].name,
                                                                    style: TextStyle(
                                                                        fontFamily: Constants
                                                                            .app_font_bold,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil
                                                                        .getBool(Constants
                                                                            .isLoggedIn)) {
                                                                      Constants.CheckNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(
                                                                                  _topListData[
                                                                                          index]
                                                                                      .id));
                                                                    } else {
                                                                      Constants.toastMessage(
                                                                          Languages.of(context)
                                                                              .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    child: _topListData[index]
                                                                            .like
                                                                        ? SvgPicture.asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color: Color(Constants
                                                                                .color_like),
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          )
                                                                        : SvgPicture.asset(
                                                                            'images/ic_heart.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(left: 10),
                                                              child: Text(
                                                                getTopRestaurantsFood(index),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Constants.app_font,
                                                                    color: Color(
                                                                        Constants.color_gray),
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 3),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                            right: 5),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_map.svg',
                                                                      width: 10,
                                                                      height: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _topListData[index]
                                                                            .distance
                                                                            .toString() +
                                                                        Languages.of(context)
                                                                            .labelkmFarAway,
                                                                    style: TextStyle(
                                                                      fontSize: ScreenUtil()
                                                                          .setSp(12.0),
                                                                      fontFamily:
                                                                          Constants.app_font,
                                                                      color: Color(0xFF132229),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar.readOnly(
                                                                        initialRating:
                                                                            _topListData[index]
                                                                                .rate
                                                                                .toDouble(),
                                                                        size: ScreenUtil()
                                                                            .setWidth(15.0),
                                                                        isHalfAllowed: true,
                                                                        halfFilledColor:
                                                                            Color(0xFFffc107),
                                                                        halfFilledIcon:
                                                                            Icons.star_half,
                                                                        filledIcon: Icons.star,
                                                                        emptyIcon:
                                                                            Icons.star_border,
                                                                        emptyColor: Color(
                                                                            Constants.color_gray),
                                                                        filledColor:
                                                                            Color(0xFFffc107),
                                                                      ),
                                                                      Text(
                                                                        '(${_topListData[index].review})',
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
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
                                                                  child: Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                      bottom: 5,
                                                                    ),
                                                                    child: (() {
                                                                      if (_topListData[index]
                                                                              .vendorType ==
                                                                          'veg') {
                                                                        return Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets
                                                                                          .only(
                                                                                      right: 2),
                                                                              child: SvgPicture
                                                                                  .asset(
                                                                                'images/ic_veg.svg',
                                                                                height:
                                                                                    ScreenUtil()
                                                                                        .setHeight(
                                                                                            10.0),
                                                                                width: ScreenUtil()
                                                                                    .setHeight(
                                                                                        10.0),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      } else if (_topListData[
                                                                                  index]
                                                                              .vendorType ==
                                                                          'non_veg') {
                                                                        return Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets
                                                                                          .only(
                                                                                      right: 2),
                                                                              child: SvgPicture
                                                                                  .asset(
                                                                                'images/ic_non_veg.svg',
                                                                                height:
                                                                                    ScreenUtil()
                                                                                        .setHeight(
                                                                                            10.0),
                                                                                width: ScreenUtil()
                                                                                    .setHeight(
                                                                                        10.0),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      } else if (_topListData[
                                                                                  index]
                                                                              .vendorType ==
                                                                          'all') {
                                                                        return Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                                  const EdgeInsets
                                                                                          .only(
                                                                                      right: 2),
                                                                              child: SvgPicture
                                                                                  .asset(
                                                                                'images/ic_veg.svg',
                                                                                height:
                                                                                    ScreenUtil()
                                                                                        .setHeight(
                                                                                            10.0),
                                                                                width: ScreenUtil()
                                                                                    .setHeight(
                                                                                        10.0),
                                                                              ),
                                                                            ),
                                                                            SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            )
                                                                          ],
                                                                        );
                                                                      }
                                                                    }()),
                                                                  ),
                                                                )
                                                              ],
                                                            )
                                                          ],
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
                                    ),
                                  );
                                }),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              Languages.of(context).labelPureVegRest,
                              style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'images/ic_right_arrow.svg',
                              color: Color(Constants.color_theme),
                              height: 25,
                              width: 25,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: ScreenUtil().setHeight(220),
                        child: _vegListData.length == 0 || _vegListData.length == null
                            ? !_isSyncing
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                            : GridView.count(
                                //childAspectRatio: 0.35,
                          childAspectRatio: ScreenUtil().screenWidth / (ScreenUtil().screenHeight + 250 ),
                                crossAxisCount: 2,
                                scrollDirection: Axis.horizontal,
                                mainAxisSpacing: ScreenUtil().setWidth(10),
                                children: List.generate(_vegListData.length, (index) {
                                  return Container(
                                    width: ScreenUtil().setWidth(220),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: Restaurants_DetailsScreen(
                                                restaurantId: _vegListData[index].id,
                                                isFav: _vegListData[index].like,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil().setHeight(100),
                                                  width: ScreenUtil().setWidth(100),
                                                  imageUrl: _vegListData[index].image,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants.color_theme)),
                                                  errorWidget: (context, url, error) => Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil().screenWidth/2,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 10,),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width: ScreenUtil().setWidth(130),
                                                                  child: Text(
                                                                    _vegListData[index].name,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 2,
                                                                    style: TextStyle(
                                                                        fontFamily: Constants.app_font_bold,
                                                                        fontSize: ScreenUtil().setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil
                                                                        .getBool(Constants
                                                                            .isLoggedIn)) {
                                                                      Constants.CheckNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(
                                                                                  _vegListData[
                                                                                          index]
                                                                                      .id));
                                                                    } else {
                                                                      Constants.toastMessage(
                                                                          Languages.of(context)
                                                                              .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    child: _vegListData[index]
                                                                            .like
                                                                        ? SvgPicture.asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color: Color(Constants
                                                                                .color_like),
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          )
                                                                        : SvgPicture.asset(
                                                                            'images/ic_heart.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 10),
                                                              child: Text(
                                                                getVegRestaurantsFood(index),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    fontFamily: Constants.app_font,
                                                                    color: Color(Constants.color_gray),
                                                                    fontSize: ScreenUtil().setSp(12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 3),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                            right: 5),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_map.svg',
                                                                      width: 10,
                                                                      height: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _vegListData[index]
                                                                            .distance
                                                                            .toString() +
                                                                        Languages.of(context)
                                                                            .labelkmFarAway,
                                                                    style: TextStyle(
                                                                      fontSize: ScreenUtil()
                                                                          .setSp(12.0),
                                                                      fontFamily:
                                                                          Constants.app_font,
                                                                      color: Color(0xFF132229),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar.readOnly(
                                                                        initialRating:
                                                                            _vegListData[index]
                                                                                .rate
                                                                                .toDouble(),
                                                                        size: ScreenUtil()
                                                                            .setWidth(15.0),
                                                                        isHalfAllowed: true,
                                                                        halfFilledColor:
                                                                            Color(0xFFffc107),
                                                                        halfFilledIcon:
                                                                            Icons.star_half,
                                                                        filledIcon: Icons.star,
                                                                        emptyIcon:
                                                                            Icons.star_border,
                                                                        emptyColor: Color(
                                                                            Constants.color_gray),
                                                                        filledColor:
                                                                            Color(0xFFffc107),
                                                                      ),
                                                                      Text(
                                                                        '(${_vegListData[index].review})',
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
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
                                                                  child: (() {
                                                                    if (_vegListData[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_vegListData[index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_vegListData[index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                          SvgPicture.asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                            width: ScreenUtil()
                                                                                .setHeight(10.0),
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
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                }),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              Languages.of(context).labelNonPureVegRest,
                              style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: SvgPicture.asset(
                              'images/ic_right_arrow.svg',
                              color: Color(Constants.color_theme),
                              height: 25,
                              width: 25,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        height: ScreenUtil().setHeight(220),
                        child: _nonvegListData.length == 0 || _nonvegListData.length == null
                            ? !_isSyncing
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                            : GridView.count(
                               // childAspectRatio: 0.35,
                          childAspectRatio: ScreenUtil().screenWidth / (ScreenUtil().screenHeight + 250 ),
                                crossAxisCount: 2,
                                scrollDirection: Axis.horizontal,
                                mainAxisSpacing: ScreenUtil().setWidth(10),
                                children: List.generate(_nonvegListData.length, (index) {
                                  return Container(
                                    width: ScreenUtil().setWidth(220),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            Transitions(
                                              transitionType: TransitionType.fade,
                                              curve: Curves.bounceInOut,
                                              reverseCurve: Curves.fastLinearToSlowEaseIn,
                                              widget: Restaurants_DetailsScreen(
                                                restaurantId: _nonvegListData[index].id,
                                                isFav: _nonvegListData[index].like,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(15.0),
                                                child: CachedNetworkImage(
                                                  height: ScreenUtil().setHeight(100),
                                                  width: ScreenUtil().setWidth(100),
                                                  imageUrl: _nonvegListData[index].image,
                                                  fit: BoxFit.fill,
                                                  placeholder: (context, url) =>
                                                      SpinKitFadingCircle(
                                                          color: Color(Constants.color_theme)),
                                                  errorWidget: (context, url, error) => Container(
                                                    child: Center(
                                                        child: Image.network(
                                                            'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: ScreenUtil().screenWidth/2,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(
                                                              left: 10,
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  width:
                                                                      ScreenUtil().setWidth(130),
                                                                  child: Text(
                                                                    _nonvegListData[index].name,
                                                                    style: TextStyle(
                                                                        fontFamily: Constants
                                                                            .app_font_bold,
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil
                                                                        .getBool(Constants
                                                                            .isLoggedIn)) {
                                                                      Constants.CheckNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(
                                                                                  _nonvegListData[
                                                                                          index]
                                                                                      .id));
                                                                    } else {
                                                                      Constants.toastMessage(
                                                                          Languages.of(context)
                                                                              .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    child: _nonvegListData[index]
                                                                            .like
                                                                        ? SvgPicture.asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color: Color(Constants
                                                                                .color_like),
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          )
                                                                        : SvgPicture.asset(
                                                                            'images/ic_heart.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(20.0),
                                                                            width: ScreenUtil()
                                                                                .setWidth(20.0),
                                                                          ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment.topLeft,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.only(left: 10),
                                                              child: Text(
                                                                getNonVegRestaurantsFood(index),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Constants.app_font,
                                                                    color: Color(
                                                                        Constants.color_gray),
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0)),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      alignment: Alignment.topLeft,
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 10),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(
                                                                  bottom: 3),
                                                              child: Row(
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(
                                                                            right: 5),
                                                                    child: SvgPicture.asset(
                                                                      'images/ic_map.svg',
                                                                      width: 10,
                                                                      height: 10,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    _nonvegListData[index]
                                                                            .distance
                                                                            .toString() +
                                                                        Languages.of(context)
                                                                            .labelkmFarAway,
                                                                    style: TextStyle(
                                                                      fontSize: ScreenUtil()
                                                                          .setSp(12.0),
                                                                      fontFamily:
                                                                          Constants.app_font,
                                                                      color: Color(0xFF132229),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Container(
                                                                  child: Row(
                                                                    children: [
                                                                      RatingBar.readOnly(
                                                                        initialRating:
                                                                            _nonvegListData[index]
                                                                                .rate
                                                                                .toDouble(),
                                                                        size: ScreenUtil()
                                                                            .setWidth(15.0),
                                                                        isHalfAllowed: true,
                                                                        halfFilledColor:
                                                                            Color(0xFFffc107),
                                                                        halfFilledIcon:
                                                                            Icons.star_half,
                                                                        filledIcon: Icons.star,
                                                                        emptyIcon:
                                                                            Icons.star_border,
                                                                        emptyColor: Color(
                                                                            Constants.color_gray),
                                                                        filledColor:
                                                                            Color(0xFFffc107),
                                                                      ),
                                                                      Text(
                                                                        '(${_nonvegListData[index].review})',
                                                                        style: TextStyle(
                                                                          fontSize: ScreenUtil()
                                                                              .setSp(12.0),
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
                                                                  child: (() {
                                                                    if (_nonvegListData[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_nonvegListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_nonvegListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                        .only(
                                                                                    right: 2),
                                                                            child:
                                                                                SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(
                                                                                      10.0),
                                                                            ),
                                                                          ),
                                                                          SvgPicture.asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                            width: ScreenUtil()
                                                                                .setHeight(10.0),
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
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );

                                }),
                              ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          Languages.of(context).labelExploreRest,
                          style: TextStyle(fontSize: 18.0, fontFamily: Constants.app_font),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15, top: 8),
                        child: _exploreResListData.length == 0 || _exploreResListData.length == null
                            ? !_isSyncing
                                ? Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisAlignment: MainAxisAlignment.center,
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
                            : ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: _exploreResListData.length,
                                itemBuilder: (BuildContext context, int index) => GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      Transitions(
                                        transitionType: TransitionType.fade,
                                        curve: Curves.bounceInOut,
                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                        widget: Restaurants_DetailsScreen(
                                          restaurantId: _exploreResListData[index].id,
                                          isFav: _exploreResListData[index].like,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.only(bottom: 20),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(15.0),
                                          child: CachedNetworkImage(
                                            height: ScreenUtil().setHeight(100),
                                            width: ScreenUtil().setWidth(100),
                                            imageUrl: _exploreResListData[index].image,
                                            fit: BoxFit.fill,
                                            placeholder: (context, url) => SpinKitFadingCircle(
                                                color: Color(Constants.color_theme)),
                                            errorWidget: (context, url, error) => Container(
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
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Container(
                                                              width: ScreenUtil().setWidth(130),
                                                              child: Text(
                                                                _exploreResListData[index].name,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        Constants.app_font_bold,
                                                                    fontSize:
                                                                        ScreenUtil().setSp(16.0)),
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (SharedPreferenceUtil.getBool(
                                                                    Constants.isLoggedIn)) {
                                                                  Constants.CheckNetwork()
                                                                      .whenComplete(() =>
                                                                          callAddRemoveFavorite(
                                                                              _exploreResListData[
                                                                                      index]
                                                                                  .id));
                                                                } else {
                                                                  Constants.toastMessage(Languages
                                                                          .of(context)
                                                                      .labelPleaseLoginToAddFavorite);
                                                                }
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets.only(
                                                                    right: ScreenUtil().setWidth(5),
                                                                    top: ScreenUtil().setWidth(5)),
                                                                child: _exploreResListData[index]
                                                                        .like
                                                                    ? SvgPicture.asset(
                                                                        'images/ic_filled_heart.svg',
                                                                        color: Color(
                                                                            Constants.color_like),
                                                                        height: ScreenUtil()
                                                                            .setHeight(20.0),
                                                                        width: ScreenUtil()
                                                                            .setWidth(20.0),
                                                                      )
                                                                    : SvgPicture.asset(
                                                                        'images/ic_heart.svg',
                                                                        height: ScreenUtil()
                                                                            .setHeight(20.0),
                                                                        width: ScreenUtil()
                                                                            .setWidth(20.0),
                                                                      ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        alignment: Alignment.topLeft,
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Text(
                                                            getExploreRestaurantsFood(index),
                                                            style: TextStyle(
                                                                fontFamily: Constants.app_font,
                                                                color: Color(Constants.color_gray),
                                                                fontSize: ScreenUtil().setSp(12.0)),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: ScreenUtil().setHeight(10)),
                                                  child: Container(
                                                    alignment: Alignment.topLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 10),
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(bottom: 3),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      right: 5),
                                                                  child: SvgPicture.asset(
                                                                    'images/ic_map.svg',
                                                                    width: 10,
                                                                    height: 10,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _exploreResListData[index]
                                                                          .distance
                                                                          .toString() +
                                                                      Languages.of(context)
                                                                          .labelkmFarAway,
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        ScreenUtil().setSp(12.0),
                                                                    fontFamily: Constants.app_font,
                                                                    color: Color(0xFF132229),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                child: Row(
                                                                  children: [
                                                                    RatingBar.readOnly(
                                                                      initialRating:
                                                                          _exploreResListData[index]
                                                                              .rate
                                                                              .toDouble(),
                                                                      size: ScreenUtil()
                                                                          .setWidth(15.0),
                                                                      isHalfAllowed: true,
                                                                      halfFilledColor:
                                                                          Color(0xFFffc107),
                                                                      halfFilledIcon:
                                                                          Icons.star_half,
                                                                      filledIcon: Icons.star,
                                                                      emptyIcon: Icons.star_border,
                                                                      emptyColor: Color(
                                                                          Constants.color_gray),
                                                                      filledColor:
                                                                          Color(0xFFffc107),
                                                                    ),
                                                                    Text(
                                                                      '(${_exploreResListData[index].review})',
                                                                      style: TextStyle(
                                                                        fontSize: ScreenUtil()
                                                                            .setSp(12.0),
                                                                        fontFamily:
                                                                            Constants.app_font,
                                                                        color: Color(0xFF132229),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    right: ScreenUtil().setWidth(5),
                                                                    bottom:
                                                                        ScreenUtil().setWidth(5)),
                                                                child: Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      right: 10),
                                                                  child: (() {
                                                                    if (_exploreResListData[index]
                                                                            .vendorType ==
                                                                        'veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_exploreResListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'non_veg') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_non_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      );
                                                                    } else if (_exploreResListData[
                                                                                index]
                                                                            .vendorType ==
                                                                        'all') {
                                                                      return Row(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(right: 2),
                                                                            child: SvgPicture.asset(
                                                                              'images/ic_veg.svg',
                                                                              height: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                              width: ScreenUtil()
                                                                                  .setHeight(10.0),
                                                                            ),
                                                                          ),
                                                                          SvgPicture.asset(
                                                                            'images/ic_non_veg.svg',
                                                                            height: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                            width: ScreenUtil()
                                                                                .setHeight(10.0),
                                                                          )
                                                                        ],
                                                                      );
                                                                    }
                                                                  }()),
                                                                ),
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
      ),
    );
  }

  callAllCuisine() {
    _allCuisineListData.clear();
    if (mounted)
      setState(() {
        _isSyncing = true;
      });

    RestClient(Retro_Api().Dio_Data()).allCuisine().then((response) {
      print(response.success);
      if (response.success) {
        if (mounted)
          setState(() {
            _isSyncing = false;
            if (0 < response.data.length) {
              _allCuisineListData.addAll(response.data);
            } else {
              _allCuisineListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      if (mounted)
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callNearByRestaurants() {
    _nearbyListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).near_by(body).then((response) {
      print(response.success);
      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _nearbyListData.addAll(response.data);
            } else {
              _nearbyListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      if (mounted)
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
          }
          break;
        default:
      }
    });
  }

  callTopRestaurants() {
    _topListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).top_rest(body).then((response) {
      print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _topListData.addAll(response.data);
            } else {
              _topListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      print(obj.toString());
      Constants.toastMessage(obj.toString());
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callVegRestaurants() {
    _vegListData.clear();
    // print(SharedPreferenceUtil.getString('selectedLat'));
    // print(SharedPreferenceUtil.getString('selectedLng'));
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).veg_rest(body).then((response) {
      print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _vegListData.addAll(response.data);
            } else {
              _vegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      print(obj.toString());
      Constants.toastMessage(obj.toString());
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callNonVegRestaurants() {
    _nonvegListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).nonveg_rest(body).then((response) {
      print(response.success);

      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _nonvegListData.addAll(response.data);
            } else {
              _nonvegListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      if (mounted)
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  callExploreRestaurants() {
    _exploreResListData.clear();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).explore_rest(body).then((response) {
      print(response.success);
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      if (response.success) {
        if (mounted)
          setState(() {
            if (0 < response.data.length) {
              _exploreResListData.addAll(response.data);
            } else {
              _exploreResListData.clear();
            }
          });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      print(obj.toString());
      Constants.toastMessage(obj.toString());
      if (mounted)
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  void callAddRemoveFavorite(int vegRestId) {
    if (mounted)
      setState(() {
        _isSyncing = true;
      });
    Map<String, String> body = {
      'id': vegRestId.toString(),
    };
    RestClient(Retro_Api().Dio_Data()).faviroute(body).then((response) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        Constants.CheckNetwork().whenComplete(() => callVegRestaurants());
        Constants.CheckNetwork().whenComplete(() => callNearByRestaurants());
        Constants.CheckNetwork().whenComplete(() => callTopRestaurants());
        Constants.CheckNetwork().whenComplete(() => callNonVegRestaurants());
        Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());
        if (mounted) setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileUpdate);
      }
    }).catchError((Object obj) {
      if (mounted)
        setState(() {
          _isSyncing = false;
        });
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
            Constants.toastMessage(Languages.of(context).labelInternalServerError);
          }
          break;
        default:
      }
    });
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (_nearbyListData.isNotEmpty) {
      for (int j = 0; j < _nearbyListData[index].cuisine.length; j++) {
        restaurantsFood.add(_nearbyListData[index].cuisine[j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" , ");
  }

  String getVegRestaurantsFood(int index) {
    vegRestaurantsFood.clear();
    if (_vegListData.isNotEmpty) {
      for (int j = 0; j < _vegListData[index].cuisine.length; j++) {
        vegRestaurantsFood.add(_vegListData[index].cuisine[j].name);
      }
    }
    print(vegRestaurantsFood.toString());

    return vegRestaurantsFood.join(" , ");
  }

  String getNonVegRestaurantsFood(int index) {
    nonVegRestaurantsFood.clear();
    if (_nonvegListData.isNotEmpty) {
      for (int j = 0; j < _nonvegListData[index].cuisine.length; j++) {
        nonVegRestaurantsFood.add(_nonvegListData[index].cuisine[j].name);
      }
    }
    print(nonVegRestaurantsFood.toString());

    return nonVegRestaurantsFood.join(" , ");
  }

  String getTopRestaurantsFood(int index) {
    topRestaurantsFood.clear();
    if (_topListData.isNotEmpty) {
      for (int j = 0; j < _topListData[index].cuisine.length; j++) {
        topRestaurantsFood.add(_topListData[index].cuisine[j].name);
      }
    }
    print(topRestaurantsFood.toString());

    return topRestaurantsFood.join(" , ");
  }

  String getExploreRestaurantsFood(int index) {
    exploreRestaurantsFood.clear();
    if (_exploreResListData.isNotEmpty) {
      for (int j = 0; j < _exploreResListData[index].cuisine.length; j++) {
        exploreRestaurantsFood.add(_exploreResListData[index].cuisine[j].name);
      }
    }
    print(exploreRestaurantsFood.toString());

    return exploreRestaurantsFood.join(" , ");
  }
}
