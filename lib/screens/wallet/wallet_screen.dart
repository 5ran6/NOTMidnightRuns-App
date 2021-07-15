import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mealup/model/balance.dart';
import 'package:mealup/network_api/Retro_Api.dart';
import 'package:mealup/network_api/api_client.dart';
import 'package:mealup/screen_animation_utils/transitions.dart';
import 'package:mealup/screens/wallet/wallet_add_screen.dart';
import 'package:mealup/utils/app_toolbar.dart';
import 'package:mealup/utils/constants.dart';
import 'package:mealup/utils/localization/language/languages.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

TextEditingController searchController = new TextEditingController();

class _WalletScreenState extends State<WalletScreen> {
  bool _isSyncing = false;
  List<Data> _searchResult = [];
  List<Data> dataList = [];
  List<Data> filterList = [];
  String balance = '';
  DateTime _selectedDate;
  DateTime _date;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    DateTime today = new DateTime(now.year, now.month, now.day);
    _date = today;
    Constants.CheckNetwork().whenComplete(() => getUserBalanceHistory());
    Constants.CheckNetwork().whenComplete(() => getWalletBalance());
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    Constants.CheckNetwork().whenComplete(() => getUserBalanceHistory());
    Constants.CheckNetwork().whenComplete(() => getWalletBalance());
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: ApplicationToolbar(
          appbarTitle: Languages.of(context).walletSetting,
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: viewportConstraints.maxHeight),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/ic_background_image.png'),
                      fit: BoxFit.cover,
                    )),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: ModalProgressHUD(
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
                              margin: EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                                    margin: EdgeInsets.only(top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 3,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Languages.of(context).walletBalance,
                                                  style: TextStyle(
                                                      color: Color(Constants.color_black),
                                                      fontFamily: Constants.app_font,
                                                      fontSize: 14),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  "\u0024$balance",
                                                  style: TextStyle(
                                                      color: Color(Constants.color_black),
                                                      fontFamily: Constants.app_font_bold,
                                                      fontSize: 26),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                  padding: EdgeInsets.only(right: 10),
                                                  child: Icon(
                                                    Icons.add_circle,
                                                    size: 30,
                                                    color: Colors.green,
                                                  )),
                                              onTap: () async {
                                                Map results = await Navigator.of(context).push(
                                                    Transitions(
                                                        transitionType: TransitionType.none,
                                                        curve: Curves.bounceInOut,
                                                        reverseCurve: Curves.fastLinearToSlowEaseIn,
                                                        widget: WalletAddScreen()));
                                                if (results != null &&
                                                    results.containsKey('selection')) {
                                                  setState(() {
                                                    _onRefresh();
                                                  });
                                                }
                                              },
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey.withOpacity(0.02),
                                              borderRadius: BorderRadius.all(Radius.circular(20))),
                                          child: TextField(
                                            style: TextStyle(color: Colors.black, fontSize: 14),
                                            controller: searchController,
                                            onChanged: onSearchTextChanged,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(20),
                                                borderSide: BorderSide(
                                                  width: 0,
                                                  style: BorderStyle.none,
                                                ),
                                              ),
                                              fillColor:
                                                  Color(Constants.color_gray).withOpacity(0.3),
                                              filled: true,
                                              hintText: 'Search here',
                                              hintStyle: TextStyle(
                                                  color: Color(Constants.color_black),
                                                  fontSize: 14,
                                                  fontFamily: Constants.app_font),
                                              suffixIcon: Icon(Icons.search,
                                                  color: Color(Constants.color_black)),
                                              // suffixIcon: IconButton(
                                              //   onPressed: () => this._clearSearch(),
                                              //   icon: Icon(Icons.clear, color: Palette.bonjour),
                                              // ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20,),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Languages.of(context).transactionHistory,
                                              style: TextStyle(
                                                  color: Color(Constants.color_black),
                                                  fontFamily: Constants.app_font_bold,
                                                  fontSize: 20),
                                            ),
                                            Text(
                                              _selectedDate != null ? 'Showing data of : ' + _selectedDate.year.toString() + '-' + _selectedDate.month.toString() + '-' + _selectedDate.day.toString() : '',
                                              style: TextStyle(
                                                  color: Color(Constants.color_gray),
                                                  fontFamily: Constants.app_font,
                                                  fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: MaterialButton(
                                          onPressed: showPicker,
                                          child: Text(
                                            'Filter',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Constants.app_font_bold,
                                                fontSize: 16),
                                          ),
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20,),
                                  filterList.length == 0 ?
                                  Flexible(child: _searchResult.length != 0 ||
                                      searchController.text.isNotEmpty
                                      ? _searchResult != null && _searchResult.isNotEmpty
                                      ? ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    itemCount: _searchResult.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  _searchResult[index].type ==
                                                      'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: _searchResult[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _searchResult[index]
                                                          .vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : _searchResult[index]
                                                          .vendorName,
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_black),
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      _searchResult[index].order ==
                                                          null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${_searchResult[index].order.orderId}',
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_gray),
                                                          fontFamily:
                                                          Constants.app_font,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${_searchResult[index].type == 'deposit' ? 0x2B : 0x2D} \u0024${_searchResult[index].amount}",
                                                style: TextStyle(
                                                    color:
                                                    _searchResult[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.app_font_bold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _searchResult[index].date,
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_gray),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${_searchResult[index].paymentDetails != null ? _searchResult[index].paymentDetails.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_black),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                      : Container(
                                      margin: EdgeInsets.only(top: 30),
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        child: Text('Not Found'),
                                      ))
                                      : dataList != null && dataList.isNotEmpty
                                      ? ListView.separated(
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                    const Divider(
                                      color: Colors.grey,
                                    ),
                                    itemCount: dataList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  dataList[index].type == 'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: dataList[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      dataList[index].vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : dataList[index]
                                                          .vendorName,
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_black),
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      dataList[index].order == null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${dataList[index].order.orderId}',
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_gray),
                                                          fontFamily:
                                                          Constants.app_font,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${dataList[index].type == 'deposit' ? '\uFF0B' : '\u2212'} \u0024${dataList[index].amount}",
                                                style: TextStyle(
                                                    color: dataList[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.app_font_bold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                dataList[index].date,
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_gray),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${dataList[index].paymentDetails != null ? dataList[index].paymentDetails.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_black),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                      : Container(
                                    margin: EdgeInsets.only(top: 30),
                                    alignment: Alignment.topCenter,
                                    child: Text('It seems you have no Transactions'),
                                  )
                                  ) :
                                  Flexible(
                                      child: ListView.separated(
                                    separatorBuilder: (BuildContext context, int index) =>
                                    const Divider(color: Colors.grey,),
                                    itemCount: filterList.length,
                                    itemBuilder: (context, index) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Icon(
                                                  filterList[index].type == 'deposit'
                                                      ? Icons.check_circle
                                                      : Icons.remove_circle,
                                                  size: 50,
                                                  color: filterList[index].type ==
                                                      'deposit'
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 7,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      filterList[index].vendorName ==
                                                          null
                                                          ? 'Deposit'
                                                          : filterList[index].vendorName,
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_black),
                                                          fontFamily: "ProximaNova",
                                                          fontSize: 16),
                                                    ),
                                                    Text(
                                                      filterList[index].order == null
                                                          ? 'Added to Wallet'
                                                          : 'Order Id : ${filterList[index].order.orderId}',
                                                      style: TextStyle(
                                                          color: Color(
                                                              Constants.color_gray),
                                                          fontFamily:
                                                          Constants.app_font,
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                "${filterList[index].type == 'deposit' ? '\uFF0B' : '\u2212'} \u0024${filterList[index].amount}",
                                                style: TextStyle(
                                                    color: filterList[index].type ==
                                                        'deposit'
                                                        ? Colors.green
                                                        : Colors.red,
                                                    fontFamily:
                                                    Constants.app_font_bold,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                filterList[index].date,
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_gray),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                "debited from ${filterList[index].paymentDetails != null ? filterList[index].paymentDetails.paymentType : 'Wallet'}",
                                                style: TextStyle(
                                                    color:
                                                    Color(Constants.color_black),
                                                    fontFamily: Constants.app_font,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  )),
            );
          },
        ),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    dataList.forEach((v) {
      if (v.date.contains(text)  || v.amount.contains(text))
        _searchResult.add(v);
      if(v.vendorName != null){
        if(v.vendorName.contains(text)){
          _searchResult.add(v);
        }
      }
    });
    filterList.clear();
    setState(() {});
  }

  /* getDataList(BuildContext context) {
    return _searchResult.length != 0 || searchController.text.isNotEmpty
        ?ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
      const Divider(
        color: Colors.grey,
      ),
      itemCount: _searchResult.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "OID: ",
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                    Text(
                      _searchResult[index].orderId,
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "\u0024${_searchResult[index].amount}",
                  style: TextStyle(
                      color: Palette.green,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              _searchResult[index].name,
              style: TextStyle(
                  color: Palette.switchs,
                  fontFamily: "ProximaBold",
                  fontSize: 16),
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Text(
                  _searchResult[index].date,
                  style: TextStyle(
                      color: Palette.switchs,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },)
        :ListView.separated(
      separatorBuilder: (BuildContext context, int index) =>
      const Divider(
        color: Colors.grey,
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "OID: ",
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                    Text(
                      dataList[index].orderId,
                      style: TextStyle(
                          color: Palette.loginhead,
                          fontFamily: "ProximaBold",
                          fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "\u0024${dataList[index].amount}",
                  style: TextStyle(
                      color: Palette.green,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              dataList[index].name,
              style: TextStyle(
                  color: Palette.switchs,
                  fontFamily: "ProximaBold",
                  fontSize: 16),
            ),
            SizedBox(height: 5,),
            Row(
              children: [
                Text(
                  dataList[index].date,
                  style: TextStyle(
                      color: Palette.switchs,
                      fontFamily: "ProximaNova",
                      fontSize: 14),
                ),
              ],
            ),
          ],
        );
      },);
  }*/

  void getUserBalanceHistory() {
    dataList.clear();
    setState(() {
      _isSyncing = true;
    });

    RestClient(Retro_Api().Dio_Data()).getBalanceHistory().then((response) {
      setState(() {
        _isSyncing = false;
        dataList.addAll(response.data);
      });
    }).catchError((Object obj) {
      setState(() {
        _isSyncing = false;
      });
      /*switch (obj.runtimeType) {
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
      }*/
    });
  }

  void getWalletBalance() {
    RestClient(Retro_Api().Dio_Data()).getWalletBalance().then((response) {
      setState(() {
        _isSyncing = false;
        balance = response.data;
      });
    }).catchError((Object obj) {
      setState(() {
        _isSyncing = false;
      });
      /* switch (obj.runtimeType) {
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
      }*/
    });
  }

  showPicker() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    CupertinoButton(
                      child: Text(
                        'Done',
                        style: TextStyle(color: Colors.blue),
                      ),
                      onPressed: () {
                        setState(() {
                          _date = _selectedDate;
                          filterList.clear();
                          for(int i=0; i <dataList.length; i++){
                            String month, day, year;
                            if(_selectedDate.month.toString().length == 1){
                              month = '0${_selectedDate.month.toString()}';
                            }else{
                              month = _selectedDate.month.toString();
                            }
                            if(_selectedDate.day.toString().length == 1){
                              day = '0${_selectedDate.day.toString()}';
                            }else{
                              day = _selectedDate.day.toString();
                            }
                            year = _selectedDate.year.toString();
                            String s = year + '-' + month + '-' + day;
                            if(s  == dataList[i].date)
                              filterList.add(dataList[i]);
                          }

                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
                Container(
                    height: 200.0,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: <Widget>[
                        Flexible(
                          flex: 8,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: _date,

                            onDateTimeChanged: (DateTime dateTime) {
                              _selectedDate = dateTime;
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
  }
}
