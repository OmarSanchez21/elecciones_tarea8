import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elecciones_tarea8/dataBaseHelper.dart';
import 'package:elecciones_tarea8/event.dart';
import 'package:flutter_sound/flutter_sound.dart';

class EventListWidget extends StatefulWidget {
  @override
  _EventListWidgetState createState() => _EventListWidgetState();
}

class _EventListWidgetState extends State<EventListWidget> {
  late Future<List<Event>> _eventList;
  bool _isPlaying = false;
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();

  @override
  void initState() {
    super.initState();
    _eventList = DatabaseHelper.instance.getAllEvents();
  }

  @override
  void dispose() {
    _audioPlayer.closeAudioSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final events = snapshot.data;
            return ListView.builder(
              itemCount: events?.length,
              itemBuilder: (context, index) {
                final event = events?[index];
                if (event != null) {
                  return ListTile(
                    title: Text(event.title ?? ''),
                    subtitle: Text(event.descripcion ?? ''),
                    trailing: Text(event.date != null ? DateFormat('dd/MM/yyyy').format(event.date!) : ''),
                    onTap: () {
                      _showEventDetailsModels(context, event);
                    },
                  );
                } else {
                  return Center(
                    child: Text('No hay registro'),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  void _showEventDetailsModels(BuildContext context, Event event) {
    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (event.photoPath != null &&
                      File(event.photoPath!).existsSync())
                    Image.file(
                      File(event.photoPath!),
                      height: 80,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  if (event.photoPath == null ||
                      !File(event.photoPath!).existsSync())
                    Container(
                      height: 80,
                      width: double.infinity,
                      color: Colors.grey,
                      child: Center(
                        child: Text('Imagen no disponible'),
                      ),
                    ),
                  SizedBox(height: 5),
                  Text('Descripcion: ${event.descripcion}'),
                  SizedBox(height: 5),
                  Text('Fecha: ${DateFormat('dd/MM/yyyy').format(event.date!)}'),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      _toggleAudio(event.audioPath!);
                    },
                    child: Text(_isPlaying ? 'Detener Audio' : 'Reproducir Audio'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar'),
              )
            ],
          );
        },
      );
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }
  }

  void _toggleAudio(String audioPath) {
    if (_isPlaying) {
      _stopAudio();
    } else {
      _startAudio(audioPath);
    }
  }

  void _startAudio(String audioPath) async {
    if (_isPlaying) return; // Evitar iniciar una nueva reproducción si ya está reproduciéndose
    try {
      await _audioPlayer.openAudioSession();
      await _audioPlayer.startPlayer(
        fromURI: audioPath,
        codec: Codec.aacADTS,
      );
      setState(() {
        _isPlaying = true;
      });
    } catch (error) {
      print('Error al reproducir el audio $error');
    }
  }

  void _stopAudio() async {
    try {
      await _audioPlayer.stopPlayer();
      setState(() {
        _isPlaying = false;
      });
    } catch (error) {
      print('Error al detener el audio $error');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('¿Estás seguro de que deseas borrar todos los datos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _deleteAllEvents();
                Navigator.of(context).pop();
              },
              child: Text('Borrar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllEvents() {
    DatabaseHelper.instance.deleteAllEvents();
    setState(() {
      _eventList = DatabaseHelper.instance.getAllEvents();
    });
  }
}
