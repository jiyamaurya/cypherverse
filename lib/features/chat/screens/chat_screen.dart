import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR TOKENS
// ─────────────────────────────────────────────────────────────────────────────
const kDarkGreen  = Color(0xFF1B5E20);
const kMedGreen   = Color(0xFF2E7D32);
const kLightGreen = Color(0xFF43A047);
const kOrange     = Color(0xFFEF6C00);
const kBg         = Color(0xFFF7F6F0);

// ─────────────────────────────────────────────────────────────────────────────
//  CHAT SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedNavIndex = 2;
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _onNavTap(int index) {
    if (index == _selectedNavIndex) return;
    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/schemes');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/documents');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Namaste Ramesh Ji! 🙏\nMain aapka Yojana Mitra AI assistant hoon. Aap mujhse kisi bhi sarkari yojana ke baare mein pooch sakte hain.',
      'textHi': 'नमस्ते रमेश जी! 🙏\nमैं आपका योजना मित्र AI असिस्टेंट हूँ। आप मुझसे किसी भी सरकारी योजना के बारे में पूछ सकते हैं।',
      'isUser': false,
      'time': '8:30 AM',
    },
  ];

  final List<Map<String, dynamic>> _quickReplies = [
    {'icon': Icons.agriculture_outlined, 'text': 'PM-Kisan ki details batao', 'textHi': 'PM-Kisan की जानकारी दें'},
    {'icon': Icons.search_outlined, 'text': 'Mere liye kaunsi yojana hai?', 'textHi': 'मेरे लिए कौन सी योजना है?'},
    {'icon': Icons.description_outlined, 'text': 'Document checklist kya hai?', 'textHi': 'दस्तावेज चेकलिस्ट क्या है?'},
    {'icon': Icons.location_on_outlined, 'text': 'Nearby CSC center dikhao', 'textHi': 'नज़दीकी CSC दिखाएं'},
    {'icon': Icons.currency_rupee_outlined, 'text': 'KCC loan kaise milta hai?', 'textHi': 'KCC लोन कैसे मिलता है?'},
    {'icon': Icons.help_outline, 'text': 'Yojana Mitra kya hai?', 'textHi': 'योजना मित्र क्या है?'},
  ];

  final Map<String, String> _botResponses = {
    'pm-kisan ki details batao': 'PM-Kisan Samman Nidhi Yojana mein ek kisan ko har saal ₹6000 milte hain (₹2000 per qist).\n\n✅ Eligibility: Zameen wale kisan\n✅ Benefit: Direct bank account mein\n✅ Registration: pmkisan.gov.in\n\nAapka naam Ramesh Singh hai aur aap 3 acre zameen ke maalik hain, toh aap **fully eligible** hain!',
    'mere liye kaunsi yojana hai?': 'Aapke profile ke anusaar, aap in yojanaon ke liye eligible hain:\n\n🌾 **PM-Kisan Samman Nidhi** — ₹6000/saal\n🛡️ **PM Fasal Bima Yojana** — Fasal suraksha\n💳 **Kisan Credit Card** — Sasta loan\n🐑 **Pashupalan Vikas Yojana** — Pashu palan sahayata\n\nMain kisi ek ki detail bataoon?',
    'document checklist kya hai?': 'Aapke liye zaroori documents:\n\n✅ Aadhaar Card — Verified\n✅ Bank Passbook — Pending\n✅ Land Record (Khasra) — Verified\n✅ PAN Card — Verified\n⚠️ Income Certificate — Missing\n\nIncome Certificate jaldi upload karein taaki sab yojanaon ka faayda utha sakein.',
    'nearby csc center dikhao': 'Aapke gaon Rampur (Block Sadar) ke paas ye CSC centers hain:\n\n📍 **Rampur CSC Center** — 1.2 km\n   Timing: 10 AM - 5 PM\n📍 **Sadar Block CSC** — 2.5 km\n   Timing: 9 AM - 6 PM\n📍 **Gram Seva Kendra** — 3.8 km\n   Timing: 10 AM - 4 PM\n\nKoi bhi center par jaakar free mein form bharen!',
    'kcc loan kaise milta hai?': 'Kisan Credit Card (KCC) yahan se milta hai:\n\n🏦 **Where:** Aapka bank branch ya CSC center\n📋 **Documents:** Aadhaar, Land Record, Bank Passbook\n💰 **Limit:** ₹3 lakh tak (3% interest)\n⏱️ **Time:** 7-10 din mein approve\n\nAapke paas sab documents hain except Income Certificate. Wo upload karein!',
    'yojana mitra kya hai?': 'Yojana Mitra aapka apna sarkari yojana assistant hai! 🙌\n\n🔍 **Yojana dhundhna** — Aapke liye best schemes\n✅ **Eligibility check** — Kaunsi yojana ke liye eligible hain\n📄 **Documents** — Kya chahiye, kya upload hua\n🗣️ **Voice support** — Hindi mein bol kar poochein\n📲 **Offline mode** — Bina internet kaam kare\n\nSab kuch FREE hai!',
  };

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timeStr =
        '${now.hourOfPeriod == 0 ? now.hour : now.hourOfPeriod}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}';

    setState(() {
      _messages.add({
        'text': text,
        'textHi': text,
        'isUser': true,
        'time': timeStr,
      });
    });

    _msgController.clear();
    _scrollToBottom();
    setState(() => _isTyping = true);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final responseText = _botResponses[text.toLowerCase()] ??
          'Main samajh gaya. Yeh ek acha sawaal hai! Abhi main iski detail nikal raha hoon. Kuch der rukiye...\n\nAap chahen toh **"Mere liye kaunsi yojana hai?"** pooch kar apni eligibility check kar sakte hain.';

      setState(() {
        _isTyping = false;
        _messages.add({
          'text': responseText,
          'textHi': responseText,
          'isUser': false,
          'time': timeStr,
        });
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedNavIndex,
        onTap: _onNavTap,
      ),
      // ── ONE continuous background that always fades fully into kBg,
      // regardless of screen height — fixes the hard "cut line" seen on
      // taller/desktop windows where a fixed-height band ran out of room.
      body: Stack(
        children: [
          // Base flat colour underneath everything
          const Positioned.fill(child: ColoredBox(color: kBg)),

          // Photo fills the WHOLE available area; the gradient stops are
          // fractional (0.0–1.0 of that area) so the fade always completes
          // smoothly no matter how tall the window/device is — no more
          // random hard edge partway down.
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/home_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          kBg.withValues(alpha: 0.35),
                          kBg.withValues(alpha: 0.7),
                          kBg.withValues(alpha: 0.92),
                          kBg,
                        ],
                        stops: const [0.0, 0.22, 0.4, 0.55, 0.7, 0.82],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Foreground content — header, quick replies, messages, input bar —
          // all transparent so the single band above shows through, same as Home.
          Column(
            children: [
              // ── STICKY HEADER — no background of its own now ───────
              _StickyHeader(),

              // ── CHAT AREA ────────────────────────────────────────
              Expanded(
                child: Column(
                  children: [
                    // Quick replies — sits directly on the fading photo
                    SizedBox(
                      height: 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _quickReplies.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final reply = _quickReplies[i];
                          return _QuickReplyChip(
                            icon: reply['icon'] as IconData,
                            text: reply['textHi'] as String,
                            onTap: () => _sendMessage(reply['text'] as String),
                          );
                        },
                      ),
                    ),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length) {
                            return const _TypingBubble();
                          }
                          return _ChatBubble(message: _messages[i]);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ── INPUT BAR ────────────────────────────────────────
              _InputBar(
                controller: _msgController,
                onSend: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STICKY HEADER — identical to Schemes/Documents/Profile headers
// ─────────────────────────────────────────────────────────────────────────────
class _StickyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // No background here anymore — the single photo band now lives one level
    // up in ChatScreen's Stack, behind header + quick replies + messages,
    // exactly like HomeScreen does. This avoids the "double photo" seam.
    return Padding(
      padding: EdgeInsets.only(top: topPadding + 10, left: 16, right: 16, bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 19, color: kDarkGreen),
            ),
          ),
          const SizedBox(width: 12),

          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(color: kMedGreen, width: 2),
              boxShadow: [BoxShadow(color: kMedGreen.withValues(alpha: 0.2), blurRadius: 6)],
            ),
            child: const Icon(Icons.smart_toy, color: kDarkGreen, size: 24),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Yojana Mitra AI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kDarkGreen,
                    shadows: [Shadow(color: Colors.white60, blurRadius: 8)],
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, color: kLightGreen, size: 8),
                    SizedBox(width: 5),
                    Text(
                      'Online — Hindi & English',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: kMedGreen,
                        shadows: [Shadow(color: Colors.white54, blurRadius: 6)],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
            ),
            child: const Row(
              children: [
                Text('हिंदी', style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: kDarkGreen, size: 16),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFBCAAA4),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: kDarkGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  QUICK REPLY CHIP
// ─────────────────────────────────────────────────────────────────────────────


// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//  QUICK REPLY CHIP
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _QuickReplyChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _QuickReplyChip({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kMedGreen.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: kMedGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CHAT BUBBLE
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message['isUser'] as bool;
    final text = message['textHi'] as String;
    final time = message['time'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 34, height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: kDarkGreen, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? kDarkGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isUser ? 0.15 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isUser ? Colors.white : Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.done_all, color: kLightGreen, size: 14),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPING BUBBLE
// ─────────────────────────────────────────────────────────────────────────────
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: kDarkGreen, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TYPING DOTS
// ─────────────────────────────────────────────────────────────────────────────
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              child: Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: kMedGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: const BoxDecoration(
                color: kBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.attach_file_outlined, color: kDarkGreen, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Yojana ke baare mein poochein...',
                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  onSubmitted: onSend,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: kOrange,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kOrange.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.mic, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => onSend(controller.text),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: kDarkGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: kDarkGreen.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  BOTTOM NAV BAR
// ─────────────────────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_filled, 'होम'),
    _NavItem(Icons.description_outlined, Icons.description, 'योजनाएं'),
    _NavItem(Icons.support_agent_outlined, Icons.support_agent, 'चैट'),
    _NavItem(Icons.folder_outlined, Icons.folder, 'दस्तावेज'),
    _NavItem(Icons.person_outline, Icons.person, 'प्रोफ़ाइल'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 15, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final isSelected = selectedIndex == i;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? kDarkGreen : Colors.grey.shade400,
                    size: 26,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? kDarkGreen : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint,
                    height: 3,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(color: kDarkGreen, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}