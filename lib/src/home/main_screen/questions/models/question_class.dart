enum QuestionType {
  multipleChoice,
  textInput,
}

class Question {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final QuestionType questionType;
  final String correctInputAns;

  const Question({
    required this.correctAnswerIndex,
    required this.question,
    required this.options,
    this.questionType = QuestionType.multipleChoice,
    required this.correctInputAns,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options?? [],
      'correctAnswerIndex': correctAnswerIndex?? 0,
      'questionType': questionType == QuestionType.textInput?"textInput":"QuestionType.multipleChoice", // Convert enum to string
      'correctInputAns': correctInputAns,
    };
  }
}
