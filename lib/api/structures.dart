/* This file's purpose is to define data structures used in the API */

import 'dart:convert';

import 'package:flutter/material.dart';

import '../main.dart';
import '../utils.dart';
import 'APIManager.dart';
import 'APIValues.dart';

/* IMPORTANT : Every classes related to the API start by 'A' */

abstract class APIStructure {
  APIStructure();
  APIStructure.fromJSON(Map<String, dynamic> json);
  Map<String, dynamic> toJSON();
}

/// Represents an API client. Most likely linked to one account (custom or fb,google,...). Anyway it has one UUID.
class AClient extends APIStructure {
  String  uuid,
          email,
          firstname,
          lastname;

  dynamic avatar = new AssetImage("assets/profile_generic.png");
  String avatar_route;

  List<int> clubsIDs = new List<int>(); // Clubs that the client is member of.
  bool isClubMember(AClub club) => this.clubsIDs.contains(club.id);

  // ignore: non_constant_identifier_names
  AClient({this.uuid = "", this.email = "", this.avatar_route = "", this.firstname, this.lastname, String clubsArrayStr = ""}) {
    // Populating clubs IDs
    if(clubsArrayStr.length == 0) return;
    clubsArrayStr.split(",").forEach((clubIDstr) {
      clubsIDs.add(int.parse(clubIDstr));
    });
  }

  // Set this client as a generic non-authenticated client
  void genericify() {
    this.uuid = "";
    this.email = "";
    this.avatar = new AssetImage("assets/profile_generic.png");
  }

  String toString() {
    return this.firstname + " " + this.lastname;
  }

  @override
  factory AClient.fromJSON(Map<String, dynamic> json) => AClient(
    uuid: json['uuid'],
    firstname: json['firstname'] ?? "",
    lastname: json['lastname'] ?? "",
    email: json['email'] ?? "",
    avatar_route: json['avatar_route'] ?? "",
    clubsArrayStr: json['clubs_ids'] ?? ""
  );

  @override
  Map<String, dynamic> toJSON() {
    return {
      'uuid': uuid,
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
    };
  }
}

class AEvent extends APIStructure {
  int       id;
  String    title,
            description,
            imageUrl,
            location,
            clientUUID; // Author of the event

  ValueNotifier<int> nbrPeopleGoingNotifier = ValueNotifier<int>(0); // So that it can be updated in real time
  int nbrPlaceAvailable = 0;

  bool isFromClub = false;

  /* ITERATIONS */

    // Note : those are relative iterations. To access this event, access iteration 0.
    Map<int, bool> selfClientIsGoingToRelativeIteration = new Map<int, bool>();

    void setSelfClientGoing(int iteration, bool going) {
      if(!this.selfClientIsGoingToRelativeIteration.containsKey(iteration)) this.selfClientIsGoingToRelativeIteration.addAll({iteration: going});
      else this.selfClientIsGoingToRelativeIteration[iteration] = going;
    }

    // Just convenient getter/setter to access iteration 0 (this event)
    bool get selfClientIsGoing => selfClientIsGoingToRelativeIteration[0] ?? false;
    set selfClientIsGoing(bool isGoing) {
      if(!this.selfClientIsGoingToRelativeIteration.containsKey(0)) this.selfClientIsGoingToRelativeIteration.addAll({0: false});
      this.selfClientIsGoingToRelativeIteration[0] = isGoing;
    }

    int global_iteration_number = 0; // For permanent events : is a generic iteration number from the originally created event. The information of the gap of time between two iterations is not contained here.
    AEvent _iteration_zero_event = null;

    // if none iteration-zero event has been specified, assume the iteration-zero is itself.
    AEvent get iteration_zero_event => _iteration_zero_event ?? this;
    set iteration_zero_event(AEvent other) {
      _iteration_zero_event = other;
    }

  DateTime  dateTimeBegin, dateTimeEnd;

  dynamic image;

  AEvent({this.id,
          this.title,
          this.dateTimeBegin,
          this.dateTimeEnd,
          this.location,
          this.description,
          this.imageUrl,
          nbrPeopleGoing,
          this.nbrPlaceAvailable,
          this.clientUUID,
          this.isFromClub = false,}) : super() {

    image = (imageUrl != null) ? NetworkImage(imageUrl) : AssetImage("assets/event1.png");
    this.nbrPeopleGoingNotifier.value = nbrPeopleGoing;


    selfClientIsGoingToRelativeIteration.addAll({0: false}); // By default
  }

  factory AEvent.clone(AEvent other) => AEvent(
      id: other.id,
      title: other.title,
      dateTimeBegin: other.dateTimeBegin,
      dateTimeEnd: other.dateTimeEnd,
      location: other.location,
      description: other.description,
      imageUrl: other.imageUrl,
      nbrPeopleGoing: other.nbrPeopleGoingNotifier.value,
      nbrPlaceAvailable: other.nbrPlaceAvailable,
      clientUUID: other.clientUUID,
      isFromClub: other.isFromClub,
    );

  String toString() {
    return "{${this.id} : ${this.title}, ${this.dateTimeBegin}, ${this.dateTimeEnd}}";
  }

  String timesToString() {
    return timeToString(dateTimeBegin) + ' - ' + timeToString(dateTimeEnd);
  }

  // If the client is going to an event. TODO: Make the same function as isGoing(AEvent, ...) overloaded for clubs.
  Future<bool> isGoing(AClient client, {Function(bool) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.EventsGoing + "/get", params: {'id': this.id.toString(), 'uuid': client.uuid, 'club': this.isFromClub.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    bool going = success && response.body.containsKey('going') && response.body['going']; // False in case of unsuccessful.
    if(onConfirmed != null) onConfirmed(going);

    return going;
  }

  Future<bool> setGoing(AClient client, {going = true, Function(bool) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.EventsGoing + "/set/" + this.id.toString(), params: {'uuid': client.uuid, 'going': going.toString(), 'club': this.isFromClub.toString(), 'iteration': this.global_iteration_number.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    if(success) { // Instead of making a full update, we can just adapt the values here as we know what happened server-side. TODO : Maybe unify the API here ?
      this.nbrPeopleGoingNotifier.value += going ? 1 : -1;
      if(client.uuid == gAPI.selfClient.uuid) this.selfClientIsGoing = going; // Updating the self client state if the client is the self client
    }

    if(onConfirmed != null) onConfirmed(success);
    return success;
  }


  /* Here are the links in notation between this code and the server's database */
  @override
  factory AEvent.fromJSON(Map<String, dynamic> json) => AEvent(
    id:                 json['id'] ?? -1,
    title:              json["title"] ?? null,
    dateTimeBegin:      DateTime.parse(json["datetime_begin"]).toLocal() ?? DateTime.now(), // DateTime is received as UTC from server
    dateTimeEnd:        DateTime.parse(json["datetime_end"]).toLocal() ?? DateTime.now(), // DateTime is received as UTC from server
    location:           json["location"] ?? "",
    description:        json["description"] ?? "",
    imageUrl:           json["image_url"] ?? "",
    nbrPlaceAvailable:  json["nbr_place_available"] ?? 0,
    nbrPeopleGoing:     json["nbr_people_going"] ?? 0,
    clientUUID:         json['client_uuid'] ?? ""
  );

  Map<String, dynamic> toJSON() => {
    "id": id,
    "title": title,
    "datetime_begin": dateTimeBegin.toString(),
    "datetime_end": dateTimeEnd.toString(),
    "location": location,
    "description": description,
    "image_url": imageUrl,
    "nbr_place_available": nbrPlaceAvailable,
    "nbr_people_going": nbrPeopleGoingNotifier.value,
    "client_uuid": clientUUID
  };
}

class AClub extends APIStructure {
  int     id;
  String  title;
  int     nbrMembers;

  Map<int, AEvent> permanentEvents = new Map<int, AEvent>();
  List<AClient> supervisors = new List<AClient>();

  String category;

  //List<AClient> _clients; // Client that are subscribed to the club

  AClub({this.id, this.title, this.nbrMembers, this.category, List<String> supervisorsUUID});

  @override
  factory AClub.fromJSON(Map<String, dynamic> json) => AClub(
    id: json['id'] ?? -1,
    title: json['title'] ?? "",
    category: json['category'] ?? 'BDA',
  );

  @override
  Map<String, dynamic> toJSON() {
    return null;
    // TODO: implement toJSON
    throw UnimplementedError();
  }

  @override
  String toString() {
    return "{id: " + id.toString() + ", title: " + title + "}";
  }

  Future<bool> registerClient({AClient client, bool member, Function(bool success) onConfirmed, bool changeValueOnTrigger = false}) async {
    bool changedOnTrigger = false;
    if(changeValueOnTrigger) {
      if(member && !client.clubsIDs.contains(this.id)) { // If the client should be a member of the club and isn't already
        client.clubsIDs.add(this.id);
        changedOnTrigger = true;
      }
      else if(!member && client.clubsIDs.contains(this.id)) { // If the client shouldn't be a member of the club and is currently member
        client.clubsIDs.remove(this.id);
        changedOnTrigger = true;
      }
    }

    FetchResponse response = await APIManager.fetch(route: APIRoutes.Clubs + "/" + APIRoutes.Register, params: {'member': member.toString(), 'club_id': this.id.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    // Updating local registration
    if(success) {
      if(!changeValueOnTrigger) {
        if(member && !client.clubsIDs.contains(this.id)) client.clubsIDs.add(this.id); // If the client should be a member of the club and isn't already
        else if(!member && client.clubsIDs.contains(this.id)) client.clubsIDs.remove(this.id); // If the client shouldn't be a member of the club and is currently member
      } // else, it already has changed
    } else { // Failure
      if(changedOnTrigger) { // Reverse the change
        if(client.clubsIDs.contains(this.id)) client.clubsIDs.remove(this.id);
        else if(!client.clubsIDs.contains(this.id)) client.clubsIDs.add(this.id);
      }
    }

    // Updating permanent registrations for the events page
    gAPI.updatePermanentEvents();

    if(onConfirmed != null) onConfirmed(success);
    return success;
  }
}

class ASocialPost extends APIStructure {

  String  clientUUID,
          title,
          body;

  bool selfClientLiked;

  int id;

  DateTime datetime;
  List<String> tags;

  ValueNotifier<int>  nbrLikesNotifier    = ValueNotifier<int>(0), // Should notify UI when changed
                      nbrCommentsNotifier = ValueNotifier<int>(0);

  ASocialPost({this.id, this.clientUUID, this.title, this.body, this.datetime, this.tags, this.selfClientLiked, int nbrLikes, int nbrComments}) {
    nbrLikesNotifier.value = nbrLikes;
    nbrCommentsNotifier.value = nbrComments;
  }

  @override
  factory ASocialPost.fromJSON(Map<String, dynamic> json) => ASocialPost(
    id:           json['id'] ?? -1,
    clientUUID:   json['client_uuid'] ?? "",
    title:        json['title'] ?? "",
    body:         json['body'] ?? "",
    datetime:     DateTime.parse(json['datetime']).toLocal() ?? new DateTime(1999), // DateTime is received as UTC from server
    tags:         json['tags'].toString().split(APIConfig.SQL_ARRAY_SEPARATOR) ?? new List<String>(),
    nbrLikes:     json['nbr_likes'] ?? 0,
    nbrComments:  json['nbr_comments'] ?? 0
  );

  Future<bool> setLike(AClient client, {@required bool liked, Function(bool success) onConfirmed, bool changeValueOnTrigger = false}) async {
    if(changeValueOnTrigger) this.nbrLikesNotifier.value += liked ? 1 : -1;

    FetchResponse response = await APIManager.fetch(route: APIRoutes.PostsLikes + '/set/' + this.id.toString(), params: {'uuid': client.uuid, 'liked': liked.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    if(success) { // Instead of making a full update, we can just adapt the values here as we know what happened server-side. TODO : Maybe unify the API here ?
      if(!changeValueOnTrigger) this.nbrLikesNotifier.value += liked ? 1 : -1; // If request succeeded and we haven't already updated the value
    } else if(changeValueOnTrigger) { // Request failed but we changed the value at the beginning
      this.nbrLikesNotifier.value -= liked ? 1 : -1; // Change back the value
    }

    if(onConfirmed != null) onConfirmed(success);
    return success;
  }

  Future<bool> hasLiked(AClient client, {Function(bool liked) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.PostsLikes + "/get", params: {'id': this.id.toString(), 'uuid': client.uuid}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    bool liked = success && response.body.containsKey('liked') && response.body['liked']; // False in case of unsuccessful.
    if(onConfirmed != null) onConfirmed(liked);

    return liked;
  }

  @override
  Map<String, dynamic> toJSON() {
    // TODO: implement toJSON
    throw UnimplementedError();
  }
}