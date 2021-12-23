import 'dart:convert';
//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Than we setup preferred orientations,
  // and only after it finished we run our app
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
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
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  final myController = TextEditingController();
  final editController = TextEditingController();
  int _counter = 0;
  String tarefa = "";
  List<dynamic> tarefas = [];
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
    loadData();
  }

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      //print(json.decode(prefs.getString("lista")?.toString() ?? ""));
      try {
        tarefas = (jsonDecode(prefs.getString("lista")?.toString() ?? "{}")
            .map((e) => e as Map<String, dynamic>)
            ?.toList());
      } catch (e) {
        print(e);
      }
      _counter = tarefas.length;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.linear);
  }

  void deleteEntry(Map<String, dynamic> dTarefa) async {
    if (tarefas.isNotEmpty) {
      if (tarefas.contains(dTarefa)) {
        setState(() {
          tarefas.remove(dTarefa);
          _counter = tarefas.length;
        });
        Fluttertoast.showToast(
            msg: "Tarefa removida com sucesso",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        saveState();
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

  void editEntry(
      Map<String, dynamic> dTarefa, Map<String, dynamic> nTarefa) async {
    if (tarefas.isNotEmpty) {
      if (tarefas.contains(dTarefa)) {
        setState(() {
          tarefas[tarefas.indexOf(dTarefa)] = nTarefa;
        });
        Fluttertoast.showToast(
            msg: "Tarefa editada com sucesso!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
        saveState();
      } else {
        Fluttertoast.showToast(
            msg: "Tarefa não encontrada.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      editController.text = "";
    }
  }

  void _incrementCounter() async {
    String id = (tarefas.length + 1).toString();
    if (myController.text != "") {
      final Map<String, dynamic> tarefa = {id: myController.text};
      setState(() {
        tarefas.add(tarefa);
        _counter = tarefas.length;
        myController.text = "";
      });
      saveState();
    } else {
      Fluttertoast.showToast(
          msg: "Tarefa vazia. Tente escrever algo!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    loadData();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    editController.dispose();
    super.dispose();
  }

  Future saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lista', jsonEncode(tarefas));
    await prefs.setInt("counter", tarefas.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
            controller: _scrollController,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                    Widget>[
              Text(
                'Lista de tarefas, atualmente contem:',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                '$_counter tarefa(s)',
                style: Theme.of(context).textTheme.headline6,
              ),
              TextField(
                obscureText: false,
                controller: myController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tarefa a ser adicionada',
                ),
              ),
              ButtonBar(children: [
                TextButton.icon(
                    onPressed: _incrementCounter,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text("Adicionar"))
              ]),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 3.0,
                child: const DecoratedBox(
                    decoration: const BoxDecoration(color: Colors.cyanAccent)),
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _counter,
                  itemBuilder: (context, index) {
                    return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height / 15,
                          minWidth: MediaQuery.of(context).size.width / 2,
                          maxHeight: MediaQuery.of(context).size.height * 4,
                          maxWidth: MediaQuery.of(context).size.width / 2,
                        ),
                        child: Container(
                            decoration: const BoxDecoration(
                                border: Border(
                              bottom: BorderSide(
                                  color: Colors.cyanAccent, width: 3.0),
                            )),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Row(children: [
                                  Expanded(
                                      child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                15,
                                            minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                5,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                          ),
                                          child: Container(
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                left: BorderSide(
                                                    color: Colors.white,
                                                    width: 7.0),
                                              )),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: tarefas[index]
                                                      .values
                                                      .last,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 13.0),
                                                ),
                                              ))))
                                ])),
                                Row(children: [
                                  ButtonBar(
                                    mainAxisSize: MainAxisSize.min,
                                    buttonPadding: new EdgeInsets.all(0.8),
                                    buttonMinWidth: 5,
                                    children: [
                                      TextButton.icon(
                                          icon: const Icon(Icons.copy),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(
                                                text: tarefas[index]
                                                    .values
                                                    .last));
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Tarefa copiada com sucesso!",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor:
                                                    Colors.blueGrey,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          },
                                          label: const Text("Copiar",
                                              style:
                                                  TextStyle(fontSize: 13.0))),
                                      TextButton.icon(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          editController.text =
                                              tarefas[index].values.last;
                                          showModalBottomSheet(
                                            context: context,
                                            enableDrag: true,
                                            isDismissible: true,
                                            useRootNavigator: true,
                                            builder: (BuildContext ctx) {
                                              return Scaffold(
                                                backgroundColor:
                                                    Colors.transparent,
                                                resizeToAvoidBottomInset:
                                                    true, // important
                                                body: SingleChildScrollView(
                                                  child: Form(
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        border: Border(
                                                          top: BorderSide(
                                                              color:
                                                                  Colors.white,
                                                              width: 15.0),
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          TextField(
                                                            obscureText: false,
                                                            controller:
                                                                editController,
                                                            decoration:
                                                                const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              labelText:
                                                                  'Nova descrição para a tarefa',
                                                            ),
                                                          ),
                                                          ButtonBar(
                                                            children: [
                                                              TextButton.icon(
                                                                icon: const Icon(
                                                                    Icons
                                                                        .save_rounded),
                                                                onPressed: () {
                                                                  Map<String,
                                                                          String>
                                                                      ntarefa =
                                                                      {
                                                                    tarefas[index]
                                                                            .entries
                                                                            .first
                                                                            .value:
                                                                        editController
                                                                            .text
                                                                  };
                                                                  editEntry(
                                                                      tarefas[
                                                                          index],
                                                                      ntarefa);
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                label:
                                                                    const Text(
                                                                  "Salvar",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          13.0),
                                                                ),
                                                              )
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
                                        label: const Text("Editar",
                                            style: TextStyle(
                                                fontSize: 13.0)),
                                      ),
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete),
                                        style: TextButton.styleFrom(
                                            primary: Colors.red),
                                        onPressed: () {
                                          deleteEntry(tarefas[index]);
                                        },
                                        label: const Text("Excluir",
                                            style: TextStyle(fontSize: 13.0)),
                                      )
                                    ],
                                  )
                                ]),
                              ],
                            )));
                  }),
            ])),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: _showBackToTopButton == false
          ? null
          : FloatingActionButton(
              onPressed: _scrollToTop,
              child: const Icon(Icons.arrow_upward),
            ),
    );
  }
}
