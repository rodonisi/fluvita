import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fluvita/utils/layout_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChapterCard extends StatelessWidget {
  final String title;
  final Icon? icon;
  final double progress;
  final Widget coverImage;
  final void Function()? onTap;
  final void Function()? onRead;

  const ChapterCard({
    super.key,
    required this.title,
    this.icon,
    required this.progress,
    required this.coverImage,
    this.onTap,
    this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: coverImage,
                  ),
                  if (progress <= 0)
                    Align(
                      alignment: .topRight,
                      child: Transform.translate(
                        offset: const Offset(20, -20),
                        child: Transform.rotate(
                          angle: math.pi / 4,
                          child: Container(
                            width: 40,
                            height: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  if (onRead != null)
                    Align(
                      alignment: .bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FilledButton.icon(
                          icon: FaIcon(FontAwesomeIcons.bookOpen),
                          label: Text('Read'),
                          onPressed: onRead,
                        ),
                      ),
                    ),
                ],
              ),
            ),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
              ),
            Padding(
              padding: LayoutConstants.smallEdgeInsets,
              child: Row(
                mainAxisSize: .min,
                spacing: LayoutConstants.smallPadding,
                children: [
                  if (icon != null) icon!,
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
