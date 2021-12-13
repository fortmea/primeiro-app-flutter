import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de tarefas',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.cyan,
      ),
      home: const MyHomePage(title: 'Lista de tarefas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();
  final editController = TextEditingController();
  int _counter = 0;
  String tarefa = "";
  List<Map<String, String>> tarefas = [];
  void deleteEntry(Map<String, String> dTarefa) {
    if (tarefas.isNotEmpty) {
      if (tarefas.contains(dTarefa)) {
        setState(() {
          tarefas.remove(dTarefa);
          _counter--;
        });
        Fluttertoast.showToast(
            msg: "Tarefa removida com sucesso",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Tarefa não encontrada",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void editEntry(Map<String, String> dTarefa, Map<String, String> nTarefa) {
    if (tarefas.isNotEmpty) {
      if (tarefas.contains(dTarefa)) {
        setState(() {
          tarefas[tarefas.indexOf(dTarefa)] = nTarefa;
        });
        Fluttertoast.showToast(
            msg: "Tarefa editada com sucesso",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Tarefa não encontrada",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      editController.text = "";
    }
  }

  void _incrementCounter() {
    String id = (tarefas.length + 1).toString();

    if (myController.text != "") {
      final Map<String, String> tarefa = {id: myController.text};
      setState(() {
        tarefas.add(tarefa);
        _counter = tarefas.length;
        myController.text = "";
      });
    } else {
      Fluttertoast.showToast(
          msg: "Tarefa vazia. Tente escrever algo",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          const Text(
            'Lista de tarefas, atualmente contem:',
          ),
          Text(
            '$_counter tarefas',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextField(
            obscureText: false,
            controller: myController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tarefa a ser adicionada',
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Colors.cyanAccent, width: 3.0),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 15,
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 15,
                            alignment: AlignmentDirectional.center,
                            child: Text(tarefas[index].values.last)),
                        ButtonBar(
                          children: [
                            TextButton(
                              onPressed: () {
                                deleteEntry(tarefas[index]);
                              },
                              child: const Text("Apagar"),
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  enableDrag: true,
                                  isDismissible: true,
                                  useRootNavigator: true,
                                  builder: (BuildContext ctx) {
                                    return Scaffold(
                                      backgroundColor: Colors.transparent,
                                      resizeToAvoidBottomInset:
                                          true, // important
                                      body: SingleChildScrollView(
                                        child: Form(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: <Widget>[
                                                TextField(
                                                  obscureText: false,
                                                  controller: editController,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Nova descrição para a tarefa',
                                                  ),
                                                ),
                                                ButtonBar(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Map<String, String>
                                                              ntarefa = {
                                                            tarefas[index]
                                                                    .entries
                                                                    .first
                                                                    .value:
                                                                editController
                                                                    .text
                                                          };
                                                          editEntry(
                                                              tarefas[index],
                                                              ntarefa);
                                                              Navigator.pop(context);
                                                        },
                                                        child: const Text(
                                                            "Salvar"))
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: const Text("Editar"),
                            )
                          ],
                        ),
                      ],
                    ));
              }),
        ]),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Adicionar tarefa',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
