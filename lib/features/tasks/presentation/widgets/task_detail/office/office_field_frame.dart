import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:balansoved_mobile/features/tasks/presentation/widgets/task_detail/task_styles.dart';

enum OfficeFieldFrameDecorationVariant { card, note }

class OfficeFieldFrame extends StatelessWidget {
  static const double radius = 18;
  static const double _accentStripeWidth = 4;

  final String label;
  final IconData watermarkIcon;
  final Color accentColor;
  final Widget child;
  final bool dense;
  final OfficeFieldFrameDecorationVariant decorationVariant;

  const OfficeFieldFrame({
    super.key,
    required this.label,
    required this.watermarkIcon,
    required this.accentColor,
    required this.child,
    this.dense = false,
    this.decorationVariant = OfficeFieldFrameDecorationVariant.card,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = TaskStyles.dividerColor(
      colorScheme,
    ).withValues(alpha: 0.45);

    final bool isNote =
        decorationVariant == OfficeFieldFrameDecorationVariant.note;
    final baseBg = isNote
        ? (Color.lerp(
                TaskStyles.accentBgColor(colorScheme),
                colorScheme.surface,
                0.86,
              ) ??
              colorScheme.surface)
        : colorScheme.surfaceContainerLowest;

    final accentAlpha = colorScheme.brightness == Brightness.dark ? 0.06 : 0.03;
    final tintedBase = isNote
        ? Color.alphaBlend(accentColor.withValues(alpha: accentAlpha), baseBg)
        : baseBg;
    final background = isNote
        ? tintedBase
        : (Color.lerp(tintedBase, colorScheme.surface, 0.55) ?? tintedBase);
    final watermarkColor = accentColor.withValues(alpha: 0.08);
    final titleColor = accentColor.withValues(
      alpha: colorScheme.brightness == Brightness.dark ? 0.95 : 0.88,
    );
    final labelStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: titleColor,
      height: 1.1,
    );
    final border = Border.all(color: borderColor, width: 1);
    final padding = dense ? 12.0 : 14.0;
    final contentPadding = EdgeInsets.all(padding);

    return SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              if (isNote)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: _accentStripeWidth,
                    color: accentColor.withValues(alpha: 0.55),
                  ),
                ),
              Positioned(
                right: -10,
                top: -10,
                child: Icon(watermarkIcon, size: 58, color: watermarkColor),
              ),
              Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: labelStyle),
                    SizedBox(height: dense ? 8 : 10),
                    child,
                  ],
                ),
              ),
            ],
          ),
        )
        .decorated(
          color: background.withValues(alpha: 0.98),
          border: border,
          borderRadius: BorderRadius.circular(radius),
        )
        .clipRRect(all: radius);
  }
}
