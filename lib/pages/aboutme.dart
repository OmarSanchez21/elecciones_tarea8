import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme
        .of(context)
        .primaryColor;
    final accentColor = Colors.yellow;

    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: accentColor,
              child: ClipOval(
                child: Image.asset(
                  'assets/yo.jpeg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Nombre: Omar Alexis',
              style: TextStyle(fontSize: 18,
                  color: primaryColor),
            ),
            Text(
              'Apellido: Sánchez Pérez',
              style: TextStyle(fontSize: 18,
                  color: primaryColor),
            ),
            Text(
              'Matrícula: 2022-0197',
              style: TextStyle(fontSize: 18,
                  color: primaryColor),
            ),
            SizedBox(height: 20),
            Text(
              'Reflexión:',
              style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            Text(
              '"La democracia es la participación de los ciudadanos en la toma de decisiones que afectan a su comunidad. Es un derecho y una responsabilidad de todos"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16,
                  color: primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
