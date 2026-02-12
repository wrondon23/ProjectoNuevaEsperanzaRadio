import 'package:flutter/material.dart';
import 'package:radio_nueva_esperanza/core/constants/app_colors.dart';

class RippleAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimate;
  final double size;

  const RippleAnimation({
    super.key,
    required this.child,
    this.isAnimate = false,
    this.size = 150.0,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isAnimate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant RippleAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimate != oldWidget.isAnimate) {
      if (widget.isAnimate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
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
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (widget.isAnimate) ...[
          _buildRipple(1.0),
          _buildRipple(0.75),
          _buildRipple(0.5),
        ],
        widget.child,
      ],
    );
  }

  Widget _buildRipple(double startValue) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = (_controller.value + startValue) % 1.0;
        final scale = 1.0 + value;
        return Positioned.fill(
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: 1.0 - value, // Fade out as it grows
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.5),
                    width:
                        2, // Constant width, or you can fade width: 2 * (1.0 - value)
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
