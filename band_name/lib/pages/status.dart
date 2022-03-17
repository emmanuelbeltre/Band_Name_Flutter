import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_name/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Server Status:  ${socketService.serverStatus}')],
      )),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.message),
          onPressed: () {
            //TAREA
            //EMITIR
            //{nombre : 'Flutter', mensaje: 'Hola desde flutter'}
            socketService.emit('emitir-mensaje',
                {'nombre': 'Fluter', 'mensaje': 'Hola desde Flutter'});
          }),
    );
  }
}
