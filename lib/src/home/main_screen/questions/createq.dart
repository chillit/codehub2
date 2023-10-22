import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final referenceDatabase = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> _formData = [];
  List<Map<String, dynamic>> _questionsData = [];
  String textAnswerValue = '';
  String component = 'Первый';
  int topic = 1;
  String exam = "igcse";
  int levelValue = 1;
  String linkValue = '';
  String bigTextValue = '';
  String language = "ru";
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String name = "";

  void _saveToDatabase() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        String currentDate = DateTime.now().toIso8601String().split('T')[0];
        final nameSnapshot =
        await _database.reference().child('users/${user.uid}/Username').once();
        name = nameSnapshot.snapshot.value?.toString() ?? '';
        referenceDatabase
            .child(
            'exams/${language}/${exam}/${component == "Первый" ? 0 : 1}/${topic - 1}/${levelValue - 1}/${user.uid}')
            .set({
          'link': linkValue,
          'Text': bigTextValue,
          'teacher': name,
          'date': currentDate,
          'questions': _questionsData,
        });
      }
    });
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Выберите язык: '),
                  DropdownButton<String>(
                    value: language,
                    items: <String>['ru', 'en', 'kz'].map((String value) {
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
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Выберите экзамен: '),
                  DropdownButton<String>(
                    value: exam,
                    items: <String>['igcse', 'ent'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        exam = newValue!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Выберите компонент: '),
                  DropdownButton<String>(
                    value: component,
                    items: <String>['Первый', 'Второй'].map((String value) {
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
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Выберите тему: '),
                  DropdownButton<int>(
                    value: topic,
                    items: <int>[1, 2, 3, 4, 5, 6].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        topic = newValue!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Выберите уровень: '),
                  DropdownButton<int>(
                    value: levelValue,
                    items: <int>[1, 2, 3, 4, 5, 6].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setState(() {
                        levelValue = newValue!;
                      });
                    },
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
                  labelText: 'Введите ссылку',
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
                  labelText: 'Введите большой текст',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              StatefulBuilder(builder: (context, setState) {
                return Column(
                  children: [
                    for (var question in _questionsData) ...[
                      Text("Question: ${question['question']}"),
                      Text("Type: ${question['questionType']}"),
                      if (question['questionType'] == 'Выборочная') ...[
                        Text("Options: ${question['options']}"),
                        Text("Correct Answer Index: ${question['correctAnswerIndex']}"),
                      ] else ...[
                        Text("Answer: ${question['textAnswer']}"),
                      ],
                      SizedBox(height: 10),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            String newQuestion = '';
                            String questionType = 'Выборочная';
                            List<String> options = [];
                            int correctAnswerIndex = 0;
                            String textAnswerValue = '';
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
                                              labelText: 'Введите вопрос',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          DropdownButton<String>(
                                            value: questionType,
                                            items: <String>['Выборочная', 'Текстовая'].map((String value) {
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
                                            hint: Text('Выберите тип вопроса'),
                                          ),
                                          SizedBox(height: 20),
                                          if (questionType == 'Выборочная') ...{
                                            for (int i = 0; i < 4; i++)
                                              Padding(
                                                padding: EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  onChanged: (value) {
                                                    options.add(value);
                                                  },
                                                  decoration: InputDecoration(
                                                    labelText: 'Введите вариант ответа ${i + 1}',
                                                    border: OutlineInputBorder(),
                                                  ),
                                                ),
                                              ),
                                            TextFormField(
                                              onChanged: (value) {
                                                correctAnswerIndex = int.tryParse(value) ?? 0;
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Индекс правильного ответа',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          } else ...{
                                            TextFormField(
                                              onChanged: (value) {
                                                textAnswerValue = value;
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Введите правильный ответ',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                          },
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                if (questionType == 'Выборочная') {
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
                                                    'correctInputAns': textAnswerValue,
                                                  });
                                                }
                                                newQuestion = '';
                                                questionType = 'Выборочная';
                                                options.clear();
                                                correctAnswerIndex = 0;
                                                textAnswerValue = '';
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Добавить'),
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
                    ),
                  ],
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveToDatabase();
                },
                child: Text('Отправить'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getDataFromDatabase();
                },
                child: Text('Получить данные'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
