import 'dart:convert';
import 'dart:io';

import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class APIManager {
  APIManager();

  static Future<FetchResponse> authenticate(String email, String password) async {
    Map<String, dynamic> json = jsonDecode((await post(API_BASEURL + ":3000" + "/auth", body: {"email": email, "password": password})).body);
    return _validateResponse(json);
  }

  static FetchResponse _validateResponse(Map<String, dynamic> json) { // Checks if we are still authenticated, changes the auth flag otherwise.
    if(!json['auth']) {
      return new FetchResponse(
        state: FetchResponseState.ERROR_AUTH,
        body: json
      );
    }

    if(json.containsKey('needed') && !json['needed']) {
      return new FetchResponse(
        state: FetchResponseState.OK_NOT_NEEDED,
        body: json
      );
    }

    if(json.containsKey('success') && !json['success']) {
      return new FetchResponse(
        state: FetchResponseState.FAILED,
        body: json
      );
    }

    return new FetchResponse(
      state: FetchResponseState.OK,
      body: json
    );
  }

  /// Is used to fetch something from the API using a GET request on the passed route.
  /// force param is used to force re-parsing even if we already had the same server response last time.
  /// params are the GET request parameters.
  static Future<FetchResponse> fetch({@required String route, @required String token, Map<String, String> params}) async {
    Map<String, dynamic> json = jsonDecode((await get(new Uri(scheme: "http", host: API_BASEHOST, port: 3000, queryParameters: params, path: route), headers: {HttpHeaders.authorizationHeader: token})).body);
    return _validateResponse(json);
  }

  static Future<NetworkImage> fetchImage({@required String route, @required String token, double scale = 1.0}) async {

    return NetworkImage(
      API_BASEURL + "/" + route,
      headers: {HttpHeaders.authorizationHeader: token},
      scale: scale
    );
  }
}

enum FetchResponseState {
  OK,
  OK_NOT_NEEDED,
  ERROR_AUTH,
  FAILED,
  ERROR_UNKNOWN
}

/// Fetch response
class FetchResponse {
  FetchResponseState state = FetchResponseState.ERROR_UNKNOWN;
  Map<String, dynamic> body;

  FetchResponse({this.state, this.body});
}