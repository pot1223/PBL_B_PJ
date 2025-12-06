import 'package:flutter/material.dart';
import '../models/archive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_profile.dart';  

final Map<String, List<_ChatMessage>> _chatHistory = {};


class ChatbotInteract extends StatefulWidget {
  final Archive archive;
  final UserProfile? profile;   //  프로필은 nullable 로 받기
  
  const ChatbotInteract({
    super.key,
    required this.archive,
    this.profile,               //  선택 파라미터
  });

  @override
  State<ChatbotInteract> createState() => _ChatbotInteractState();
}

class _ChatbotInteractState extends State<ChatbotInteract> {

  String _historyKey() {
    final a = widget.archive;
    // created + disasterName + location 조합으로 키 생성
    return '${a.disasterName}_${a.location}_${a.created.toIso8601String()}';
  }

  void _saveHistory() {
  final key = _historyKey();
  // 리스트 복사해서 저장 (참조 꼬이지 않도록)
  _chatHistory[key] = List<_ChatMessage>.from(_messages);
}



  //채팅창 텍스트 제어 
  final TextEditingController _input = TextEditingController();

  // 채팅 목록 스크롤 
  final ScrollController _scroll = ScrollController();

  bool _sending = false;
  final List<_ChatMessage> _messages = [];

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}  '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';


@override
void initState() {
  super.initState();

  final key = _historyKey();
  final existing = _chatHistory[key];

  if (existing != null && existing.isNotEmpty) {
    // 🔥 기존 히스토리가 있으면 그대로 복구
    _messages.addAll(existing);
    // 웰컴 메시지는 또 안 불러도 됨
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  } else {
    // 처음 들어온 아카이브라면 웰컴 메시지 호출
    _initWelcomeMessage();
  }
}


Future<void> _initWelcomeMessage() async {
  // 첫 진입 시 웰컴 메시지 요청
  setState(() {
    _sending = true; // 선택: 웰컴 생성 중에는 전송 버튼 비활성화
  });

  final reply = await _callLLM(
    '사용자에게 첫 인사/웰컴 메시지를 만들어줘.',
    contextInfo: _contextForLLM(),  
    intent: 'welcome',             
  );

  if (!mounted) return;
  setState(() {
    _messages.add(_ChatMessage.bot(reply));
    _sending = false;
  });
  _saveHistory();
  _scrollToBottom();
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

  // 어떤 버튼인지 → intent 문자열로 구분
  final intent = switch (label) {
    '주변 대피로'   => 'shelter',
    '행동강령'     => 'guideline',
    '실시간 현황'   => 'realtime',
    _              => 'general',
  };

  final query = switch (label) {
    '주변 대피로' => '${a.location} 기준으로 가까운 대피소/대피로를 알려줘. '
        '가능하면 주소·운영시간·연락처·지도 링크(형식: 이름 – 주소 – 운영시간 – 연락처 – 지도URL)를 요약해서.',
    '행동강령' => '${a.disasterName} 상황에서 지금(기준일: ${_formatDate(a.created)}) '
        '10분 내로 해야 할 행동 수칙을 단계별로 간단히 알려줘. (응급/일반/교통/전력/통신 포함)',
    '실시간 현황' => '[${a.disasterName}] 관련 실시간 현황을 요약해줘. '
        '(가능하면 공식/공공 데이터 기준, 수치/주의보 단계/예상 변화)',
    _ => '$label에 대해 알려줘.',
  };

  await _sendUserThenGetBot(query, intent: intent);
}

  Future<void> _onSend() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await _sendUserThenGetBot(text);
  }


  Future<void> _sendUserThenGetBot(String text, {String intent = 'general'}) async {
  setState(() {
    _messages.add(_ChatMessage.user(text));
    _sending = true;
  });
  _saveHistory();  
  _scrollToBottom();

  final reply = await _callLLM(
    text,
    contextInfo: _contextForLLM(),
    intent: intent,
  );

  if (!mounted) return;
  setState(() {
    _messages.add(_ChatMessage.bot(reply));
    _sending = false;
  });
  _saveHistory();  
  _scrollToBottom();
}

  String _contextForLLM() {
  final a = widget.archive;
  final p = widget.profile;

  final buffer = StringBuffer();

  buffer.writeln('컨텍스트:');
  buffer.writeln('- 재난 아카이브 정보:');
  buffer.writeln('  • 재난 유형(disasterName): ${a.disasterName}');
  buffer.writeln('  • 지역(location): ${a.location}');
  buffer.writeln('  • 기준일(created): ${_formatDate(a.created)}');
  buffer.writeln('  • 제목(title): ${a.title}');
  buffer.writeln('  • 설명(description): ${a.description}');

  buffer.writeln('');
  if (p != null) {
    buffer.writeln('- 사용자 프로필 정보(UserProfile):');
    buffer.writeln('  • userId: ${p.userId}');
    buffer.writeln('  • completeness: ${p.completeness}%');
    buffer.writeln('  • hasPets: ${p.hasPets}');
    buffer.writeln('  • livesWithFamily: ${p.livesWithFamily}');
    buffer.writeln('  • hasVehicle: ${p.hasVehicle}');
    buffer.writeln('  • housingTypeCode: ${p.housingTypeCode}');
    if (p.currentLocation != null) {
      final cl = p.currentLocation!;
      buffer.writeln('  • currentLocation: ${cl.toJson()}');  // 간단히 JSON으로
    }
    if (p.interestedAreas.isNotEmpty) {
      buffer.writeln('  • interestedAreas:');
      for (final area in p.interestedAreas) {
        buffer.writeln('    - ${area.toJson()}');
      }
    }
  } else {
    buffer.writeln('- 사용자 프로필: 없음 (기본 안내 제공)');
  }

  buffer.writeln('');
  buffer.writeln('출력 형식: 친근하지만 과하지 않게, 문단/리스트를 적절히 섞어서 한국어로 답변해줘.');

  return buffer.toString();
  }

  Future<String> _callLLM(
    String userText, {
    required String contextInfo,
    String intent = 'general',
  }) async {
    const String endpoint = 'http://10.0.2.2:8000/chat';

    final a = widget.archive;
    final p = widget.profile;  // ✅ 추가

    try {
      final uri = Uri.parse(endpoint);
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          // 1) 사용자의 실제 입력
          'message': userText,

          // 2) 프론트에서 정리한 컨텍스트(문자열)
          'context': contextInfo,

          // 3) intent로 상황 구분 (welcome / general / shelter / guideline / realtime 등)
          'intent': intent,

          // 4) 구조화된 재난 아카이브 정보
          'archive': {
            'disaster_name': a.disasterName,
            'location': a.location,
            'created': a.created.toIso8601String(),
            'description': a.description,
            'title': a.title,
          },

          // 5) 구조화된 사용자 프로필 정보 (nullable)
          'profile': p?.toJson(),
        }),
      );

      if (response.statusCode != 200) {
        return '서버 오류가 발생했습니다. (status: ${response.statusCode})\n${response.body}';
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final reply = json['reply'] as String?;
      if (reply == null || reply.isEmpty) {
        return '서버 응답 파싱 중 오류가 발생했습니다.';
      }
      return reply;
    } catch (e) {
      return '서버에 연결할 수 없습니다: $e';
    }
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