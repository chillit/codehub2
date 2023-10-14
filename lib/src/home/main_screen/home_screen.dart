import 'package:duolingo/src/components/circle_avatar.dart';
import 'package:duolingo/src/home/main_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:duolingo/src/home/main_screen/questions/question.dart';
import 'package:duolingo/src/home/main_screen/home_screen_ent.dart';
import 'package:duolingo/src/home/main_screen/questions/models/question_class.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duolingo/src/pages/create_account.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void pree(component){
    print(component);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Home(currScreen: choose(component: component,))));
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
              Text(AppLocalizations.of(context)!.wantlearn,
                style: TextStyle(
                  fontFamily: 'Feather',
                  fontSize: 32,
                  color: Colors.black54,
                ),),
              SizedBox(height: 60,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SquareImageTextWidget(imageUrl: 'assets/images/exams/comps/1.png',text: AppLocalizations.of(context)!.fcomp,language: '0',bg: Color(0xFFFFFFFF),press: (){pree("0");},height: 2.3,),
                  SizedBox(width: 20,),
                  SquareImageTextWidget(imageUrl: 'assets/images/exams/comps/2.png',text: AppLocalizations.of(context)!.scomp,language: '1', bg: Color(0xFFFFFFFF),press: (){pree("1");},height: 2.3)
                ],),
            ],
          ),
        ),
      ),
    );
  }
}
class choose extends StatefulWidget {
  @override
  _chooseState createState() => _chooseState();
  final String component;
  choose({required this.component});
}

class _chooseState extends State<choose> {
  void pree(topic){
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => Home(currScreen: qHomeScreen(topic: topic,component: widget.component,),)));
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
              Text(AppLocalizations.of(context)!.chstopic,
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
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/1.png',text: AppLocalizations.of(context)!.topic,language: 'topic',bg: Color(0xFFFFFFFF),press: (){pree("0");},height: 5,),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/2.png',text: AppLocalizations.of(context)!.topic,language: 'topic', bg: Color(0xFFFFFFFF),press: (){pree("1");},height: 5)
                    ],),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/3.png',text: AppLocalizations.of(context)!.topic,language: 'topic',bg: Color(0xFFFFFFFF),press: (){pree("2");},height: 5),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/4.png',text: AppLocalizations.of(context)!.topic,language: 'topic', bg: Color(0xFFFFFFFF),press: (){pree("3");},height: 5)
                    ],),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/5.png',text: AppLocalizations.of(context)!.topic,language: 'topic',bg: Color(0xFFFFFFFF),press: (){pree("4");},height: 5),
                      SizedBox(width: 20,),
                      SquareImageTextWidget(imageUrl: 'assets/images/exams/topics/6.png',text: AppLocalizations.of(context)!.topic,language: 'topic', bg: Color(0xFFFFFFFF),press: (){pree("5");},height: 5)
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
class qHomeScreen extends StatefulWidget {
  @override
  _qHomeScreenState createState() => _qHomeScreenState();
  final String component;
  final String topic;
  qHomeScreen({required this.component,required this.topic});
}

class _qHomeScreenState extends State<qHomeScreen> {
  List<Question> pythonQuestions = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String video = "";
  String text = "";
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
    final user = _auth.currentUser;
    if (user != null) {
      currentUserUID = user.uid;

      final levelRef = _database.reference().child('users/$currentUserUID/topics/${widget.component}/${widget.topic}');
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
    final locale = Localizations.localeOf(context);
    setState(() {
      isLoading = true;
    });
    final databaseReference = FirebaseDatabase.instance.reference();
    print("aloha ${widget.component},${widget.topic},${level}");
    final DatabaseEvent dataSnapshot = locale.languageCode=="ru"?await databaseReference.child('exams/ru/allq/$userLanguage/${widget.component}/${widget.topic}/${level}').once():locale.languageCode=="en"?await databaseReference.child('exams/en/allq/$userLanguage/${widget.component}/${widget.topic}/${level}').once():await databaseReference.child('exams/kz/allq/$userLanguage/${widget.component}/${widget.topic}/${level}').once();

    final questionsData = dataSnapshot.snapshot.value as List<dynamic>;
    final List<Question> pythonQuestions = [];
    print(userLanguage);
    print(questionsData);
    for (final questionData in questionsData) {
      final question = Question(
        question: questionData['question'] ?? '',
        correctAnswerIndex: questionData['correctAnswerIndex'] ?? 0,
        options: (questionData['options'] as List<dynamic>?)?.map((option) => option.toString())?.toList() ?? [],
        questionType: QuestionType.values.firstWhere(
              (type) => type.toString() == 'QuestionType.${questionData['questionType']}',
          orElse: () => QuestionType.multipleChoice,
        ),
        correctInputAns: questionData['correctInputAns'] ?? '',
      );

      pythonQuestions.add(question);
    }
    DatabaseEvent videoSnapshot = locale.languageCode=="ru"?await databaseReference.child('exams/ru/videos/$userLanguage/${widget.component}/${widget.topic}/${level}/video').once():locale.languageCode=="en"?await databaseReference.child('exams/en/videos/$userLanguage/${widget.component}/${widget.topic}/${level}/video').once():await databaseReference.child('exams/kz/videos/$userLanguage/${widget.component}/${widget.topic}/${level}/video').once();
    video = videoSnapshot.snapshot.value as String;
    DatabaseEvent textSnapshot = locale.languageCode=="ru"?await databaseReference.child('exams/ru/texts/$userLanguage/${widget.component}/${widget.topic}/${level}/1').once():locale.languageCode=="en"?await databaseReference.child('exams/en/texts/$userLanguage/${widget.component}/${widget.topic}/${level}/1').once():await databaseReference.child('exams/kz/texts/$userLanguage/${widget.component}/${widget.topic}/${level}/1').once();
    text = textSnapshot.snapshot.value as String;
    String updatedText = text.replaceAll("\\n", "\n");
    setState(() {
      isLoading = false;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => locale.languageCode == "ru"? VideoScreen(questionss: pythonQuestions,pointsto: 50,level:level,link: video,text: updatedText,topic: widget.topic,language: userLanguage,component: widget.component,)
            : TextScreen(questionss: pythonQuestions,pointsto: 50,level:level,text: updatedText,topic: widget.topic,language: userLanguage,component: widget.component,),
      ),
    );

    return pythonQuestions;
  }
  Future<List<Question>> getpractice() async {
    setState(() {
      isLoading = true;
    });
    final databaseReference = FirebaseDatabase.instance.reference();
    print("aloha ${widget.component},${widget.topic}");
    final DatabaseEvent dataSnapshot = userLanguage=="igcse"?await databaseReference.child('exams/$userLanguage/practice').once():await databaseReference.child('allq/$userLanguage/practice').once();

    final questionsData = dataSnapshot.snapshot.value as List<dynamic>;
    final List<Question> pythonQuestions = [];
    print(questionsData);
    for (final questionData in questionsData) {
      final question = Question(
        question: questionData['question'] ?? '',
        correctAnswerIndex: questionData['correctAnswerIndex'] ?? 0,
        options: (questionData['options'] as List<dynamic>?)?.map((option) =>
            option.toString())?.toList() ?? [],
        questionType: QuestionType.values.firstWhere(
              (type) =>
          type.toString() == 'QuestionType.${questionData['questionType']}',
          orElse: () => QuestionType.multipleChoice,
        ),
        correctInputAns: questionData['correctInputAns'] ?? '',
      );

      pythonQuestions.add(question);
    }
    print("done");
    setState(() {
      isLoading = false;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(questionss: pythonQuestions,pointsto: 50,level:-1,link: "dQw4w9WgXcQ",text: "there is no text",topic: widget.topic,language: userLanguage,component: widget.component,),
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
                      GestureDetector(
                        onTap: (){
                          getpractice();
                        },
                        child: Image.asset(
                          "assets/images/home_screen/lesson_divisor_castle.png",
                          height: 85,
                        ),
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