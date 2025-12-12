import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

class StampCountPicker extends StatefulWidget {
  const StampCountPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxValue = 12,
    this.title,
    this.helperText,
    this.height = 180,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int maxValue;
  final String? title;
  final String? helperText;
  final double height;

  @override
  State<StampCountPicker> createState() => _StampCountPickerState();
}

class _StampCountPickerState extends State<StampCountPicker> {
  late FixedExtentScrollController _controller;

  int get _effectiveMax => widget.maxValue.clamp(1, 12);

  int get _clampedValue => widget.value.clamp(1, _effectiveMax);

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: _clampedValue - 1);
  }

  @override
  void didUpdateWidget(covariant StampCountPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.maxValue != widget.maxValue) {
      final target = _clampedValue - 1;
      if (_controller.hasClients && _controller.selectedItem != target) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.animateToItem(
            target,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final options = List.generate(_effectiveMax, (index) => index + 1);
    final background = theme.secondaryBackground;
    final fadeHeight = (widget.height - 44) / 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Text(
            widget.title!,
            style: theme.bodyMedium,
          ),
        if (widget.title != null) const SizedBox(height: 8),
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 6,
                color: Color(0x11000000),
              )
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CupertinoPicker(
                scrollController: _controller,
                itemExtent: 44,
                diameterRatio: 1.2,
                useMagnifier: true,
                magnification: 1.08,
                squeeze: 1.05,
                onSelectedItemChanged: (index) =>
                    widget.onChanged(options[index]),
                children: options
                    .map(
                      (value) => Center(
                        child: Text(
                          value == 1 ? '1 stamp' : '$value stamps',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: value == _clampedValue
                                ? theme.primary
                                : theme.secondaryText,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Column(
                    children: [
                      Container(
                        height: fadeHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              background.withOpacity(0.95),
                              background.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.primary,
                            width: 1.4,
                          ),
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      Container(
                        height: fadeHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              background.withOpacity(0.95),
                              background.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: theme.bodySmall,
          ),
        ],
      ],
    );
  }
}
