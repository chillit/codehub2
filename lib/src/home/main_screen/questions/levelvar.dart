import 'package:duolingo/src/home/main_screen/questions/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'models/question_class.dart';

class YourPage extends StatefulWidget {
  final Function(Locale) setLocale;
  final String userLocale;
  final String userLanguage;
  final String topic;
  final int level;
  final String component;

  YourPage({
    required this.setLocale,
    required this.userLocale,
    required this.userLanguage,
    required this.topic,
    required this.level,
    this.component = '',
  });

  @override
  _YourPageState createState() => _YourPageState();
}

class _YourPageState extends State<YourPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isLoading = true;
  String video = "";
  String text = "";
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    print(_auth.currentUser?.uid);
    final DatabaseEvent dataSnapshot = widget.userLanguage == "igcse"?await databaseReference.child('exams/${widget.userLocale}/${widget.userLanguage}/${widget.component}/${widget.topic}/${widget.level}').once()
        :await databaseReference.child('exams/${widget.userLocale}/${widget.userLanguage}/${widget.topic}/${widget.level}').once();
    Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    if (values != null) {
      values.forEach((key, value) {
        dataList.add({...value, 'userId': key});
      });
      filteredList = List.from(dataList);
      setState(() {});
    }
    print(filteredList);
  }
  void _deleteData(String userId) async {
    if (widget.userLanguage == "igcse") {
      try {
        await databaseReference
            .child(
            'exams/${widget.userLocale}/${widget.userLanguage}/${widget.component}/${widget.topic}/${widget.level}/${userId}')
            .remove();
        setState(() {
          dataList.removeWhere((element) => element['userId'] == userId);
          filteredList.removeWhere((element) => element['userId'] == userId);
        });
      } catch (e) {
        print('Failed to delete: $e');
      }
    } else {
      try {
        await databaseReference
            .child('exams/${widget.userLocale}/${widget.userLanguage}/${widget.topic}/${widget.level}/${userId}')
            .remove();
        setState(() {
          dataList.removeWhere((element) => element['userId'] == userId);
          filteredList.removeWhere((element) => element['userId'] == userId);
        });
      } catch (e) {
        print('Failed to delete: $e');
      }
    }
  }
  void _filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> dummyListData = [];
      dataList.forEach((item) {
        if (item['teacher'].toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredList.clear();
        filteredList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        filteredList.clear();
        filteredList.addAll(dataList);
      });
    }
  }
  Future<List<Question>> getPythonQuestions(data) async {
    final locale = Localizations.localeOf(context);
    setState(() {
      isLoading = true;
    });
    final List<Question> pythonQuestions = [];
    print(data["questions"]);
    for (final questionData in data["questions"]) {
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
    video = data["link"];
    text = data["Text"];
    String updatedText = text.replaceAll("\\n", "\n");
    setState(() {
      isLoading = false;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextScreen(setLocale: widget.setLocale, questionss: pythonQuestions,pointsto: 50,level:0,text: updatedText,topic: widget.topic,language: widget.userLanguage,component: widget.component,),
      ),
    );

    return pythonQuestions;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromRGBO(126,74,59, 1),size: 32),
        flexibleSpace: Center(
        child: Image.asset(
        'assets/images/safety/safety-Appbar.png',
        height: MediaQuery.of(context).size.width/2, // Adjust the height as needed
        width: MediaQuery.of(context).size.width/2, // Use the full width of the screen
    ),
    ),),
      body: dataList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  height: 200,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Center(child: Text('${filteredList[index]['teacher']}',style: TextStyle(fontSize: 32),)),

                      trailing: _auth.currentUser?.uid == filteredList[index]['userId']
                          ? IconButton(
                          onPressed: () {
                            print(filteredList[index]["userId"]);
                            _deleteData(filteredList[index]['userId']);
                          },
                          icon: Icon(Icons.delete))
                          : null,
                      onTap: () {
                        getPythonQuestions(filteredList[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
