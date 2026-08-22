import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yojana_mitra/core/services/explainer_service.dart';

// ─────────────────────────────────────────────────────────────────────────
//  COLOR TOKENS — kept local so this widget can drop into any screen
//  without depending on that screen's private color constants.
// ─────────────────────────────────────────────────────────────────────────
const _eDark = Color(0xFF1B5E20);
const _eMed = Color(0xFF2E7D32);
const _eBg = Color(0xFFF7F6F0);
const _ePurple = Color(0xFF6A1B9A); // visually distinct from primary green CTAs

/// Pill-shaped "Explain Simply" affordance. Use inside chat bubbles, under
/// scheme text blocks — anywhere a farmer might get stuck on wording.
class ExplainButton extends StatelessWidget {
  final String title;
  final String content;
  final ExplainerService? service;
  final bool dense;

  const ExplainButton({
    super.key,
    required this.title,
    required this.content,
    this.service,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'सरल भाषा में समझाएं, Explain this simply',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.selectionClick();
            showExplainerSheet(context, title: title, content: content, service: service);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 36, minWidth: 44),
            padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 12, vertical: dense ? 6 : 8),
            decoration: BoxDecoration(
              color: _ePurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _ePurple.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: dense ? 13 : 15, color: _ePurple),
                SizedBox(width: dense ? 4 : 6),
                Text(
                  'सरल भाषा में / Explain Simply',
                  style: TextStyle(
                    fontSize: dense ? 11 : 12.5,
                    fontWeight: FontWeight.w800,
                    color: _ePurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-only variant — fits neatly inside section-card headers where
/// space is tight.
class ExplainIconButton extends StatelessWidget {
  final String title;
  final String content;
  final ExplainerService? service;

  const ExplainIconButton({
    super.key,
    required this.title,
    required this.content,
    this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title — सरल भाषा में समझाएं, Explain simply',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            showExplainerSheet(context, title: title, content: content, service: service);
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _ePurple.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 17, color: _ePurple),
          ),
        ),
      ),
    );
  }
}

/// Opens the Explainer as a draggable bottom sheet. Call this directly if
/// you need a custom trigger instead of [ExplainButton]/[ExplainIconButton].
Future<void> showExplainerSheet(
  BuildContext context, {
  required String title,
  required String content,
  ExplainerService? service,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => _ExplainerSheet(
      title: title,
      content: content,
      service: service ?? defaultExplainerService,
    ),
  );
}

enum _ExplainState { loading, success, error }

class _ExplainerSheet extends StatefulWidget {
  final String title;
  final String content;
  final ExplainerService service;
  const _ExplainerSheet({required this.title, required this.content, required this.service});

  @override
  State<_ExplainerSheet> createState() => _ExplainerSheetState();
}

class _ExplainerSheetState extends State<_ExplainerSheet> {
  ExplainerLanguage _lang = ExplainerLanguage.hindi;
  _ExplainState _state = _ExplainState.loading;
  String _result = '';
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = _ExplainState.loading);
    try {
      final res = await widget.service.explain(content: widget.content, language: _lang);
      if (!mounted) return;
      setState(() {
        _result = res;
        _state = _ExplainState.success;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMsg = _lang == ExplainerLanguage.hindi
            ? 'समझाने में दिक्कत आई। दोबारा कोशिश करें।'
            : 'Something went wrong. Please try again.';
        _state = _ExplainState.error;
      });
    }
  }

  void _switchLang(ExplainerLanguage lang) {
    if (lang == _lang) return;
    setState(() => _lang = lang);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(3)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: _ePurple.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome_rounded, color: _ePurple, size: 19),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'सरल व्याख्या / Simple Explanation',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _eDark),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'बंद करें, Close',
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        iconSize: 22,
                        color: Colors.grey.shade600,
                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _LangToggle(
                        label: 'हिंदी',
                        selected: _lang == ExplainerLanguage.hindi,
                        onTap: () => _switchLang(ExplainerLanguage.hindi),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _LangToggle(
                        label: 'English',
                        selected: _lang == ExplainerLanguage.english,
                        onTap: () => _switchLang(ExplainerLanguage.english),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 24),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _ExplainState.loading:
        return const _LoadingState();
      case _ExplainState.error:
        return _ErrorState(message: _errorMsg, onRetry: _load);
      case _ExplainState.success:
        return _ResultState(text: _result);
    }
  }
}

class _LangToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _eDark : _eBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selected ? _eDark : Colors.grey.shade300),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(strokeWidth: 3, color: _ePurple),
          ),
          const SizedBox(height: 16),
          Text(
            'सरल भाषा में तैयार कर रहे हैं…',
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text('Preparing a simple explanation…', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFC62828), size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
              label: const Text(
                'दोबारा कोशिश करें / Retry',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _eDark,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultState extends StatefulWidget {
  final String text;
  const _ResultState({required this.text});

  @override
  State<_ResultState> createState() => _ResultStateState();
}

class _ResultStateState extends State<_ResultState> {
  int? _feedback; // 1 = helpful, 0 = not helpful

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _eBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SelectableText(
            widget.text,
            style: const TextStyle(fontSize: 14.5, height: 1.65, color: Colors.black87, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'क्या यह मददगार था?',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            _FeedbackIcon(
              icon: Icons.thumb_up_alt_outlined,
              activeIcon: Icons.thumb_up_alt_rounded,
              active: _feedback == 1,
              label: 'मददगार, Helpful',
              onTap: () => setState(() => _feedback = 1),
            ),
            const SizedBox(width: 6),
            _FeedbackIcon(
              icon: Icons.thumb_down_alt_outlined,
              activeIcon: Icons.thumb_down_alt_rounded,
              active: _feedback == 0,
              label: 'मददगार नहीं, Not helpful',
              onTap: () => setState(() => _feedback = 0),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeedbackIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool active;
  final String label;
  final VoidCallback onTap;
  const _FeedbackIcon({
    required this.icon,
    required this.activeIcon,
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? _eMed.withValues(alpha: 0.12) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(active ? activeIcon : icon, size: 18, color: active ? _eMed : Colors.grey.shade500),
        ),
      ),
    );
  }
}