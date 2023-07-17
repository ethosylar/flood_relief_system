import 'dart:convert';
import 'dart:ffi';

RescuersLocation rescuerLocationFromJson(String str) => RescuersLocation.fromJson(json.decode(str));
String rescuerLocationToJson(RescuersLocation data) => json.encode(data.toJson());

class RescuersLocation{
  String? rescuer_id_location;
  String? rescuers_id;
  double? location_res_lat;
  double? location_res_long;
  DateTime? datetime;
  String? status;

  RescuersLocation({
    this.rescuer_id_location,
    this.rescuers_id,
    this.location_res_lat,
    this.location_res_long,
    this.datetime,
    this.status,
  });

  factory RescuersLocation.fromJson(Map<String, dynamic> json) => RescuersLocation(
    rescuer_id_location: json["rescuer_id_location"],
    rescuers_id: json["rescuers_id"],
    location_res_lat: json["location_res_lat"],
    location_res_long: json["location_res_long"],
    datetime: json["datetime"],
      status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "rescuer_id_location": rescuer_id_location,
    "rescuers_id": rescuers_id,
    "location_res_lat": location_res_lat,
    "location_res_long": location_res_long,
    "datetime": datetime,
    "status": status,
  };
}