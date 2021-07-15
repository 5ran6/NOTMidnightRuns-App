// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl}) {
    ArgumentError.checkNotNull(_dio, '_dio');
    baseUrl ??= 'https://www.saasmonks.in/App-Demo/MealUp-76850/public/api/';
  }

  final Dio _dio;

  String baseUrl;

  @override
  Future<RegisterModel> register(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('user_register',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = RegisterModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CheckOTPModel> check_otp(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('check_otp',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CheckOTPModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CheckOTPForForgotPasswordModel> check_otp_forForgotPassowrd(
      map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('check_otp',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CheckOTPForForgotPasswordModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<SendOTPModel> send_otp(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('send_otp',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SendOTPModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<LoginModel> user_login(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('user_login',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = LoginModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> update_image(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('update_image',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<UserDetailsModel> user() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('user',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = UserDetailsModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> update_user(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('update_user',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<FAQListModel> faq() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('faq',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = FAQListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<OrderSettingModel> order_setting() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('order_setting',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = OrderSettingModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<AllCuisinesModel> allCuisine() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('cuisine',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = AllCuisinesModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<PaymentSettingModel> payment_setting() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('payment_setting',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = PaymentSettingModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<NearByRestaurantModel> near_by(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('near_by',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = NearByRestaurantModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<TopRestaurantsListModel> top_rest(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('top_rest',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = TopRestaurantsListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> book_order(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = map;
    final _result = await _dio.request<Map<String, dynamic>>('book_order',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<VegRestaurantModel> veg_rest(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('veg_rest',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = VegRestaurantModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<NonVegRestaurantModel> nonveg_rest(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('nonveg_rest',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = NonVegRestaurantModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<ExploreRestaurantListModel> explore_rest(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('explore_rest',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = ExploreRestaurantListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> faviroute(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('faviroute',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> add_address(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('add_address',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<String> apply_promo_code(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<String>('apply_promo_code',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = _result.data;
    return value;
  }

  @override
  Future<SearchListModel> search(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('search',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SearchListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> add_feedback(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = map;
    final _result = await _dio.request<Map<String, dynamic>>('add_feedback',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> add_review(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = map;
    final _result = await _dio.request<Map<String, dynamic>>('add_review',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<UserAddressListModel> user_address() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('user_address',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = UserAddressListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<OrderHistoryListModel> show_order() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('show_order',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = OrderHistoryListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<OrderStatus> user_order_status() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>(
        'user_order_status',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = OrderStatus.fromJson(_result.data);
    return value;
  }

  @override
  Future<UpdateAddressModel> update_address(id, map) async {
    ArgumentError.checkNotNull(id, 'id');
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>(
        'update_address/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = UpdateAddressModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<PromoCodeModel> promo_code(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('promo_code/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = PromoCodeModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<SingleOrderDetailsModel> single_order(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('single_order/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SingleOrderDetailsModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> cancel_order(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('cancel_order',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> refund(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('refund',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> bank_details(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('bank_details',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<TrackingModel> tracking(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('tracking/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = TrackingModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> remove_address(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>(
        'remove_address/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CartTaxModal> getTax() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('tax',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CartTaxModal.fromJson(_result.data);
    return value;
  }

  @override
  Future<SingleRestaurantsDetailsModel> single_vendor(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>(
        'single_vendor/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = SingleRestaurantsDetailsModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<FavoriteListModel> rest_faviroute() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('rest_faviroute',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = FavoriteListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<AppSettingModel> setting() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('setting',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = AppSettingModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> change_forgot(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>(
        'user_forgot_password',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> change_password(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>(
        'user_change_password',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<ExploreRestaurantListModel> filter(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('filter',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = ExploreRestaurantListModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<CuisineVendorDetailsModel> cuisine_vendor(id) async {
    ArgumentError.checkNotNull(id, 'id');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>(
        'cuisine_vendor/$id',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CuisineVendorDetailsModel.fromJson(_result.data);
    return value;
  }

  @override
  Future<Balance> getBalanceHistory() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('user_balance',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = Balance.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> getWalletBalance() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.request<Map<String, dynamic>>('wallet_balance',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'GET',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }

  @override
  Future<CommenRes> addBalance(map) async {
    ArgumentError.checkNotNull(map, 'map');
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(map ?? <String, dynamic>{});
    final _result = await _dio.request<Map<String, dynamic>>('add_balance',
        queryParameters: queryParameters,
        options: RequestOptions(
            method: 'POST',
            headers: <String, dynamic>{},
            extra: _extra,
            baseUrl: baseUrl),
        data: _data);
    final value = CommenRes.fromJson(_result.data);
    return value;
  }
}
