import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final referenceDatabase = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _formData = [];
  List<Map<String, dynamic>> _questionsData = [];
  String textAnswerValue = '';
  String component = "";
  String topic = '';
  String exam = "";
  String levelValue = '';
  String linkValue = '';
  String bigTextValue = '';
  String language = "";
  bool isUntSelected = false;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String name = "";

  void _addQuestion(String newQuestion, String questionType, List<String> options, int correctAnswerIndex, String textAnswerValue) {
    print(options);
    setState(() {
      if (questionType == '${AppLocalizations.of(context)!.multiplech}') {
        _questionsData.add({
          'question': newQuestion,
          'questionType': "multipleChoice",
          'options': List.from(options),
          'correctAnswerIndex': correctAnswerIndex,
        });
      } else {
        _questionsData.add({
          'question': newQuestion,
          'questionType': "textInput",
          'textAnswer': textAnswerValue,
        });
      }
    });
  }
  void _saveToDatabase() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        if ((exam == "igcse" && (language.isEmpty || exam.isEmpty || (isUntSelected && component.isEmpty) || topic.isEmpty || levelValue.isEmpty)) || (isUntSelected && language.isEmpty || exam.isEmpty || topic.isEmpty || levelValue.isEmpty)) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Please fill in all dropdowns.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          if(isUntSelected){
            String currentDate = DateTime.now().toIso8601String().split('T')[0];
            final nameSnapshot =
            await _database.reference().child('users/${user.uid}/Username').once();
            name = nameSnapshot.snapshot.value?.toString() ?? '';
            referenceDatabase
                .child(
                'exams/${language}/ent/${int.parse(topic) - 1}/${int.parse(levelValue) - 1}/${user.uid}')
                .set({
              'link': linkValue,
              'Text': bigTextValue,
              'teacher': name,
              'date': currentDate,
              'questions': _questionsData,
            });
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Created a level for UNT!"),
                  actions: [
                    TextButton(
                      onPressed: () {

                        Navigator.of(context).pop();
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );

          }
          else{
            String currentDate = DateTime.now().toIso8601String().split('T')[0];
            final nameSnapshot =
            await _database.reference().child('users/${user.uid}/Username').once();
            name = nameSnapshot.snapshot.value?.toString() ?? '';
            referenceDatabase
                .child(
                'exams/${language}/igcse/${component == "${AppLocalizations.of(context)!.first}" ? 0 : 1}/${int.parse(topic) - 1}/${int.parse(levelValue) - 1}/${user.uid}')
                .set({
              'link': linkValue,
              'Text': bigTextValue,
              'teacher': name,
              'date': currentDate,
              'questions': _questionsData,
            });
          }
        }
      }
    });
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Created a level for an IGCSE!"),
          actions: [
            TextButton(
              onPressed: () {
                // Ваша логика для isUntSelected is false
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  void _getDataFromDatabase() {
    referenceDatabase.child('formData').once().then((DatabaseEvent snapshot) {
      Map<dynamic, dynamic> values = snapshot.snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        print('Key: $key, Value: $value');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Background.png"), // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsetsDirectional.only(top:8.0,start: 16,end: 16),
                child: Column(
                  children: [
                    SizedBox(height: 15,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          iconSize: 38,
                          icon: Icon(

                            Icons.arrow_back,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppLocalizations.of(context)!.chooselan}: '),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.4),
                              border: Border.all()),
                          child: DropdownButton<String>(
                            value: language,
                            items: <String>['','ru', 'en', 'kz'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                language = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppLocalizations.of(context)!.chooseexam}: '),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.4),
                              border: Border.all()),
                          child: DropdownButton<String>(
                            value: exam,
                            items: <String>["",'${AppLocalizations.of(context)!.igcse}', '${AppLocalizations.of(context)!.unt}'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                exam = newValue!;
                                if (newValue == '${AppLocalizations.of(context)!.unt}') {
                                  isUntSelected = true;
                                } else {
                                  isUntSelected = false;
                                }
                              });
                            },
                          ),
                        ),

                      ],
                    ),
                    SizedBox(height: 20),
                    !isUntSelected?Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppLocalizations.of(context)!.choosecom}: '),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.4),
                              border: Border.all()),
                          child: DropdownButton<String>(
                            value: component,
                            items: <String>['','${AppLocalizations.of(context)!.first}', '${AppLocalizations.of(context)!.second}'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                component = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ):Container(),
                    !isUntSelected?SizedBox(height: 20):Container(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppLocalizations.of(context)!.chstopic}: '),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.4),
                              border: Border.all()),
                          child: DropdownButton<String>(
                            value: topic,
                            items: <String>['','1','2','3','4','5','6'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                topic = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${AppLocalizations.of(context)!.chooselvl}: '),
                        SizedBox(width: 10,),
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.grey.withOpacity(0.4),
                              border: Border.all()),
                          child: DropdownButton<String>(
                            value: levelValue,
                            items: <String>['','1','2','3','4','5','6'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                levelValue = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          linkValue = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context)!.typelink}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          bigTextValue = value;
                        });
                      },
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: '${AppLocalizations.of(context)!.typebigt}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    StatefulBuilder(builder: (context, setState) {
                      return Column(
                        children: [
                          for (var question in _questionsData) ...[
                            Text("${AppLocalizations.of(context)!.question}: ${question['question']}"),
                            Text("${AppLocalizations.of(context)!.type}: ${question['questionType']}"),
                            if (question['questionType'] == 'Выборочная') ...[
                              Text("${AppLocalizations.of(context)!.options}: ${question['options']}"),
                              Text("${AppLocalizations.of(context)!.correctansi}: ${question['correctAnswerIndex']}"),
                            ] else ...[
                              Text("${AppLocalizations.of(context)!.answer}: ${question['textAnswer']}"),
                            ],
                            SizedBox(height: 10),
                          ],
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  String newQuestion = '';
                                  String questionType = '';
                                  List<String> options = [];
                                  int correctAnswerIndex = 0;
                                  String textAnswerValue = '';
                                  List<TextEditingController> optionControllers = List.generate(4, (index) => TextEditingController());
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextFormField(
                                                  onChanged: (value) {
                                                    newQuestion = value;
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: '${AppLocalizations.of(context)!.typeque}',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                DropdownButton<String>(
                                                  value: questionType,
                                                  items: <String>['','${AppLocalizations.of(context)!.multiplech}', '${AppLocalizations.of(context)!.textinput}'].map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? newValue) {
                                                    setState(() {
                                                      questionType = newValue!;
                                                      options.clear();
                                                    });
                                                  },
                                                  hint: Text('${AppLocalizations.of(context)!.choosetypeq}'),
                                                ),
                                                SizedBox(height: 20),
                                                if (questionType == '${AppLocalizations.of(context)!.multiplech}') ...{
                                                  for (int i = 0; i < 4; i++)
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 10),
                                                      child: TextFormField(
                                                        controller: optionControllers[i], // Используйте контроллеры
                                                        onChanged: (value) {
                                                          options[i] = value; // Обновите соответствующий элемент в массиве options
                                                        },
                                                        decoration: InputDecoration(
                                                          labelText: '${AppLocalizations.of(context)!.choosetypeq} ${i + 1}',
                                                          border: OutlineInputBorder(),
                                                        ),
                                                      ),
                                                    ),
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      correctAnswerIndex = int.tryParse(value) ?? 0;
                                                    },
                                                    decoration: InputDecoration(
                                                      labelText: '${AppLocalizations.of(context)!.correctansi}',
                                                      border: OutlineInputBorder(),
                                                    ),
                                                  ),
                                                } else ...{
                                                  TextFormField(
                                                    onChanged: (value) {
                                                      textAnswerValue = value;
                                                    },
                                                    decoration: InputDecoration(
                                                      labelText: '${AppLocalizations.of(context)!.typecorans}',
                                                      border: OutlineInputBorder(),
                                                    ),
                                                  ),
                                                },
                                                SizedBox(height: 20),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    // Пройдем по всем контроллерам, извлекаем их значения и добавляем в options
                                                    for (var controller in optionControllers) {
                                                      options.add(controller.text);
                                                    }
                                                    // Далее добавляем остальные значения
                                                    _addQuestion(newQuestion, questionType, options, correctAnswerIndex, textAnswerValue);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('${AppLocalizations.of(context)!.add}'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.add),
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromRGBO(126,74,59, 1), // Set the button background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0), // Add rounded corners
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 20.0), // Adjust horizontal padding
                            ),
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 20),
                     Container(
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.black54, width: 1.0),
                         borderRadius: BorderRadius.circular(15.0),
                       ),
                       child: IconButton(
                        onPressed: () {
                          _saveToDatabase();
                        },
                        icon: Icon(Icons.send), // Use the send icon
                        iconSize: 68, // Adjust the icon size
                        color: Color.fromRGBO(126,74,59, 1), // Change the icon color
                    ),
                     ),
                    SizedBox(height: 50,)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
