import 'dart:convert';

PPS ppsFromJson(String str) => PPS.fromJson(json.decode(str));
String ppsToJson(PPS data) => json.encode(data.toJson());

class PPS{
  String? pps_id;
  String? pps_name;
  String? pps_address;
  String? pps_status;
  double? pps_lat;
  double? pps_long;
  int? pps_capacity;
  int? pps_cur_capacity;

  PPS({
    this.pps_id,
    this.pps_address,
    this.pps_capacity,
    this.pps_cur_capacity,
    this.pps_lat,
    this.pps_long,
    this.pps_name,
    this.pps_status});

  factory PPS.fromJson(Map<String, dynamic> json) => PPS(
    pps_id: json["pps_id"],
    pps_address: json["pps_address"],
    pps_status: json["pps_status"],
    pps_name: json["pps_name"],
    pps_long: json["pps_long"],
    pps_capacity: json["pps_capacity"],
    pps_cur_capacity: json["pps_cur_capacity"],
    pps_lat: json["pps_lat"],
  );

  Map<String, dynamic> toJson() => {
    "pps_id": pps_id,
    "pps_address": pps_address,
    "pps_status": pps_status,
    "pps_status": pps_status,
    "pps_name": pps_name,
    "pps_long": pps_long,
    "pps_lat": pps_lat,
    "pps_capacity": pps_capacity,
    "pps_cur_capacity": pps_cur_capacity,
  };
}