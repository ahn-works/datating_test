import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/global_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/oomu_ui_helpers.dart';

class CommunityPostCreateScreen extends StatefulWidget {
  final String currentLocation;

  const CommunityPostCreateScreen({super.key, required this.currentLocation});

  @override
  State<CommunityPostCreateScreen> createState() =>
      _CommunityPostCreateScreenState();
}

class _CommunityPostCreateScreenState extends State<CommunityPostCreateScreen> {
  final Color textPrimary = OomuUiHelpers.textPrimary;
  final Color textSecondary = OomuUiHelpers.textSecondary;
  final Color surfaceColor = OomuUiHelpers.backgroundNeutral;
  final Color coralAccent = const Color(0xFFF25767);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _selectedCategory = '☕ 일상·수다';
  String _selectedTag = '동네토크';
  String? _selectedPhoto;

  final List<String> _categories = [
    '☕ 일상·수다',
    '🎭 공연·핫플',
    '🍰 맛집·카페',
    '❓ 동네질문',
  ];

  final List<String> _tags = [
    '동네토크',
    '스위니토드',
    '두바이쫀득쿠키',
    'TXT월드투어',
    '성수팝업웨이팅',
    '을지로혼술바',
    '마라탕릴레이',
  ];

  final List<String> _presetPhotos = [
    'assets/images/cover_cafe.jpg',
    'assets/images/cover_food.jpg',
    'assets/images/cover_wine.jpg',
    'assets/images/cover_running.jpg',
  ];

  bool _submitting = false;
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final content = _contentController.text.trim();
    if (content.isEmpty) return;
    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 후 글을 등록할 수 있어요. 입력한 내용은 유지돼요.')));
      return;
    }
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final generation = globalData.sessionGeneration;
    final titleInput = _titleController.text.trim();
    final title = titleInput.isEmpty
        ? content.split('\n').first.characters.take(40).toString()
        : titleInput;
    final ref = FirebaseFirestore.instance.collection('community_posts').doc();
    final post = <String, dynamic>{
      'id': ref.id,
      'authorId': uid,
      'title': title,
      'content': content,
      'category': _selectedCategory == '🎭 공연·핫플'
          ? '공연/전시'
          : _selectedCategory == '🍰 맛집·카페'
              ? '맛집/카페'
              : _selectedCategory == '❓ 동네질문'
                  ? '질문/추천'
                  : '동네 토크',
      'tag': _selectedTag,
      'author': globalData.userNickname.value.isEmpty
          ? '이웃'
          : globalData.userNickname.value,
      'authorAvatar': globalData.userAvatar.value,
      'location': widget.currentLocation,
      if (globalData.temperature.value > 0)
        'manner': globalData.temperature.value,
      'likes': 0,
      'likedUserIds': <String>[],
      'comments': 0,
      'image': _selectedPhoto,
      'createdAt': FieldValue.serverTimestamp(),
    };
    setState(() => _submitting = true);
    try {
      await ref.set(post);
      if (!mounted ||
          FirebaseAuth.instance.currentUser?.uid != uid ||
          generation != globalData.sessionGeneration) return;
      Navigator.pop(context, {...post, 'time': '방금 전'});
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('글을 저장하지 못했어요. 입력한 내용을 유지했으니 다시 시도해 주세요.')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        !_submitting && _contentController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            '취소',
            style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          '동네 이야기 쓰기',
          style: TextStyle(
              color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () {
                        HapticFeedback.mediumImpact();
                        _submit();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: coralAccent,
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _submitting ? '저장 중' : '등록',
                  style: TextStyle(
                    color: canSubmit ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selector chips
            Text('카테고리 선택',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFFFF0F2) : surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: isSelected
                                ? coralAccent
                                : const Color(0xFFEAECF0)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? coralAccent : textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            // Tag selector chips
            Text('트렌드 태그 선택',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: _tags.map((t) {
                  final isSelected = _selectedTag == t;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTag = t);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? coralAccent : const Color(0xFFF3EAEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '#$t',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF555555),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFF3EAEB)),
            const SizedBox(height: 10),

            // Title Input
            TextField(
              controller: _titleController,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textPrimary),
              decoration: InputDecoration(
                hintText: '제목을 입력하세요 (선택)',
                hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF3EAEB)),
            const SizedBox(height: 8),

            // Content Input
            TextField(
              controller: _contentController,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
              style: TextStyle(fontSize: 14.5, color: textPrimary, height: 1.5),
              decoration: InputDecoration(
                hintText:
                    '${widget.currentLocation} 이웃들과 나누고 싶은 공연 후기, 맛집 추천, 동네 질문 등을 자유롭게 적어보세요 :)',
                hintStyle: TextStyle(
                    color: textSecondary.withValues(alpha: 0.6),
                    fontSize: 13.5,
                    height: 1.45),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 16),

            // Photo Attachment Section
            Text('사진 첨부 (선택)',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPhoto = null);
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _selectedPhoto == null
                            ? const Color(0xFFFFF0F2)
                            : surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _selectedPhoto == null
                                ? coralAccent
                                : const Color(0xFFEAECF0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.not_interested_rounded,
                              size: 20,
                              color: _selectedPhoto == null
                                  ? coralAccent
                                  : textSecondary),
                          const SizedBox(height: 2),
                          Text(
                            '사진 없음',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _selectedPhoto == null
                                    ? coralAccent
                                    : textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ..._presetPhotos.map((photoPath) {
                    final isSel = _selectedPhoto == photoPath;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPhoto = photoPath),
                      child: Container(
                        width: 68,
                        height: 68,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isSel ? coralAccent : Colors.transparent,
                              width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(photoPath, fit: BoxFit.cover),
                              if (isSel)
                                Container(
                                  color: coralAccent.withValues(alpha: 0.3),
                                  child: const Center(
                                    child: Icon(Icons.check_circle,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
