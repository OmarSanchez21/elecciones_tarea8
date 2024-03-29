import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:elecciones_tarea8/event.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:elecciones_tarea8/dataBaseHelper.dart';

class EventFormWidget extends StatefulWidget {
  @override
  _EventFormWidgetState createState() => _EventFormWidgetState();
}

class _EventFormWidgetState extends State<EventFormWidget> {
  final TextEditingController _titulo = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  DateTime _selectDate = DateTime.now();
  File? _imageFile;
  final picker = ImagePicker();
  String? _audioPath;
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    final PermissionStatus status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permiso de micrófono denegado'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    await _audioPlayer.openAudioSession();
  }

  void _procesarImagen(XFile? pickedFile) {
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      } else {
        print('No se ha seleccionado ninguna imagen');
      }
    });
  }

  Future<void> _selectImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Seleccionar de la galería'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
                  _procesarImagen(pickedFile);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tomar foto'),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
                  _procesarImagen(pickedFile);
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _eliminarImagen() async {
    setState(() {
      _imageFile = null;
    });
  }

  Future<void> _grabarAudio() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stopRecorder();
        setState(() {
          _isRecording = false;
        });
      } else {
        if (await Permission.microphone.request().isGranted) {
          String? audioPath = await _getAudioPath();
          if (audioPath != null) {
            await _audioRecorder.openAudioSession();
            await _audioRecorder.startRecorder(
                toFile: audioPath, codec: Codec.aacADTS);
            setState(() {
              _audioPath = audioPath;
              _isRecording = true;
            });
          }
        }
      }
    } catch (error) {
      print('Error al grabar el audio: $error');
    }
  }

  Future<String?> _getAudioPath() async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    if (appDocDir != null) {
      return '${appDocDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    }
    return null;
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context, firstDate: DateTime(2000), lastDate: DateTime(2101));
    if (pickedDate != null && pickedDate != _selectDate) {
      setState(() {
        _selectDate = pickedDate;
      });
    }
  }

  Future<void> _guardarEvento() async {
    try {
      if (_titulo.text.isEmpty ||
          _descripcion.text.isEmpty ||
          _audioPath == null ||
          _imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complete todos los campos.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      final newEvent = Event(
          title: _titulo.text,
          descripcion: _descripcion.text,
          date: _selectDate,
          photoPath: _imageFile?.path,
          audioPath: _audioPath);
      await DatabaseHelper.instance.insertEvent(newEvent);
      _titulo.clear();
      _descripcion.clear();
      setState(() {
        _selectDate = DateTime.now();
        _imageFile = null;
        _audioPath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento Guardado Correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error al guardar el evento: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ha ocurrido un error al guardar el evento'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingresar Nuevo Evento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titulo,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: _descripcion,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 10.0),
            _imageFile != null
                ? Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: Image.file(_imageFile!),
            )
                : SizedBox.shrink(),
            ElevatedButton(
              onPressed: _imageFile != null ? _eliminarImagen : _selectImage,
              child: Text(
                  _imageFile != null ? 'Eliminar Imagen' : 'Seleccionar Imagen'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _grabarAudio,
              child: Text(_isRecording ? 'Detener Grabación' : 'Grabar Audio'),
            ),
            _audioPath != null
                ? Text('Audio Grabado: $_audioPath')
                : SizedBox.shrink(),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectDate)}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _seleccionarFecha(context),
                  child: Text('Seleccionar Fecha'),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: _guardarEvento,
              child: Text('Guardar Evento'),
            )
          ],
        ),
      ),
    );
  }
}

