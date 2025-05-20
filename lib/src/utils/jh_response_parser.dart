import 'package:dio/dio.dart';
import 'package:skana_ehentai/src/model/jh_response/jh_response.dart';


class JHResponseParser {
  static JHResponse commonParse(Headers headers, dynamic data) {
    return JHResponse.fromJson(data);
  }
}
