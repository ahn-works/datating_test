import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../ui/oomu_tokens.dart';
import '../ui/oomu_button.dart';
import '../ui/oomu_chip.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import '../services/r2_storage_service.dart';

class CommunityPostCreateScreen extends StatefulWidget {
  final String currentLocation;

  const CommunityPostCreateScreen({
    super.key,
    this.currentLocation = '여수 화장동',
  });

  @override
  State<CommunityPostCreateScreen> createState() =>
      _CommunityPostCreateScreenState();
}

class _CommunityPostCreateScreenState extends State<CommunityPostCreateScreen> {
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
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;

      setState(() => _isUploadingPhoto = true);
      final bytes = await file.readAsBytes();
      String uploadedUrl = '';
      try {
        uploadedUrl = await r2Storage.uploadImageBytes(
          bytes: bytes,
          fileName: file.name,
          category: R2UploadCategory.meetupCover,
        );
      } catch (e) {
        debugPrint('[R2 Storage] Community post photo upload error: $e');
        uploadedUrl = file.path;
      }

      if (mounted) {
        setState(() {
          _selectedPhoto = uploadedUrl.isNotEmpty ? uploadedUrl : file.path;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📸 Cloudflare R2에 사진이 안전하게 등록되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 오류: $e')),
        );
      }
    }
  }

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
    if (Firebase.apps.isEmpty ||
        (FirebaseAuth.instance.currentUser == null &&
            globalData.activeUserId.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 후 글을 등록할 수 있어요. 입력한 내용은 유지돼요.')),
      );
      return;
    }
    final uid = FirebaseAuth.instance.currentUser?.uid ??
        (globalData.activeUserId.isNotEmpty
            ? globalData.activeUserId
            : 'user_${DateTime.now().millisecondsSinceEpoch}');
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
      if (!mounted || generation != globalData.sessionGeneration) {
        return;
      }
      Navigator.pop(context, {...post, 'time': '방금 전'});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('글을 저장하지 못했어요. 입력한 내용을 유지했으니 다시 시도해 주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit =
        !_submitting && _contentController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '취소',
            style: TextStyle(
              color: OomuTokens.textSecondary,
              fontSize: OomuTokens.fs14,
              fontWeight: OomuTokens.w600,
            ),
          ),
        ),
        title: const Text(
          '동네 이야기 쓰기',
          style: TextStyle(
            color: OomuTokens.textPrimary,
            fontSize: OomuTokens.fs16,
            fontWeight: OomuTokens.w700,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(
            OomuTokens.s20,
            OomuTokens.s8,
            OomuTokens.s20,
            MediaQuery.of(context).viewInsets.bottom + OomuTokens.s12,
          ),
          decoration: const BoxDecoration(
            color: OomuTokens.surface,
            border: Border(
              top: BorderSide(color: OomuTokens.border),
            ),
          ),
          child: OomuButton(
            label: _submitting ? '저장 중' : '등록',
            isLoading: _submitting,
            onPressed: canSubmit
                ? () {
                    HapticFeedback.mediumImpact();
                    _submit();
                  }
                : null,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: OomuTokens.s20,
          vertical: OomuTokens.s16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category selector chips
            const Text(
              '카테고리 선택',
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.textSecondary,
              ),
            ),
            const SizedBox(height: OomuTokens.s8),
            Wrap(
              spacing: OomuTokens.s8,
              runSpacing: OomuTokens.s8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return OomuChip(
                  label: cat,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedCategory = cat);
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: OomuTokens.s20),

            // Tag selector chips (Wrap 배치로 화면 밖 넘침 원천 차단)
            const Text(
              '트렌드 태그 선택',
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.textSecondary,
              ),
            ),
            const SizedBox(height: OomuTokens.s8),
            Wrap(
              spacing: OomuTokens.s8,
              runSpacing: OomuTokens.s8,
              children: _tags.map((t) {
                final isSelected = _selectedTag == t;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTag = t);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OomuTokens.s12,
                      vertical: OomuTokens.s8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? OomuTokens.coral
                          : OomuTokens.surfaceMuted,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                    ),
                    child: Text(
                      '#$t',
                      style: TextStyle(
                        fontSize: OomuTokens.fs12,
                        fontWeight: isSelected
                            ? OomuTokens.w700
                            : OomuTokens.w600,
                        color: isSelected
                            ? OomuTokens.surface
                            : OomuTokens.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: OomuTokens.s16),
            const Divider(color: OomuTokens.border, height: 1),
            const SizedBox(height: OomuTokens.s12),

            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: OomuTokens.fs16,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '제목을 입력하세요 (선택)',
                hintStyle: TextStyle(
                  color: OomuTokens.textMuted,
                  fontSize: OomuTokens.fs16,
                  fontWeight: OomuTokens.w600,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: OomuTokens.s8),
            const Divider(color: OomuTokens.border, height: 1),
            const SizedBox(height: OomuTokens.s8),

            // Content Input
            TextField(
              controller: _contentController,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontSize: OomuTokens.fs14,
                color: OomuTokens.textPrimary,
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText:
                    '${widget.currentLocation} 이웃들과 나누고 싶은 공연 후기, 맛집 추천, 동네 질문 등을 자유롭게 적어보세요 :)',
                hintStyle: const TextStyle(
                  color: OomuTokens.textMuted,
                  fontSize: OomuTokens.fs14,
                  height: 1.45,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: OomuTokens.s16),

            // Photo Attachment Section
            const Text(
              '사진 첨부 (선택)',
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                fontWeight: OomuTokens.w700,
                color: OomuTokens.textSecondary,
              ),
            ),
            const SizedBox(height: OomuTokens.s8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedPhoto = null);
                    },
                    child: Container(
                      width: 68,
                      height: 68,
                      margin: const EdgeInsets.only(right: OomuTokens.s8),
                      decoration: BoxDecoration(
                        color: _selectedPhoto == null
                            ? OomuTokens.surfaceMuted
                            : OomuTokens.surface,
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        border: Border.all(
                          color: _selectedPhoto == null
                              ? OomuTokens.coral
                              : OomuTokens.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.not_interested_rounded,
                            size: 20,
                            color: _selectedPhoto == null
                                ? OomuTokens.coral
                                : OomuTokens.textSecondary,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '사진 없음',
                            style: TextStyle(
                              fontSize: OomuTokens.fs11,
                              fontWeight: OomuTokens.w700,
                              color: _selectedPhoto == null
                                  ? OomuTokens.coral
                                  : OomuTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cloudflare R2 직접 사진 촬영/갤러리 선택 타일
                  GestureDetector(
                    onTap: _isUploadingPhoto
                        ? null
                        : () => _pickAndUploadPhoto(ImageSource.gallery),
                    child: Container(
                      width: 68,
                      height: 68,
                      margin: const EdgeInsets.only(right: OomuTokens.s8),
                      decoration: BoxDecoration(
                        color: OomuTokens.surface,
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                        border: Border.all(
                          color: _selectedPhoto != null && !_presetPhotos.contains(_selectedPhoto)
                              ? OomuTokens.coral
                              : OomuTokens.border,
                        ),
                      ),
                      child: _isUploadingPhoto
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: OomuTokens.coral,
                                ),
                              ),
                            )
                          : (_selectedPhoto != null && !_presetPhotos.contains(_selectedPhoto))
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(OomuTokens.r12 - 1),
                                  child: Image(
                                    image: appImg(_selectedPhoto),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 22,
                                      color: OomuTokens.coral,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '내 사진',
                                      style: TextStyle(
                                        fontSize: OomuTokens.fs11,
                                        fontWeight: OomuTokens.w700,
                                        color: OomuTokens.coral,
                                      ),
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
                        margin: const EdgeInsets.only(right: OomuTokens.s8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                          border: Border.all(
                            color: isSel ? OomuTokens.coral : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(OomuTokens.r12 - 2),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image(
                                image: appImg(photoPath),
                                fit: BoxFit.cover,
                              ),
                              if (isSel)
                                Container(
                                  color: OomuTokens.coral.withValues(alpha: 0.3),
                                  child: const Center(
                                    child: Icon(
                                      Icons.check_circle,
                                      color: OomuTokens.surface,
                                      size: 20,
                                    ),
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
