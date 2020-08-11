import 'dart:convert';
import 'dart:io';

import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'APIManager.dart';

typedef VoidCallback = void Function();

class _JsonKeys {
  static const EventsList   = "events";
  static const Event        = "events";

  static const ClubsList    = "clubs";
  static const Club         = "club";

  static const ClientsList  = "clients";
  static const Client       = "client";
}

class _Routes {
  static const Events   = "events";
  static const EventsGoing = "events/going";

  static const Clubs    = "clubs";

  static const Clients  = "clients";
}

/// Used to declare flags for the API. For example, when re-fetching everything from server, only one update method should be called with the correct flag to indicate what to update.
class APIFlags {
  static const EVENTS       = 1 << 0; // 0001
  static const CLUBS        = 1 << 1; // 0010

  static const PROFILE      = 1 << 2; // 0100 // The user's profile, the self client.
  static const EVERYTHING   = 0x11111111;
}

class APIValues {

  bool forced = false; // Should request be forced ? If not, server returned json won't be parsed if the server indicates that it already returned the exact same json.
  String _token = "";
  AClient selfClient = new AClient();

  /// Toggles the forces request mode. Forced requests' response is parsed even if it is the exact same answer as the previous request of the same type.
  void toggleForced() {
    this.forced = !this.forced;
  }

  /// Authenticates the client with the provided credentials and saves its uuid and the access token.
  Future<bool> authenticate({@required String email, @required String password, Function onAuthenticated}) async {
    FetchResponse response = await APIManager.authenticate(email, password);
    if(response.state != FetchResponseState.OK) return false;

    // Authentication succeeded
    _token = response.body['token'];
    selfClient = AClient.fromJSON(response.body['client']);

    if(onAuthenticated != null) onAuthenticated();

    return true;
  }

  // Always call this function to update, with the desired updates as the flag.
  /// Match local data with server according to the given flag.
  void update(int flag, {Function authNotAliveCallback, Function onUpdateDone}) async {
    bool authStillAlive = true;
    if(flag & APIFlags.EVENTS != 0)   authStillAlive &= await _updateEvents();
    if(flag & APIFlags.CLUBS != 0)    authStillAlive &= await _updateClubs();
    if(flag & APIFlags.PROFILE != 0)  authStillAlive &= await _updateProfile();

    if(!authStillAlive && authNotAliveCallback != null) authNotAliveCallback();
    if(authStillAlive && onUpdateDone != null)          onUpdateDone(); // Calling the callback only if the auth is still alive..
  }

  /* ########################### */
  /* ######### PROFILE ######### */
  /* ########################### */
  Future<bool> _updateProfile() async {
    // Fetching self client infos
    FetchResponse response = await APIManager.fetch(route: _Routes.Clients + "/" + selfClient.uuid, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;
    // Note : if the uuid isn't resolved yet, server will return an ERROR_AUTH and not an unknown error, because having the token means having the uuid (it comes with it).

    // Not needed, and forced request disabled : using the cached profile infos (not updating anything)
    if(!forced && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating profile infos
    selfClient = AClient.fromJSON(response.body);

    // Fetching profile picture (avatar)
    selfClient.avatar = await APIManager.fetchImage(route: selfClient.avatar_route, token: _token);

    return true;
  }

  /* ############################ */
  /* ########## EVENTS ########## */
  /* ############################ */

  // This list must be the only one accessed to retrieve the actual events.
  // Mapping should be done with indices of this list
  List<AEvent> events = new List<AEvent>();
  Map<DateTime, List<int>> mappedEventsIndices = new Map<DateTime, List<int>>();

  // Returns false iff there was an authentication error
  Future<bool> _updateEvents() async {
    // Fetching events from server
    FetchResponse response = await APIManager.fetch(route: _Routes.Events + "/*", token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!forced && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating the events list
    events.clear();
    (response.body[_JsonKeys.EventsList] as List<dynamic>).forEach((eventJSON) {events.add(new AEvent.fromJSON(eventJSON));});

    // Updating the DateTime mapping
    mappedEventsIndices.clear();
    for(int i = 0;i < events.length; i++) {
      if(!mappedEventsIndices.containsKey(events[i].dateTimeBegin)) { // The datetime is not in the map yet
        mappedEventsIndices.addAll({events[i].dateTimeBegin: new List<int>()});
      }
      mappedEventsIndices[events[i].dateTimeBegin].add(i);
    }

    return true;
  }

  // Return the success state of the request
  Future<bool> requestGoing(int eventLocalId, {goingRequest: true, Function(bool success) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: _Routes.EventsGoing + "/" + events[eventLocalId].id.toString(), params: {'going': goingRequest.toString()}, token: _token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;


    if(success) { // Instead of making a full update, we can just adapt the values here as we know what happened server-side. TODO : Maybe unify the API here ?
      this.events[eventLocalId].nbrPeopleGoing += (goingRequest) ? 1 : -1;
    }

    if(onConfirmed != null) onConfirmed(success);
    return success;
  }

  /* ############################ */
  /* ########## CLUBS ########### */
  /* ############################ */

  List<AClub> clubs = new List<AClub>();

  Future<bool> _updateClubs() async {
    // Fetching events from server
    FetchResponse response = await APIManager.fetch(route: _Routes.Clubs, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!forced && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Fetch succeeded : updating cached list
    clubs.clear();
    (response.body[_JsonKeys.ClubsList] as List<dynamic>).forEach((clubJSON) {clubs.add(new AClub.fromJSON(clubJSON));});

    return true;
  }

  /* ################################################ */
  /* ########## MIRRORING SERVER ON LOCAL ########### */
  /* ################################################ */

  Future<void> save() async {
    String path = await appLocalPath;
    File file = new File(path + "/" + API_SAVEFILE);

    // Deleting the file before overwriting
    if(file.existsSync()) file.deleteSync();

    // Serializing data
    Map<String, dynamic> json = new Map<String, dynamic>();

    /* Initializing JSON arrays */
    json.addAll({
      _JsonKeys.ClientsList: new List<Map<String, dynamic>>(),
      _JsonKeys.EventsList: new List<Map<String, dynamic>>(),
      _JsonKeys.ClubsList: new List<Map<String, dynamic>>(),
    });

    // Events
    for(AEvent ev in this.events) json[_JsonKeys.EventsList].add(ev.toJSON());

    // Clubs
    for(AClub cl in this.clubs) json[_JsonKeys.ClubsList].add(cl.toJSON());

    // Writing back into the file
    file.writeAsString(jsonEncode(json));
  }
}