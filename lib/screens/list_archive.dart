import 'package:flutter/material.dart';
import '../models/archive.dart';
import 'chatbot_interact.dart';


class ListArchive extends StatefulWidget {
  const ListArchive({super.key});

  @override
  State<ListArchive> createState() => _ListArchiveState();
}

class _ListArchiveState extends State<ListArchive> {
  // 데모 데이터 삽입 
  final List<Archive> _archives = [
    Archive(
      id: '1',
      disasterName: '침수',
      title: '10분 이내 침수 가능성 높음',
      link: 'assets/disaster_icon/flood_icon.png',
      location: '인천 덕수구',
      created: DateTime(2025, 10, 19, 12, 14),
    ),

    Archive(
      id: '2',
      disasterName: '침수',
      title: '10분 이내 침수 가능성 높음',
      link: 'assets/disaster_icon/flood_icon.png',
      location: '인천 덕수구',
      created: DateTime(2025, 10, 19, 12, 14)
    ),

    Archive(
      id: '3',
      disasterName: '침수',
      title: '10분 이내 침수 가능성 높음',
      link: 'assets/disaster_icon/flood_icon.png',
      location: '인천 덕수구',
      created: DateTime(2025, 10, 19, 12, 14)
    ),

  ];

  String _formatDate(DateTime dt) => '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}  ' '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(title: const Text('재난 히스토리')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _archives.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, int index) {
          final archive = _archives[index];
          return _ArchiveCard(
            archive: archive,
            dateText: _formatDate(archive.created),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatbotInteract(archive : archive),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class _ArchiveCard extends StatelessWidget {
  const _ArchiveCard({
    required this.archive,
    required this.dateText,
    required this.onTap,
  });

  final Archive archive;
  final String dateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical:4),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withOpacity(0.06),
        clipBehavior:  Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical:12 ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Chip(
                            text: archive.disasterName,
                            bg: const Color(0xFFFFE9DB),
                            fg: const Color(0xFFEA580C),
                            border: const Color(0xFFFFD2B8),
                          ),
                        const SizedBox(width: 6),

                      _Chip(
                            text: archive.location,
                            bg: const Color(0xFFF2F4F7),
                            fg: const Color(0xFF475567),
                            border: const Color(0xFFE5E7EB),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        dateText,
                        style:const TextStyle(
                          color:Color(0xFF98A2B3),
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),
                      Text(
                        archive.title,
                        style:const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Color(0xFF101828),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    archive.link,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      color: const Color(0xFFF2F4F7),
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
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


class _Chip extends StatelessWidget {
  const _Chip({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color:border),
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










