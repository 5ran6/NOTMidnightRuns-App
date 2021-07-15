import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/manage_your_location.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:mealup/utils/rounded_corner_app_button.dart';
import 'package:mealup/utils_google_map/address_search.dart';
import 'package:mealup/utils_google_map/place_service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:uuid/uuid.dart';

class EditAddressScreen extends StatefulWidget {
  final int addressId, userId;

  final String strAddress, strAddressType, latitude, longitude;

  const EditAddressScreen(
      {Key key,
      @required this.addressId,
      @required this.userId,
      @required this.latitude,
      @required this.longitude,
      @required this.strAddress,
      @required this.strAddressType})
      : super(key: key);

  @override
  _EditAddressScreenState createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  LatLng _initialcameraposition;
  GoogleMapController _controller;
  Location _location = Location();
  BitmapDescriptor _markerIcon;

  ProgressDialog progressDialog;

  TextEditingController _textFullAddress = new TextEditingController();
  TextEditingController _textLandmark = new TextEditingController();
  TextEditingController _textAddressLable = new TextEditingController();

  String str_longitude = '',
      str_latitude = '',
      str_searchedAddress = '',
      strAddressLable = '';

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIcon == null) {
      BitmapDescriptor bitmapDescriptor =
          await _bitmapDescriptorFromSvgAsset(context, 'images/ic_marker.svg');
      _updateBitmap(bitmapDescriptor);
    }
  }

  Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    DrawableRoot svgDrawableRoot = await svg.fromSvgString(svgString, null);

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;
    double width =
        32 * devicePixelRatio; // where 32 is your SVG's original width
    double height = 32 * devicePixelRatio; // same thing

    // Convert to ui.Picture
    ui.Picture picture = svgDrawableRoot.toPicture(size: Size(width, height));

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI
    ui.Image image = await picture.toImage(width.toInt(), height.toInt());
    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIcon = bitmap;
    });
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
        markerId: MarkerId("marker_1"),
        position: _initialcameraposition,
        icon: _markerIcon,
      ),
    ].toSet();
  }

  void _onMapCreated(GoogleMapController _cntlr) {
    _controller = _cntlr;
    _location.onLocationChanged.listen((l) {
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(double.parse(widget.latitude),
                  double.parse(widget.longitude)),
              zoom: 18),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      str_longitude = widget.longitude;
      str_latitude = widget.latitude;
      _initialcameraposition =
          LatLng(double.parse(widget.latitude), double.parse(widget.longitude));
      strAddressLable = widget.strAddressType;

      _textAddressLable.text = strAddressLable;
      _textFullAddress.text = widget.strAddress;
      str_searchedAddress = widget.strAddress;
    });
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

    _createMarkerImageFromAsset(context);

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _initialcameraposition),
                  mapType: MapType.normal,
                  onMapCreated: _onMapCreated,
                  myLocationEnabled: true,
                  markers: _createMarker(),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          // generate a new token here
                          final sessionToken = Uuid().v4();
                          final Suggestion1 result = await showSearch(
                            context: context,
                            delegate: AddressSearch(sessionToken),
                          );
                          // This will change the text displayed in the TextField
                          if (result != null) {
                            final placeDetails =
                                await PlaceApiProvider(sessionToken)
                                    .getPlaceDetailFromId(result.placeId);
                            setState(() {
                              _textFullAddress.text = result.description +
                                  '\n' +
                                  placeDetails.street +
                                  ' ' +
                                  placeDetails.city;
                              _textFullAddress.text = result.description +
                                  '\n' +
                                  placeDetails.street +
                                  ' ' +
                                  placeDetails.city;
                              str_searchedAddress = result.description +
                                  '\n' +
                                  placeDetails.street +
                                  ' ' +
                                  placeDetails.city;
                              print(result.lat);
                              print(result.longi);
                              str_longitude = result.longi.toString();
                              str_latitude = result.lat.toString();

                              _controller.animateCamera(
                                CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                      target: LatLng(double.parse(str_latitude),
                                          double.parse(str_longitude)),
                                      zoom: 18),
                                ),
                              );
                              _initialcameraposition = LatLng(
                                  double.parse(str_latitude),
                                  double.parse(str_longitude));
                              _createMarker();
                            });
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: ScreenUtil().setHeight(10)),
                                  child: SvgPicture.asset(
                                    'images/search.svg',
                                    width: ScreenUtil().setWidth(15),
                                    color: Colors.black,
                                    height: ScreenUtil().setHeight(15),
                                  ),
                                ),
                              ),
                              TextSpan(
                                text: Languages.of(context).labelSearchLocation,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: Constants.app_font_bold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ScreenUtil().setSp(16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          str_searchedAddress,
                          style: TextStyle(
                              color: Color(Constants.color_gray),
                              fontFamily: Constants.app_font),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          Languages.of(context).labelHouseNo,
                          style: TextStyle(
                              fontFamily: Constants.app_font_bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          height: ScreenUtil().setHeight(100),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _textFullAddress,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: Languages.of(context)
                                        .labelTypeFullAddressHere,
                                    border: InputBorder.none),
                                maxLines: 3,
                                style: TextStyle(
                                    fontFamily: Constants.app_font,
                                    fontSize: 16,
                                    color: Color(
                                      Constants.color_gray,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          Languages.of(context).labelLandmark,
                          style: TextStyle(
                              fontFamily: Constants.app_font_bold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 2, bottom: 2),
                              child: TextField(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.only(left: 10),
                                  hintText: Languages.of(context)
                                      .labelAnyLandmarkNearYourLocation,
                                  hintStyle: TextStyle(
                                    fontSize: 16,
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
                      Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 10),
                        child: RoundedCornerAppButton(
                          onPressed: () {
                            showdialog();
                          },
                          btn_lable: Languages.of(context).labelEditAddress,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  showdialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 0, top: 20),
              child: Container(
                height: ScreenUtil().setHeight(250),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Languages.of(context).labelAttachLabel,
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
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, top: 2, bottom: 2),
                                child: TextField(
                                  controller: _textAddressLable,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    hintText: Languages.of(context)
                                        .labelAddLabelForThisLocation,
                                    hintStyle: TextStyle(
                                      fontSize: 14,
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
                        SizedBox(
                          height: ScreenUtil().setHeight(25),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              'images/ic_map.svg',
                              width: 18,
                              height: ScreenUtil().setHeight(18),
                              color: Color(Constants.color_theme),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, top: 2),
                                child: Text(
                                  str_searchedAddress,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: Constants.app_font,
                                      color: Color(Constants.color_black)),
                                ),
                              ),
                            )
                          ],
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
                                  Languages.of(context).labelCancel,
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
                                    if (str_searchedAddress.isEmpty ||
                                        str_searchedAddress == null) {
                                      Constants.toastMessage(
                                          Languages.of(context)
                                              .labelPleaseSearchaddress);
                                    } else if (_textAddressLable.text.isEmpty ||
                                        _textAddressLable.text == null) {
                                      Constants.toastMessage(
                                          Languages.of(context)
                                              .labelPleaseAddLabelforaddress);
                                    } else {
                                      callUpdateUserAddress(widget.addressId);
                                    }
                                  },
                                  child: Text(
                                    Languages.of(context).labelSaveIt,
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

  void callUpdateUserAddress(int addressId) {
    progressDialog.show();

    Map<String, String> body = {
      'address': str_searchedAddress,
      'lat': str_latitude,
      'lang': str_longitude,
      'type': _textAddressLable.text,
    };
    RestClient(Retro_Api().Dio_Data())
        .update_address(addressId, body)
        .then((response) {
      progressDialog.hide();
      print(response.success);

      if (response.success) {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(
          Transitions(
            transitionType: TransitionType.slideUp,
            curve: Curves.bounceInOut,
            reverseCurve: Curves.fastLinearToSlowEaseIn,
            widget: ManageYourLocation(),
          ),
        );
      } else {
        Constants.toastMessage(Languages.of(context).labelErrorWhileAddAddress);
      }
    }).catchError((Object obj) {
      progressDialog.hide();
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          var msg = res.statusMessage;
          var responsecode = res.statusCode;
          if (responsecode == 401) {
            Constants.toastMessage('{status code : $responsecode}');
            print(responsecode);
            print(res.statusMessage);
          } else if (responsecode == 422) {
            print("code:$responsecode");
            print("msg:$msg");
            Constants.toastMessage('{status code : $responsecode}');
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
