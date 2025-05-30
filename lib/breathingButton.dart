import 'package:flutter/material.dart';

class BreathingButton extends StatefulWidget {
  final Color borderColor;
  final VoidCallback? onPressed;
  final double? size;
  final bool animate;

  const BreathingButton({
    super.key,
    this.borderColor = const Color(0xFF1E0E62),
    this.onPressed,
    this.size,
    this.animate = true,
  });

  @override
  _BreathingButtonState createState() => _BreathingButtonState();
}

class _BreathingButtonState extends State<BreathingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double get startSize => widget.size ?? 120.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: startSize,
      end: startSize + 10.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BreathingButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 애니메이션 상태 변경 감지
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPressed?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: widget.animate ? _animation.value : startSize,
            height: widget.animate ? _animation.value : startSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.borderColor, // 실시간 색상 반영
                width: 30,
              ),
            ),
          );
        },
      ),
    );
  }
}
