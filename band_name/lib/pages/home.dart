import 'dart:io';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metalica', votes: 5),
    // Band(id: '2', name: 'Twenty One Pillots', votes: 4),
    // Band(id: '3', name: 'Calle 3', votes: 65),
    // Band(id: '4', name: "Gun's and Roses", votes: 15),
    // Band(id: '5', name: 'Imagine Dragons', votes: 54),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    socketService.serverStatus.toString();
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.Online
                ? Icon(
                    Icons.check_circle,
                    color: Colors.blue[300],
                  )
                : Icon(
                    Icons.offline_bolt,
                    color: Colors.red[300],
                  ),
          )
        ],
        title: Text(
          'Band Names',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          if (bands.isNotEmpty) _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, int i) => bandTile(bands[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 1,
          onPressed: () {
            print(socketService.serverStatus.toString());

            addNewBand();
          }),
    );
  }

  Widget bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) =>
          //TODO: llamar el borrado en el server

          socketService.socket.emit('deletle-band', {'id': band.id}),
      background: Container(
        padding: EdgeInsets.only(left: 9),
        color: Colors.red[300],
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Deletle Band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () =>
            // print(band.id);
            socketService.socket.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('New Band Name'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text('Add'),
                      elevation: 5,
                      textColor: Colors.blue,
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New Band Name'),
            content: CupertinoTextField(controller: textController),
            actions: [
              CupertinoDialogAction(
                  child: Text('Add'),
                  onPressed: () => addBandToList(textController.text)),
              CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: Text('Dismiss'),
                  isDefaultAction: true,
                  onPressed: () => Navigator.pop(context))
            ],
          );
        });
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      //agregar banda
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  //Mostrar grafica

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();

    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final List<Color> colorList = [
      Color.fromARGB(255, 187, 222, 251),
      Color.fromARGB(255, 247, 243, 200),
      Color.fromARGB(255, 255, 235, 238),
      Color.fromARGB(255, 239, 154, 154),
      Color.fromARGB(255, 232, 245, 233),
      Color.fromARGB(255, 165, 214, 167),
      Color.fromARGB(255, 252, 228, 236),
      Color.fromARGB(255, 255, 245, 157),
      Color.fromARGB(255, 228, 108, 148),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15),
      child: Container(
          width: double.infinity,
          height: 200,
          child: PieChart(
            emptyColor: Color.fromARGB(255, 187, 222, 251),
            dataMap: dataMap,
            animationDuration: Duration(milliseconds: 800),
            // chartLegendSpacing: 32,
            // chartRadius: MediaQuery.of(context).size.width / ,
            colorList: colorList,
            // initialAngleInDegree: 0,
            chartType: ChartType.ring,
            ringStrokeWidth: 32,
            // centerText: "HYBRID",
            legendOptions: const LegendOptions(
              showLegendsInRow: false,
              legendPosition: LegendPosition.right,
              showLegends: true,
              // legendShape: _BoxShape.circle,
              legendTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            chartValuesOptions: const ChartValuesOptions(
              showChartValueBackground: true,
              // showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: false,
              decimalPlaces: 0,
            ),
            // gradientList: ---To add gradient colors---
            // emptyColorGradient: ---Empty Color gradient---
          )),
    );
  }
}
