import 'package:flutter/material.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/order_details_screen.dart';
import 'package:mealup/utils/app_toolbar_with_btn_clr.dart';
import 'package:mealup/utils/constants.dart';
import 'dart:typed_data';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:location/location.dart';
import 'package:mealup/utils/timeline.dart';

class TrackYourOrderScreen1 extends StatefulWidget {

  final int orderId;

  const TrackYourOrderScreen1({Key key, this.orderId}) : super(key: key);

  @override
  _TrackYourOrderScreenState createState() => _TrackYourOrderScreenState();
}

class _TrackYourOrderScreenState extends State<TrackYourOrderScreen1> {
  LatLng _initialcameraposition = LatLng(22.3039, 70.8022);
  GoogleMapController _controller;
  Location _location = Location();
  BitmapDescriptor _markerIcon;

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
          CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 18),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ApplicationToolbar_WithClrBtn(
          appbarTitle: '',
          str_button_title: 'View Order Details',
          btn_color: Color(Constants.color_theme),
          onBtnPress: () {
            Navigator.of(context).push(Transitions(
                transitionType: TransitionType.fade,
                curve: Curves.bounceInOut,
                reverseCurve: Curves.fastLinearToSlowEaseIn,
                widget: OrderDetailsScreen(orderId: widget.orderId,)));
          },
        ),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _initialcameraposition),
                mapType: MapType.normal,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                markers: _createMarker(),
              ),
            ),
            Expanded(
              flex: 4,
              child:     Column(
                children: [
                  Timeline(
                    children: <Widget>[

                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          'Food is being prepared',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constants.app_font,
                          ),
                        ),
                      ),

                      Container(
                        height: 100,
                        margin: EdgeInsets.only(left: 15,top: 15,right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                'Food is ready for pickup',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: Constants.app_font,
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Container(
                                height: 70,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: Image.asset(
                                        'images/ic_pizza.jpg',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      child: Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Martin Lucifer',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily:
                                                        Constants.app_font_bold,
                                                        fontWeight: FontWeight.w900),
                                                  ),
                                                  Text(
                                                    '+10101010010',
                                                    style: TextStyle(
                                                        color:
                                                        Color(Constants.color_gray),
                                                        fontFamily: Constants.app_font),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 10),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                child: Icon(Icons.call,color: Colors.white,),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(Constants.color_theme)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )


                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          'Successfully Delivered',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: Constants.app_font,
                          ),
                        ),
                      ),


                    ],
                    indicators: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        // child: Icon(Icons.call,color: Colors.white,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(Constants.color_theme)),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        // child: Icon(Icons.call,color: Colors.white,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(Constants.color_theme)),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        // child: Icon(Icons.call,color: Colors.white,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(Constants.color_theme)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
