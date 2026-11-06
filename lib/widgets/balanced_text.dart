import 'package:flutter/material.dart';

/// 한국어 제목을 어절 단위로 줄바꿈하는 **표시 전용** 텍스트입니다.
///
/// Flutter `Text`에는 CSS `word-break: keep-all`이 없어 "하 / 실", "방식 / 은?"처럼
/// 단어 중간에서 끊깁니다. 이를 막기 위해 표시용 문자열에서만 다음을 적용합니다.
///
/// - 연속된 한글 음절 사이에 WORD JOINER(U+2060)를 넣어 어절 내부 줄바꿈을 막습니다.
///   (서로게이트 페어·ZWJ 이모지·국기 이모지에는 절대 넣지 않습니다.)
/// - 마지막 두 단어 사이 공백은 NBSP(U+00A0)로 바꿔, 마지막 줄에 1~2글자만 남는
///   외톨이 줄(widow)을 줄입니다.
///
/// 폰트 로딩 시점과 무관하게 동작하도록 줄 수 측정에 의존하지 않습니다.
/// 원문 데이터(저장값)는 변경하지 않으며, [display]의 결과에서 U+2060을 제거하고
/// NBSP를 공백으로 되돌리면 원문과 같습니다.
class BalancedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  const BalancedText(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 2,
    this.overflow = TextOverflow.ellipsis,
  });

  static bool _isHangulSyllable(int rune) => rune >= 0xAC00 && rune <= 0xD7A3;

  static bool _isShortTailOrEmoji(String word) {
    if (word.isEmpty) return true;
    final runes = word.runes.toList();
    if (runes.length <= 2) return true;
    // Check if word contains any Hangul syllable; if pure emoji/symbols, it is a short tail
    return !runes.any(_isHangulSyllable);
  }

  /// 표시용 문자열. 원문과 글자 내용은 같고 제어 문자만 추가/치환됩니다.
  static String display(String text) {
    if (text.isEmpty) return text;
    final trimmedEnd = text.trimRight();
    final words = trimmedEnd.split(' ');
    String glued;
    if (words.length >= 3 && _isShortTailOrEmoji(words.last)) {
      final prefix = words.sublist(0, words.length - 2).join(' ');
      glued = '$prefix\u00A0${words[words.length - 2]}\u00A0${words.last}';
    } else {
      final lastSpace = trimmedEnd.lastIndexOf(' ');
      glued = lastSpace > 0
          ? text.replaceRange(lastSpace, lastSpace + 1, '\u00A0')
          : text;
    }

    final b = StringBuffer();
    int? prev;
    for (final r in glued.runes) {
      if (prev != null && _isHangulSyllable(prev) && _isHangulSyllable(r)) {
        b.write('\u2060');
      }
      b.writeCharCode(r);
      prev = r;
    }
    return b.toString();
  }

  /// [display] 결과를 원문으로 되돌립니다(테스트·검증용).
  static String restore(String shown) =>
      shown.replaceAll('\u2060', '').replaceAll('\u00A0', ' ');

  @override
  Widget build(BuildContext context) {
    return Text(
      display(text),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
