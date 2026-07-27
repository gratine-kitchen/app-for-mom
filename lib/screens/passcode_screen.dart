import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';

/// The shared family passcode. Change this to your own before deploying.
const _familyPasscode = 'family2026';

/// A simple passcode gate shown only when accessing the app via web browser.
///
/// Native (iOS/Android) users skip this screen entirely and go straight to
/// [child].
class PasscodeGate extends StatefulWidget {
  /// The main app content to show after successful passcode entry.
  final Widget child;

  const PasscodeGate({super.key, required this.child});

  @override
  State<PasscodeGate> createState() => _PasscodeGateState();
}

class _PasscodeGateState extends State<PasscodeGate> {
  final _controller = TextEditingController();
  String? _error;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    // TODO: Remove before production — prepopulates passcode during development.
    _controller.text = _familyPasscode;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _familyPasscode.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _unlock() {
    final entered = _controller.text.trim();
    if (entered.isEmpty) return;

    setState(() => _unlocking = true);

    // Small delay so the user can see the loading state
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      if (entered == _familyPasscode) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.child),
        );
      } else {
        setState(() {
          _error = AppStrings.wrongPasscode;
          _unlocking = false;
        });
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.enterPasscode,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.passcodeHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  obscuringCharacter: '●',
                  textAlign: TextAlign.center,
                  autofocus: true,
                  onSubmitted: (_) => _unlock(),
                  decoration: InputDecoration(
                    labelText: AppStrings.passcodeLabel,
                    hintText: AppStrings.passcodeFieldHint,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _unlocking ? null : _unlock,
                    icon: _unlocking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.arrow_forward),
                    label: Text(
                      _unlocking ? AppStrings.saving : AppStrings.unlock,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
