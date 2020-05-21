import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

class DioUtils {
  static DioUtils _instance;
  factory DioUtils() => _getInstance();
  DioUtils._();

  static DioUtils _getInstance() {
    if (_instance == null) {
      _instance = DioUtils._();
    }
    return _instance;
  }

  static final String okCode = "200";
  static Dio _dio;

  static Future<void> init() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path + "/.cookies/";
    CookieJar cj = PersistCookieJar(dir: tempPath);
    _dio = Dio(BaseOptions(
        baseUrl: "http://music.api.tianlinyong.cn",
        followRedirects: false
    ))
      ..interceptors.add(CookieManager(cj));
  }


  static Future request(String method, String url, { Map<String, dynamic> params, Options options }) async {
    try {
      if (options == null) {
        options = Options();
      }
      options.merge(method: method);
      params = filterMapNull(params);
      Response res = await _dio.request(
        url,
        data: method == "POST" || method == "PUT" ? params : null,
        queryParameters: method == "GET" || method == "DELETE" ? params : null,
        options: options,
      );
      return handleResult(res);
    } catch(e) {
      throw handleException(e);
    }
  }

  static Future get(String url, { Map<String, dynamic> queryParameters }) async {
    queryParameters = filterMapNull(queryParameters);
    try {
      Response res = await _dio.get(url, queryParameters: queryParameters);
      return handleResult(res);
    } catch(e) {
      throw handleException(e);
    }
  }

  static Future post(String url, { Map<String, dynamic> queryParameters, data }) async{
    queryParameters = filterMapNull(queryParameters);
    data = filterMapNull(data);
    try {
      Response res = await _dio.post(url, queryParameters: queryParameters, data: data);
      return handleResult(res);
    } catch(e) {
      throw handleException(e);
    }
  }

  static Future put(String url, { Map<String, dynamic> queryParameters, data }) async{
    queryParameters = filterMapNull(queryParameters);
    data = filterMapNull(data);
    try {
      Response res = await _dio.put(url, queryParameters: queryParameters, data: data);
      return handleResult(res);
    } catch(e) {
      throw handleException(e);
    }
  }

  static Future delete(String url, { Map<String, dynamic> queryParameters, data }) async {
    queryParameters = filterMapNull(queryParameters);
    data = filterMapNull(data);
    try {
      Response res = await _dio.delete(url, queryParameters: queryParameters, data: data);
      return handleResult(res);
    } catch(e) {
      throw handleException(e);
    }
  }

  /// 过滤Map中为null的值
  static filterMapNull(Map<String, dynamic> o) {
    if (o == null || o.isEmpty) return o;

    o.forEach((String key, dynamic value) {
      if (value == null) {
        o.remove(key);
      } else if (value is String) {
        value = value.toString().trim();
      } else if (value is Map) {
        value = filterMapNull(value);
      } else if (value is List) {
        value = filterListNull(value);
      }
    });
    return o;
  }

  /// 过滤List中为Null的值
  static filterListNull(List<dynamic> o) {
    if (o == null || o.isEmpty) return o;
    o.forEach((dynamic value) {
      if (value == null) {
        o.remove(value);
      } else if (value is String) {
        value = value.toString().trim();
      } else if (value is Map) {
        value = filterMapNull(value);
      } else if (value is List) {
        value = filterListNull(value);
      }
    });
    return o;
  }

  /// 返回结果处理
  static handleResult(res) {
    if (res.data["code"] != null && res.data["code"].toString() == okCode) {
      return res.data;
    } else {
//      ErrorResult errorResult = ErrorResult(res.data["code"].toString() ?? "-100", res.data["message"]);
//      BotToast.showText(
//          text: errorResult.message,
//          borderRadius: BorderRadius.all(Radius.circular(20)),
//          textStyle: TextStyle(
//              fontSize: 15,
//              color: Colors.white
//          ),
//          duration: Duration(seconds: 3)
//      );
      throw res.data["message"];
    }
  }

  /// 异常结果处理
  static handleException(e) {
    print(e);
    ErrorResult errorResult;
    if (e is DioError) {
      switch (e.type) {
        case DioErrorType.CANCEL:
          errorResult = ErrorResult("-1", "请求取消");
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          errorResult = ErrorResult("-1", "连接超时");
          break;
        case DioErrorType.SEND_TIMEOUT:
          errorResult = ErrorResult("-1", "请求超时");
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorResult = ErrorResult("-1", "响应超时");
          break;
        case DioErrorType.RESPONSE:
          if (e.response.data != null) {
            errorResult = ErrorResult(e.response.data["code"].toString(), e.response.data["message"] ?? e.response.data["msg"] ?? '');
            break;
          }
          String errCode = e.response.statusCode.toString();
          String errMsg = "";
          switch (e.response.statusCode) {
            case 400:
              errMsg = "客户端请求的语法错误";
              break;
            case 401:
              errMsg = "未授权，请重新登录";
              break;
            case 403:
              errMsg = "拒绝访问";
              break;
            case 404:
              errMsg = "您所请求的资源无法找到";
              break;
            case 500:
              errMsg = "服务器错误";
              break;
            default:
              errMsg = "连接服务器失败，错误码:$errCode";
              break;
          }
          errorResult = ErrorResult(errCode, errMsg);
          break;
        case DioErrorType.DEFAULT:
          errorResult = ErrorResult("-1", e.message);
          break;
      }
    } else {
      errorResult = ErrorResult("-2", e.toString());
    }
    if (errorResult != null) {
      BotToast.showText(
          text: errorResult.message,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          textStyle: TextStyle(
              fontSize: 15,
              color: Colors.white
          ),
          duration: Duration(seconds: 3)
      );
    }
    return errorResult;
  }
}

class ErrorResult {
  final String code;
  final String message;

  ErrorResult(this.code, this.message);

  @override
  String toString() {
    return "========= DioUtils Error Result: code=$code, message=$message";
  }
}