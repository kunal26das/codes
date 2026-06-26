import '../models/frames.dart';

/// Character ASCII — show each character's ASCII code as it is read.
List<TextFrame> asciiCodes({String text = 'Aa9 z!'}) {
  final frames = <TextFrame>[TextFrame(text: text, caption: 'Every character is stored as an integer ASCII code.')];
  for (var i = 0; i < text.length; i++) {
    frames.add(TextFrame(text: text, examining: {i}, caption: '\'${text[i] == ' ' ? '␣' : text[i]}\' has ASCII code ${text.codeUnitAt(i)}.'));
  }
  frames.add(TextFrame(text: text, matched: {for (var i = 0; i < text.length; i++) i}, caption: 'Each glyph mapped to its code point.'));
  return frames;
}

/// Character identification — classify each character as letter, digit, or other.
List<TextFrame> charIdentification({String text = 'Go2Cmd!'}) {
  final frames = <TextFrame>[TextFrame(text: text, caption: 'Classify each character: letter, digit, or symbol.')];
  final letters = <int>{};
  final digits = <int>{};
  final others = <int>{};
  for (var i = 0; i < text.length; i++) {
    final c = text.codeUnitAt(i);
    final isLetter = (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
    final isDigit = c >= 48 && c <= 57;
    final kind = isLetter ? 'a letter' : (isDigit ? 'a digit' : 'a symbol');
    if (isLetter) {
      letters.add(i);
    } else if (isDigit) {
      digits.add(i);
    } else {
      others.add(i);
    }
    frames.add(TextFrame(
      text: text,
      examining: {i},
      matched: {...letters},
      rejected: {...others},
      caption: '\'${text[i] == ' ' ? '␣' : text[i]}\' is $kind.',
    ));
  }
  frames.add(TextFrame(
    text: text,
    matched: {...letters},
    rejected: {...others},
    caption: '${letters.length} letters, ${digits.length} digits, ${others.length} symbols.',
  ));
  return frames;
}

/// Palindrome check — compare characters from both ends inward.
List<TextFrame> palindromeCheck({String text = 'racecar'}) {
  final frames = <TextFrame>[TextFrame(text: text, caption: 'Is "$text" a palindrome? Compare from both ends inward.')];
  var lo = 0, hi = text.length - 1;
  final matched = <int>{};
  while (lo < hi) {
    if (text[lo] == text[hi]) {
      matched.add(lo);
      matched.add(hi);
      frames.add(TextFrame(text: text, examining: {lo, hi}, matched: {...matched}, caption: '\'${text[lo]}\' == \'${text[hi]}\' — matches.'));
      lo++;
      hi--;
    } else {
      frames.add(TextFrame(text: text, rejected: {lo, hi}, matched: {...matched}, caption: '\'${text[lo]}\' ≠ \'${text[hi]}\' — not a palindrome.'));
      return frames;
    }
  }
  frames.add(TextFrame(text: text, matched: {for (var i = 0; i < text.length; i++) i}, caption: '"$text" reads the same both ways — a palindrome!'));
  return frames;
}

/// Substring extraction — highlight the characters in a chosen range.
List<TextFrame> substringExtraction({String text = 'algorithms', int start = 2, int end = 6}) {
  final frames = <TextFrame>[TextFrame(text: text, caption: 'Extract the substring [$start, $end).')];
  final picked = <int>{};
  for (var i = start; i < end; i++) {
    picked.add(i);
    frames.add(TextFrame(text: text, examining: {i}, matched: {...picked}, caption: 'Take \'${text[i]}\' at index $i.'));
  }
  frames.add(TextFrame(text: text, matched: {...picked}, caption: 'Substring = "${text.substring(start, end)}".'));
  return frames;
}

/// String concatenation — append a second string onto the first.
List<TextFrame> stringConcatenation({String a = 'data', String b = 'set'}) {
  final result = a + b;
  final frames = <TextFrame>[TextFrame(text: result, matched: {for (var i = 0; i < a.length; i++) i}, caption: 'Start with "$a"; append "$b".')];
  for (var i = a.length; i < result.length; i++) {
    frames.add(TextFrame(
      text: result,
      matched: {for (var k = 0; k < a.length; k++) k},
      examining: {i},
      caption: 'Append \'${result[i]}\'.',
    ));
  }
  frames.add(TextFrame(text: result, matched: {for (var i = 0; i < result.length; i++) i}, caption: '"$a" + "$b" = "$result".'));
  return frames;
}

/// Vowel count — scan the string and tally the vowels.
List<TextFrame> vowelCount({String text = 'visualizer'}) {
  const vowels = 'aeiouAEIOU';
  final frames = <TextFrame>[TextFrame(text: text, caption: 'Count the vowels in "$text".')];
  final found = <int>{};
  for (var i = 0; i < text.length; i++) {
    if (vowels.contains(text[i])) {
      found.add(i);
      frames.add(TextFrame(text: text, examining: {i}, matched: {...found}, caption: '\'${text[i]}\' is a vowel (${found.length} so far).'));
    } else {
      frames.add(TextFrame(text: text, examining: {i}, matched: {...found}, caption: '\'${text[i]}\' is a consonant.'));
    }
  }
  frames.add(TextFrame(text: text, matched: {...found}, caption: '"$text" has ${found.length} vowels.'));
  return frames;
}
