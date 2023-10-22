import 'package:duolingo/src/home/main_screen/questions/question.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final DatabaseEvent dataSnapshot = await databaseReference.child('exams/${widget.userLocale}/${widget.userLanguage}/${widget.component}/${widget.topic}/0').once();
    print("${widget.userLocale}, ${widget.userLanguage} ${widget.component}, ${widget.topic}, ${widget.level}");
    Map<dynamic, dynamic> values = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;
    if (values != null) {
      values.forEach((key, value) {
        dataList.add({...value, 'userId': key});
      });

      filteredList = List.from(dataList);
      setState(() {});
      print(filteredList);
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
        builder: (context) => locale.languageCode == "ru"? VideoScreen(setLocale: widget.setLocale, questionss: pythonQuestions,pointsto: 50,level:0,link: video,text: updatedText,topic: widget.topic,language: widget.userLanguage,component: widget.component,)
            : TextScreen(setLocale: widget.setLocale, questionss: pythonQuestions,pointsto: 50,level:0,text: updatedText,topic: widget.topic,language: widget.userLanguage,component: widget.component,),
      ),
    );

    return pythonQuestions;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Page'),
      ),
      body: dataList.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _filterSearchResults(value);
              },
              decoration: InputDecoration(
                labelText: "Search by Teacher",
                hintText: "Search by Teacher",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Teacher: ${filteredList[index]['teacher']}'),
                  subtitle: Text('Date: ${filteredList[index]['date']}'),
                  onTap: (){
                    getPythonQuestions(filteredList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
