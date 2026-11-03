import 'package:flutter/material.dart';

/// Balances a short heading by measuring its display width. The actual Text
/// retains the original string, including emoji, spaces and accessibility text.
class BalancedHeading extends StatelessWidget {
  final String text;
  final TextStyle style;
  const BalancedHeading(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: PaintingBinding.instance.systemFonts,
    builder: (context, _) => LayoutBuilder(builder: (context, bounds) {
    if (!bounds.maxWidth.isFinite || text.isEmpty) {
      return Text(text, style: style);
    }
    final painter = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    painter.layout(maxWidth: bounds.maxWidth);
    final lines = painter.computeLineMetrics().length;
    var width = bounds.maxWidth;
    if (lines == 2) {
      double measure(String value) {
        painter.text = TextSpan(text: value, style: DefaultTextStyle.of(context).style.merge(style));
        painter.layout();
        return painter.width;
      }
      double? preferred;
      for (final space in RegExp(r'\s+').allMatches(text)) {
        final first = measure(text.substring(0, space.start));
        final second = measure(text.substring(space.end));
        // Choose an existing word boundary. A character-balanced midpoint can
        // otherwise turn "카페" into "카 / 페" on Korean screens.
        if (first >= second && first + 2 <= bounds.maxWidth &&
            (preferred == null || first < preferred)) {
          preferred = first;
        }
      }
      if (preferred != null) width = preferred + 2;
    }
    painter.dispose();
    return Align(alignment: AlignmentDirectional.centerStart,
      child: SizedBox(width: width, child: Text(text, style: style)));
  }));
}
