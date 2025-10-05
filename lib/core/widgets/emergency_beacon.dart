import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated emergency beacon (rotating light like a girofar)
class EmergencyBeacon extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final bool isActive;

  const EmergencyBeacon({
    super.key,
    this.size = 60,
    this.color = AppTheme.primaryColor,
    this.duration = const Duration(seconds: 2),
    this.isActive = true,
  });

  @override
  State<EmergencyBeacon> createState() => _EmergencyBeaconState();
}

class _EmergencyBeaconState extends State<EmergencyBeacon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EmergencyBeacon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BeaconPainter(
              rotation: _controller.value * 2 * pi,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class _BeaconPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _BeaconPainter({
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Rotating beam
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(radius, -radius * 0.5)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -pi / 4,
        pi / 2,
        false,
      )
      ..close();

    canvas.drawPath(path, beamPaint);
    canvas.restore();

    // Center light
    final lightPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.3, lightPaint);

    // Pulsing outer ring
    final ringPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.8, ringPaint);
  }

  @override
  bool shouldRepaint(_BeaconPainter oldDelegate) =>
      rotation != oldDelegate.rotation || color != oldDelegate.color;
}

/// Pulsing alert indicator
class PulsingAlert extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;

  const PulsingAlert({
    super.key,
    required this.child,
    this.color = AppTheme.primaryColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<PulsingAlert> createState() => _PulsingAlertState();
}

class _PulsingAlertState extends State<PulsingAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Ripple animation for alert creation
class RippleAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final int rippleCount;

  const RippleAnimation({
    super.key,
    this.color = AppTheme.primaryColor,
    this.size = 200,
    this.rippleCount = 3,
  });

  @override
  State<RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<RippleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RipplePainter(
              progress: _controller.value,
              color: widget.color,
              rippleCount: widget.rippleCount,
            ),
          );
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int rippleCount;

  _RipplePainter({
    required this.progress,
    required this.color,
    required this.rippleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < rippleCount; i++) {
      final rippleProgress =
          (progress + (i / rippleCount)) % 1.0;
      final radius = maxRadius * rippleProgress;
      final opacity = (1.0 - rippleProgress) * 0.6;

      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Sliding warning banner
class WarningBanner extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const WarningBanner({
    super.key,
    required this.message,
    this.icon = Icons.warning_amber_rounded,
    this.backgroundColor = AppTheme.warningColor,
    this.textColor = Colors.white,
  });

  @override
  State<WarningBanner> createState() => _WarningBannerState();
}

class _WarningBannerState extends State<WarningBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(widget.icon, color: widget.textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.message,
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flash effect for critical alerts
class FlashEffect extends StatefulWidget {
  final Widget child;
  final Color flashColor;
  final Duration duration;

  const FlashEffect({
    super.key,
    required this.child,
    this.flashColor = AppTheme.primaryColor,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<FlashEffect> createState() => _FlashEffectState();
}

class _FlashEffectState extends State<FlashEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.flashColor.withOpacity(_animation.value * 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
