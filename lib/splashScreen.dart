import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class VirAshatSplashScreen extends StatefulWidget {
  const VirAshatSplashScreen({Key? key}) : super(key: key);

  @override
  State<VirAshatSplashScreen> createState() => _VirAshatSplashScreenState();
}

class _VirAshatSplashScreenState extends State<VirAshatSplashScreen>
    with TickerProviderStateMixin {
  // Logo animation
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // Text animation
  late AnimationController _textController;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<Offset> _subtitleSlide;

  // Tagline animation
  late AnimationController _taglineController;
  late Animation<double> _taglineFade;

  // Spin animation (logo rotation during scale-in)
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  // Shimmer / ring pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // Bottom loader
  late AnimationController _loaderController;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // ── Logo ──────────────────────────────────────────────
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.18, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );

    // ── Text (title + subtitle) ───────────────────────────
    _textController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.35, 1.0, curve: Curves.easeOut)),
    );
    _subtitleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic)),
    );

    // ── Tagline ───────────────────────────────────────────
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    // ── Spin (synced with logo scale) ─────────────────────
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    // ── Pulse ring ────────────────────────────────────────
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat();
    _pulseScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.28, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    // ── Bottom loader ─────────────────────────────────────
    _loaderController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    // ── Sequence ──────────────────────────────────────────
    Future.delayed(const Duration(milliseconds: 120), () {
      _logoController.forward();
      _spinController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1900), () {
      _taglineController.forward();
    });

    // Navigate
    Future.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) context.go('/webview');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _spinController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _pulseController.dispose();
    _loaderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      body: Stack(
        children: [
          // ── Deep radial glow behind logo ─────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _logoFade,
              builder: (_, __) => Opacity(
                opacity: (_logoFade.value * 0.55).clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.12),
                      radius: 0.72,
                      colors: [
                        Color(0x5500C49A), // teal glow
                        Color(0x221A7CCC), // blue glow
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle grid pattern ───────────────────────────
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // ── Main content ──────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo with pulse ring ──────────────────
                AnimatedBuilder(
                  animation: Listenable.merge([_logoController, _pulseController, _spinController]),
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: SizedBox(
                          width: 148,
                          height: 148,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse ring
                              Opacity(
                                opacity: _pulseOpacity.value,
                                child: Transform.scale(
                                  scale: _pulseScale.value,
                                  child: Container(
                                    width: 148,
                                    height: 148,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF00C49A),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Logo glass card with spinning logo inside
                              Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF111827),
                                  border: Border.all(
                                    color: const Color(0xFF1E2D45),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00C49A).withOpacity(0.22),
                                      blurRadius: 32,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF1A7CCC).withOpacity(0.18),
                                      blurRadius: 48,
                                      spreadRadius: 4,
                                    ),
                                    const BoxShadow(
                                      color: Color(0x44000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    // Spin the logo image itself (not the circle)
                                    child: RotationTransition(
                                      turns: _spinAnimation,
                                      child: Image.asset(
                                        'lib/BiharSHayata LOG.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── App name ──────────────────────────────
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFB8D4F0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            'Bihar Sahayata',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.6,
                              height: 1.1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Subtitle badge
                        FadeTransition(
                          opacity: _subtitleFade,
                          child: SlideTransition(
                            position: _subtitleSlide,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF00C49A).withOpacity(0.35),
                                  width: 1,
                                ),
                                color: const Color(0xFF00C49A).withOpacity(0.08),
                              ),
                              child: const Text(
                                'Emergency Response Platform',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF00C49A),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Tagline ───────────────────────────────
                FadeTransition(
                  opacity: _taglineFade,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Intelligent Disaster Coordination\nwhen every second matters',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.42),
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom: powered by + dots loader ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: Column(
                    children: [
                      // Animated dots loader
                      AnimatedBuilder(
                        animation: _loaderController,
                        builder: (_, __) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              final phase = (_loaderController.value - i * 0.18).clamp(0.0, 1.0);
                              final opacity = (phase < 0.5
                                      ? phase * 2
                                      : (1.0 - phase) * 2)
                                  .clamp(0.25, 1.0);
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF00C49A).withOpacity(opacity),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // Powered by
                      Text(
                        'Government of Bihar  ·  Disaster Management Dept.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.25),
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle dot-grid background painter ──────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 28.0;
    final paint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}