import 'package:flutter/material.dart';

class Event{
  int? id;
  String title;
  String descripcion;
  DateTime date;
  String? photoPath;
  String? audioPath;

  Event({
    this.id,
    required this.title,
    required this.descripcion,
    required this.date,
    this.photoPath,
    this.audioPath
  });

  Map<String, dynamic> toMap(){
    return{
      'title': title,
      'descripcion' : descripcion,
      'date': date.toIso8601String(),
      'photoPath': photoPath,
      'audioPath': audioPath,
    };
  }
}

