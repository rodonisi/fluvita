import 'package:flutter/material.dart';

class MeasuredWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size>? onSizeMeasured;

  const MeasuredWidget({
    super.key,
    required this.child,
    this.onSizeMeasured,
  });

  @override
  State<MeasuredWidget> createState() => _MeasuredWidgetState();
}

class _MeasuredWidgetState extends State<MeasuredWidget> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _key.currentContext;
          if (context != null && context.size != null) {
            widget.onSizeMeasured?.call(context.size!);
          }
        });
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: _key,
          child: widget.child,
        ), // This triggers notifications on resize
      ),
    );
  }
}
