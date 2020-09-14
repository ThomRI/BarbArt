import 'dart:convert';
import 'dart:io';

import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class APIManager {
  APIManager();

  /// Returns true iff the server is responding
  static Future<bool> pingServer() async {
    return (await fetch(route: 'ping', token: null)).state == FetchResponseState.OK;
  }

  static Future<FetchResponse> register({ @required String email,
                                          @required String password,
                                          @required String firstname,
                                          @required String lastname}) async {

    // Note: The password should be sent over HTTPS so this shouldn't be an issue.
    Map<String, dynamic> json = jsonDecode((await post(API_BASEURL + "/register", body: {"email": email, "password": password, "firstname": firstname, "lastname": lastname})).body);
    return _validateResponse(json);
  }

  static Future<FetchResponse> authenticate(String email, String password) async {
    Map<String, dynamic> json = jsonDecode((await post(API_BASEURL + "/auth", body: {"email": email, "password": password})).body);
    return _validateResponse(json);
  }

  static FetchResponse _validateResponse(Map<String, dynamic> json) { // Checks if we are still authenticated, changes the auth flag otherwise.
    if(json.containsKey('auth') && !json['auth']) {
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
    Map<String, dynamic> json = jsonDecode((await get(new Uri(scheme: "https", host: API_BASEHOST, port: API_PORT, queryParameters: params, path: route), headers: {HttpHeaders.authorizationHeader: token})).body);
    return _validateResponse(json);
  }

  static Future<FetchResponse> send({@required String route, @required String token, Map<String, String> params}) async {
    Map<String, dynamic> json = jsonDecode((await post(API_BASEURL + "/" + route, body: params, headers: {HttpHeaders.authorizationHeader: token})).body);
    return _validateResponse(json);
  }

  static NetworkImage fetchImage({@required String route, @required String token, double scale = 1.0}) {
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