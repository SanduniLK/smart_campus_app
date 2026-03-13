import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientSignInButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;
  final double borderRadius;
  final List<Color>? customColors;

  const GradientSignInButton({
    super.key,
    required this.onPressed,
    this.text = 'Sign In',
    this.height = 55,
    this.borderRadius = 16,
    this.customColors,
  });

  @override
  State<GradientSignInButton> createState() => _GradientSignInButtonState();
}

class _GradientSignInButtonState extends State<GradientSignInButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> get _defaultColors => const [
    Color(0xFF000000), // Black
    Color(0xFFE91E63), // Pink
    Color(0xFFFFC107), // Yellow
    Color(0xFFF06292), // Rose Pink
    Color(0xFF000000), // Back to Black
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: SweepGradient(
              colors: widget.customColors ?? _defaultColors,
              stops: const [0.0, 0.3, 0.6, 0.9, 1.0],
              center: Alignment.center,
              startAngle: _animation.value * 2 * 3.14159,
              endAngle: (_animation.value * 2 * 3.14159) + 3.14159 * 2,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.transparent,
              child: Center(
                child: Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
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