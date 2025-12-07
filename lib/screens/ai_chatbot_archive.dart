// lib/screens/ai_chatbot_archive.dart
import 'package:pbl_b_app/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:pbl_b_app/models/archive.dart';
import 'package:pbl_b_app/models/archive_list.dart';
import 'package:pbl_b_app/models/user_profile.dart';
import 'package:pbl_b_app/screens/chatbot_interact.dart';

class AiChatbotArchivePage extends StatefulWidget {
  final UserProfile profile;
  final HiveService hiveService;

  const AiChatbotArchivePage({
    super.key,
    required this.profile,
    required this.hiveService,
  });

  @override
  State<AiChatbotArchivePage> createState() => _AiChatbotArchivePageState();
}

class _AiChatbotArchivePageState extends State<AiChatbotArchivePage> {
  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final List<Archive> archives = archiveList;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '재난 히스토리',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: archives.isEmpty
          ? const Center(
              child: Text(
                '아직 저장된 재난 히스토리가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ...archives.map(
                    (archiveItem) => _buildArchiveCard(
                      context,
                      archive: archiveItem,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
    );
  }

  Widget _buildArchiveCard(
    BuildContext context, {
    required Archive archive,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            final latestProfile = widget.hiveService.getProfile() ?? widget.profile;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatbotInteract(
                  archive: archive,
                  profile: latestProfile, // 🔥 여기서 프로필 전달
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(archive.created),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _ArchiveChip(
                      text: archive.disasterName,
                      bg: const Color(0xFFFFE9DB),
                      fg: const Color(0xFFEA580C),
                      border: const Color(0xFFFFD2B8),
                    ),
                    _ArchiveChip(
                      text: archive.location,
                      bg: const Color(0xFFF2F4F7),
                      fg: const Color(0xFF475567),
                      border: const Color(0xFFE5E7EB),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  archive.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  archive.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 28,
          top: 10,
          child: GestureDetector(
            onTap: () {
              setState(() {
                archiveList.remove(archive);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 18,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArchiveChip extends StatelessWidget {
  const _ArchiveChip({
    required this.text,
    required this.bg,
    required this.fg,
    required this.border,
  });

  final String text;
  final Color bg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
