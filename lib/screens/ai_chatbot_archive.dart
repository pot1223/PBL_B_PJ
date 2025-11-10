import 'package:flutter/material.dart';

import 'package:pbl_b_app/models/archive.dart'; 

import 'package:pbl_b_app/screens/chatbot_interact.dart'; 

class AiChatbotArchivePage extends StatelessWidget {
  const AiChatbotArchivePage({super.key});

  // 3. 날짜 포맷을 위한 헬퍼 함수 (chatbot_interact.dart와 동일하게)
  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {


    final List<Archive> dummyArchives = [
      Archive(
        disasterName: '침수 위험',
        location: '서울특별시 강남구',
        created: DateTime(2025, 11, 10, 14, 15),
        title: '서울특별시 강남구 침수 위험',
        description: 'PBL님이 자주 방문하는 지역에 침수 위험이 발생했어요...',
      ),
      Archive(
        disasterName: '침수 위험',
        location: '서울특별시 서초구',
        created: DateTime(2025, 11, 2, 12, 18),
        title: '서울특별시 서초구 침수 위험',
        description: 'PBL님의 주거 지역에 침수 위험이 발생했어요...',
      ),
      Archive(
        disasterName: '침수 위험',
        location: '서울특별시 마포구',
        created: DateTime(2025, 10, 28, 19, 20),
        title: '서울특별시 마포구 침수 위험',
        description: 'PBL님의 부모님 댁 지역에 침수 위험이 발생했어요...',
      ),
      Archive(
        disasterName: '침수 위험',
        location: '서울특별시 강남구',
        created: DateTime(2025, 10, 1, 21, 13),
        title: '서울특별시 강남구 침수 위험',
        description: 'PBL님이 현재 위치하신 지역에 침수 위험이 발생했어요...',
      ),
    ];

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
      body: SingleChildScrollView(
        child: Column(
          children: [
    
            ...dummyArchives.map((archiveItem) {
              return _buildSurveyCard(
                context,
                archive: archiveItem, 
              );
            }).toList(),
            
            const SizedBox(height: 20.0), 
          ],
        ),
      ),
    );
  }


  Widget _buildSurveyCard(
    BuildContext context, {
    required Archive archive,
  }) {
    return GestureDetector(
      onTap: () {
   
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatbotInteract(archive: archive), 
          ),
        );
      },
      child: Container(
        height: 130.0,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      
            Text(
              _formatDate(archive.created), // 헬퍼 함수로 날짜 포맷
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              archive.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              archive.description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}