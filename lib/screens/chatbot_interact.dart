import 'package:flutter/material.dart';
import '../models/archive.dart';

class ChatbotInteract extends StatefulWidget {
  final Archive archive;
  const ChatbotInteract({super.key, required this.archive});

  @override
  State<ChatbotInteract> createState() => _ChatbotInteractState();
}

class _ChatbotInteractState extends State<ChatbotInteract> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _sending = false;
  final List<_ChatMessage> _messages = [];

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    final a = widget.archive;
    _messages.add(
      _ChatMessage.bot(
        '안녕하세요! ${a.disasterName} 관련 안내를 도와드릴게요.\n'
        '• 지역: ${a.location}\n'
        '• 기준일: ${_formatDate(a.created)}\n\n'
        '원하시는 정보를 선택하거나, 아래 입력창에 자유롭게 질문해 주세요',
      ),
    );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.archive;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('재난 챗봇')),
      body: Column(
        children: [
          // 상단 요약 영역
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 텍스트 블럭
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Chip(
                            text: a.disasterName,
                            bg: const Color(0xFFFFE9DB),
                            fg: const Color(0xFFEA580C),
                            border: const Color(0xFFFFD2B8),
                          ),
                          _Chip(
                            text: a.location,
                            bg: const Color(0xFFF2F4F7),
                            fg: const Color(0xFF475567),
                            border: const Color(0xFFE5E7EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(a.created),
                        style: const TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 메시지 리스트
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _ChatBubble(msg: _messages[i]),
            ),
          ),

          // 퀵 액션 버튼들
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickButton(label: '주변 대피로', onTap: () => _onQuickAsk('주변 대피로')),
                _QuickButton(label: '행동강령', onTap: () => _onQuickAsk('행동강령')),
                _QuickButton(label: '실시간 현황', onTap: () => _onQuickAsk('실시간 현황')),
              ],
            ),
          ),

          // 입력바 (분리된 위젯)
          SafeArea(
            top: false,
            child: _InputBar(
              controller: _input,
              sending: _sending,
              onSend: _onSend,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onQuickAsk(String label) async {
    final a = widget.archive;
    final query = switch (label) {
      '주변 대피로' => '[${a.disasterName}] ${a.location} 기준으로 가까운 대피소/대피로를 알려줘. '
          '가능하면 주소·운영시간·연락처·지도 링크(형식: 이름 – 주소 – 운영시간 – 연락처 – 지도URL)를 요약해서.',
      '행동강령' => '[${a.disasterName}] 상황에서 지금(기준일: ${_formatDate(a.created)}) '
          '10분 내로 해야 할 행동 수칙을 단계별로 간단히 알려줘. (응급/일반/교통/전력/통신 포함)',
      '실시간 현황' => '[${a.disasterName}] 관련 실시간 현황을 요약해줘. '
          '(가능하면 공식/공공 데이터 기준, 수치/주의보 단계/예상 변화)',
      _ => '$label에 대해 알려줘.',
    };
    await _sendUserThenGetBot(query);
  }

  Future<void> _onSend() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await _sendUserThenGetBot(text);
  }

  Future<void> _sendUserThenGetBot(String text) async {
    setState(() {
      _messages.add(_ChatMessage.user(text));
      _sending = true;
    });
    _scrollToBottom();

    final reply = await _fakeLLM(text, contextInfo: _contextForLLM());

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage.bot(reply));
      _sending = false;
    });
    _scrollToBottom();
  }

  String _contextForLLM() {
    final a = widget.archive;
    return '컨텍스트:\n'
        '- 재난: ${a.disasterName}\n'
        '- 지역: ${a.location}\n'
        '- 기준일: ${_formatDate(a.created)}\n'
        '- 제목: ${a.title}\n';
  }

  // 데모용 응답
  Future<String> _fakeLLM(String userText, {required String contextInfo}) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (userText.contains('대피') || userText.contains('대피로')) {
      return '가까운 대피 안내(예시)\n'
          '1) ○○구청 대피소 – 서울 ○○구 ○○로 12 – 24시간 – 02-1234-5678 – https://map.example/1\n'
          '2) ○○문화센터 – 서울 ○○구 ○○길 34 – 09:00~22:00 – 02-2345-6789 – https://map.example/2\n'
          '\n※ 실서비스에서는 실제 공공데이터/API 연동으로 갱신됩니다.';
    }
    if (userText.contains('행동') || userText.contains('수칙')) {
      return '즉시 행동 수칙(예시)\n'
          '• 0~10분: 전원/가스 차단, 저지대/지하 피하기\n'
          '• 가족/동료와 위치 공유, 비상연락망 확인\n'
          '• 이동 시 차량보다 도보 우선, 침수 구역 접근 금지';
    }
    if (userText.contains('실시간') || userText.contains('현황')) {
      return '실시간 현황(예시)\n'
          '• 주의보 단계: 호우 주의보\n'
          '• 강수량(1시간): 18mm\n'
          '• 하천 수위: 평시 대비 +0.3m\n'
          '※ 데모 값이며, 실제에선 공공API/센서 연동';
    }
    // 일반 답변
    return '문의하신 내용에 대해 확인했습니다.\n'
        '컨텍스트 요약:\n$contextInfo\n'
        '요청: 「$userText」\n'
        '→ 데모 응답입니다. 실제 서비스에서는 LLM이 문맥에 맞게 상세 답변을 제공합니다.';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const ValueKey('chat_input'),     // ✅ 조합 상태 고정
              controller: controller,
              minLines: 1,
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              enableSuggestions: true,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요…',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF94A3B8)),
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send_rounded),
            label: const Text('전송'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final _ChatMessage msg;

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    final bg = isUser ? const Color(0xFF2563EB) : Colors.white;
    final fg = isUser ? Colors.white : const Color(0xFF0F172A);
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(14),
      topRight: const Radius.circular(14),
      bottomLeft: Radius.circular(isUser ? 14 : 2),
      bottomRight: Radius.circular(isUser ? 2 : 14),
    );

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 560),
          margin: EdgeInsets.only(
            left: isUser ? 60 : 0,
            right: isUser ? 0 : 60,
            top: 6,
            bottom: 6,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            boxShadow: isUser
                ? null
                : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
          ),
          child: Text(msg.text, style: TextStyle(color: fg, fontSize: 14, height: 1.45)),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1D4ED8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.bg, required this.fg, required this.border});
  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;

  _ChatMessage({required this.isUser, required this.text, DateTime? time})
      : time = time ?? DateTime.now();

  factory _ChatMessage.user(String text) => _ChatMessage(isUser: true, text: text);
  factory _ChatMessage.bot(String text) => _ChatMessage(isUser: false, text: text);
}
