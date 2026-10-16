import 'package:flutter/material.dart';
import '../data/oomu_categories.dart';
import '../utils/app_image.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/interactive_map_popup.dart';
import '../widgets/place_search_map_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/r2_storage_service.dart';
import '../utils/global_data.dart';
import 'soso_car_home_screen.dart';
import 'soso_car_chat_screen.dart';

class OOMUHostScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialLocation;
  final String? initialMainCategory;
  final String? initialSubCategory;
  final String? initialCoverImageUrl;
  final String? initialVibe;

  const OOMUHostScreen({
    super.key,
    this.initialTitle,
    this.initialLocation,
    this.initialMainCategory,
    this.initialSubCategory,
    this.initialCoverImageUrl,
    this.initialVibe,
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
    if (widget.initialMainCategory != null && widget.initialMainCategory!.isNotEmpty) {
      _selectedMainCategory = widget.initialMainCategory!;
    }
    if (widget.initialSubCategory != null && widget.initialSubCategory!.isNotEmpty) {
      _selectedSubCategory = widget.initialSubCategory!;
    }
    if (widget.initialCoverImageUrl != null && widget.initialCoverImageUrl!.isNotEmpty) {
      _coverImageUrl = widget.initialCoverImageUrl!;
    }
    if (widget.initialVibe != null && widget.initialVibe!.isNotEmpty) {
      _selectedVibe = widget.initialVibe!;
    }
  }

  final Color textPrimary = const Color(0xFF111111);
  final Color textSecondary = const Color(0xFF767676);
  final Color surfaceColor = const Color(0xFFF5F5F7);
  final Color accentColor = const Color(0xFFF19E39);
  final Color destructiveColor = const Color(0xFFFF3B30);

  String _selectedMainCategory = '일상 & 푸드';
  String _selectedSubCategory = '동네 맛집 & 소셜 다이닝';
  String _selectedVibe = '소소하게';
  final List<String> _selectedCustomTags = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  String _memberCount = '2~4명';
  String _genderLimit = '성별 무관';
  String _ageLimit = '20대~30대';

  final List<Map<String, dynamic>> _categories = [
    {'name': '맛집/카페', 'icon': Icons.restaurant},
    {'name': '술/친목', 'icon': Icons.local_bar},
    {'name': '문화/전시', 'icon': Icons.palette},
    {'name': '러닝/운동', 'icon': Icons.directions_run},
    {'name': '드라이브', 'icon': Icons.directions_car},
    {'name': '스터디', 'icon': Icons.menu_book},
  ];

  bool _isSaving = false;

  void _showBottomSheetPicker(String title, List<String> options, String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFEBEBEF), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              const SizedBox(height: 16),
              ...options.map((opt) {
                final isSelected = opt == currentValue;
                return ListTile(
                  title: Text(opt, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? accentColor : textPrimary)),
                  trailing: isSelected ? Icon(Icons.check_circle, color: accentColor) : null,
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
      }
    );
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    const SnackBar(content: Text('⚠️ 사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.')),
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

              final finalCover = uploadedUrl.isNotEmpty ? uploadedUrl : file.path;
              if (mounted) {
                setState(() => _coverImageUrl = finalCover);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(source == ImageSource.camera
                        ? '📸 카메라로 촬영한 모임 커버 사진이 Cloudflare R2에 등록되었습니다!'
                        : '🖼️ 갤러리에서 선택한 모임 커버 사진이 Cloudflare R2에 등록되었습니다!'),
                    backgroundColor: const Color(0xFFF38020),
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
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('커버 사진 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF38020).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                          child: const Text('R2 oomu-spot 연동', style: TextStyle(color: Color(0xFFF38020), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                  // 1. Primary Action Cards (Camera & Gallery)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: isUploading ? null : () => pickAndSetCover(ImageSource.camera),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5F0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFF5E36).withOpacity(0.35)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.photo_camera_rounded, color: Color(0xFFFF5E36), size: 24),
                                const SizedBox(height: 6),
                                const Text('사진 찍기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF111111))),
                                Text('카메라 촬영', style: TextStyle(fontSize: 11, color: textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: isUploading ? null : () => pickAndSetCover(ImageSource.gallery),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7EE),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF38020).withOpacity(0.35)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.photo_library_rounded, color: Color(0xFFF38020), size: 24),
                                const SizedBox(height: 6),
                                const Text('사진 불러오기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF111111))),
                                Text('갤러리 / 앨범', style: TextStyle(fontSize: 11, color: textSecondary)),
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
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF38020).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF38020))),
                          SizedBox(width: 10),
                          Text('Cloudflare R2 (oomu-spot)에 사진 업로드 중...', style: TextStyle(color: Color(0xFFF38020), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Text('또는 추천 프리셋에서 선택', style: TextStyle(fontSize: 13, color: textSecondary, fontWeight: FontWeight.w600)),
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
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: selected ? accentColor : Colors.transparent, width: 3),
                            image: DecorationImage(image: AssetImage(p['path']!), fit: BoxFit.cover, colorFilter: const ColorFilter.mode(Colors.black26, BlendMode.darken)),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(8),
                          child: Text(p['label']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: 'Cloudflare R2 URL 직접 입력 (https://...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    if (_titleController.text.trim().isEmpty || _descController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('필수 정보를 모두 입력해주세요.')));
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final title = _titleController.text.trim();
      final docRef = await FirebaseFirestore.instance.collection('meetups').add({
        'title': title,
        'description': _descController.text.trim(),
        'location': _locationController.text.trim(),
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
        'host': globalData.userNickname.value.isNotEmpty ? globalData.userNickname.value : '매운맛킬러',
        'hostAvatar': globalData.userAvatar.value,
        'imageUrl': _coverImageUrl,
        'photos': [_coverImageUrl],
        'members': '1/${RegExp(r'(\d+)').allMatches(_memberCount).map((m) => m.group(1)).lastOrNull ?? '4'}',
        'manner': globalData.temperature.value,
        'price': 'N빵',
        'transport': '각자 이동',
        'isFemaleOnly': _genderLimit.toString().contains('여'),
        'date': '일정 협의',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 신규 모임용 실시간 채팅방 Firestore 생성
      try {
        await FirebaseFirestore.instance.collection('chatRooms').doc(docRef.id).set({
          'id': docRef.id,
          'title': title,
          'lastMessage': '$title 모임 대화방이 개설되었습니다. 🎉',
          'lastMessageTime': '방금',
          'time': '방금',
          'members': 1,
          'imageUrl': _coverImageUrl,
          'isGroup': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Chat room init note: $e');
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: Color(0xFFF19E39), size: 64),
                  const SizedBox(height: 24),
                  Text('모임이 개설되었습니다!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 12),
                  Text('새로운 사람들과의 만남을 기대해보세요.', textAlign: TextAlign.center, style: TextStyle(color: textSecondary, fontSize: 14)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () {
                        Navigator.pop(ctx); // close dialog
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => OOMUChatScreen(
                          title: title, 
                          memberCount: 1,
                          chatRoomId: docRef.id,
                        )));
                      },
                      child: const Text('채팅방으로 이동', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('새로운 모임 열기', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
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
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: appImg(_coverImageUrl),
                    fit: BoxFit.cover,
                    colorFilter: const ColorFilter.mode(Colors.black26, BlendMode.darken),
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo, color: Colors.white, size: 32),
                      SizedBox(height: 8),
                      Text('커버 사진 변경', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Category Selection (대분류 ➔ 중분류 ➔ 추천 소분류 태그 & 분위기)
            Text('어떤 취향의 모임인가요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
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
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFFF0EB) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF5E36) : const Color(0xFFEBEBEF),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(cat.icon, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFFF5E36) : textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 12,
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
            Text('중분류 세부 선택', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
            const SizedBox(height: 8),
            _buildHostSubCategoryChips(),
            const SizedBox(height: 18),

            // 2-3. 추천 소분류 예시 태그
            Text('추천 태그 (터치하여 추가/해제)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
            const SizedBox(height: 8),
            _buildHostExampleTagChips(),
            const SizedBox(height: 18),

            // 2-4. 분위기 (지금 내 상황 Vibe)
            Text('모임 분위기 (상황)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: OOMUCategoryData.vibes.map((v) {
                final isSelected = _selectedVibe == v.title;
                return ChoiceChip(
                  label: Text('${v.emoji} ${v.title}'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFFECE5),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFFF5E36) : textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedVibe = v.title);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // 3. Meetup Info
            Text('모임의 기본 정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 16),
            _buildTextField('모임 제목', _titleController, '예) 연남동에서 커피 한잔 하실 분!'),
                        _buildLocationField(context),
            _buildTextField('상세 소개', _descController, '어떤 사람들과 어떤 시간을 보내고 싶은지 자세히 적어주세요.', maxLines: 4),
            
            const SizedBox(height: 40),

            // 4. Conditions (Toss/Social App Style Settings)
            Text('참여 조건 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary)),
            const SizedBox(height: 16),
            _buildSettingRow('참여 인원', _memberCount, () {
              _showBottomSheetPicker('참여 인원', ['2명 (1:1)', '2~4명', '3~6명', '인원 제한 없음'], _memberCount, (val) => setState(() => _memberCount = val));
            }),
            _buildSettingRow('성별 제한', _genderLimit, () {
              _showBottomSheetPicker('성별 제한', ['성별 무관', '여성만', '남성만'], _genderLimit, (val) => setState(() => _genderLimit = val));
            }),
            _buildSettingRow('연령대', _ageLimit, () {
              _showBottomSheetPicker('연령대', ['연령 무관', '20대만', '30대만', '20대~30대', '30대~40대'], _ageLimit, (val) => setState(() => _ageLimit = val));
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _submitMeetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('새로운 모임 열기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
      setState(() {
        _locationController.text = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📍 \'$result\' (으)로 모임 장소가 설정되었습니다.'),
          backgroundColor: const Color(0xFFFF5E36),
          duration: const Duration(seconds: 2),
        ),
      );
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
              Text('모임 장소', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textSecondary)),
              GestureDetector(
                onTap: _openPlaceSearchModal,
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, size: 16, color: Color(0xFFFF5E36)),
                    SizedBox(width: 4),
                    Text('지도/키워드 검색', style: TextStyle(fontSize: 13, color: Color(0xFFFF5E36), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5EA)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary),
                    decoration: InputDecoration(
                      hintText: '장소 직접 입력 (예: 스타벅스 홍대점, 맛집)',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E9EA7)),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFF5E36), size: 22),
                      suffixIcon: _locationController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              onPressed: () => setState(() => _locationController.clear()),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                GestureDetector(
                  onTap: _openPlaceSearchModal,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded, size: 16, color: Color(0xFFFF5E36)),
                        SizedBox(width: 4),
                        Text('지도 선택', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF5E36))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: textSecondary)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFFC7C7CC), fontSize: 15, fontWeight: FontWeight.normal),
              fillColor: surfaceColor,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: accentColor, width: 1.5)),
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
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
            Row(
              children: [
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: accentColor)),
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
          selectedColor: const Color(0xFFFF5E36),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
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
            color: isAdded ? Colors.white : textSecondary,
          ),
          label: Text(tag),
          backgroundColor: isAdded ? const Color(0xFF1E1E24) : Colors.white,
          side: BorderSide(color: isAdded ? const Color(0xFF1E1E24) : const Color(0xFFE5E5EA)),
          labelStyle: TextStyle(
            color: isAdded ? Colors.white : textPrimary,
            fontSize: 12,
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
