// lib/features/splash/presentation/pages/splash_page.dart
//
// Animation sequence:
//   Phase 1 (0–800ms)    — 4 diamond petals fly from corners, assemble X mark
//   Phase 2 (800ms)      — assembled mark pulses once (scale 1→1.09→1)
//   Phase 3 (920ms…)     — "penseMate" chars rise from clip, staggered left→right
//                          "pense" = light-weight / muted, "Mate" = bold / full white
//   Phase 4              — italic gradient slogan slides up from clip
//                          decorative rule lines + dot fade in
//   Phase 5              — loading bar fills with shimmer → navigate to home

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xpensemate/core/localization/localization_extensions.dart';
import 'package:xpensemate/core/theme/theme_context_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Brand colors — hardcoded so splash is theme-independent at startup
// ─────────────────────────────────────────────────────────────────────────────
const _cTL = Color(0xFF25C4C3); // top-left     teal
const _cTR = Color(0xFF2E7692); // top-right    deep ocean
const _cBL = Color(0xFF22D7A4); // bottom-left  mint
const _cBR = Color(0xFF20CE6F); // bottom-right green

const _splashBg    = Color(0xFF0D1F2D);
const _textFull    = Color(0xFFE2F0F0);  // "Mate" — full brightness
const _textMuted   = Color(0xBFE2F0F0);  // "pense" — 75% opacity

// Slogan gradient stops
const _gradBegin = _cTL;
const _gradMid   = _cBL;
const _gradEnd   = _cBR;

// ─────────────────────────────────────────────────────────────────────────────
// SplashPage
// ─────────────────────────────────────────────────────────────────────────────
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  // ── Phase 1: petal fly-in ────────────────────────────────────────────────
  late final AnimationController _petalCtrl;
  late final Animation<Offset> _tlSlide;
  late final Animation<Offset> _trSlide;
  late final Animation<Offset> _blSlide;
  late final Animation<Offset> _brSlide;
  late final Animation<double> _petalFade;

  // ── Phase 2: pulse ────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  // ── Phase 3: wordmark chars — each gets its own controller ────────────────
  // "pense" = indices 0-4, "Mate" = indices 5-8
  static const _word = 'penseMate';
  static const _lightCount = 5; // "pense"
  final List<AnimationController> _charCtrl = [];
  final List<Animation<double>> _charSlide = []; // 0=bottom,1=top
  final List<Animation<double>> _charFade  = [];

  // ── Phase 4: slogan + rule lines ──────────────────────────────────────────
  late final AnimationController _sloganCtrl;
  late final Animation<double> _sloganSlide; // 0=clipped,1=visible
  late final AnimationController _ruleCtrl;
  late final Animation<double> _ruleFade;

  // ── Phase 5: loading ──────────────────────────────────────────────────────
  late final AnimationController _loadingCtrl;
  late final Animation<double> _loadingProgress;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    _setup();
    _run();
  }

  void _setup() {
    // ── Phase 1 ───────────────────────────────────────────────────────────────
    _petalCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    const flyDist = 1.8;
    const flyIn   = Interval(0, 1, curve: Curves.easeOutCubic);

    _tlSlide = Tween<Offset>(begin: const Offset(-flyDist,-flyDist), end: Offset.zero)
        .animate(CurvedAnimation(parent: _petalCtrl, curve: flyIn));
    _trSlide = Tween<Offset>(begin: const Offset(flyDist,-flyDist), end: Offset.zero)
        .animate(CurvedAnimation(parent: _petalCtrl, curve: flyIn));
    _blSlide = Tween<Offset>(begin: const Offset(-flyDist,flyDist), end: Offset.zero)
        .animate(CurvedAnimation(parent: _petalCtrl, curve: flyIn));
    _brSlide = Tween<Offset>(begin: const Offset(flyDist,flyDist), end: Offset.zero)
        .animate(CurvedAnimation(parent: _petalCtrl, curve: flyIn));

    _petalFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _petalCtrl,
        curve: const Interval(0, 0.4, curve: Curves.easeIn),
      ),
    );

    // ── Phase 2 ───────────────────────────────────────────────────────────────
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin:1, end:1.09)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin:1.09, end:1)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_pulseCtrl);

    // ── Phase 3 — per-character clip-rise (380ms each, 55ms stagger) ─────────
    for (var i = 0; i < _word.length; i++) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      );
      _charCtrl.add(c);

      // Slide: 1.1 (below clip) → 0 (in place), with easeOutBack spring
      _charSlide.add(
        Tween<double>(begin: 1.1, end: 0).animate(
          CurvedAnimation(parent: c, curve: Curves.easeOutBack),
        ),
      );

      // Fade: 0→1 in first 25% of duration
      _charFade.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: c,
            curve: const Interval(0, 0.25, curve: Curves.easeIn),
          ),
        ),
      );
    }

    // ── Phase 4 — slogan clip-rise (700ms) ────────────────────────────────────
    _sloganCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _sloganSlide = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _sloganCtrl, curve: Curves.easeOutCubic),
    );

    // Rule lines fade (400ms)
    _ruleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _ruleFade = CurvedAnimation(parent: _ruleCtrl, curve: Curves.easeIn);

    // ── Phase 5 ───────────────────────────────────────────────────────────────
    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _loadingProgress = CurvedAnimation(
      parent: _loadingCtrl,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _run() async {
    // Phase 1 — petals
    await _petalCtrl.forward();

    // Phase 2 — pulse
    await _pulseCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 120));

    // Phase 3 — staggered char rise (fire all with delay, await last)
    if (!mounted) return;
    const stagger = Duration(milliseconds: 55);
    for (var i = 0; i < _word.length; i++) {
      await Future<void>.delayed(stagger);
      if (!mounted) return;
      _charCtrl[i].forward(); // fire and forget — stagger drives timing
    }
    // Wait for the last one to fully finish
    await _charCtrl.last.forward();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    // Phase 4 — slogan
    if (!mounted) return;
    await _sloganCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await _ruleCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 350));

    // Phase 5 — loading
    if (!mounted) return;
    setState(() => _showLoading = true);
    await _loadingCtrl.forward();
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _petalCtrl.dispose();
    _pulseCtrl.dispose();
    _sloganCtrl.dispose();
    _ruleCtrl.dispose();
    _loadingCtrl.dispose();
    for (final c in _charCtrl) c.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: context.secondaryColor.withValues(alpha: 0.4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Brand row: mark + wordmark ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // X mark — pulse wraps whole mark
                  ScaleTransition(
                    scale: _pulse,
                    child: _XLogoMark(
                      tlSlide: _tlSlide,
                      trSlide: _trSlide,
                      blSlide: _blSlide,
                      brSlide: _brSlide,
                      fade: _petalFade,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Wordmark — each char in its own clip container
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: List.generate(_word.length, (i) {
                      final isLight = i < _lightCount;
                      return ClipRect(
                        child: AnimatedBuilder(
                          animation: _charCtrl[i],
                          builder: (_, __) => FractionalTranslation(
                            translation: Offset(0, _charSlide[i].value),
                            child: Opacity(
                              opacity: _charFade[i].value.clamp(0.0, 1.0),
                              child: Text(
                                _word[i],
                                style: GoogleFonts.dmSans(
                                  fontSize: 40,
                                  fontWeight: isLight
                                      ? FontWeight.w300
                                      : FontWeight.w700,
                                  color: isLight ? _textMuted : _textFull,
                                  height: 1.15,
                                  letterSpacing: -0.8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Slogan — italic, gradient, clip-rise ──────────────────
              ClipRect(
                child: AnimatedBuilder(
                  animation: _sloganCtrl,
                  builder: (_, __) => FractionalTranslation(
                    translation: Offset(0, _sloganSlide.value),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [_gradBegin, _gradMid, _gradEnd],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        context.l10n.moto,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.white, // overridden by ShaderMask
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ── Decorative rule row ───────────────────────────────────
              FadeTransition(
                opacity: _ruleFade,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Left rule — fades left→transparent
                    Container(
                      width: 44,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, _cTL],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Centre dot
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cTL,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right rule — fades transparent→right
                    Container(
                      width: 44,
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_cTL, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // ── Loading bar ────────────────────────────────────────────
              if (_showLoading) _LoadingBar(progress: _loadingProgress),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _XLogoMark — v1 geometry kept exactly (rotated diamonds, 3.5px gap)
// ─────────────────────────────────────────────────────────────────────────────
class _XLogoMark extends StatelessWidget {
  const _XLogoMark({
    required this.tlSlide,
    required this.trSlide,
    required this.blSlide,
    required this.brSlide,
    required this.fade,
  });

  final Animation<Offset> tlSlide;
  final Animation<Offset> trSlide;
  final Animation<Offset> blSlide;
  final Animation<Offset> brSlide;
  final Animation<double> fade;

  static const double _cell = 22;
  static const double _gap  = 3.5;
  static const double _size = _cell * 2 + _gap;

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: fade,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            children: [
              Positioned(left:0, top:0,
                child: SlideTransition(position: tlSlide,
                    child: const _DiamondPetal(color: _cTL, size: _cell),),),
              Positioned(right:0, top:0,
                child: SlideTransition(position: trSlide,
                    child: const _DiamondPetal(color: _cTR, size: _cell),),),
              Positioned(left:0, bottom:0,
                child: SlideTransition(position: blSlide,
                    child: const _DiamondPetal(color: _cBL, size: _cell),),),
              Positioned(right:0, bottom:0,
                child: SlideTransition(position: brSlide,
                    child: const _DiamondPetal(color: _cBR, size: _cell),),),
            ],
          ),
        ),
      );
}

class _DiamondPetal extends StatelessWidget {
  const _DiamondPetal({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: 0.785398, // 45°
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.35),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// _LoadingBar
// ─────────────────────────────────────────────────────────────────────────────
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Spaced uppercase label
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              final dots = '.' * ((progress.value * 3).floor() % 4);
              return FadeTransition(
                opacity: progress,
                child: Text(
                  '${context.l10n.loading}$dots',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2.5,
                    color: _cBL, // 28% opacity
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          // 2px thin track with gradient fill + shimmer
          AnimatedBuilder(
            animation: _loadingProgress,
            builder: (_, __) => Container(
              width: 160,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0x12E2F0F0),
                borderRadius: BorderRadius.circular(1),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Gradient fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingProgress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_cTL, _cBL, _cBR],
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  // Shimmer leading edge
                  Positioned(
                    left: (_loadingProgress.value * 160 - 16)
                        .clamp(0.0, 144.0),
                    top: -1,
                    child: Container(
                      width: 16,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.6),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  // Expose the parent's animation so the builder inside can reference it.
  // Dart closures capture `progress` from the constructor — this works fine.
  Animation<double> get _loadingProgress => progress;
}