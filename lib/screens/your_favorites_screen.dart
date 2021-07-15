import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mealup/componants/explore_restaurants_list.dart';
import 'package:mealup/model/favorite_list_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:dio/dio.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class YourFavoritesScreen extends StatefulWidget {
  @override
  _YourFavoritesScreenState createState() => _YourFavoritesScreenState();
}

class _YourFavoritesScreenState extends State<YourFavoritesScreen> {
  List<FavoriteListData> _listFavoriteData = [];
  List<String> favoriteRestaurantsFood = [];
  bool _isSyncing = false;
  // ProgressDialog progressDialog;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    Constants.CheckNetwork().whenComplete(() => callGetFavoritesList());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    Constants.CheckNetwork().whenComplete(() => callGetFavoritesList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelYourFavorites),
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
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 10),
                        child:
                            _listFavoriteData.length == 0 ||
                                    _listFavoriteData.length == null
                                ? !_isSyncing
                                    ? Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image(
                                              width: ScreenUtil().setWidth(150),
                                              height:
                                                  ScreenUtil().setHeight(180),
                                              image: AssetImage(
                                                  'images/ic_no_rest.png'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(10)),
                                              child: Text(
                                                Languages.of(context)
                                                    .labelNodata,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(18),
                                                  fontFamily:
                                                      Constants.app_font_bold,
                                                  color: Color(
                                                      Constants.color_theme),
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
                                    itemCount: _listFavoriteData.length,
                                    itemBuilder:
                                        (BuildContext context, int index) =>
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  Transitions(
                                                    transitionType:
                                                        TransitionType.fade,
                                                    curve: Curves.bounceInOut,
                                                    reverseCurve: Curves
                                                        .fastLinearToSlowEaseIn,
                                                    widget:
                                                        Restaurants_DetailsScreen(
                                                      restaurantId:
                                                          _listFavoriteData[
                                                                  index]
                                                              .id,
                                                      isFav: true,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Card(
                                                margin:
                                                    EdgeInsets.only(bottom: 20),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15.0),
                                                      child: CachedNetworkImage(
                                                        height: ScreenUtil()
                                                            .setHeight(100),
                                                        width: ScreenUtil()
                                                            .setWidth(100),
                                                        imageUrl:
                                                            _listFavoriteData[
                                                                    index]
                                                                .image,
                                                        fit: BoxFit.fill,
                                                        placeholder: (context,
                                                                url) =>
                                                            SpinKitFadingCircle(
                                                                color: Color(
                                                                    Constants
                                                                        .color_theme)),
                                                        errorWidget: (context,
                                                                url, error) =>
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
                                                                          _listFavoriteData[index]
                                                                              .name,
                                                                          style: TextStyle(
                                                                              fontFamily: Constants.app_font_bold,
                                                                              fontSize: ScreenUtil().setSp(16.0)),
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (SharedPreferenceUtil.getBool(Constants.isLoggedIn)) {
                                                                              showdialog(_listFavoriteData[index].id);
                                                                            } else {
                                                                              Constants.toastMessage(Languages.of(context).labelPleaseLoginToAddFavorite);
                                                                            }
                                                                          },
                                                                          child: Container(
                                                                              child: SvgPicture.asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color:
                                                                                Color(Constants.color_like),
                                                                            height:
                                                                                ScreenUtil().setHeight(20.0),
                                                                            width:
                                                                                ScreenUtil().setWidth(20.0),
                                                                          )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10),
                                                                      child:
                                                                          Text(
                                                                        getFavRestaurantsFood(
                                                                            index),
                                                                        style: TextStyle(
                                                                            fontFamily:
                                                                                Constants.app_font,
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
                                                                  top: ScreenUtil()
                                                                      .setHeight(
                                                                          10)),
                                                              child: Container(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(bottom: 3),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(right: 5),
                                                                              child: SvgPicture.asset(
                                                                                'images/ic_map.svg',
                                                                                width: 10,
                                                                                height: ScreenUtil().setHeight(10),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              _listFavoriteData[index].distance.toString() + Languages.of(context).labelkmFarAway,
                                                                              style: TextStyle(
                                                                                fontSize: ScreenUtil().setSp(12.0),
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
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                RatingBar.readOnly(
                                                                                  initialRating: _listFavoriteData[index].rate.toDouble(),
                                                                                  size: ScreenUtil().setWidth(15.0),
                                                                                  isHalfAllowed: true,
                                                                                  halfFilledColor: Color(0xFFffc107),
                                                                                  halfFilledIcon: Icons.star_half,
                                                                                  filledIcon: Icons.star,
                                                                                  emptyIcon: Icons.star_border,
                                                                                  emptyColor: Color(Constants.color_gray),
                                                                                  filledColor: Color(0xFFffc107),
                                                                                ),
                                                                                Text(
                                                                                  '(${_listFavoriteData[index].review})',
                                                                                  style: TextStyle(
                                                                                    fontSize: ScreenUtil().setSp(12.0),
                                                                                    fontFamily: Constants.app_font,
                                                                                    color: Color(0xFF132229),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.only(right: 10),
                                                                              child: _listFavoriteData[index].vendorType == 'veg'
                                                                                  ? Row(
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(right: 2),
                                                                                          child: SvgPicture.asset(
                                                                                            'images/ic_veg.svg',
                                                                                            height: ScreenUtil().setHeight(10.0),
                                                                                            width: ScreenUtil().setHeight(10.0),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Row(
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(right: 2),
                                                                                          child: SvgPicture.asset(
                                                                                            'images/ic_veg.svg',
                                                                                            height: ScreenUtil().setHeight(10.0),
                                                                                            width: ScreenUtil().setHeight(10.0),
                                                                                          ),
                                                                                        ),
                                                                                        SvgPicture.asset(
                                                                                          'images/ic_non_veg.svg',
                                                                                          height: ScreenUtil().setHeight(10.0),
                                                                                          width: ScreenUtil().setHeight(10.0),
                                                                                        )
                                                                                      ],
                                                                                    ),
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
                                            )),
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

  showdialog(int id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 20),
              child: Container(
                height: ScreenUtil().setHeight(180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context).labelRemoveFromTheList,
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
                      height: ScreenUtil().setHeight(10),
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
                          height: ScreenUtil().setHeight(20),
                        ),
                        Text(
                          Languages.of(context).labelAreYouSureToRemove,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: Constants.app_font,
                              color: Color(Constants.color_black)),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(20),
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
                                    Navigator.pop(context);
                                    callAddRemoveFavorite(id);
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

  void callAddRemoveFavorite(int vegRestId) {
    setState(() {
      _isSyncing = true;
    });
    Map<String, String> body = {
      'id': vegRestId.toString(),
    };
    RestClient(Retro_Api().Dio_Data()).faviroute(body).then((response) {
      setState(() {
        _isSyncing = false;
      });
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        callGetFavoritesList();
        setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileUpdate);
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

  String getFavRestaurantsFood(int index) {
    favoriteRestaurantsFood.clear();
    if (_listFavoriteData.isNotEmpty) {
      for (int j = 0; j < _listFavoriteData[index].cuisine.length; j++) {
        favoriteRestaurantsFood.add(_listFavoriteData[index].cuisine[j].name);
      }
    }
    print(favoriteRestaurantsFood.toString());

    return favoriteRestaurantsFood.join(" , ");
  }

  callGetFavoritesList() {
    _listFavoriteData.clear();
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).rest_faviroute().then((response) {
      print(response.success);
      setState(() {
        _isSyncing = false;
      });
      if (response.success) {
        setState(() {
          _listFavoriteData.addAll(response.data);
          // _listFavoriteData.clear();
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
}
