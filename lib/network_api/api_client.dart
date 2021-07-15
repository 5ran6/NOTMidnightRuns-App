import 'package:mealup/model/TrackingModel.dart';
import 'package:mealup/model/UserAddressListModel.dart';
import 'package:mealup/model/app_setting_model.dart';
import 'package:mealup/model/balance.dart';
import 'package:mealup/model/check_opt_model.dart';
import 'package:mealup/model/check_otp_model_for_forgot_password.dart';
import 'package:mealup/model/commen_res.dart';
import 'package:mealup/model/cuisine_vendor_details_model.dart';
import 'package:mealup/model/exploreRestaurantsListModel.dart';
import 'package:mealup/model/faq_list_model.dart';
import 'package:mealup/model/favorite_list_model.dart';
import 'package:mealup/model/login_model.dart';
import 'package:mealup/model/order_history_list_model.dart';
import 'package:mealup/model/order_setting_api_model.dart';
import 'package:mealup/model/order_status.dart';
import 'package:mealup/model/payment_setting_model.dart';
import 'package:mealup/model/promocode_model.dart';
import 'package:mealup/model/cart_tax_modal.dart';
import 'package:mealup/model/register_model.dart';
import 'package:mealup/model/search_list_model.dart';
import 'package:mealup/model/send_otp_model.dart';
import 'package:mealup/model/single_order_details_model.dart';
import 'package:mealup/model/top_restaurants_model.dart';
import 'package:mealup/model/user_details_model.dart';
import 'package:mealup/model/AllCuisinesModel.dart';
import 'package:mealup/model/nearByRestaurantsModel.dart';
import 'package:mealup/model/vegRestaurantsModel.dart';
import 'package:mealup/model/nonvegRestaurantsModel.dart';
import 'package:mealup/model/update_address_model.dart';
import 'package:mealup/model/single_restaurants_details_model.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_client.g.dart';

 @RestApi(baseUrl: "") // set your api url here(domain/api)
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;

  @POST("user_register")
  Future<RegisterModel> register(@Body() Map<String, String> map);

  @POST("check_otp")
  Future<CheckOTPModel> check_otp(@Body() Map<String, String> map);

  @POST("check_otp")
  Future<CheckOTPForForgotPasswordModel> check_otp_forForgotPassowrd(
      @Body() Map<String, String> map);

  @POST("send_otp")
  Future<SendOTPModel> send_otp(@Body() Map<String, String> map);

  @POST("user_login")
  Future<LoginModel> user_login(@Body() Map<String, String> map);

  @POST("update_image")
  Future<CommenRes> update_image(@Body() Map<String, String> map);

  @GET("user")
  Future<UserDetailsModel> user();

  @POST("update_user")
  Future<CommenRes> update_user(@Body() Map<String, String> map);

  @GET("faq")
  Future<FAQListModel> faq();

  @GET("order_setting")
  Future<OrderSettingModel> order_setting();

  @GET("cuisine")
  Future<AllCuisinesModel> allCuisine();

  @GET("payment_setting")
  Future<PaymentSettingModel> payment_setting();

  @POST("near_by")
  Future<NearByRestaurantModel> near_by(@Body() Map<String, String> map);

  @POST("top_rest")
  Future<TopRestaurantsListModel> top_rest(@Body() Map<String, String> map);

  @POST("book_order")
  Future<CommenRes> book_order(
    @Body() map,
  );

  @POST("veg_rest")
  Future<VegRestaurantModel> veg_rest(@Body() Map<String, String> map);

  @POST("nonveg_rest")
  Future<NonVegRestaurantModel> nonveg_rest(@Body() Map<String, String> map);

  @POST("explore_rest")
  Future<ExploreRestaurantListModel> explore_rest(
      @Body() Map<String, String> map);

  @POST("faviroute")
  Future<CommenRes> faviroute(@Body() Map<String, String> map);

  @POST("add_address")
  Future<CommenRes> add_address(@Body() Map<String, String> map);

  @POST("apply_promo_code")
  Future<String> apply_promo_code(@Body() Map<String, String> map);

  @POST("search")
  Future<SearchListModel> search(@Body() Map<String, String> map);

  @POST("add_feedback")
  Future<CommenRes> add_feedback(
    @Body() map,
  );

  @POST("add_review")
  Future<CommenRes> add_review(
    @Body() map,
  );

  @GET("user_address")
  Future<UserAddressListModel> user_address();

  @GET("show_order")
  Future<OrderHistoryListModel> show_order();

  @GET("user_order_status")
  Future<OrderStatus> user_order_status();

  @POST("update_address/{id}")
  Future<UpdateAddressModel> update_address(
      @Path() int id, @Body() Map<String, String> map);

  @GET("promo_code/{id}")
  Future<PromoCodeModel> promo_code(
    @Path() int id,
  );

  @GET("single_order/{id}")
  Future<SingleOrderDetailsModel> single_order(
    @Path() int id,
  );

  @POST("cancel_order")
  Future<CommenRes> cancel_order(@Body() Map<String, String> map);

  @POST("refund")
  Future<CommenRes> refund(@Body() Map<String, String> map);

  @POST("bank_details")
  Future<CommenRes> bank_details(@Body() Map<String, String> map);

  @GET("tracking/{id}")
  Future<TrackingModel> tracking(
    @Path() int id,
  );

  @GET("remove_address/{id}")
  Future<CommenRes> remove_address(@Path() int id);

  @GET("tax")
  Future<CartTaxModal> getTax();

  @GET("single_vendor/{id}")
  Future<SingleRestaurantsDetailsModel> single_vendor(@Path() int id);

  @POST("rest_faviroute")
  Future<FavoriteListModel> rest_faviroute();

  @GET("setting")
  Future<AppSettingModel> setting();

  @POST("user_forgot_password")
  Future<CommenRes> change_forgot(@Body() Map<String, String> map);

  @POST("user_change_password")
  Future<CommenRes> change_password(@Body() Map<String, String> map);

  @POST("filter")
  Future<ExploreRestaurantListModel> filter(@Body() Map<String, String> map);

  @GET("cuisine_vendor/{id}")
  Future<CuisineVendorDetailsModel> cuisine_vendor(@Path() int id);

  @GET("user_balance")
  Future<Balance> getBalanceHistory();

  @GET("wallet_balance")
  Future<CommenRes> getWalletBalance();

  @POST("add_balance")
  Future<CommenRes> addBalance(@Body() Map<String, String> map);

}
