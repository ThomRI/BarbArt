import 'dart:convert';
import 'dart:io';

import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'APIManager.dart';

typedef VoidCallback = void Function();

class APIJsonKeys {
  static const EventsList         = "events";
  static const Event              = "events";

  static const ClubsList          = "clubs";
  static const Club               = "club";

  static const ClientsList        = "clients";
  static const Client             = "client";

  static const PostsList          = "posts";
  static const Post               = "post";

  static const MusicReservations  = "reservations";
}

class APIRoutes {
  static const Events       = "events";
  static const EventsGoing  = "events/going";

  static const Clubs        = "clubs";

  static const Clients      = "clients";

  static const Posts        = "posts";
  static const PostsLikes   = "posts/likes";

  static const Music        = "music";
}

/// Used to declare flags for the API. For example, when re-fetching everything from server, only one update method should be called with the correct flag to indicate what to update.
class APIFlags {
  static const EVENTS             = 1 << 0; // 0001
  static const CLUBS              = 1 << 1; // 0010

  static const PROFILE            = 1 << 2; // 0100 // The user's profile, the self client.

  static const SOCIAL_POSTS       = 1 << 3; // 1000

  static const MUSIC_RESERVATIONS = 1 << 4; // 0001 0000

  static const EVERYTHING         = 0x11111111;
}

class APIConfig {
  static const String SQL_ARRAY_SEPARATOR = ",";

  DateTime  postsBeginTime,
            postsEndTime;

  final forceRequests; // Should request be forced ? If not, server returned json won't be parsed if the server indicates that it already returned the exact same json. TODO : Implement server side

  APIConfig({this.postsBeginTime, this.postsEndTime, this.forceRequests = false});
}

class APIValues {
  final APIConfig config;

  AClient selfClient = new AClient();

  String _token = "";

  APIValues({@required this.config});

  String get token => _token;

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
    if(flag & APIFlags.EVENTS != 0)             authStillAlive &= await _updateEvents();
    if(flag & APIFlags.CLUBS != 0)              authStillAlive &= await _updateClubs();
    if(flag & APIFlags.PROFILE != 0)            authStillAlive &= await _updateProfile();
    if(flag & APIFlags.SOCIAL_POSTS != 0)       authStillAlive &= await _updateSocialPosts();
    if(flag & APIFlags.MUSIC_RESERVATIONS != 0) authStillAlive &= await _updateMusicReservations();

    if(!authStillAlive && authNotAliveCallback != null) authNotAliveCallback();
    if(authStillAlive && onUpdateDone != null)          onUpdateDone(); // Calling the callback only if the auth is still alive..
  }

  /* ########################### */
  /* ######### CLIENTS ######### */
  /* ########################### */
  List<AClient> clients = new List<AClient>(); // This is a list of cached clients which won't necessarily contain every clients registered on the server.
  Map<String, int> _uuidToIndexClients = new Map<String, int>();

  AClient clientFromUUID(String uuid) => clients[_uuidToIndexClients[uuid]];

  void cacheClient(AClient client, {bool cacheAvatar = false}) {
    if(_uuidToIndexClients.containsKey(client.uuid)) return;

    // Fetching the avatar if needed
    if(cacheAvatar) {
      client.avatar = APIManager.fetchImage(route: client.avatar_route, token: _token);
    }

    clients.add(client);
    _uuidToIndexClients.addAll({client.uuid: clients.length - 1});
  }


  /* ########################### */
  /* ######### PROFILE ######### */
  /* ########################### */
  Future<bool> _updateProfile() async {
    // Fetching self client infos
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Clients + "/" + selfClient.uuid, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;
    // Note : if the uuid isn't resolved yet, server will return an ERROR_AUTH and not an unknown error, because having the token means having the uuid (it comes with it).

    // Not needed, and forced request disabled : using the cached profile infos (not updating anything)
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating profile infos
    selfClient = AClient.fromJSON(response.body[APIJsonKeys.ClientsList][0]);

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
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Events + "/*", token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating the events list
    events.clear();
    (response.body[APIJsonKeys.EventsList] as List<dynamic>).forEach((eventJSON) {events.add(new AEvent.fromJSON(eventJSON));});

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

  /* ############################ */
  /* ########## CLUBS ########### */
  /* ############################ */

  List<AClub> clubs = new List<AClub>();

  Future<bool> _updateClubs() async {
    // Fetching events from server
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Clubs, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Fetch succeeded : updating cached list
    clubs.clear();
    (response.body[APIJsonKeys.ClubsList] as List<dynamic>).forEach((clubJSON) {clubs.add(new AClub.fromJSON(clubJSON));});

    return true;
  }

  /* ################################### */
  /* ########## SOCIAL POSTS ########### */
  /* ################################### */

  List<ASocialPost> socialPosts = new List<ASocialPost>();

  Future<bool> _updateSocialPosts() async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Posts, params: {'begin_datetime': config.postsBeginTime.toString(), 'end_datetime': config.postsEndTime.toString()}, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    socialPosts.clear();
    (response.body[APIJsonKeys.PostsList] as List<dynamic>).forEach((socialPostJSON) {socialPosts.add(new ASocialPost.fromJSON(socialPostJSON));});

    /* Caching the authors of the posts in the cached client list */
    (response.body[APIJsonKeys.ClientsList] as List<dynamic>).forEach((clientJSON) {this.cacheClient(new AClient.fromJSON(clientJSON), cacheAvatar: true);});

    return true;
  }

  /* ######################################## */
  /* ########## MUSIC RESERVATION ########### */
  /* ######################################## */

  // Note : Music reservations use the events system of the API. Basically a reservation is a AEvent.

  // This list must be the only one accessed to retrieve the actual events.
  // Mapping should be done with indices of this list
  List<AEvent> musicReservations = new List<AEvent>();
  Map<DateTime, List<int>> mappedMusicReservationsIndicesByDay = new Map<DateTime, List<int>>();

  // Returns false iff there was an authentication error
  /// Updates the music reservations starting from today
  Future<bool> _updateMusicReservations() async {
    // Fetching reservations from server
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Music, params: {'date': extractDate(DateTime.now()).toString()}, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating the events list
    musicReservations.clear();
    (response.body[APIJsonKeys.MusicReservations] as List<dynamic>).forEach((eventJSON) {musicReservations.add(new AEvent.fromJSON(eventJSON));});

    // Updating the DateTime mapping
    mappedMusicReservationsIndicesByDay.clear();
    for(int i = 0;i < musicReservations.length; i++) {
      DateTime extracted = extractDate(musicReservations[i].dateTimeBegin);
      if(!mappedMusicReservationsIndicesByDay.containsKey(extracted)) { // The datetime is not in the map yet
        mappedMusicReservationsIndicesByDay.addAll({extracted: new List<int>()});
      }
      mappedMusicReservationsIndicesByDay[extracted].add(i);
    }

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
      APIJsonKeys.ClientsList: new List<Map<String, dynamic>>(),
      APIJsonKeys.EventsList: new List<Map<String, dynamic>>(),
      APIJsonKeys.ClubsList: new List<Map<String, dynamic>>(),
    });

    // Events
    for(AEvent ev in this.events) json[APIJsonKeys.EventsList].add(ev.toJSON());

    // Clubs
    for(AClub cl in this.clubs) json[APIJsonKeys.ClubsList].add(cl.toJSON());

    // Writing back into the file
    file.writeAsString(jsonEncode(json));
  }
}