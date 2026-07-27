import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Generates simple WAV audio files for game feedback sounds.
/// Run: dart run scripts/generate_audio.dart

void main() {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  // Correct: pleasant ascending two-tone chime (~400ms)
  File('assets/audio/correct.wav').writeAsBytesSync(
    _wavBytes(_correctSamples(44100)),
  );

  // Wrong: low gentle buzz (~400ms)
  File('assets/audio/wrong.wav').writeAsBytesSync(
    _wavBytes(_wrongSamples(44100)),
  );

  print('✅ Generated assets/audio/correct.wav');
  print('✅ Generated assets/audio/wrong.wav');
}

/// Generates ascending chime samples: C5 (523Hz) → E5 (659Hz).
List<int> _correctSamples(int sampleRate) {
  const duration = 0.40;
  final totalSamples = (sampleRate * duration).round();
  final samples = <int>[];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = i / totalSamples;

    // Frequency sweeps from 523Hz to 659Hz.
    final freq = 523 + (659 - 523) * progress;
    final envelope = _envelope(progress, duration);
    final sample = (envelope * sin(2 * pi * freq * t) * 16000).round();
    samples.add(sample.clamp(-32768, 32767));
  }

  return samples;
}

/// Generates a gentle low-frequency buzz.
List<int> _wrongSamples(int sampleRate) {
  const duration = 0.40;
  final totalSamples = (sampleRate * duration).round();
  final samples = <int>[];

  for (int i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    final progress = i / totalSamples;

    // Two low tones beating: 180Hz + 200Hz, gentle buzz.
    final signal = 0.6 * sin(2 * pi * 180 * t) + 0.4 * sin(2 * pi * 200 * t);
    final envelope = _envelope(progress, duration);
    final sample = (envelope * signal * 15000).round();
    samples.add(sample.clamp(-32768, 32767));
  }

  return samples;
}

/// Smooth fade-in / fade-out envelope.
double _envelope(double progress, double duration) {
  const attack = 0.02; // 20ms fade-in
  const releaseDuration = 0.08; // 80ms fade-out at end

  if (progress < attack / duration) {
    return progress / (attack / duration);
  }
  final releaseStart = 1.0 - releaseDuration / duration;
  if (progress > releaseStart) {
    return (1.0 - progress) / (releaseDuration / duration);
  }
  return 1.0;
}

/// Encodes 16-bit mono PCM samples into a WAV file byte array.
Uint8List _wavBytes(List<int> samples) {
  final dataSize = samples.length * 2;
  final buffer = BytesBuilder();

  // RIFF header
  buffer.add('RIFF'.codeUnits);
  buffer.add(_int32LE(36 + dataSize));
  buffer.add('WAVE'.codeUnits);

  // fmt chunk
  buffer.add('fmt '.codeUnits);
  buffer.add(_int32LE(16)); // chunk size
  buffer.add(_int16LE(1)); // PCM
  buffer.add(_int16LE(1)); // mono
  buffer.add(_int32LE(44100)); // sample rate
  buffer.add(_int32LE(44100 * 2)); // byte rate
  buffer.add(_int16LE(2)); // block align
  buffer.add(_int16LE(16)); // bits per sample

  // data chunk
  buffer.add('data'.codeUnits);
  buffer.add(_int32LE(dataSize));
  for (final s in samples) {
    buffer.add(_int16LE(s));
  }

  return buffer.toBytes();
}

Uint8List _int32LE(int v) {
  final b = BytesBuilder();
  b.addByte(v & 0xFF);
  b.addByte((v >> 8) & 0xFF);
  b.addByte((v >> 16) & 0xFF);
  b.addByte((v >> 24) & 0xFF);
  return b.toBytes();
}

Uint8List _int16LE(int v) {
  final b = BytesBuilder();
  b.addByte(v & 0xFF);
  b.addByte((v >> 8) & 0xFF);
  return b.toBytes();
}
