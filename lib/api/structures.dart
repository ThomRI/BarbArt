/* This file's purpose is to define data structures used in the API */

import 'package:flutter/material.dart';

import '../utils.dart';

/* IMPORTANT : Every classes related to the API start by 'A' */

abstract class APIStructure {
  APIStructure();
  APIStructure.fromJSON(Map<String, dynamic> json);
  Map<String, dynamic> toJSON();
}

/// Represents an API client. Most likely linked to one account (custom or fb,google,...). Anyway it has one UUID.
class AClient extends APIStructure{
  String  uuid,
          email;

  dynamic avatar = new AssetImage("assets/event.png");
  String avatar_route;

  // ignore: non_constant_identifier_names
  AClient({this.uuid = "", this.email = "", this.avatar_route = ""});

  // Set this client as a generic non-authenticated client
  void genericify() {
    this.uuid = "";
    this.email = "";
    this.avatar = new AssetImage("assets/profile_generic.png");
  }

  @override
  factory AClient.fromJSON(Map<String, dynamic> json) => AClient(
    uuid: json['uuid'],
    email: json['email'] ?? "",
    avatar_route: json['avatar_route'] ?? ""
  );

  @override
  Map<String, dynamic> toJSON() {
    // TODO: implement toJSON
    throw UnimplementedError();
  }
}

class AEvent extends APIStructure{
  int       id;
  String    title,
            description,
            imageUrl,
            location;

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
          this.nbrPlaceAvailable}) : super();

  String toString() {
    return "{${this.title}, ${this.dateTimeBegin}}";
  }

  String timesToString() {
    return timeToString(dateTimeBegin) + ' - ' + timeToString(dateTimeEnd);
  }

  /* Here are the links in notation between this code and the server's database */
  @override
  factory AEvent.fromJSON(Map<String, dynamic> json) => AEvent(
    id: json['id'],
    title: json["title"],
    dateTimeBegin: DateTime.parse(json["datetime_begin"]),
    dateTimeEnd: DateTime.parse(json["datetime_end"]),
    location: json["location"],
    description: json["description"],
    imageUrl: json["image_url"],
    nbrPlaceAvailable: json["nbr_place_available"],
    nbrPeopleGoing: json["nbr_people_going"]
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
    "nbr_people_going": nbrPeopleGoing
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