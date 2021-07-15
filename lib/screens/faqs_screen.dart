import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mealup/model/faq_list_model.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FAQs_Screen extends StatefulWidget {
  @override
  _FAQs_ScreenState createState() => _FAQs_ScreenState();
}

class _FAQs_ScreenState extends State<FAQs_Screen> {
  List<FAQListData> _faqListData = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    Constants.CheckNetwork().whenComplete(() => callFAQListData());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    Constants.CheckNetwork().whenComplete(() => callFAQListData());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/ic_background_image.png'),
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          appBar: ApplicationToolbar(
            appbarTitle: Languages.of(context).labelFactAQuestions,
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
              child: _faqListData.length == 0 || _faqListData.length == null
                  ? Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            width: ScreenUtil().setWidth(100),
                            height: ScreenUtil().setHeight(100),
                            image: AssetImage('images/ic_nodata.png'),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(10)),
                            child: Text(
                              'No Data Available.',
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
                  : ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _faqListData.length,
                      itemBuilder: (context, i) {
                        return new ExpansionTile(
                          expandedCrossAxisAlignment: CrossAxisAlignment.start,
                          trailing: Container(
                            child:
                                SvgPicture.asset('images/ic_bottom_arrow.svg'),
                          ),
                          title: new Text(
                            _faqListData[i].question,
                            style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w100,
                              fontFamily: Constants.app_font_bold,
                            ),
                          ),
                          children: <Widget>[
                            new Column(
                              children: _buildExpandableContent(new FoodItem(
                                _faqListData[i].question,
                                [_faqListData[i].answer],
                              )),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void callFAQListData() {
    setState(() {
      _isSyncing = true;
    });
    RestClient(Retro_Api().Dio_Data()).faq().then((response) {
      setState(() {
        _isSyncing = false;
      });
      print(response.success);
      if (response.success) {
        setState(() {
          _faqListData.addAll(response.data);
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

_buildExpandableContent(FoodItem vehicle) {
  List<Widget> columnContent = [];

  for (String content in vehicle.contents)
    columnContent.add(
      Padding(
        padding: const EdgeInsets.only(left: 30, right: 5, bottom: 20),
        child: Text(
          content,
          style: new TextStyle(
              fontSize: 14.0,
              color: Color(Constants.color_gray),
              fontFamily: Constants.app_font),
        ),
      ),
    );

  return columnContent;
}

class FoodItem {
  final String title;
  List<String> contents = [];

  FoodItem(this.title, this.contents);
}
