import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../games/math_quiz_game.dart';
import '../../l10n/app_strings.dart';

/// Full-screen arithmetic quiz with multiple-choice answers.
class MathQuizScreen extends StatefulWidget {
  const MathQuizScreen({super.key});

  @override
  State<MathQuizScreen> createState() => _MathQuizScreenState();
}

class _MathQuizScreenState extends State<MathQuizScreen> {
  late MathQuizGame _game;

  /// Whether we are currently showing feedback (correct/wrong flash).
  bool _showingFeedback = false;

  /// The index of the option the user selected (-1 = none yet).
  int? _selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    _game = MathQuizGame();
  }

  void _onOptionSelected(int selectedValue) {
    if (_showingFeedback || _game.isFinished) return;

    final isCorrect = _game.checkAnswer(selectedValue);

    HapticFeedback.lightImpact();

    setState(() {
      _showingFeedback = true;
      // Find which option was tapped so we can highlight it.
      final question = _game.questions[_game.currentIndex - 1];
      _selectedOptionIndex = question.options.indexOf(selectedValue);
    });

    Future.delayed(
      isCorrect ? const Duration(milliseconds: 600) : const Duration(milliseconds: 1000),
      () {
        if (!mounted) return;
        setState(() {
          _showingFeedback = false;
          _selectedOptionIndex = null;
        });
      },
    );
  }

  void _playAgain() {
    setState(() {
      _game.restart();
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_game.isFinished) {
      return _buildResultScreen();
    }
    return _buildQuizScreen();
  }

  // ---- Quiz Screen ----

  Widget _buildQuizScreen() {
    final question = _game.currentQuestion!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.back,
          onPressed: _goBack,
        ),
        title: Text(
          AppStrings.quizProgress(_game.currentIndex + 1, _game.length),
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AppStrings.score(_game.score),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ---- Question ----
              Text(
                question.displayText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),

              const Spacer(flex: 1),

              // ---- Answer Grid (2×2) ----
              SizedBox(
                width: double.infinity,
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: question.options.map((value) {
                    return _AnswerButton(
                      value: value,
                      correctAnswer: question.answer,
                      showingFeedback: _showingFeedback,
                      isSelected: question.options.indexOf(value) ==
                          _selectedOptionIndex,
                      onTap: () => _onOptionSelected(value),
                    );
                  }).toList(),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Result Screen ----

  Widget _buildResultScreen() {
    final theme = Theme.of(context);
    final correct = _game.score;
    final total = _game.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: AppStrings.back,
          onPressed: _goBack,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  correct == total ? Icons.emoji_events : Icons.celebration_outlined,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.quizComplete,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.quizScore(correct, total),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                FilledButton.icon(
                  onPressed: _playAgain,
                  icon: const Icon(Icons.refresh),
                  label: Text(AppStrings.playAgain),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _goBack,
                  child: Text(AppStrings.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single answer option button with feedback coloring.
class _AnswerButton extends StatelessWidget {
  final int value;
  final int correctAnswer;
  final bool showingFeedback;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.value,
    required this.correctAnswer,
    required this.showingFeedback,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine button color based on feedback state.
    Color? backgroundColor;
    Color? foregroundColor;

    if (showingFeedback) {
      if (value == correctAnswer) {
        backgroundColor = Colors.green;
        foregroundColor = Colors.white;
      } else if (isSelected) {
        backgroundColor = Colors.red;
        foregroundColor = Colors.white;
      } else {
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        foregroundColor = theme.colorScheme.onSurface.withValues(alpha: 0.3);
      }
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: showingFeedback ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text('$value'),
      ),
    );
  }
}
