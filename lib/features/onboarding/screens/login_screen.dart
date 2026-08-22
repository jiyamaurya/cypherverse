import 'package:flutter/material.dart';
    import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:yojana_mitra/core/constants/app_strings.dart';
      
  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    final TextEditingController _phoneController = TextEditingController();
    String? _phoneError;

    // Indian mobile numbers: exactly 10 digits, starting with 6, 7, 8, or 9.
    static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');

    String? _validatePhone(String value) {
      final t = value.trim();
      if (t.isEmpty) return 'मोबाइल नंबर दर्ज करें / Please enter your mobile number';
      if (t.length < 10) return 'नंबर 10 अंकों का होना चाहिए (${t.length}/10) / Number must be 10 digits (${t.length}/10)';
      if (t.length > 10) return 'नंबर केवल 10 अंकों का होना चाहिए / Number must be exactly 10 digits';
      if (!_phoneRegex.hasMatch(t)) return 'मान्य भारतीय नंबर दर्ज करें, 6-9 से शुरू / Enter a valid Indian number starting with 6-9';
      return null;
    }

    bool _validateAndProceed() {
      final error = _validatePhone(_phoneController.text);
      setState(() => _phoneError = error);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: const TextStyle(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFEF6C00),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return false;
      }
      return true;
    }

    @override
    void dispose() {
      _phoneController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── LAYER 1: Background ──
            _RuralBackground(),

            // ── LAYER 2: Gradient overlay ──
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.55, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.10),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.03),
                    Colors.black.withValues(alpha: 0.20),
                  ],
                ),
              ),
            ),

            // ── LAYER 3: Content ──
            SafeArea(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Logo (smaller, no white circle) ──
                    SizedBox(
                      width: 72,
                      height: 58,
                      child: Image.asset('assets/images/app_logo.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 6),

                    // ── App name ──
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B5E20), // dark forest green
                        letterSpacing: 0.3,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),

                    // ── Tagline ──
                    Text(
                      'आपका साथी सरकारी योजनाओं में',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32), // medium forest green
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // ── Glass card (compact) ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.85),
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Welcome heading
                                const Text(
                                  'Swagat hai 👋',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'आइए, सही योजनाओं का लाभ उठाएं',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Phone input (compact) — voice/mic icon removed
                                Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: _phoneError != null
                                          ? Colors.red.shade400
                                          : Colors.grey.shade300,
                                      width: _phoneError != null ? 1.6 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.03),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 12),
                                        child: Icon(
                                          Icons.smartphone_outlined,
                                          color: Color(0xFF9E9E9E),
                                          size: 18,
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 10,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          onChanged: (v) {
                                            if (_phoneError != null) {
                                              setState(() => _phoneError = _validatePhone(v));
                                            }
                                          },
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF212121),
                                          ),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter Mobile Number',
                                            hintStyle: TextStyle(
                                              color: Color(0xFFBDBDBD),
                                              fontSize: 14,
                                            ),
                                            filled: true,
                                            fillColor: Colors.transparent,
                                            counterText: '',
                                            contentPadding: EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 12,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_phoneError != null) ...[
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Row(children: [
                                      Icon(Icons.error_outline, size: 13, color: Colors.red.shade600),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          _phoneError!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],

                                const SizedBox(height: 10),

                                // Get OTP (compact)
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (!_validateAndProceed()) return;
                                      Navigator.pushNamed(
                                        context,
                                        '/profile-setup',
                                        arguments: _phoneController.text.trim(),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF6C00),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 16,
                                        right: 12,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(width: 18),
                                        Text(
                                          'Get OTP',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // OR divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade400,
                                        thickness: 0.8,
                                        endIndent: 8,
                                      ),
                                    ),
                                    Text(
                                      'या',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: Colors.grey.shade400,
                                        thickness: 0.8,
                                        indent: 8,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Login with PIN (compact)
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (!_validateAndProceed()) return;
                                      Navigator.pushNamed(
                                        context,
                                        '/profile-setup',
                                        arguments: _phoneController.text.trim(),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.shield_outlined,
                                      size: 18,
                                      color: Color(0xFF2E7D4F),
                                    ),
                                    label: const Text(
                                      'Login with PIN',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E7D4F),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Security banner (compact)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF43A047,
                                    ).withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_user_outlined,
                                        size: 18,
                                        color: Color(0xFF2E7D4F),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'हम आपका Aadhaar नंबर store नहीं करते',
                                              style: TextStyle(
                                                color: const Color(0xFF1A5C2E),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'आपका डेटा पूरी तरह सुरक्षित है',
                                              style: TextStyle(
                                                color: const Color(0xFF2E7D4F),
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.lock_outline,
                                        size: 14,
                                        color: Color(0xFF2E7D4F),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  RURAL BACKGROUND
  // ══════════════════════════════════════════════════════════════════════
  class _RuralBackground extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      return Image.asset(
        'assets/images/login_bg.png',
        fit: BoxFit.cover,
        alignment: const Alignment(0.0, 0.15),
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(painter: _RuralSunsetPainter(), size: Size.infinite);
        },
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  //  _RuralSunsetPainter
  // ══════════════════════════════════════════════════════════════════════
  class _RuralSunsetPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
      final w = size.width;
      final h = size.height;
      final horizonY = h * 0.50;

      // ── 1. SKY ─────────────────────────────────────────────────────
      final skyPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment(0.0, 0.60),
          colors: const [
            Color(0xFF5D4037),
            Color(0xFF8D6E63),
            Color(0xFFBF360C),
            Color(0xFFE65100),
            Color(0xFFF57C00),
            Color(0xFFFFA000),
            Color(0xFFFFCA28),
            Color(0xFFFFE082),
            Color(0xFFFFF8E1),
          ],
          stops: const [0.0, 0.08, 0.18, 0.30, 0.42, 0.55, 0.68, 0.84, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, horizonY + 50));
      canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY + 50), skyPaint);

      // ── 2. SUN GLOW ────────────────────────────────────────────────
      final sunX = w * 0.55;
      final sunY = horizonY - 2;

      final ambientGlow = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      ambientGlow.color = const Color(0xFFFFE082).withValues(alpha: 0.25);
      canvas.drawCircle(Offset(sunX, sunY), 140, ambientGlow);

      final outerGlow = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
      outerGlow.color = const Color(0xFFFFCC80).withValues(alpha: 0.40);
      canvas.drawCircle(Offset(sunX, sunY), 80, outerGlow);

      final midGlow = Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      midGlow.color = const Color(0xFFFFB74D).withValues(alpha: 0.55);
      canvas.drawCircle(Offset(sunX, sunY), 45, midGlow);

      canvas.drawCircle(
        Offset(sunX, sunY),
        26,
        Paint()..color = const Color(0xFFFFCC02),
      );
      canvas.drawCircle(
        Offset(sunX, sunY),
        16,
        Paint()..color = const Color(0xFFFFEE58),
      );
      canvas.drawCircle(
        Offset(sunX, sunY),
        8,
        Paint()..color = const Color(0xFFFFFDE7),
      );

      // ── 3. DISTANT HILLS ───────────────────────────────────────────
      final backHillPaint = Paint()
        ..color = const Color(0xFF1B5E20).withValues(alpha: 0.50)
        ..style = PaintingStyle.fill;

      final backHill = Path()
        ..moveTo(0, horizonY + 18)
        ..quadraticBezierTo(w * 0.08, horizonY - 12, w * 0.20, horizonY + 2)
        ..quadraticBezierTo(w * 0.30, horizonY - 22, w * 0.45, horizonY - 8)
        ..quadraticBezierTo(w * 0.55, horizonY - 28, w * 0.68, horizonY - 2)
        ..quadraticBezierTo(w * 0.80, horizonY - 15, w * 0.90, horizonY + 6)
        ..quadraticBezierTo(w * 0.96, horizonY - 3, w, horizonY + 12)
        ..lineTo(w, horizonY + 50)
        ..lineTo(0, horizonY + 50)
        ..close();
      canvas.drawPath(backHill, backHillPaint);

      // ── 4. TREELINE ────────────────────────────────────────────────
      final treePaint = Paint()
        ..color = const Color(0xFF1B5E20).withValues(alpha: 0.60)
        ..style = PaintingStyle.fill;

      _drawTree(canvas, treePaint, w * 0.08, horizonY - 4, 12, 20);
      _drawTree(canvas, treePaint, w * 0.16, horizonY + 4, 9, 14);
      _drawTree(canvas, treePaint, w * 0.33, horizonY - 16, 18, 28);
      _drawTree(canvas, treePaint, w * 0.40, horizonY - 10, 14, 22);
      _drawTree(canvas, treePaint, w * 0.68, horizonY - 6, 12, 19);
      _drawTree(canvas, treePaint, w * 0.80, horizonY + 3, 10, 16);
      _drawTree(canvas, treePaint, w * 0.92, horizonY + 7, 8, 12);

      // ── 5. HUTS ────────────────────────────────────────────────────
      final hutPaint = Paint()
        ..color = const Color(0xFF1B5E20).withValues(alpha: 0.65)
        ..style = PaintingStyle.fill;

      _drawHut(canvas, hutPaint, w * 0.24, horizonY + 4, 10, 8);
      _drawHut(canvas, hutPaint, w * 0.78, horizonY + 8, 8, 6);

      // ── 6. FRONT HILL / FIELD ──────────────────────────────────────
      final fieldPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [
            Color(0xFF388E3C),
            Color(0xFF2E7D32),
            Color(0xFF1B5E20),
            Color(0xFF0D3B0F),
          ],
        ).createShader(Rect.fromLTWH(0, horizonY + 8, w, h - horizonY));

      final frontHill = Path()
        ..moveTo(0, horizonY + 22)
        ..quadraticBezierTo(w * 0.15, horizonY + 12, w * 0.35, horizonY + 18)
        ..quadraticBezierTo(w * 0.55, horizonY + 10, w * 0.75, horizonY + 16)
        ..quadraticBezierTo(w * 0.90, horizonY + 12, w, horizonY + 20)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(frontHill, fieldPaint);

      // ── 7. CROP ROWS ───────────────────────────────────────────────
      final cropPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int i = 0; i < 14; i++) {
        final y = horizonY + 30 + i * 14.0;
        final alpha = 0.14 - i * 0.009;
        if (alpha <= 0) break;
        cropPaint.color = const Color(
          0xFF66BB6A,
        ).withValues(alpha: alpha.clamp(0.0, 1.0));
        canvas.drawLine(Offset(w * 0.02, y), Offset(w * 0.98, y + 2), cropPaint);
      }

      // ── 8. FARMER ──────────────────────────────────────────────────
      final farmerPaint = Paint()
        ..color = const Color(0xFF0A1A0A).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      _drawFarmer(canvas, farmerPaint, w * 0.44, horizonY + 24);

      // ── 9. BOTTOM FADE ─────────────────────────────────────────────
      final bottomFade = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, const Color(0xFF0A1A0A).withValues(alpha: 0.30)],
        ).createShader(Rect.fromLTWH(0, h * 0.72, w, h * 0.28));
      canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), bottomFade);
    }

    void _drawTree(
      Canvas canvas,
      Paint paint,
      double x,
      double y,
      double r,
      double trunkH,
    ) {
      canvas.drawCircle(Offset(x, y - trunkH), r.toDouble(), paint);
      canvas.drawCircle(
        Offset(x - r * 0.55, y - trunkH + r * 0.3),
        r * 0.7,
        paint,
      );
      canvas.drawCircle(
        Offset(x + r * 0.55, y - trunkH + r * 0.3),
        r * 0.7,
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y - trunkH * 0.3),
          width: r * 0.3,
          height: trunkH * 0.7,
        ),
        paint,
      );
    }

    void _drawHut(
      Canvas canvas,
      Paint paint,
      double x,
      double y,
      double hw,
      double hh,
    ) {
      canvas.drawRect(Rect.fromLTWH(x - hw / 2, y - hh, hw, hh), paint);
      final roof = Path()
        ..moveTo(x - hw * 0.7, y - hh)
        ..lineTo(x, y - hh - hh * 0.7)
        ..lineTo(x + hw * 0.7, y - hh)
        ..close();
      canvas.drawPath(roof, paint);
    }

    void _drawFarmer(Canvas canvas, Paint paint, double x, double baseY) {
      final p = paint;
      const s = 1.6;

      canvas.drawCircle(Offset(x + 2 * s, baseY - 62 * s), 7 * s, p);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 2 * s, baseY - 70 * s),
          width: 16 * s,
          height: 7 * s,
        ),
        p,
      );
      canvas.drawRect(Rect.fromLTWH(x - 1 * s, baseY - 56 * s, 5 * s, 6 * s), p);

      final torso = Path()
        ..moveTo(x - 8 * s, baseY - 50 * s)
        ..lineTo(x + 10 * s, baseY - 50 * s)
        ..lineTo(x + 8 * s, baseY - 24 * s)
        ..lineTo(x - 6 * s, baseY - 24 * s)
        ..close();
      canvas.drawPath(torso, p);

      final leftArm = Path()
        ..moveTo(x - 8 * s, baseY - 48 * s)
        ..quadraticBezierTo(
          x - 16 * s,
          baseY - 36 * s,
          x - 12 * s,
          baseY - 26 * s,
        )
        ..lineTo(x - 9 * s, baseY - 27 * s)
        ..quadraticBezierTo(x - 13 * s, baseY - 37 * s, x - 5 * s, baseY - 47 * s)
        ..close();
      canvas.drawPath(leftArm, p);

      final rightArm = Path()
        ..moveTo(x + 10 * s, baseY - 48 * s)
        ..quadraticBezierTo(
          x + 18 * s,
          baseY - 36 * s,
          x + 14 * s,
          baseY - 26 * s,
        )
        ..lineTo(x + 11 * s, baseY - 27 * s)
        ..quadraticBezierTo(x + 15 * s, baseY - 37 * s, x + 7 * s, baseY - 47 * s)
        ..close();
      canvas.drawPath(rightArm, p);

      final dhoti = Path()
        ..moveTo(x - 6 * s, baseY - 24 * s)
        ..lineTo(x + 8 * s, baseY - 24 * s)
        ..lineTo(x + 10 * s, baseY)
        ..lineTo(x - 8 * s, baseY)
        ..close();
      canvas.drawPath(dhoti, p);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 8 * s, baseY - 3 * s, 7 * s, 3 * s),
          const Radius.circular(1.5),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 3 * s, baseY - 3 * s, 7 * s, 3 * s),
          const Radius.circular(1.5),
        ),
        p,
      );
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }

  // ══════════════════════════════════════════════════════════════════════
  //  _YojanaMitraLogoPainter — Dark forest green matching target
  // ══════════════════════════════════════════════════════════════════════
  class _YojanaMitraLogoPainter extends CustomPainter {
    static const _fieldGreen = Color(
      0xFF1B5E20,
    ); // dark forest green for field rows
    static const _leafGreen = Color(0xFF2E7D32); // medium forest green for leaves
    static const _sunOrange = Color(0xFFF57C00); // warm orange for sun disc
    static const _rayYellow = Color(0xFFFFA726); // amber for sun rays

    @override
    void paint(Canvas canvas, Size size) {
      final w = size.width;
      final h = size.height;
      final cx = w / 2;

      // ── FIELD ROWS ─────────────────────────────────────────────────
      const rowH = 5.5;
      const rowGap = 3.5;
      final rowPaint = Paint()
        ..color = _fieldGreen
        ..style = PaintingStyle.fill;

      final rowFractions = [1.00, 0.78, 0.58, 0.40];

      for (int i = 0; i < rowFractions.length; i++) {
        final rw = w * rowFractions[i];
        final centerY = h * 0.97 - rowH / 2 - i * (rowH + rowGap);
        final left = cx - rw / 2;
        final right = cx + rw / 2;
        final top = centerY - rowH / 2;
        final bottom = centerY + rowH / 2;

        final wavePath = Path();
        const arcH = 1.5;
        wavePath.moveTo(left, bottom);
        wavePath.lineTo(right, bottom);
        wavePath.lineTo(right, top);
        wavePath.quadraticBezierTo(cx, top - arcH, left, top);
        wavePath.close();

        canvas.save();
        canvas.clipRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(left, top - arcH - 1, right, bottom),
            const Radius.circular(3),
          ),
        );
        canvas.drawPath(wavePath, rowPaint);
        canvas.restore();
      }

      // ── LEAVES ─────────────────────────────────────────────────────
      final fieldTopY = h * 0.97 - rowH / 2 - 3 * (rowH + rowGap) - rowH / 2;

      final leafPaint = Paint()
        ..color = _leafGreen
        ..style = PaintingStyle.fill;

      _drawLeaf(
        canvas,
        leafPaint,
        base: Offset(cx - 10, fieldTopY + 2),
        tilt: -0.52,
        len: 24,
        wid: 10,
      );
      _drawLeaf(
        canvas,
        leafPaint,
        base: Offset(cx + 8, fieldTopY + 2),
        tilt: 0.52,
        len: 20,
        wid: 9,
      );

      // ── SUN ────────────────────────────────────────────────────────
      final sunCx = cx + 5.0;
      final sunCy = fieldTopY - 11;

      const rayDist = 14.0;
      const rayR = 2.0;
      final rayPaint = Paint()..color = _rayYellow;

      for (int i = 0; i < 8; i++) {
        final angle = i * math.pi / 4 - math.pi / 2;
        canvas.drawCircle(
          Offset(
            sunCx + math.cos(angle) * rayDist,
            sunCy + math.sin(angle) * rayDist,
          ),
          rayR,
          rayPaint,
        );
      }

      canvas.drawCircle(Offset(sunCx, sunCy), 9.0, Paint()..color = _sunOrange);
    }

    void _drawLeaf(
      Canvas canvas,
      Paint paint, {
      required Offset base,
      required double tilt,
      required double len,
      required double wid,
    }) {
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(tilt);

      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(wid / 2, -len * 0.25, wid / 2, -len * 0.70, 0, -len)
        ..cubicTo(-wid / 2, -len * 0.70, -wid / 2, -len * 0.25, 0, 0)
        ..close();
      canvas.drawPath(path, paint);

      canvas.drawLine(
        Offset.zero,
        Offset(0, -len),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke,
      );

      canvas.restore();
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
  }