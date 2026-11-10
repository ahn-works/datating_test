import '../utils/oomu_ui_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/kakao_map_service.dart';
import '../widgets/kakao_map_view.dart';
import 'package:flutter/material.dart';
import '../data/oomu_categories.dart';
import '../utils/app_image.dart';
import '../ui/oomu_tokens.dart';
import '../widgets/place_search_map_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/r2_storage_service.dart';
import '../utils/global_data.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_chat_screen.dart';

class OOMUHostScreen extends StatefulWidget {
  final String? sourceEventId;
  final String? sourceEventTitle;
  final String? initialTitle;
  final String? initialLocation;
  final String? initialMainCategory;
  final String? initialSubCategory;
  final String? initialCoverImageUrl;
  final String? initialVibe;
  final double? initialLat;
  final double? initialLng;

  const OOMUHostScreen({
    super.key,
    this.sourceEventId,
    this.sourceEventTitle,
    this.initialTitle,
    this.initialLocation,
    this.initialMainCategory,
    this.initialSubCategory,
    this.initialCoverImageUrl,
    this.initialVibe,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null && widget.initialTitle!.isNotEmpty) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _locationController.text = widget.initialLocation!;
    }
    if (widget.initialMainCategory != null &&
        widget.initialMainCategory!.isNotEmpty) {
      _selectedMainCategory = widget.initialMainCategory!;
    }
    if (widget.initialSubCategory != null &&
        widget.initialSubCategory!.isNotEmpty) {
      _selectedSubCategory = widget.initialSubCategory!;
    }
    if (widget.initialCoverImageUrl != null &&
        widget.initialCoverImageUrl!.isNotEmpty) {
      _coverImageUrl = widget.initialCoverImageUrl!;
    }
    if (widget.initialVibe != null && widget.initialVibe!.isNotEmpty) {
      _selectedVibe = widget.initialVibe!;
    }
    if (widget.initialLat != null && widget.initialLng != null) {
      _selectedPlaceLat = widget.initialLat;
      _selectedPlaceLng = widget.initialLng;
      _selectedPlaceResolvedName = widget.initialLocation?.trim();
    } else if (widget.initialLocation != null &&
        widget.initialLocation!.isNotEmpty) {
      _autoResolveLocation(widget.initialLocation!);
    }
  }

  Future<void> _autoResolveLocation(String query) async {
    try {
      final resolved = await KakaoMapService.resolveVerifiedPlace(query);
      if (resolved != null &&
          mounted &&
          _locationController.text.trim() == query.trim()) {
        setState(() {
          _selectedPlaceLat = resolved.lat;
          _selectedPlaceLng = resolved.lng;
          _selectedPlaceResolvedName = query.trim();
        });
      }
    } catch (_) {}
  }

  double? _selectedPlaceLat;
  double? _selectedPlaceLng;
  String? _selectedPlaceResolvedName;
  final Color textPrimary = OomuTokens.textPrimary;
  final Color textSecondary = OomuTokens.textSecondary;
  final Color surfaceColor = OomuTokens.bgCanvas;
  final Color accentColor = OomuTokens.primary;
  final Color destructiveColor = OomuTokens.error;

  String _selectedMainCategory = '일상 & 푸드';
  String _selectedSubCategory = '동네 맛집 & 소셜 다이닝';
  String _selectedVibe = '소소하게';
  final List<String> _selectedCustomTags = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _memberCount = '2~4명 (2:2 소셜)';
  String _genderLimit = '성별 무관';
  String _ageLimit = '20대~30대';

  bool _isSaving = false;

  void _showBottomSheetPicker(String title, List<String> options,
      String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
        context: context,
        backgroundColor: OomuTokens.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: OomuTokens.divider,
                        borderRadius: BorderRadius.circular(OomuTokens.r2))),
                const SizedBox(height: 24),
                Text(title,
                    style: TextStyle(
                        fontSize: OomuTokens.fs18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary)),
                const SizedBox(height: 16),
                ...options.map((opt) {
                  final isSelected = opt == currentValue;
                  return ListTile(
                    title: Text(opt,
                        style: TextStyle(
                            fontSize: OomuTokens.fs16,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? accentColor : textPrimary)),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: accentColor)
                        : null,
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
                const SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  String _coverImageUrl = 'assets/images/cover_food.jpg';
  final List<Map<String, String>> _coverPresets = const [
    {'label': '🍲 맛집', 'path': 'assets/images/cover_food.jpg'},
    {'label': '☕ 감성카페', 'path': 'assets/images/cover_cafe.jpg'},
    {'label': '🍷 와인바', 'path': 'assets/images/cover_wine.jpg'},
    {'label': '🏃 러닝', 'path': 'assets/images/cover_running.jpg'},
  ];

  void _showCoverImagePickerBottomSheet() {
    final urlController = TextEditingController();
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OomuTokens.surface,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Future<void> pickAndSetCover(ImageSource source) async {
            try {
              final picker = ImagePicker();
              final XFile? file = await picker.pickImage(
                source: source,
                maxWidth: 1280,
                maxHeight: 720,
                imageQuality: 85,
              );
              if (file == null) return;

              if (!R2StorageService.isImageFile(file.name)) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.')),
                  );
                }
                return;
              }

              setSheetState(() => isUploading = true);
              final bytes = await file.readAsBytes();

              String uploadedUrl = '';
              try {
                uploadedUrl = await r2Storage.uploadImageBytes(
                  bytes: bytes,
                  fileName: file.name,
                  category: R2UploadCategory.meetupCover,
                );
              } catch (e) {
                debugPrint('[R2 Storage] Cover upload fallback: $e');
                uploadedUrl = file.path;
              }

              final finalCover =
                  uploadedUrl.isNotEmpty ? uploadedUrl : file.path;
              if (mounted) {
                setState(() => _coverImageUrl = finalCover);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(source == ImageSource.camera
                        ? '📸 카메라로 촬영한 모임 커버 사진이 Cloudflare R2에 등록되었습니다!'
                        : '🖼️ 갤러리에서 선택한 모임 커버 사진이 Cloudflare R2에 등록되었습니다!'),
                    backgroundColor: OomuTokens.primary,
                  ),
                );
              }
            } catch (e) {
              setSheetState(() => isUploading = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('업로드 실패: $e')),
                );
              }
            }
          }

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('커버 사진 선택',
                            style: TextStyle(
                                fontSize: OomuTokens.fs18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: OomuTokens.primarySubtle,
                              borderRadius: BorderRadius.circular(OomuTokens.r6)),
                          child: Text('등록한 모임 사진',
                              style: TextStyle(
                                  color: OomuTokens.primary,
                                  fontSize: OomuTokens.fs11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 1. Primary Action Cards (Camera & Gallery)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: isUploading
                                ? null
                                : () => pickAndSetCover(ImageSource.camera),
                            borderRadius: BorderRadius.circular(OomuTokens.r16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 10),
                              decoration: BoxDecoration(
                                color: OomuTokens.surfaceElevated,
                                borderRadius: BorderRadius.circular(OomuTokens.r16),
                                border: Border.all(
                                    color: OomuTokens.primary
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.photo_camera_rounded,
                                      color: OomuTokens.primary,
                                      size: 24),
                                  const SizedBox(height: 6),
                                  Text('사진 찍기',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: OomuTokens.fs13,
                                          color: textPrimary)),
                                  Text('카메라 촬영',
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs11, color: textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: isUploading
                                ? null
                                : () => pickAndSetCover(ImageSource.gallery),
                            borderRadius: BorderRadius.circular(OomuTokens.r16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 10),
                              decoration: BoxDecoration(
                                color: OomuTokens.mannerYellowBg,
                                borderRadius: BorderRadius.circular(OomuTokens.r16),
                                border: Border.all(
                                    color: OomuTokens.primary
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.photo_library_rounded,
                                      color: OomuTokens.primary,
                                      size: 24),
                                  const SizedBox(height: 6),
                                  Text('사진 불러오기',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: OomuTokens.fs13,
                                          color: textPrimary)),
                                  Text('갤러리 / 앨범',
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs11, color: textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (isUploading) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color:
                              OomuTokens.primarySubtle,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: OomuTokens.primary)),
                            const SizedBox(width: 10),
                            Text('Cloudflare R2 (oomu-spot)에 사진 업로드 중...',
                                style: TextStyle(
                                    color: OomuTokens.primary,
                                    fontSize: OomuTokens.fs12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    Text('또는 추천 프리셋에서 선택',
                        style: TextStyle(
                            fontSize: OomuTokens.fs13,
                            color: textSecondary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.7,
                      children: _coverPresets.map((p) {
                        final selected = _coverImageUrl == p['path'];
                        return GestureDetector(
                          onTap: () {
                            setState(() => _coverImageUrl = p['path']!);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(OomuTokens.r14),
                              border: Border.all(
                                  color: selected
                                      ? accentColor
                                      : Colors.transparent,
                                  width: 3),
                              image: DecorationImage(
                                  image: AssetImage(p['path']!),
                                  fit: BoxFit.cover,
                                  colorFilter: const ColorFilter.mode(
                                      Colors.black26, BlendMode.darken)),
                            ),
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(8),
                            child: Text(p['label']!,
                                style: TextStyle(
                                    color: OomuTokens.surface,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'Cloudflare R2 URL 직접 입력 (https://...)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(OomuTokens.r12)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.check, color: accentColor),
                          onPressed: () {
                            final u = urlController.text.trim();
                            if (u.startsWith('http')) {
                              setState(() => _coverImageUrl = u);
                              Navigator.pop(ctx);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitMeetup() async {
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final title = _titleController.text.trim();
      final locText = _locationController.text.trim();
      double? saveLat = _selectedPlaceLat;
      double? saveLng = _selectedPlaceLng;
      if (saveLat == null ||
          saveLng == null ||
          _selectedPlaceResolvedName != locText) {
        try {
          final verified = await KakaoMapService.resolveVerifiedPlace(locText);
          if (verified != null) {
            saveLat = verified.lat;
            saveLng = verified.lng;
          } else {
            saveLat = null;
            saveLng = null;
          }
        } catch (_) {
          saveLat = null;
          saveLng = null;
        }
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('로그인 후 모임을 열 수 있어요.');
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('meetups').doc();
      final batch = db.batch();
      batch.set(docRef, {
        'title': title,
        'hostUid': user.uid,
        'participantIds': [user.uid],
        if (widget.sourceEventId != null) 'sourceEventId': widget.sourceEventId,
        if (widget.sourceEventTitle != null)
          'sourceEventTitle': widget.sourceEventTitle,
        'description': _descController.text.trim(),
        'location': locText,
        if (saveLat != null && saveLng != null) 'lat': saveLat,
        if (saveLat != null && saveLng != null) 'lng': saveLng,
        'category': _selectedSubCategory,
        'mainCategory': _selectedMainCategory,
        'vibe': _selectedVibe,
        'tags': [
          _selectedMainCategory,
          _selectedSubCategory,
          _selectedVibe,
          ..._selectedCustomTags,
        ],
        'memberCount': _memberCount,
        'genderLimit': _genderLimit,
        'ageLimit': _ageLimit,
        'host': globalData.userNickname.value.isNotEmpty
            ? globalData.userNickname.value
            : '모임 호스트',
        'hostAvatar': globalData.userAvatar.value,
        'imageUrl': _coverImageUrl,
        'photos': [_coverImageUrl],
        'members':
            '1/${RegExp(r'(\d+)').allMatches(_memberCount).map((m) => m.group(1)).lastOrNull ?? '4'}',
        'manner': globalData.temperature.value,
        'mannerTemp': globalData.temperature.value,
        'price': 'N빵',
        'transport': '각자 이동',
        'isFemaleOnly': _genderLimit.toString().contains('여'),
        'date': '일정 협의',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 모임과 채팅방이 함께 저장되어야 개설 직후 실제 대화방에 들어갈 수 있다.
      batch.set(db.collection('chatRooms').doc(docRef.id), {
        'id': docRef.id,
        'title': title,
        'lastMessage': '',
        'hostUid': user.uid,
        'participants': [user.uid],
        'meetupId': docRef.id,
        'location': locText,
        'date': '일정 협의',
        'lastMessageTime': '방금',
        'time': '방금',
        'members': 1,
        'imageUrl': _coverImageUrl,
        'isGroup': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(OomuTokens.r24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration,
                      color: OomuTokens.primary, size: 64),
                  const SizedBox(height: 24),
                  Text('모임이 개설되었습니다!',
                      style: TextStyle(
                          fontSize: OomuTokens.fs20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 12),
                  Text('새로운 사람들과의 만남을 기대해보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textSecondary, fontSize: OomuTokens.fs14)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(OomuTokens.r12))),
                      onPressed: () {
                        Navigator.pop(ctx); // close dialog
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => OOMUChatScreen(
                                      title: title,
                                      memberCount: 1,
                                      chatRoomId: docRef.id,
                                    )));
                      },
                      child: Text('채팅방으로 이동',
                          style: TextStyle(
                              color: OomuTokens.surface,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('모임을 저장하지 못했어요. 잠시 후 다시 시도해 주세요.'),
        ));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        title: Text('새로운 모임 열기',
            style: TextStyle(
                color: textPrimary, fontWeight: FontWeight.w800, fontSize: OomuTokens.fs18)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image (프리셋 선택 / 직접 URL 입력)
            GestureDetector(
              onTap: _showCoverImagePickerBottomSheet,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(OomuTokens.r20),
                  image: DecorationImage(
                    image: appImg(_coverImageUrl),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(
                        Colors.black26, BlendMode.darken),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo, color: OomuTokens.surface, size: 32),
                      const SizedBox(height: 8),
                      Text('커버 사진 변경',
                          style: TextStyle(
                              color: OomuTokens.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: OomuTokens.fs16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Category Selection (대분류 ➔ 중분류 ➔ 추천 소분류 태그 & 분위기)
            Text('어떤 취향의 모임인가요?',
                style: TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 14),

            // 2-1. 대분류 가로 스크롤 카드
            SizedBox(
              height: 94,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: OOMUCategoryData.mainCategories.length,
                itemBuilder: (context, index) {
                  final cat = OOMUCategoryData.mainCategories[index];
                  final isSelected = _selectedMainCategory == cat.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMainCategory = cat.name;
                        _selectedSubCategory = cat.subCategories.first.name;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 96,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? OomuTokens.primarySubtle : OomuTokens.surface,
                        borderRadius: BorderRadius.circular(OomuTokens.r16),
                        border: Border.all(
                          color: isSelected
                              ? OomuTokens.primary
                              : OomuTokens.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.icon, style: TextStyle(fontSize: OomuTokens.fs26)),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? OomuTokens.primary
                                  : textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: OomuTokens.fs12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 2-2. 중분류 선택 칩
            Text('중분류 세부 선택',
                style: TextStyle(
                    fontSize: OomuTokens.fs14,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            _buildHostSubCategoryChips(),
            const SizedBox(height: 18),

            // 2-3. 추천 소분류 예시 태그
            Text('추천 태그 (터치하여 추가/해제)',
                style: TextStyle(
                    fontSize: OomuTokens.fs14,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            _buildHostExampleTagChips(),
            const SizedBox(height: 18),

            // 2-4. 분위기 (지금 내 상황 Vibe)
            Text('모임 분위기 (상황)',
                style: TextStyle(
                    fontSize: OomuTokens.fs14,
                    fontWeight: FontWeight.bold,
                    color: textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OOMUCategoryData.vibes.map((v) {
                final isSelected = _selectedVibe == v.title;
                return ChoiceChip(
                  label: Text('${v.emoji} ${v.title}'),
                  selected: isSelected,
                  selectedColor: OomuTokens.primarySubtle,
                  labelStyle: TextStyle(
                    color: isSelected ? OomuTokens.primary : textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: OomuTokens.fs13,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedVibe = v.title);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // 3. Meetup Info
            Text('모임의 기본 정보',
                style: TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 16),
            _buildTextField('모임 제목', _titleController, '예) 연남동에서 커피 한잔 하실 분!'),
            _buildLocationField(context),
            _buildTextField(
                '상세 소개', _descController, '어떤 사람들과 어떤 시간을 보내고 싶은지 자세히 적어주세요.',
                maxLines: 4),

            const SizedBox(height: 40),

            // 4. Conditions (Toss/Social App Style Settings)
            Text('참여 조건 설정',
                style: TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 16),
            _buildSettingRow('참여 인원', _memberCount, () {
              _showBottomSheetPicker(
                  '참여 인원',
                  ['2~4명 (2:2 소셜)', '4~6명 (3:3 미팅)', '인원 제한 없음'],
                  _memberCount,
                  (val) => setState(() => _memberCount = val));
            }),
            _buildSettingRow('성별 제한', _genderLimit, () {
              _showBottomSheetPicker('성별 제한', ['성별 무관', '여성만', '남성만'],
                  _genderLimit, (val) => setState(() => _genderLimit = val));
            }),
            _buildSettingRow('연령대', _ageLimit, () {
              _showBottomSheetPicker(
                  '연령대',
                  ['연령 무관', '20대만', '30대만', '20대~30대', '30대~40대'],
                  _ageLimit,
                  (val) => setState(() => _ageLimit = val));
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: OomuTokens.surface,
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitMeetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(OomuTokens.r16)),
            ),
            child: _isSaving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: OomuTokens.surface, strokeWidth: 2))
                : Text('새로운 모임 열기',
                    style: TextStyle(
                        fontSize: OomuTokens.fs16,
                        fontWeight: FontWeight.bold,
                        color: OomuTokens.surface)),
          ),
        ),
      ),
    );
  }

  Future<void> _openPlaceSearchModal() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaceSearchMapModal(
        initialQuery: _locationController.text.trim(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      double? lat;
      double? lng;
      try {
        final verified = await KakaoMapService.resolveVerifiedPlace(result);
        if (verified != null) {
          lat = verified.lat;
          lng = verified.lng;
        }
      } catch (_) {}

      setState(() {
        _locationController.text = result;
        _selectedPlaceLat = lat;
        _selectedPlaceLng = lng;
        _selectedPlaceResolvedName =
            (lat != null && lng != null) ? result.trim() : null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lat != null && lng != null
                  ? '📍 \'$result\' 카카오 지도 위치가 지정되었습니다.'
                  : '📍 \'$result\' 장소명이 설정되었습니다.',
            ),
            backgroundColor: OomuTokens.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildLocationField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('모임 장소',
                  style: TextStyle(
                      fontSize: OomuTokens.fs14,
                      fontWeight: FontWeight.bold,
                      color: textSecondary)),
              GestureDetector(
                onTap: _openPlaceSearchModal,
                child: Row(
                  children: [
                    Icon(Icons.search_rounded,
                        size: 16, color: OomuTokens.primary),
                    const SizedBox(width: 4),
                    Text('지도/키워드 검색',
                        style: TextStyle(
                            fontSize: OomuTokens.fs13,
                            color: OomuTokens.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(OomuTokens.r16),
              border: Border.all(color: OomuTokens.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    style: TextStyle(
                        fontSize: OomuTokens.fs15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary),
                    decoration: InputDecoration(
                      hintText: '장소 직접 입력 (예: 스타벅스 홍대점, 맛집)',
                      hintStyle: TextStyle(
                          fontSize: OomuTokens.fs13, color: OomuTokens.textMuted),
                      prefixIcon: Icon(Icons.location_on,
                          color: OomuTokens.primary, size: 22),
                      suffixIcon: _locationController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  size: 18, color: OomuTokens.textMuted),
                              onPressed: () => setState(() {
                                _locationController.clear();
                                _selectedPlaceLat = null;
                                _selectedPlaceLng = null;
                                _selectedPlaceResolvedName = null;
                              }),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                    ),
                    onChanged: (val) => setState(() {
                      if (val.trim() != _selectedPlaceResolvedName) {
                        _selectedPlaceLat = null;
                        _selectedPlaceLng = null;
                        _selectedPlaceResolvedName = null;
                      }
                    }),
                  ),
                ),
                GestureDetector(
                  onTap: _openPlaceSearchModal,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: OomuTokens.primarySubtle,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded,
                            size: 16, color: OomuTokens.primary),
                        const SizedBox(width: 4),
                        Text('지도 선택',
                            style: TextStyle(
                                fontSize: OomuTokens.fs12,
                                fontWeight: FontWeight.bold,
                                color: OomuTokens.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_locationController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_selectedPlaceLat != null && _selectedPlaceLng != null)
              // 1티어 카카오맵 정밀 위치 카드 (불필요한 내비 버튼 배제한 100점 클린 프리뷰)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: OomuTokens.surface,
                  borderRadius: BorderRadius.circular(OomuTokens.r18),
                  border: Border.all(color: OomuTokens.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: OomuTokens.verified.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(OomuTokens.r6),
                              border:
                                  Border.all(color: OomuTokens.verified.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 12, color: OomuTokens.verified),
                                const SizedBox(width: 4),
                                Text(
                                  '카카오 지도 핀 위치 확인됨',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs11,
                                      fontWeight: FontWeight.w700,
                                      color: OomuTokens.verified),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _openPlaceSearchModal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune_rounded,
                                    size: 13, color: OomuTokens.primary),
                                const SizedBox(width: 3),
                                Text(
                                  '위치 변경',
                                  style: TextStyle(
                                      fontSize: OomuTokens.fs12,
                                      fontWeight: FontWeight.bold,
                                      color: OomuTokens.primary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.zero,
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: KakaoMapView(
                          locationName: _locationController.text.trim(),
                          lat: _selectedPlaceLat!,
                          lng: _selectedPlaceLng!,
                          height: 160,
                          hideActions: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.place_rounded,
                              size: 14, color: OomuTokens.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _locationController.text.trim(),
                              style: TextStyle(
                                  fontSize: OomuTokens.fs13,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: OomuTokens.primarySubtle,
                  borderRadius: BorderRadius.circular(OomuTokens.r14),
                  border: Border.all(color: OomuTokens.primaryBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: OomuTokens.primarySubtle,
                        borderRadius: BorderRadius.circular(OomuTokens.r8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.map_rounded,
                          size: 16, color: OomuTokens.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '지도에서 정확한 위치를 지정해 보세요',
                            style: TextStyle(
                                fontSize: OomuTokens.fs13,
                                fontWeight: FontWeight.w700,
                                color: OomuTokens.textPrimary),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '참여 이웃들이 헤매지 않고 쉽게 찾아올 수 있어요.',
                            style: TextStyle(
                                fontSize: OomuTokens.fs11, color: OomuTokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _openPlaceSearchModal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: OomuTokens.primary,
                          borderRadius: BorderRadius.circular(OomuTokens.r8),
                        ),
                        child: Text(
                          '지도 선택',
                          style: TextStyle(
                              fontSize: OomuTokens.fs12,
                              fontWeight: FontWeight.bold,
                              color: OomuTokens.surface),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: OomuTokens.fs14,
                  color: textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(
                color: textPrimary, fontSize: OomuTokens.fs15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: OomuTokens.textMuted,
                  fontSize: OomuTokens.fs15,
                  fontWeight: FontWeight.normal),
              fillColor: surfaceColor,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                  borderSide: BorderSide(color: accentColor, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(OomuTokens.r16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: OomuTokens.fs16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary)),
            Row(
              children: [
                Text(value,
                    style: TextStyle(
                        fontSize: OomuTokens.fs15,
                        fontWeight: FontWeight.w600,
                        color: accentColor)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: textSecondary, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostSubCategoryChips() {
    final mainCat = OOMUCategoryData.mainCategories.firstWhere(
      (m) => m.name == _selectedMainCategory,
      orElse: () => OOMUCategoryData.mainCategories.first,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: mainCat.subCategories.map((sub) {
        final isSelected = _selectedSubCategory == sub.name;
        return ChoiceChip(
          label: Text(sub.name),
          selected: isSelected,
          selectedColor: OomuTokens.primary,
          labelStyle: TextStyle(
            color: isSelected ? OomuTokens.surface : textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: OomuTokens.fs13,
          ),
          onSelected: (val) {
            if (val) setState(() => _selectedSubCategory = sub.name);
          },
        );
      }).toList(),
    );
  }

  Widget _buildHostExampleTagChips() {
    final mainCat = OOMUCategoryData.mainCategories.firstWhere(
      (m) => m.name == _selectedMainCategory,
      orElse: () => OOMUCategoryData.mainCategories.first,
    );

    final currentSub = mainCat.subCategories.firstWhere(
      (s) => s.name == _selectedSubCategory,
      orElse: () => mainCat.subCategories.first,
    );

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: currentSub.exampleTags.map((tag) {
        final isAdded = _selectedCustomTags.contains(tag);
        return ActionChip(
          avatar: Icon(
            isAdded ? Icons.check : Icons.add,
            size: 14,
            color: isAdded ? OomuTokens.surface : textSecondary,
          ),
          label: Text(tag),
          backgroundColor: isAdded ? OomuTokens.textPrimary : OomuTokens.surface,
          side: BorderSide(
              color:
                  isAdded ? OomuTokens.textPrimary : OomuTokens.border),
          labelStyle: TextStyle(
            color: isAdded ? OomuTokens.surface : textPrimary,
            fontSize: OomuTokens.fs12,
            fontWeight: isAdded ? FontWeight.bold : FontWeight.normal,
          ),
          onPressed: () {
            setState(() {
              if (isAdded) {
                _selectedCustomTags.remove(tag);
              } else {
                _selectedCustomTags.add(tag);
              }
            });
          },
        );
      }).toList(),
    );
  }
}
