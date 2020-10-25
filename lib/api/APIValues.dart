import 'dart:convert';
import 'dart:io';

import 'package:barbart/api/APIWebSocket.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/clubs/clubspage.dart';
import 'package:barbart/pages/events/eventspage.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/pages/music/musicpage.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

import 'APIManager.dart';

typedef VoidCallback = void Function();

class APIJsonKeys {
  static const EventsList             = "events";
  static const Event                  = "events";

  static const ClubsList              = "clubs";
  static const Club                   = "club";

  static const ClientsList            = "clients";
  static const Client                 = "client";

  static const PostsList              = "posts";
  static const Post                   = "post";

  static const Registrations          = "registrations";
  static const PermanentRegistrations = "permanentRegistrations";

  static const SupervisorList         = "supervisors";
}

class APIRoutes {
  static const Authentication = "auth";

  static const Events         = "events";
  static const EventsGoing    = "events/going";

  static const Clubs          = "clubs";

  static const Clients        = "clients";
  static const Avatar         = "avatar";

  static const Posts          = "posts";
  static const PostsLikes     = "posts/likes";

  static const Music          = "music";

  static const Register       = "register";
  static const Delete         = "delete";

  static const Check          = "check";
  static const Update         = "update";
}

/// Used to declare flags for the API. For example, when re-fetching everything from server, only one update method should be called with the correct flag to indicate what to update.
class APIFlags {
  // ---- UPDATE RELATED CODES (FROM 0 to 14) ----
  static const EVENTS               = 1 << 0; // 0001
  static const CLUBS                = 1 << 1; // 0010

  static const PROFILE              = 1 << 2; // 0100 // The user's profile, the self client.

  static const SOCIAL_POSTS         = 1 << 3; // 1000

  static const MUSIC_RESERVATIONS   = 1 << 4; // 0001 0000

  static const EVENTS_SELF_GOING    = 1 << 5;

  static const UPDATE_ENDCODE       = 1 << 15; // Last code for update (this particular one is thus not available)

  static const EVERYTHING           = 0x1111111111111111;

  // ---- NON UPDATE RELATED CODES (FROM 16 to 31) ----
  static const SOCIAL_POST_LIKES    = 1 << 16;

  static const EVENT_NBR_GOING      = 1 << 17;

  static const NON_UPDATE_ENDCODE   = 1 << 31; // Last code for non update related codes (this particular one is thus not available)

}

class APIConfig {
  static const String SQL_ARRAY_SEPARATOR = ",";

  DateTime  postsBeginTime,
            postsEndTime;

  final forceRequests; // Should request be forced ? If not, server returned json won't be parsed if the server indicates that it already returned the exact same json. TODO : Implement server side

  APIConfig({this.postsBeginTime, this.postsEndTime, this.forceRequests = false});
}

class APIValues {
  Map<String, AbstractPageComponent> pages = {
    'HomePage'  : HomePage(),
    'EventsPage': EventsPage(minimumDateTime: kEventsMinimumDateTime, maximumDateTime: kEventsMaximumDateTime,),
    'MusicPage' : MusicPage(),
    //'ClubsPage' : ClubsPage(),
  };

  Map<int, String> updateCodeMap = {
    APIFlags.SOCIAL_POSTS       : 'HomePage',
    APIFlags.EVENTS             : 'EventsPage',
    APIFlags.MUSIC_RESERVATIONS : 'MusicPage',
    APIFlags.CLUBS              : 'ClubsPage',
  };

  final APIConfig config;

  AClient selfClient = new AClient();

  String _token = "";

  /* ############################## */
  /* ######### WEB SOCKET ######### */
  /* ############################## */

  /* Web Socket API */
  APIWebSocket ws = new APIWebSocket();

  APIValues({@required this.config}) {
    // WebSocket API configuration
    ws.addCallback((message) {
      _handleWSMessage(message);
    });
  }

  void _handleWSMessage(dynamic message) {
    Map<String, dynamic> json = jsonDecode(message);
    if(!json.containsKey("code")) return;

    if(json['code'] < APIFlags.UPDATE_ENDCODE) { // Should update
      update(json['code']);
      pages[updateCodeMap[json['code']]].notifier.notify();

      return;
    }

    // From here the code should be something else than an update
    switch(json['code']) {
      case APIFlags.SOCIAL_POST_LIKES: { // Number of likes on a particular post has been updated. This is update related but is not a global update of every likes and thus is here instead of in the update pipeline.
        this.socialPosts[json['post_id']].nbrLikesNotifier.value = json['nbr_likes'];
      } break;

      case APIFlags.EVENT_NBR_GOING: {
        this.events[int.parse(json['event_id'])].nbrPeopleGoingNotifier.value = json['nbr_people_going'];
      } break;
    }
  }

  String get token => _token;
  bool get authenticated => _token != "";

  Future<bool> register({ @required String email,
                          @required String password,
                          @required String firstname,
                          @required String lastname,
                          Function(AClient) onRegistered, Function onRegistrationFailed,
                          bool makeSelf = false}) async {
    FetchResponse response = await APIManager.register(email: null, password: null, firstname: null, lastname: null);
    if(response.state != FetchResponseState.OK) { // Something went wrong
      if(onRegistrationFailed != null) onRegistrationFailed();
      return false;
    }

    // Registration succeeded
    AClient client = new AClient.fromJSON(response.body['client']);
    if(makeSelf) this.selfClient = client;

    if(onRegistered != null) onRegistered(client);
    return true;
  }

  /// Authenticates the client with the provided credentials and saves its uuid and the access token.
  Future<bool> authenticate({@required String email, @required String password, Function onAuthenticated, Function onAuthenticationFailed}) async {
    FetchResponse response = await APIManager.authenticate(email, password);
    if(response.state != FetchResponseState.OK) {
      if(onAuthenticationFailed != null) onAuthenticationFailed();
      return false;
    }

    // Authentication succeeded
    _token = response.body['token'];
    selfClient = AClient.fromJSON(response.body['client']);

    if(onAuthenticated != null) onAuthenticated();

    return true;
  }

  Future<bool> checkCredentials({@required String password, Function(bool success) onConfirmed}) async {
    FetchResponse response = await APIManager.send(route: APIRoutes.Authentication + "/" + APIRoutes.Check, token: _token, params: {'password': password});

    bool success = response.state == FetchResponseState.OK;
    if(onConfirmed != null) onConfirmed(success);

    return success;
  }

  Future<bool> updateCredentials({String email, String password, String lastname, String firstname, Function(bool success) onConfirmed}) async {
    Map<String, String> params = new Map<String, String>();

    if(email != null) params.addAll({'email': email});
    if(password != null) params.addAll({'password': password});
    if(lastname != null) params.addAll({'lastname': lastname});
    if(firstname != null) params.addAll({'firstname': firstname});

    FetchResponse response = await APIManager.send(route: APIRoutes.Authentication + "/" + APIRoutes.Update, token: _token, params: params);

    bool success = response.state == FetchResponseState.OK;
    if(onConfirmed != null) onConfirmed(success);

    return success;
  }

  /// Is used to check the validity of the token with the server
  Future<bool> checkToken() async {
    if(_token == "") { // Loading token from file if the cached token is empty.
      if(!(await loadToken())) {
        return false; // If loading from the file failed, don't even try to check the token : it's empty.
      }
    }

    FetchResponse response = await APIManager.fetch(route: APIRoutes.Authentication, token: token ?? _token);
    if(response.state != FetchResponseState.OK) return false;

    // Saving UUID
    selfClient.uuid = response.body['uuid'];

    return true;
  }

  Future<bool> attemptAutoLogin() async {
    // Checking the token
    return await APIManager.pingServer() && await checkToken();
  }

  Future<void> logout() async {
    File tokenFile = new File((await appLocalPath) + "/" + API_TOKEN_SAVEFILE);
    if(tokenFile.existsSync()) tokenFile.deleteSync();

    _token = "";
  }

  // Always call this function to update, with the desired updates as the flag.
  /// Match local data with server according to the given flag.
    void update(int flag, {Function authNotAliveCallback, Function onUpdateDone}) async {
    bool authStillAlive = true;
    if(flag & APIFlags.EVENTS != 0)             authStillAlive &= await _updateEvents();
    if(flag & APIFlags.CLUBS != 0)              authStillAlive &= await _updateClubs(); // Must be updated before the profile to retrieve correctly the client's clubs
    if(flag & APIFlags.PROFILE != 0)            authStillAlive &= await _updateProfile();
    if(flag & APIFlags.SOCIAL_POSTS != 0)       authStillAlive &= await _updateSocialPosts();
    if(flag & APIFlags.MUSIC_RESERVATIONS != 0) authStillAlive &= await _updateMusicReservations();
    if(flag & APIFlags.EVENTS_SELF_GOING != 0)    authStillAlive &= await _updateEventsGoing();

    if(!authStillAlive && authNotAliveCallback != null) authNotAliveCallback();
    if(authStillAlive && onUpdateDone != null)          onUpdateDone(); // Calling the callback only if the auth is still alive..
  }

  /* ########################### */
  /* ######### CLIENTS ######### */
  /* ########################### */
  List<AClient> clients = new List<AClient>(); // This is a list of cached clients which won't necessarily contain every clients registered on the server.
  Map<String, int> _uuidToIndexClients = new Map<String, int>();

  AClient clientFromUUID(String uuid) => (uuid == selfClient.uuid) ? selfClient : clients[_uuidToIndexClients[uuid]];

  void cacheClient(AClient client, {bool cacheAvatar = false}) {
    // Fetching the avatar if needed
    if(cacheAvatar) {
      // Note: Sending the timestamp is useful so that two consecutive URL are never the same. Otherwise NetworkImage doesn't load the same url.
      client.avatar = APIManager.fetchImage(route: client.avatar_route + "?timestamp = " + DateTime.now().millisecondsSinceEpoch.toString(), token: _token);
    }

    if(_uuidToIndexClients.containsKey(client.uuid)) return;

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
    selfClient.avatar = APIManager.fetchImage(route: selfClient.avatar_route, token: _token);

    // Requesting an open WebSocket connection
    this.ws.uuid = selfClient.uuid; // Setting the websocket uuid so that it can be authenticated.

    return true;
  }

  Future<bool> registerAvatar({File avatarFile, Function() onConfirmed}) async {
    String b64 = base64Encode(avatarFile.readAsBytesSync());
    FetchResponse response = await APIManager.send(route: APIRoutes.Clients + "/" + APIRoutes.Avatar + "/" + APIRoutes.Register, params: {'base_64': b64}, token: _token);
    if(response.state != FetchResponseState.OK) return false;

    // Fetching profile picture (avatar)
    cacheClient(selfClient, cacheAvatar: true);

    if(onConfirmed != null) onConfirmed();
    return true;
  }

  /* ############################ */
  /* ########## EVENTS ########## */
  /* ############################ */

  // This list must be the only one accessed to retrieve the actual events.
  // Mapping should be done with indices of this list
  Map<int, AEvent> events = new Map<int, AEvent>();
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
    (response.body[APIJsonKeys.EventsList] as List<dynamic>).forEach((eventJSON) {
      AEvent event = new AEvent.fromJSON(eventJSON);
      events.addAll({event.id: event});
    });

    // Updating the DateTime mapping
    mappedEventsIndices.clear();
    for(int i in events.keys) {
      if(!mappedEventsIndices.containsKey(events[i].dateTimeBegin)) { // The datetime is not in the map yet
        mappedEventsIndices.addAll({events[i].dateTimeBegin: new List<int>()});
      }
      mappedEventsIndices[events[i].dateTimeBegin].add(i);
    }

    return true;
  }

  // Events must have been loaded first
  Future<bool> _updateEventsGoing() async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.EventsGoing + "/get_all", params: {"uuid": selfClient.uuid}, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Updating the self going state of casual events
    (response.body['events'] as List<dynamic>).forEach((eventJSON) {
      int id = eventJSON['event_id'];

      if(!this.events.containsKey(id)) return;
      this.events[id].selfClientIsGoing = eventJSON['is_going'] ?? false;
    });

    // Updating the self going state of clubs events
    (response.body['clubs_events'] as List<dynamic>).forEach((clubJSON) {
      int club_id = clubJSON['club_id'];

      if(!this.clubs.containsKey(club_id)) return;

      (clubJSON['events'] as List<dynamic>).forEach((eventJSON) {
        int event_id = eventJSON['event_id'];

        if(!this.clubs[club_id].permanentEvents.containsKey(event_id)) return;

        (eventJSON['is_going_iterations'] as List<dynamic>).forEach((iterationJSON) {
          int iterationNumber = iterationJSON['iteration'];
          this.clubs[club_id].permanentEvents[event_id].setSelfClientGoing(iterationNumber, iterationJSON['is_going']);
        });
      });
    });

    /* Updating permanent events for the EventsPage */
    updatePermanentEvents();

    return true;
  }

  void updatePermanentEvents() {
    (this.pages['EventsPage'] as EventsPage).permanentEventList.clear();
    this.selfClient.clubsIDs.forEach((clubID) {
      (this.pages['EventsPage'] as EventsPage).permanentEventList.addAll(this.clubs[clubID].permanentEvents.values.toList());
    });

    /* Generating virtual events for the EventsPage */
    (this.pages['EventsPage'] as EventsPage).generateVirtualPermanentEvents();
  }

  /* ############################ */
  /* ########## CLUBS ########### */
  /* ############################ */

  Map<int, AClub> clubs = new Map<int, AClub>(); // To store the same ids than the server

  Map<String, List<int>> _clubIDMapByCategory = new Map<String, List<int>>(); // Linking categories to club IDs
  List<String> get getClubCategoryList => _clubIDMapByCategory.keys.toList();

  List<AClub> getClubListByCategory(String category) {
    if(!_clubIDMapByCategory.containsKey(category)) return new List<AClub>();

    List<AClub> clubs = new List<AClub>();
    _clubIDMapByCategory[category].forEach((id) {clubs.add(this.clubs[id]);});

    return clubs;
  }

  Future<bool> _updateClubs() async {
    // Fetching events from server
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Clubs, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Fetch succeeded : updating cached list
    clubs.clear();
    (response.body[APIJsonKeys.ClubsList] as List<dynamic>).forEach((clubJSON) {
      // Storing the club with the same ID than the server
      AClub club = new AClub.fromJSON(clubJSON);

      // Caching supervisors
      (clubJSON[APIJsonKeys.SupervisorList] as List<dynamic>).forEach((supervisorJSON) {
        AClient supervisor = AClient.fromJSON(supervisorJSON);
        cacheClient(supervisor);

        // Adding the cached supervisor from its uuid : 'supervisor' will be deleted, and in the event of the uuid already cached before, won't even be referenced.
        club.supervisors.add(this.clientFromUUID(supervisor.uuid));
      });

      // Linking the club with its category
      if(!_clubIDMapByCategory.containsKey(club.category)) _clubIDMapByCategory.addAll({club.category: new List<int>()});
      _clubIDMapByCategory[club.category].add(club.id);

      // Fetching events associated with the club
      (clubJSON[APIJsonKeys.EventsList] as List<dynamic>).forEach((eventJSON) {
        eventJSON['title'] = club.title;

        AEvent event = new AEvent.fromJSON(eventJSON);
        event.isFromClub = true;

        club.permanentEvents.addAll({event.id: event});
      });

      clubs.addAll({club.id: club});
    });

    return true;
  }

  /* ################################### */
  /* ########## SOCIAL POSTS ########### */
  /* ################################### */

  Map<int, ASocialPost> socialPosts = new Map<int, ASocialPost>();

  Future<bool> _updateSocialPosts() async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Posts, params: {'begin_datetime': config.postsBeginTime.toString(), 'end_datetime': config.postsEndTime.toString()}, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    socialPosts.clear();
    (response.body[APIJsonKeys.PostsList] as List<dynamic>).forEach((socialPostJSON) {
      ASocialPost post = new ASocialPost.fromJSON(socialPostJSON);
      socialPosts.addAll({post.id: post});
    });

    /* Caching the authors of the posts in the cached client list */
    (response.body[APIJsonKeys.ClientsList] as List<dynamic>).forEach((clientJSON) {this.cacheClient(new AClient.fromJSON(clientJSON), cacheAvatar: true);});

    return true;
  }

  /* ######################################### */
  /* ########## MUSIC REGISTRATION ########### */
  /* ######################################### */

  // Note : Music reservations use the events system of the API. Basically a reservation is a AEvent.

  // This list must be the only one accessed to retrieve the actual events.
  // Mapping should be done with indices of this list
  List<AEvent> musicRegistrations = new List<AEvent>();
  Map<DateTime, List<int>> mappedMusicRegistrationsIndicesByDay = new Map<DateTime, List<int>>();

  // Map< Day of week number, List<Permanent Registrations that day> >
  Map<int, List<AEvent>> mappedMusicPermanentRegistrations = Map.fromIterable(
    [for(int day = DateTime.monday;day <= DateTime.sunday;day++) day], // List of days, alternatively List<int>.generate(7, (i) => i + 1)
    key: (k) => k,
    value: (k) => new List<AEvent>(),
  ); // No need to save a list because the only use of permanent registrations is to be recurrent by day.

  // Returns false iff there was an authentication error
  /// Updates the music reservations starting from today
  Future<bool> _updateMusicReservations() async {
    // Fetching reservations from server
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Music, params: {'from_date': extractDate(DateTime.now()).toString()}, token: _token);
    if(response.state == FetchResponseState.ERROR_AUTH) return false;

    // Not needed, and forced request disabled : using the cache list (not updating anything).
    if(!config.forceRequests && response.state == FetchResponseState.OK_NOT_NEEDED) return true;

    // Updating the events list
    musicRegistrations.clear();
    (response.body[APIJsonKeys.Registrations] as List<dynamic>).forEach((eventJSON) {musicRegistrations.add(new AEvent.fromJSON(eventJSON));});

    // Updating the DateTime mapping
    mappedMusicRegistrationsIndicesByDay.clear();
    for(int i = 0;i < musicRegistrations.length; i++) {
      DateTime extracted = extractDate(musicRegistrations[i].dateTimeBegin);
      if(!mappedMusicRegistrationsIndicesByDay.containsKey(extracted)) { // The datetime is not in the map yet
        mappedMusicRegistrationsIndicesByDay.addAll({extracted: new List<int>()});
      }
      mappedMusicRegistrationsIndicesByDay[extracted].add(i);
    }

    // Dealing with permanent registrations
    for(int day = DateTime.monday; day <= DateTime.sunday; day++) mappedMusicPermanentRegistrations[day].clear(); // Clearing each day-corresponding list.
    (response.body[APIJsonKeys.PermanentRegistrations] as List<dynamic>).forEach((eventJSON) {
      AEvent event = new AEvent.fromJSON(eventJSON);
      mappedMusicPermanentRegistrations[event.dateTimeBegin.weekday].add(event);
    });

    // Caching clients
    (response.body[APIJsonKeys.ClientsList] as List<dynamic>).forEach((clientJSON) {this.cacheClient(new AClient.fromJSON(clientJSON), cacheAvatar: false);});

    return true;
  }

  Future<bool> registerMusicRegistration(AClient client, {@required DateTime beginTime, @required DateTime endTime, Function(AEvent registration) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Music + "/" + APIRoutes.Register, params: {'beginTime': beginTime.toUtc().toString(), 'endTime': endTime.toUtc().toString()}, token: _token);
    if(response.state != FetchResponseState.OK) return false;

    // Request should be successful from here, meaning that the server correctly registered the request, and that the registration is unique, and not overlapping any other
    // (We can then safely add it to the cached registrations)

    // Updating local cached registrations without updating everything
    AEvent registration = new AEvent.fromJSON(response.body['registration']);
    DateTime extracted = extractDate(registration.dateTimeBegin);

    musicRegistrations.add(registration);
    if(!mappedMusicRegistrationsIndicesByDay.containsKey(extracted)) {
      mappedMusicRegistrationsIndicesByDay.addAll({extracted: new List<int>()}); // Adding the new extracted date to the map if not already existent
    }
    mappedMusicRegistrationsIndicesByDay[extracted].add(musicRegistrations.length - 1);

    if(onConfirmed != null) onConfirmed(registration);
    return true;
  }

  Future<bool> deleteMusicRegistration(AEvent registration, {Function() onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.Music + "/" + APIRoutes.Delete + "/" + registration.id.toString(), token: _token);
    if(response.state != FetchResponseState.OK) return false;

    if(onConfirmed != null) onConfirmed();
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

    /* Initializing JSON arrays and values */
    json.addAll({
      'self_client': jsonEncode(selfClient.toJSON()),
      APIJsonKeys.ClientsList: new List<Map<String, dynamic>>(),
      APIJsonKeys.EventsList: new List<Map<String, dynamic>>(),
      APIJsonKeys.ClubsList: new List<Map<String, dynamic>>(),
    });

    // Cached clients
    for(AClient client in this.clients) json[APIJsonKeys.ClientsList].add(client.toJSON());

    // Events
    for(AEvent ev in this.events.values) json[APIJsonKeys.EventsList].add(ev.toJSON());

    // Clubs
    for(AClub cl in this.clubs.values) json[APIJsonKeys.ClubsList].add(cl.toJSON());

    // Writing back into the file
    file.writeAsString(jsonEncode(json));

    /* Saving token */
    saveToken();
  }

  Future<void> saveToken() async {
    File file = new File((await appLocalPath) + "/" + API_TOKEN_SAVEFILE);

    if(file.existsSync()) file.deleteSync();

    file.writeAsString(jsonEncode({
      'token': _token
    }));
  }

  // Loads the token. Returns true iff the token was successfully loaded from the API_SAVEFILE.
  // This is a different function because token has to be loaded independently of the rest to provide fast auto authentication
  // TODO: Only load the saved file once.
  Future<bool> loadToken() async {
    File file = new File((await appLocalPath) + "/" + API_TOKEN_SAVEFILE);
    if(!file.existsSync()) return false;

    Map<String, dynamic> json = jsonDecode(file.readAsStringSync());

    if(!json.containsKey('token')) return false;

    // Updating cached token
    _token = json['token'];

    return true;
  }

  // For now only loads the selfClient for login autocompletion // TODO: Load everything
  Future<bool> load() async {
    File file = new File((await appLocalPath) + "/" + API_SAVEFILE);
    if(!file.existsSync()) return false;

    Map<String, dynamic> json = jsonDecode(file.readAsStringSync());
    if(!json.containsKey('self_client')) return false;

    selfClient = AClient.fromJSON(jsonDecode(json['self_client']));
    return true;
  }
}