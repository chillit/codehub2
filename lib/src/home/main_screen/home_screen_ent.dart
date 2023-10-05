import 'package:duolingo/src/components/circle_avatar.dart';
import 'package:duolingo/src/home/main_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:duolingo/src/home/main_screen/questions/question.dart';

import 'package:duolingo/src/home/main_screen/questions/models/question_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../pages/create_account.dart';
import 'home_screen.dart';

class chooseent extends StatefulWidget {
  @override
  _chooseentState createState() => _chooseentState();
}

class _chooseentState extends State<chooseent> {
  void pree(topic){
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomeScreenEnt(topic: topic,)));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20,),
              SizedBox(height: 40,),
              Text('I wanna learn...',
                style: TextStyle(
                  fontFamily: 'Feather',
                  fontSize: 32,
                  color: Colors.black54,
                ),),
              SizedBox(height: 60,),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/igcse.png',text: 'igcse',language: 'igcse',bg: Color(0xFFFFFFFF),press: (){pree(0);}),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/ent.png',text: 'ent',language: 'ent', bg: Color(0xFFFFFFFF),press: (){pree(1);})
                    ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/igcse.png',text: 'igcse',language: 'igcse',bg: Color(0xFFFFFFFF),press: (){pree(2);}),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/ent.png',text: 'ent',language: 'ent', bg: Color(0xFFFFFFFF),press: (){pree(3);})
                    ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/igcse.png',text: 'igcse',language: 'igcse',bg: Color(0xFFFFFFFF),press: (){pree(4);}),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/ent.png',text: 'ent',language: 'ent', bg: Color(0xFFFFFFFF),press: (){pree(5);})
                    ],),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreenEnt extends StatefulWidget {
  @override
  _HomeScreenEntState createState() => _HomeScreenEntState();
  final String topic;
  HomeScreenEnt({required this.topic});
}

class _HomeScreenEntState extends State<HomeScreenEnt> {
  List<Question> pythonQuestions = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  String currentUserUID = "";
  int userLevel = 0;
  String userLanguage = "";


  bool isLoading = true; // Add this variable to track loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    print("ENTTTT");
    final user = _auth.currentUser;
    if (user != null) {
      currentUserUID = user.uid;

      final levelRef = _database.reference().child('users/$currentUserUID/level');
      final languageRef = _database.reference().child('users/$currentUserUID/language');


      DatabaseEvent levelSnapshot = await levelRef.once();
      DatabaseEvent languageSnapshot = await languageRef.once();
      userLevel = levelSnapshot.snapshot.value as int;
      userLanguage = languageSnapshot.snapshot.value?.toString() ?? '';
      setState(() {
        isLoading = false; // Set loading to false when data is fetched
      });
    }
  }
  Future<List<Question>> getPythonQuestions(level) async {
    setState(() {
      isLoading = true;
    });
    final databaseReference = await FirebaseDatabase.instance.reference();
    final DatabaseEvent dataSnapshot = await databaseReference.child('allq/$userLanguage/$level').once();

    final questionsData = await dataSnapshot.snapshot.value as List<dynamic>;
    print(questionsData);
    final List<Question> pythonQuestions = [];

    for (final questionData in questionsData) {
      final correctInputAns = questionData['correctInputAns'] ?? ''; // Provide a default value, like an empty string

      final optionsList = questionData['options'] as List<dynamic>?;

      final question = Question(
        question: questionData['question'] ?? '',
        correctAnswerIndex: questionData['correctAnswerIndex'] ?? -1, // Provide a default value
        options: optionsList?.map((option) => option.toString()).toList() ?? [], // Provide an empty list as a default
        questionType: QuestionType.values.firstWhere(
              (type) => type.toString() == 'QuestionType.${questionData['questionType']}',
          orElse: () => QuestionType.multipleChoice,
        ),
        correctInputAns: correctInputAns,
      );



      pythonQuestions.add(question);
    }
    DatabaseEvent videoRef = await databaseReference.child('videos/${userLanguage}/$level/video').once();
    final videoValue = videoRef.snapshot.value as String;
    DatabaseEvent textRef = await databaseReference.child('texts/${userLanguage}/$level/1').once();
    final textValue = textRef.snapshot.value;
    String formattedText = textValue.toString().replaceAll(r'\n', '\n');
    setState(() {
      isLoading = false;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(questionss: pythonQuestions,pointsto: 50,level:level,link: videoValue,text: formattedText,topic: widget.topic,language: userLanguage,), // Замените YourNewPage() на вашу новую страницу
      ),
    );

    return pythonQuestions;
  }
  Text _textCirle(String text) =>
      Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading?
      Center(child: CircularProgressIndicator(),):
      Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/Back_white.png"), // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 38),
                Column(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        userLevel>=1?getPythonQuestions(0):null;
                      },
                      child: userLevel<1?
                      CircleAvatarIndicator(Color(0xFF808080),"assets/images/mark.png"):userLevel>1?
                      CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                      CircleAvatarIndicator(Color(0xFF55acf3),
                          "assets/images/home_screen/lesson_egg.png"),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 110,),
                        InkWell(
                          onTap: () async {
                            userLevel>=2?getPythonQuestions(1):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<2?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>2?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_dialog.png"),

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 70,),
                        InkWell(
                          onTap: () async {
                            userLevel>=3?getPythonQuestions(2):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<3?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>3?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_airplane.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 120,),
                        InkWell(
                          onTap: () async {
                            userLevel>=4?getPythonQuestions(3):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<4?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>4?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_hamburger.png"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 160,),
                        InkWell(
                          onTap: () async {
                            userLevel>=5?getPythonQuestions(4):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<5?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>5?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_baby.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: () async {
                        userLevel>=6?getPythonQuestions(5):null;
                      },
                      child: userLevel<6?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>6?
                      CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                      CircleAvatarIndicator(Color(0xFF55acf3),
                          "assets/images/home_screen/lesson_egg.png"),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 110,),
                        InkWell(
                          onTap: () async {
                            userLevel>=7?getPythonQuestions(6):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<7?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>7?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_dialog.png"),

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 70,),
                        InkWell(
                          onTap: () async {
                            userLevel>=8?getPythonQuestions(7):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<8?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>8?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_airplane.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 120,),
                        InkWell(
                          onTap: () async {
                            userLevel>=9?getPythonQuestions(8):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<9?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>9?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_hamburger.png"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 160,),
                        InkWell(
                          onTap: () async {
                            userLevel>=10?getPythonQuestions(9):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<10?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>10?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_baby.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: () async {
                        userLevel>=11?getPythonQuestions(10):null;
                      },
                      child: userLevel<11?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>11?
                      CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                      CircleAvatarIndicator(Color(0xFF55acf3),
                          "assets/images/home_screen/lesson_egg.png"),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 110,),
                        InkWell(
                          onTap: () async {
                            userLevel>=12?getPythonQuestions(11):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<12?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>12?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_dialog.png"),

                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 70,),
                        InkWell(
                          onTap: () async {
                            userLevel>=13?getPythonQuestions(12):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<13?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>13?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_airplane.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(width: 120,),
                        InkWell(
                          onTap: () async {
                            userLevel>=14?getPythonQuestions(13):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<14?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>14?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_hamburger.png"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 160,),
                        InkWell(
                          onTap: () async {
                            userLevel>=15?getPythonQuestions(14):null;
                          },
                          child: Column(
                            children: <Widget>[
                              userLevel<15?CircleAvatarIndicator(Color(0xFF808080),"assets/images/lock.png"):userLevel>15?
                              CircleAvatarIndicator(Color(0xFFFFFF00),"assets/images/mark.png"):
                              CircleAvatarIndicator(Color(0xFF55acf3),
                                  "assets/images/home_screen/lesson_baby.png"),
                            ],
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 40),

                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: <
                        Widget>[
                      Expanded(
                        child: Container(
                            margin: const EdgeInsets.only(left: 10, right: 15),
                            child: Divider(
                              color: Colors.black,
                              height: 50,
                            )),
                      ),
                      Image.asset(
                        "assets/images/home_screen/lesson_divisor_castle.png",
                        height: 85,
                      ),
                      Expanded(
                        child: Container(
                            margin: const EdgeInsets.only(left: 15, right: 10),
                            child: Divider(
                              color: Colors.black,
                              height: 50,
                            )),
                      ),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}