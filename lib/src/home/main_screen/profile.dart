import 'package:duolingo/src/home/main_screen/questions/question.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:duolingo/src/home/main_screen/questions/models/question_class.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import '../../../main.dart';
import '../login/login_page.dart';


class Profile extends StatefulWidget {

  final Function(Locale) setLocale;
  const Profile({Key? key, required this.setLocale}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late DatabaseReference _databaseReference;
  bool _isLoading = true;
  String name = '';
  int userPoints = 0;
  String rank = '';
  String language = '';
  List<Question> recentMistakes = []; // List to store recent mistakes/questions


  void _showResultDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,// Запрещаем закрытие при нажатии вне окна
      builder: (BuildContext context) {
        return Container(height: 250,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.setLocale(Locale("en"));
                    Navigator.of(context).pop();
                  },
                  child: Text('English',style: TextStyle(

                      fontSize: 16
                  ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7e7e94),
                    onPrimary: Colors.white, // text color
                    elevation: 5, // shadow elevation// button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // button border radius
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.setLocale(Locale("ru"));
                    Navigator.of(context).pop();
                  },
                  child: Text('Russian',style: TextStyle(

                      fontSize: 16
                  ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7e7e94),
                    onPrimary: Colors.white, // text color
                    elevation: 5, // shadow elevation// button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // button border radius
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    widget.setLocale(Locale("kk"));
                    Navigator.of(context).pop();;
                  },
                  child: Text('Kazakh',style: TextStyle(

                      fontSize: 16
                  ),),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF7e7e94),
                    onPrimary: Colors.white, // text color
                    elevation: 5, // shadow elevation// button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14), // button border radius
                    ),
                  ),
                ),
              ),
            ],
          ),

        );
      },
    );
  }

  Future<void> _getUserData() async {
    try {
      setState(() {
        _isLoading = true; // Установите состояние загрузки в true
      });
      final user = _auth.currentUser;
      if (user != null) {
        _databaseReference = FirebaseDatabase.instance.reference().child('users/${user.uid}');
        final dataSnapshot = await _databaseReference.once();
        final Map<dynamic, dynamic> data = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
        print(data);
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            name = data['Username'] ??
                ''; // Provide a default value if 'Username' is null
            userPoints = data['points'] ??
                0; // Provide a default value if 'points' is null
            rank =
                data['rank'] ?? ''; // Provide a default value if 'rank' is null
            language = data['language'] ??
                ''; // Provide a default value if 'language' is null
            // Load recent mistakes/questions from data (assuming it's stored in a list)
            recentMistakes = List<Question>.from(
              (data['mistakes'] ?? []).map(
                    (mistakeData) =>
                    Question(
                      question: (mistakeData['question'] ?? ''),
                      // Начиная с третьего символа
                      options: List<String>.from(mistakeData['options'] ?? []),
                      correctAnswerIndex: mistakeData['correctAnswerIndex'] ??
                          0,
                      questionType: (mistakeData['questionType'] == "textInput")
                          ? QuestionType.textInput
                          : (mistakeData['questionType'] == "multipleChoice")
                          ? QuestionType.multipleChoice :
                      QuestionType.multipleChoice,
                      correctInputAns: mistakeData['correctInputAns'] ?? '',
                    ),
              ),
            );
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading =
        false; // В случае ошибки также установите состояние загрузки в false
      });
    }
  }


  void _showQuestionDialog(Question question) {
    print(question.questionType);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${AppLocalizations.of(context)!.answer}:"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              question.questionType == QuestionType.multipleChoice ? Text(
                  question.options![question.correctAnswerIndex!]) : Text(
                  question.correctInputAns!)
            ],
          ),
        );
      },
    );
  }

  Future<List<Question>> getPythonQuestions() async {
    final user = _auth.currentUser;
    final List<Question> pythonQuestions = [];
    if (user != null) {
      final useruid = user.uid;
      final databaseReference = FirebaseDatabase.instance.reference();
      final DatabaseEvent dataSnapshot = await databaseReference.child(
          'users/$useruid/mistakes').once();

      final questionsData = dataSnapshot.snapshot.value as List<dynamic>;

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
      final DatabaseReference reference = FirebaseDatabase.instance.reference()
          .child("users/$useruid/mistakes");
      reference.remove().then((_) {
        print('Папка успешно удалена');
      }).catchError((error) {
        print('Ошибка при удалении папки: $error');
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionScreen(questionss: pythonQuestions,
            setLocale: widget.setLocale,
            pointsto: 20,
            level: -1,
            language: 'iscse',
            topic: "1",
            component: "1",), // Замените YourNewPage() на вашу новую страницу
        ),
      );
    }
    return pythonQuestions;
  }


  _titleText(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
    );
  }

  @override
  void initState() {
    super.initState();
    _getUserData();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // Replace Future.delayed with the actual logic to load localization
        future: Future.delayed(Duration(seconds: 2), () => true),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading localization'));
          } else if (snapshot.hasData) {
            return buildContent(context);
          } else {
            return Center(child: Text('Unknown error'));
          }
        },
      ),
    );
  }


  @override
  Widget buildContent(BuildContext context){
      final locale = Localizations.localeOf(context);
      return Scaffold(
        body: _isLoading ?
        Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: (){
                      _showResultDialog();
                    }, icon: Icon(Icons.language,color: Colors.grey,))
                  ],
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          userPoints >= 400
                              ? "assets/images/ranks/r.png"
                              : userPoints >= 350
                              ? "assets/images/ranks/i.png"
                              : userPoints >= 300
                              ? "assets/images/ranks/a.png"
                              : userPoints >= 250
                              ? "assets/images/ranks/d.png"
                              : userPoints >= 200
                              ? "assets/images/ranks/p.png"
                              : userPoints >= 150
                              ? "assets/images/ranks/g.png"
                              : userPoints >= 100
                              ? "assets/images/ranks/s.png"
                              : userPoints >= 50
                              ? "assets/images/ranks/b.png"
                              : "assets/images/ranks/ir.png",
                          height: 120,
                        ),
                      ),
                    ),
                    Expanded(child: SizedBox(width: 30,))
                  ],
                ),
                Divider(color: Colors.grey.shade500),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    _titleText("${AppLocalizations.of(context)!.information}:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Card(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 50,
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.40,
                            child: ListTile(
                                leading: Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.amber,
                                ),
                                title: Text(
                                  "$userPoints",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )),
                          ),
                        ),
                        Card(
                          child: Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.40,
                              child: ListTile(
                                  leading: Icon(
                                    Icons.language,
                                    color: Colors.amber,
                                  ),
                                  title: Text(
                                    language == "CS" ? "C#" : "$language",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _titleText(AppLocalizations.of(context)!.lastmis),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(width: 0.8, color: Colors.grey),

                          ),
                          child: TextButton(
                              onPressed: () {
                                getPythonQuestions();
                              },
                              child: Text(AppLocalizations.of(context)!.trainb,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange),)),
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    // List of recent mistakes/questions
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: recentMistakes.isEmpty ? 1 : recentMistakes.length + 1, // +1 for the message
                        itemBuilder: (context, index) {
                          if (recentMistakes.isEmpty) {
                            // Display the message when the list is empty
                            return ListTile(
                              title: Text(AppLocalizations.of(context)!.noMistakesMessage),
                            );
                          } else {
                            final question = recentMistakes[index];
                            return ListTile(
                              title: Text(question.question),
                              onTap: () {
                                _showQuestionDialog(question);
                              },
                            );
                          }
                        }
                    ),
                    SizedBox(height: 20,),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 1.0,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                          child: Text(
                            AppLocalizations.of(context)!.dangerz,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7d0c0c),

                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1.0, // Высота разделителя
                            color: Colors.grey.withOpacity(
                                0.5), // Цвет с прозрачностью
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF7d0c0c),
                          padding: EdgeInsets.all(16.0),
                        ),
                        onPressed: () {
                          final locale = Localizations.localeOf(context);
                          print(locale.languageCode);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  locale.languageCode=="en"?"Log Out":locale.languageCode=="ru"?"Выйти":"Шығу",),
                                content: Text(
                                  locale.languageCode=="en"?"Are you sure you want to exit?":locale.languageCode=="ru"?"Вы уверены, что хотите выйти?":"Сіз шыққыңыз келетініне сенімдісіз бе?",
                                  ),
                                actionsPadding: EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                buttonPadding: EdgeInsets.all(0),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        0, 12, 0, 8),
                                    child: ButtonBar(
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            locale.languageCode=="en"?"No":locale.languageCode=="ru"?"Нет":"Жоқ",
                                            style: TextStyle(

                                                color: Colors.grey),),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xFF7d0c0c),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                          ),
                                          onPressed: () async {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MyApp(),
                                              ),
                                            );

                                            try {
                                              await _auth.signOut();
                                            } catch (error) {
                                              print(
                                                  'Ошибка при выходе из аккаунта: $error');
                                            }
                                          },
                                          child: Text(
                                            locale.languageCode=="en"?"Yes":locale.languageCode=="ru"?"Да":"Иә",),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.logout,
                          style: TextStyle(
                              fontSize: 16.0,),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}
