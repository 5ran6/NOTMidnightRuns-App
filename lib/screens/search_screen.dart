import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/componants/horizontal_listview_with_image_and_text.dart';
import 'package:mealup/model/search_list_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/restaurants_details_screen.dart';
import 'package:mealup/screens/single_cuisine_details_screen.dart';
import 'package:mealup/utils/SharedPreferenceUtil.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rating_bar/rating_bar.dart';
import 'package:dio/dio.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<VendorListData> vendorList = [];
  List<CuisineListData> cuisineList = [];
  List<String> restaurantsFood = [];
  ProgressDialog progressDialog;
  TextEditingController search_controller = new TextEditingController();
  List<String> searchHistoryList = [];

  @override
  void initState() {
    super.initState();
    if (SharedPreferenceUtil.getStringList(Constants.recentSearch).length != null &&
        SharedPreferenceUtil.getStringList(Constants.recentSearch).length != 0) {
      searchHistoryList = SharedPreferenceUtil.getStringList(Constants.recentSearch);
    }
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
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 5),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 30,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10),
                                  child: TextField(
                                    controller: search_controller,
                                    onChanged: onSearchTextChanged,
                                    onEditingComplete: onEditCompleted,
                                    textInputAction: TextInputAction.search,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 10),
                                      suffixIcon: IconButton(
                                        onPressed: () => {},
                                        icon: SvgPicture.asset(
                                          'images/search.svg',
                                          width: 20,
                                          height: 20,
                                          color: Color(Constants.color_gray),
                                        ),
                                      ),
                                      hintText: Languages.of(context)
                                          .labelSearchSomething,
                                      hintStyle: TextStyle(
                                        fontSize: 14,
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
                            )
                          ],
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              searchHistoryList.length != null &&
                                      searchHistoryList.length != 0
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, left: 15, right: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                Languages.of(context)
                                                    .labelRecentlySearches,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                      Constants.app_font,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    searchHistoryList.clear();
                                                  });
                                                },
                                                child: Text(
                                                  Languages.of(context)
                                                      .labelClear,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontFamily:
                                                          Constants.app_font,
                                                      color: Color(Constants
                                                          .color_theme)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          itemCount: searchHistoryList.length,
                                          itemBuilder: (BuildContext context,
                                                  int index) =>
                                              InkWell(
                                            onTap: () {
                                              search_controller.text =
                                                  searchHistoryList[index];
                                              onSearchTextChanged(
                                                  search_controller.text);
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0, top: 15),
                                              child: Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        WidgetSpan(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 10),
                                                            child: SvgPicture
                                                                .asset(
                                                              'images/ic_clock.svg',
                                                              width: 15,
                                                              height: 15,
                                                            ),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                            text:
                                                                searchHistoryList[
                                                                    index],
                                                            style: TextStyle(
                                                                color: Color(
                                                                    Constants
                                                                        .color_black),
                                                                fontFamily:
                                                                    Constants
                                                                        .app_font,
                                                                fontSize: 14)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  Languages.of(context).labelSearchByFood,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: Constants.app_font),
                                ),
                              ),
                              cuisineList.length == 0 || cuisineList.length == null
                                  ? Container(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Image(
                                      width: ScreenUtil().setWidth(100),
                                      height: ScreenUtil().setHeight(100),
                                      image: AssetImage(
                                          'images/ic_no_rest.png'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top:
                                          ScreenUtil().setHeight(10)),
                                      child: Text(
                                        Languages.of(context).labelNodata,
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
                                  : Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 10),
                                child: SizedBox(
                                  height: ScreenUtil().setHeight(147),
                                  width: ScreenUtil().setWidth(114),
                                  child: ListView.builder(
                                    physics: ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: cuisineList.length,
                                    itemBuilder: (BuildContext context,
                                        int index) =>
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  Transitions(
                                                      transitionType:
                                                      TransitionType.none,
                                                      curve:
                                                      Curves.bounceInOut,
                                                      reverseCurve: Curves
                                                          .fastLinearToSlowEaseIn,
                                                      widget:
                                                      SingleCuisineDetailsScreen(
                                                        cuisineId:
                                                        vendorList[index]
                                                            .id,
                                                        strCuisineName:
                                                        cuisineList[index]
                                                            .name,
                                                      )));
                                            },
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    15.0),
                                              ),
                                              child: Column(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        15.0),
                                                    child: CachedNetworkImage(
                                                      height: 100,
                                                      width: 100,
                                                      imageUrl:
                                                      cuisineList[index]
                                                          .image,
                                                      fit: BoxFit.cover,
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
                                                    child: Center(
                                                      child: Text(
                                                        cuisineList[index]
                                                            .name,
                                                        style: TextStyle(
                                                          fontFamily: Constants
                                                              .app_font_bold,
                                                          fontSize:
                                                          ScreenUtil()
                                                              .setSp(
                                                              16.0),
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
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 10),
                                child: Text(
                                  Languages.of(context).labelSearchByTopBrands,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: Constants.app_font),
                                ),
                              ),
                              Container(
                                height: ScreenUtil().setHeight(220),
                                child: (() {
                                  if (vendorList.length == 0 ||
                                      vendorList.length == null) {
                                    return Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Image(
                                            width: ScreenUtil().setWidth(100),
                                            height: ScreenUtil().setHeight(100),
                                            image: AssetImage(
                                                'images/ic_no_rest.png'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top:
                                                ScreenUtil().setHeight(10)),
                                            child: Text(
                                              Languages.of(context).labelNodata,
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
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: GridView.count(
                                        childAspectRatio: 0.35,
                                        crossAxisCount: 2,
                                        scrollDirection: Axis.horizontal,
                                        mainAxisSpacing:
                                        ScreenUtil().setWidth(10),
                                        children: List.generate(
                                            vendorList.length, (index) {
                                          return Container(
                                            width: ScreenUtil().setWidth(220),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: GestureDetector(
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
                                                        vendorList[index]
                                                            .id,
                                                        isFav: false,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Card(
                                                  margin: EdgeInsets.only(
                                                      bottom: 20),
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
                                                        BorderRadius
                                                            .circular(15.0),
                                                        child:
                                                        CachedNetworkImage(
                                                          height: 100,
                                                          width: 100,
                                                          imageUrl:
                                                          vendorList[index]
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
                                                                    child: Image
                                                                        .network(
                                                                        'https://saasmonks.in/App-Demo/MealUp-76850/public/images/upload/noimage.png')),
                                                              ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: ScreenUtil()
                                                            .setWidth(180),
                                                        child: Container(
                                                          width: ScreenUtil()
                                                              .setWidth(180),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                            children: [
                                                              Container(
                                                                child: Column(
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                        left:
                                                                        10,
                                                                        right:
                                                                        10,
                                                                      ),
                                                                      child:
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Text(
                                                                            vendorList[index].name,
                                                                            style:
                                                                            TextStyle(fontFamily: Constants.app_font_bold, fontSize: ScreenUtil().setSp(16.0)),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      alignment:
                                                                      Alignment
                                                                          .topLeft,
                                                                      child:
                                                                      Padding(
                                                                        padding:
                                                                        const EdgeInsets.only(left: 10),
                                                                        child:
                                                                        Text(getRestaurantsFood(index),
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
                                                                alignment:
                                                                Alignment
                                                                    .topLeft,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left: 10),
                                                                  child: Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Container(
                                                                            child:
                                                                            Row(
                                                                              children: [
                                                                                RatingBar.readOnly(
                                                                                  initialRating: vendorList[index].rate.toDouble(),
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
                                                                                  '(${vendorList[index].review})',
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
                                                                              child: vendorList[index].vendorType == 'veg'
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
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                          ;
                                        }),
                                      ),
                                    );
                                  }
                                }()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ),
      ),
    );
  }

  String getRestaurantsFood(int index) {
    restaurantsFood.clear();
    if (vendorList.isNotEmpty) {
      for (int j = 0; j < vendorList[index].cuisine.length; j++) {
        restaurantsFood.add(vendorList[index].cuisine[j].name);
      }
    }
    print(restaurantsFood.toString());

    return restaurantsFood.join(" , ");
  }

  onSearchTextChanged(String text) async {
    cuisineList.clear();
    vendorList.clear();
    // progressDialog.show();
    Map<String, String> body = {
      'lat': SharedPreferenceUtil.getString('selectedLat'),
      'lang': SharedPreferenceUtil.getString('selectedLng'),
      'name': text,
    };
    RestClient(Retro_Api().Dio_Data()).search(body).then((response) {
      print(response.success);
      // progressDialog.hide();
      if (response.success) {
        setState(() {
          if (response.data.vendor.length != 0) {
            vendorList.clear();
            vendorList.addAll(response.data.vendor);
          } else {
            vendorList.clear();
          }

          if (response.data.cuisine.length != 0) {
            cuisineList.clear();
            cuisineList.addAll(response.data.cuisine);
          } else {
            cuisineList.clear();
          }
        });
      } else {
        Constants.toastMessage(Languages.of(context).labelNodata);
      }
    }).catchError((Object obj) {
      // progressDialog.hide();
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

  void onEditCompleted() {
    setState(() {
      if (searchHistoryList.length <= 2) {
        searchHistoryList.add(search_controller.text);
      } else {
        searchHistoryList.removeAt(0);
        searchHistoryList.add(search_controller.text);
      }
    });
    SharedPreferenceUtil.putStringList(
        Constants.recentSearch, searchHistoryList);
    print('=====================================HISTORY+++++++++++++++++' +
        searchHistoryList.toString());
  }
}
