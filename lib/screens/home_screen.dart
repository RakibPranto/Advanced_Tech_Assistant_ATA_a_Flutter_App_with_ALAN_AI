import 'dart:convert';
import 'package:alan_voice/alan_voice.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/task.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _taskController;
  List<Task>? _tasks;
  List<bool>? _tasksDone;
  _HomeScreenState() {
    //init Alan with sample project id
    AlanVoice.addButton(
        '9ad981e8079ff4967cc350588471ad442e956eca572e1d8b807a3e2338fdd0dc/stage',
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    // Listening to the Alan button state changes

    AlanVoice.onCommand.add((command) {
      debugPrint("Got new command ${command.toString()} from Alan");
    });
  }
  void saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Task t = Task.fromString(_taskController.text);
    String tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    print(list);
    list.add(json.encode(t.getMap()));
    print(list);
    prefs.setString('task', json.encode(list));
    _taskController.text = '';
    Navigator.of(context).pop();

    _getTasks();
  }

  void _getTasks() async {
    _tasks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tasks = prefs.getString('task');
    List list = (tasks == null) ? [] : json.decode(tasks);
    for (dynamic d in list) {
      _tasks?.add(Task.fromMap(json.decode(d)));
    }

    print(_tasks);

    _tasksDone = List.generate(_tasks!.length, (index) => false);
    setState(() {});
  }

  void updatePendingTasksList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Task>? pendingList = [];
    for (var i = 0; i < _tasks!.length; i++) {
      if (!_tasksDone![i]) pendingList.add(_tasks![i]);
    }

    var pendingListEncoded = List.generate(
        pendingList.length, (i) => json.encode(pendingList[i].getMap()));

    prefs.setString('task', json.encode(pendingListEncoded));

    _getTasks();
  }

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController();

    _getTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'A.T.A:Your Assistant',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: updatePendingTasksList,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('task', json.encode([]));

              _getTasks();
            },
          ),
        ],
      ),
      body: (_tasks == null)
          ? const Center(
              child: Text('No Tasks added yet!'),
            )
          : Column(
              children: _tasks!
                  .map((e) => Container(
                        height: 70.0,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        padding: const EdgeInsets.only(left: 10.0),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(
                            color: Colors.black,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.task!,
                              style: GoogleFonts.montserrat(),
                            ),
                            Checkbox(
                              value: _tasksDone![_tasks!.indexOf(e)],
                              key: GlobalKey(),
                              onChanged: (val) {
                                setState(() {
                                  _tasksDone![_tasks!.indexOf(e)] = val!;
                                });
                              },
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            padding: const EdgeInsets.all(10.0),
            height: 250,
            color: Colors.blue[200],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add task',
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontSize: 20.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(thickness: 1.2),
                const SizedBox(height: 20.0),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Enter task',
                    hintStyle: GoogleFonts.montserrat(),
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  width: MediaQuery.of(context).size.width,
                  // height: 200.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                          ),
                          child: Text(
                            'RESET',
                            style: GoogleFonts.montserrat(),
                          ),
                          onPressed: () => _taskController.text = '',
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 2) - 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shadowColor: Colors.blue,
                            primary: Colors.blue,
                          ),
                          child: Text(
                            'ADD',
                            style: GoogleFonts.montserrat(),
                          ),
                          onPressed: () => saveData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
