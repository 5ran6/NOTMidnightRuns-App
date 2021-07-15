import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/componants/custom_appbar.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/offer_screen.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/screens/search_screen.dart';
import 'package:mealup/screens/set_location_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ExploreScreen extends StatefulWidget {
  final String strSortBy, strQuickFilter, strSelectedCousinesId;

  const ExploreScreen(
      {Key key,
      this.strSortBy,
      this.strQuickFilter,
      this.strSelectedCousinesId})
      : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<ExploreRestaurantsListData> _exploreResListData = [];
  List<String> exploreRestaurantsFood = [];

  bool _isSyncing = false;

  List<String> _listSortBy = [];
  List<String> _listQuickFilter = [];

  List<AllCuisineData> _allCuisineListData = [];

  List<String> selectedCuisineListId = [];

  ProgressDialog progressDialog;
  int radioindex;
  int radioQuickFilter;
  int radioCousines;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());
    getSortByList();
    getQuickFilterList();
    Constants.CheckNetwork().whenComplete(() => callAllCuisine());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  callExploreRestaurants() {
    _exploreResListData.clear();
    setState(() {
      _isSyncing = true;
    });

    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
    };
    RestClient(Retro_Api().Dio_Data()).explore_rest(body).then((response) {
      print(response.success);

      if (response.success) {
        setState(() {
          _isSyncing = false;
          _exploreResListData.addAll(response.data);
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

  callGetFilteredDataList(
      String selectedCuisineId, String sortBy, String quick) {
    _exploreResListData.clear();
    progressDialog.show();

    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
      'cousins': selectedCuisineId,
      'quick_filter': quick,
      'sorting': sortBy,
    };
    RestClient(Retro_Api().Dio_Data()).filter(body).then((response) {
      print(response.success);
      progressDialog.hide();
      if (response.success) {
        setState(() {
          _exploreResListData.addAll(response.data);
        });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
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

  @override
  void initState() {
    super.initState();

    Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());

    Constants.CheckNetwork().whenComplete(() => callAllCuisine());
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

  void callSetState() {
    setState(() {});
  }

  void openFilterSheet() {
    showModalBottomSheet(
        context: context,
        isDismissible: false,
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
                                color: Color(0xffeeeeee),
                                child: Center(
                                  child: Text(
                                    Languages.of(context).labelCancel,
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
                                String sortBy, quickFilter;
                                if (radioindex == 0) {
                                  print('High To Low');
                                  sortBy = 'high';
                                } else if (radioindex == 1) {
                                  print('Low To High');
                                  sortBy = 'low';
                                }
                                if (radioQuickFilter == 0) {
                                  print('Veg re');
                                  quickFilter = 'veg';
                                } else if (radioQuickFilter == 1) {
                                  print('Non-Veg re');
                                  quickFilter = 'nonveg';
                                } else if (radioQuickFilter == 2) {
                                  print('Both Non Veg re');
                                  quickFilter = 'all';
                                }
                                selectedCuisineListId.clear();
                                for (int i = 0;
                                    i < _allCuisineListData.length;
                                    i++) {
                                  if (_allCuisineListData[i].isChecked) {
                                    selectedCuisineListId.add(
                                        _allCuisineListData[i].id.toString());
                                  }
                                }
                                String commaSeparated =
                                    selectedCuisineListId.join(',');
                                print('Selected cuisine Id : ---' +
                                    commaSeparated);
                                Navigator.pop(context);
                                callGetFilteredDataList(
                                    commaSeparated, sortBy, quickFilter);
                              },
                              child: Container(
                                color: Color(Constants.color_theme),
                                child: Center(
                                  child: Text(
                                    Languages.of(context).labelApplyFilter,
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
                      appbarTitle: Languages.of(context).labelFilter,
                      str_button_title: Languages.of(context).labelClear,
                      btn_color: Color(Constants.color_theme),
                      onBtnPress: () {
                        Navigator.pop(context);
                        setState(() {
                          selectedCuisineListId.clear();
                          radioindex = null;
                          radioQuickFilter = null;
                          for (int i = 0;
                              i <= _allCuisineListData.length;
                              i++) {
                            _allCuisineListData[i].isChecked = false;
                          }
                        });
                        Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());
                      },
                    ),
                    backgroundColor: Color(0xFFFAFAFA),
                    body: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('images/ic_background_image.png'),
                        fit: BoxFit.cover,
                      )),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(20),
                            right: ScreenUtil().setWidth(10)),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Languages.of(context).labelSortingBy,
                                style: TextStyle(
                                    fontFamily: Constants.app_font,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(15)),
                                child: Container(
                                  height: ScreenUtil().setHeight(60),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
                                    mainAxisSpacing: 5,
                                    children: List.generate(_listSortBy.length,
                                        (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // changeIndex(index);
                                          setState(() {
                                            radioindex = index;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            radioindex == index
                                                ? getChecked()
                                                : getunChecked(),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setWidth(10)),
                                              child: Text(
                                                _listSortBy[index],
                                                style: TextStyle(
                                                    fontFamily:
                                                        Constants.app_font,
                                                    fontSize:
                                                        ScreenUtil().setSp(14)),
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
                                Languages.of(context).labelQuickFilters,
                                style: TextStyle(
                                    fontFamily: Constants.app_font,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(15)),
                                child: Container(
                                  height: ScreenUtil().setHeight(100),
                                  child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    crossAxisCount: 2,
                                    childAspectRatio: 5,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 5,
                                    children: List.generate(
                                        _listQuickFilter.length, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            radioQuickFilter = index;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            radioQuickFilter == index
                                                ? getChecked()
                                                : getunChecked(),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  _listQuickFilter[index],
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                Languages.of(context).labelCousines,
                                style: TextStyle(
                                    fontFamily: Constants.app_font,
                                    fontSize: ScreenUtil().setSp(18)),
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(15)),
                                  child: Container(
                                    child: GridView.count(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      crossAxisCount: 2,
                                      childAspectRatio: 5,
                                      mainAxisSpacing: 10,
                                      children: List.generate(
                                          _allCuisineListData.length, (index) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _allCuisineListData[index]
                                                      .isChecked =
                                                  !_allCuisineListData[index]
                                                      .isChecked;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              _allCuisineListData[index]
                                                      .isChecked
                                                  ? getChecked()
                                                  : getunChecked(),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: ScreenUtil()
                                                        .setWidth(10)),
                                                child: Text(
                                                  _allCuisineListData[index]
                                                      .name,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          Constants.app_font,
                                                      fontSize: ScreenUtil()
                                                          .setSp(14)),
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
      height: 25,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SvgPicture.asset(
          'images/ic_check.svg',
          width: 15,
          height: 15,
        ),
      ),
      decoration: myBoxDecoration_checked(false, Color(Constants.color_theme)),
    );
  }

  Widget getunChecked() {
    return Container(
      width: 25,
      height: 25,
      decoration: myBoxDecoration_checked(true, Colors.white),
    );
  }

  BoxDecoration myBoxDecoration_checked(bool isBorder, Color color) {
    return BoxDecoration(
      color: color,
      border: isBorder ? Border.all(width: 1.0) : null,
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    );
  }

  void changeCousinesIndex(int index) {
    setState(() {
      radioCousines = index;
    });
  }

  void getSortByList() {
    _listSortBy.clear();
    _listSortBy.add(Languages.of(context).labelHighToLow);
    _listSortBy.add(Languages.of(context).labelLowToHigh);
  }

  void getQuickFilterList() {
    _listQuickFilter.clear();
    _listQuickFilter.add(Languages.of(context).labelVegRestaurant);
    _listQuickFilter.add(Languages.of(context).labelNonVegRestaurant);
    _listQuickFilter.add(Languages.of(context).labelBothVegNonVeg);
  }

  callAllCuisine() {
    _allCuisineListData.clear();

    RestClient(Retro_Api().Dio_Data()).allCuisine().then((response) {
      print(response.success);
      if (progressDialog.isShowing()) {
        progressDialog.hide();
      }
      if (response.success) {
        _allCuisineListData.addAll(response.data);

        callSetState();
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

  @override
  Widget build(BuildContext context) {
    getSortByList();
    getQuickFilterList();

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
        appBar: CustomAppbar(
          isFilter: true,
          onFilterTap: () {
            openFilterSheet();
          },
          onOfferTap: () {
            Navigator.of(context).push(
              Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: OfferScreen(),
              ),
            );
          },
          onSearchTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.slideUp,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: SearchScreen()));
          },
          onLocationTap: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.none,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: SetLocationScreen()));
          },
          strSelectedAddress:
              SharedPreferenceUtil.getString(Constants.selectedAddress).isEmpty
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
                  image: DecorationImage(
                image: AssetImage('images/ic_background_image.png'),
                fit: BoxFit.cover,
              )),
              child: SingleChildScrollView(
                child: Padding(
                    padding:
                        const EdgeInsets.only(left: 15, right: 10, top: 10),
                    child: _exploreResListData.isNotEmpty
                        ? ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: _exploreResListData.length,
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
                                                  _exploreResListData[index].id,
                                              isFav: _exploreResListData[index].like,
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
                                                width:
                                                    ScreenUtil().setWidth(100),
                                                imageUrl:
                                                    _exploreResListData[index]
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
                                                                Container(
                                                                width : ScreenUtil().setWidth(130),
                                                                  child: Text(
                                                                    _exploreResListData[
                                                                            index]
                                                                        .name,
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            Constants
                                                                                .app_font_bold,
                                                                        fontSize:
                                                                            ScreenUtil()
                                                                                .setSp(16.0)),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    if (SharedPreferenceUtil.getBool(
                                                                        Constants
                                                                            .isLoggedIn)) {
                                                                      Constants
                                                                              .CheckNetwork()
                                                                          .whenComplete(() =>
                                                                              callAddRemoveFavorite(_exploreResListData[index].id));
                                                                    } else {
                                                                      Constants.toastMessage(
                                                                          Languages.of(context)
                                                                              .labelPleaseLoginToAddFavorite);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        right: ScreenUtil().setWidth(5),
                                                                        top: ScreenUtil().setWidth(5)),
                                                                    child: _exploreResListData[index]
                                                                            .like
                                                                        ? SvgPicture
                                                                            .asset(
                                                                            'images/ic_filled_heart.svg',
                                                                            color: Color(Constants.color_like),
                                                                            height: ScreenUtil().setHeight(20.0),
                                                                            width: ScreenUtil().setWidth(20.0),
                                                                          )
                                                                        : SvgPicture
                                                                            .asset(
                                                                            'images/ic_heart.svg',

                                                                            height:
                                                                                ScreenUtil().setHeight(20.0),
                                                                            width:
                                                                                ScreenUtil().setWidth(20.0),
                                                                          ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .topLeft,
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
                                                                    fontSize: ScreenUtil()
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
                                                                      .only(
                                                                  left: 10),
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        bottom:
                                                                            3),
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              5),
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        'images/ic_map.svg',
                                                                        width:
                                                                            10,
                                                                        height:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      _exploreResListData[index]
                                                                              .distance
                                                                              .toString() +
                                                                          Languages.of(context)
                                                                              .labelkmFarAway,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            ScreenUtil().setSp(12.0),
                                                                        fontFamily:
                                                                            Constants.app_font,
                                                                        color: Color(
                                                                            0xFF132229),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
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
                                                                          initialRating: _exploreResListData[index]
                                                                              .rate
                                                                              .toDouble(),
                                                                          size:
                                                                              ScreenUtil().setWidth(15.0),
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
                                                                          '(${_exploreResListData[index].review})',
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
                                                                                5),
                                                                        bottom:
                                                                            ScreenUtil().setWidth(5)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          (() {
                                                                        if (_exploreResListData[index].vendorType ==
                                                                            'veg') {
                                                                          return Row(
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
                                                                          );
                                                                        } else if (_exploreResListData[index].vendorType ==
                                                                            'non_veg') {
                                                                          return Row(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(right: 2),
                                                                                child: SvgPicture.asset(
                                                                                  'images/ic_non_veg.svg',
                                                                                  height: ScreenUtil().setHeight(10.0),
                                                                                  width: ScreenUtil().setHeight(10.0),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          );
                                                                        } else if (_exploreResListData[index].vendorType ==
                                                                            'all') {
                                                                          return Row(
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
                                    ))
                        : !_isSyncing
                            ? Container(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      width: ScreenUtil().setWidth(150),
                                      height: ScreenUtil().setHeight(180),
                                      image:
                                          AssetImage('images/ic_no_rest.png'),
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
                            : Container()),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void callAddRemoveFavorite(int vegRestId) {
    progressDialog.show();
    Map<String, String> body = {
      'id': vegRestId.toString(),
    };
    RestClient(Retro_Api().Dio_Data()).faviroute(body).then((response) {
      progressDialog.hide();
      print(response.success);
      if (response.success) {
        Constants.toastMessage(response.data);
        Constants.CheckNetwork().whenComplete(() => callExploreRestaurants());

        setState(() {});
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileUpdate);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
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
}
