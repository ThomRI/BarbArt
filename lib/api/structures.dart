/* This file's purpose is to define data structures used in the API */

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



  // ignore: non_constant_identifier_names
  AClient({this.uuid = "", this.email = "", this.avatar_route = "", this.firstname, this.lastname});

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
    avatar_route: json['avatar_route'] ?? ""
  );

  @override
  Map<String, dynamic> toJSON() {
    // TODO: implement toJSON
    throw UnimplementedError();
  }
}

class AEvent extends APIStructure {
  int       id;
  String    title,
            description,
            imageUrl,
            location,
            clientUUID;

  int nbrPeopleGoing    = 0,
      nbrPlaceAvailable = 0;

  DateTime  dateTimeBegin, dateTimeEnd;

  dynamic image = AssetImage("assets/event.png");

  AEvent({this.id,
          this.title,
          this.dateTimeBegin,
          this.dateTimeEnd,
          this.location,
          this.description,
          this.imageUrl,
          this.nbrPeopleGoing,
          this.nbrPlaceAvailable,
          this.clientUUID}) : super();

  String toString() {
    return "{${this.title}, ${this.dateTimeBegin}}";
  }

  String timesToString() {
    return timeToString(dateTimeBegin) + ' - ' + timeToString(dateTimeEnd);
  }

  // If the client is going to an event. TODO: Make the same function as isGoing(AEvent, ...) overloaded for clubs.
  Future<bool> isGoing(AClient client, {Function(bool) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.EventsGoing + "/get", params: {'id': this.id.toString(), 'uuid': client.uuid}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    bool going = success && response.body.containsKey('going') && response.body['going']; // False in case of unsuccessful.
    if(onConfirmed != null) onConfirmed(going);

    return going;
  }

  Future<bool> setGoing(AClient client, {going = true, Function(bool) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.EventsGoing + "/set/" + this.id.toString(), params: {'uuid': client.uuid, 'going': going.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    if(success) { // Instead of making a full update, we can just adapt the values here as we know what happened server-side. TODO : Maybe unify the API here ?
      this.nbrPeopleGoing += (going) ? 1 : -1;
    }

    if(onConfirmed != null) onConfirmed(success);
    return success;
  }


  /* Here are the links in notation between this code and the server's database */
  @override
  factory AEvent.fromJSON(Map<String, dynamic> json) => AEvent(
    id:                 json['id'] ?? -1,
    title:              json["title"] ?? "",
    dateTimeBegin:      DateTime.parse(json["datetime_begin"]) ?? DateTime.now(),
    dateTimeEnd:        DateTime.parse(json["datetime_end"]) ?? DateTime.now(),
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
    "nbr_people_going": nbrPeopleGoing,
    "client_uuid": clientUUID
  };
}

class AClub extends APIStructure {
  String  name;
  int     availableSlots,
          totalSlots;

  List<AClient> _clients; // Client that are subscribed to the club

  AClub({this.name, this.availableSlots, this.totalSlots});

  @override
  factory AClub.fromJSON(Map<String, dynamic> json) => AClub(
    name: "",
    availableSlots: 0,
    totalSlots: 0
  );

  @override
  Map<String, dynamic> toJSON() {
    // TODO: implement toJSON
    throw UnimplementedError();
  }
}

class AClubEvent extends AEvent {
  @override
  Map<String, dynamic> toJSON() {
    // TODO: implement toJSON
    throw UnimplementedError();
  }

  @override
  DateTime dateTimeBegin;

  @override
  DateTime dateTimeEnd;

  @override
  String description;

  @override
  int id;

  @override
  String imageUrl;

  @override
  String location;

  @override
  String title;

}

class ASocialPost extends APIStructure {

  String  clientUUID,
          title,
          body;

  int id;

  DateTime datetime;
  List<String> tags;

  int nbrLikes    = 0,
      nbrComments = 0;

  ASocialPost({this.id, this.clientUUID, this.title, this.body, this.datetime, this.tags, this.nbrLikes, this.nbrComments});

  @override
  factory ASocialPost.fromJSON(Map<String, dynamic> json) => ASocialPost(
    id:           json['id'] ?? -1,
    clientUUID:   json['client_uuid'] ?? "",
    title:        json['title'] ?? "",
    body:         json['body'] ?? "",
    datetime:     DateTime.parse(json['datetime']) ?? new DateTime(1999),
    tags:         json['tags'].toString().split(APIConfig.SQL_ARRAY_SEPARATOR) ?? new List<String>(),
    nbrLikes:     json['nbr_likes'] ?? 0,
    nbrComments:  json['nbr_comments'] ?? 0
  );

  Future<bool> setLike(AClient client, {@required bool liked, Function(bool success) onConfirmed}) async {
    FetchResponse response = await APIManager.fetch(route: APIRoutes.PostsLikes + '/set/' + this.id.toString(), params: {'uuid': client.uuid, 'liked': liked.toString()}, token: gAPI.token);

    bool success = true;
    if(response.state != FetchResponseState.OK) success = false;

    if(success) { // Instead of making a full update, we can just adapt the values here as we know what happened server-side. TODO : Maybe unify the API here ?
      this.nbrLikes += liked ? 1 : -1;
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