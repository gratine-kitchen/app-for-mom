import 'dart:math';

/// A single arithmetic question with 4 multiple-choice options.
class MathQuestion {
  final int a;
  final int b;
  final String operator;
  final int answer;
  final List<int> options;

  const MathQuestion({
    required this.a,
    required this.b,
    required this.operator,
    required this.answer,
    required this.options,
  });

  /// Returns the question text, e.g. "3 + 5 = ?"
  String get displayText => '$a $operator $b = ?';
}

/// Generates and manages a round of single-digit arithmetic questions.
///
/// Questions use operands 1–9 with addition (+) or subtraction (−).
/// Subtraction always produces a non-negative result.
/// Each question has 4 answer choices: 1 correct + 3 distractors.
class MathQuizGame {
  static const int defaultTotalQuestions = 6;

  final int totalQuestions;
  final List<MathQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;

  MathQuizGame({this.totalQuestions = defaultTotalQuestions}) {
    _generateQuestions();
  }

  /// The list of all questions in this round.
  List<MathQuestion> get questions => List.unmodifiable(_questions);

  /// The current question index (0-based).
  int get currentIndex => _currentIndex;

  /// Number of correct answers so far.
  int get score => _score;

  /// Total questions in this round.
  int get length => _questions.length;

  /// Whether all questions have been answered.
  bool get isFinished => _currentIndex >= _questions.length;

  /// The current question, or null if finished.
  MathQuestion? get currentQuestion =>
      isFinished ? null : _questions[_currentIndex];

  /// Checks [selected] against the current question's correct answer.
  /// Returns true if correct. Advances to the next question.
  bool checkAnswer(int selected) {
    if (isFinished) return false;

    final correct = _questions[_currentIndex].answer == selected;
    if (correct) _score++;
    _currentIndex++;
    return correct;
  }

  /// Resets and regenerates all questions for a new round.
  void restart() {
    _currentIndex = 0;
    _score = 0;
    _generateQuestions();
  }

  // ---- Private ----

  void _generateQuestions() {
    _questions.clear();
    final random = Random();

    for (int i = 0; i < totalQuestions; i++) {
      final isAdd = random.nextBool();
      final a = random.nextInt(9) + 1; // 1–9

      int b;
      int answer;
      String op;

      if (isAdd) {
        b = random.nextInt(9) + 1;
        answer = a + b;
        op = '+';
      } else {
        b = random.nextInt(a + 1); // ensure a - b >= 0
        answer = a - b;
        op = '−';
      }

      final distractors = _generateDistractors(answer, random);
      final options = [...distractors, answer]..shuffle(random);

      _questions.add(MathQuestion(
        a: a,
        b: b,
        operator: op,
        answer: answer,
        options: options,
      ));
    }
  }

  /// Generates 3 unique wrong answers close to [correct].
  Set<int> _generateDistractors(int correct, Random random) {
    final distractors = <int>{};

    // Build a pool of candidates around the correct answer.
    final candidates = <int>[];
    for (int offset = -4; offset <= 4; offset++) {
      final candidate = correct + offset;
      if (candidate != correct && candidate >= 0 && candidate <= 20) {
        candidates.add(candidate);
      }
    }
    candidates.shuffle(random);

    for (final c in candidates) {
      if (distractors.length >= 3) break;
      if (c != correct) distractors.add(c);
    }

    // Fallback: just in case the pool was too small
    while (distractors.length < 3) {
      final fallback = random.nextInt(20);
      if (fallback != correct) distractors.add(fallback);
    }

    return distractors;
  }
}
