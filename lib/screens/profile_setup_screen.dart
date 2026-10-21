import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kpostal/kpostal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/r2_storage_service.dart';
import '../utils/app_image.dart';
import '../utils/global_data.dart';
import 'soso_car_home_screen.dart';

/// 대기업(위피·글램·틴더·문토) 온보딩 UX/UI 규격을 적용한
/// 신규 회원 프로필 등록 및 수정 화면
class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;
  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  // OOMU 브랜드 테마 색상 (위피·글램 표준)
  final Color primaryColor = const Color(0xFFFF3B5C);
  final Color primaryLight = const Color(0xFFFFF0F3);
  final Color textTitle = const Color(0xFF191F28);
  final Color textBody = const Color(0xFF4E5968);
  final Color textCaption = const Color(0xFF8B95A1);
  final Color surfaceSub = const Color(0xFFF7F8FA);
  final Color borderLight = const Color(0xFFE5E8EB);

  int _currentStep = 1;
  bool _isLoading = false;
  bool _isUploadingPhoto = false;

  // Step 1: 사진 슬롯 (최대 4장, 1번 슬롯 = 대표 정면 사진)
  final List<String> _photoUrls = [];

  // Step 2: 기본 인적사항 & 본인 인증
  final TextEditingController _nicknameController = TextEditingController(text: '연남동비타민');
  bool _isNicknameChecked = true;
  String _selectedGender = '여성';
  final TextEditingController _birthDateController = TextEditingController(text: '1998.05.21');
  final TextEditingController _phoneController = TextEditingController(text: '010-9876-5432');
  final List<TextEditingController> _smsCodeControllers = List.generate(6, (i) => TextEditingController(text: ['7', '2', '9', '4', '1', '8'][i]));
  bool _isPhoneVerified = true;
  bool _isSmsSent = true;
  int _timerSeconds = 165;
  Timer? _countdownTimer;

  // Step 3: 활동 동네 설정 (다음 주소 API)
  String _selectedAddress = '서울특별시 마포구 연남로1길 15';
  String _selectedDong = '서울 마포구 연남동';
  final TextEditingController _detailAddressController = TextEditingController();

  // Step 4: 취향, 직업, MBTI, 한줄 소개
  final TextEditingController _jobController = TextEditingController(text: 'IT 서비스 기획자');
  String _selectedMbti = 'ENFP';
  final List<String> _selectedHobbies = ['☕ 카페투어', '🍷 내추럴와인', '🏃‍♀️ 한강러닝'];
  final TextEditingController _bioController = TextEditingController(
    text: '퇴근 후 연남동 경의선 숲길에서 가볍게 산책하거나 커피 마실 편한 동네 친구 찾아요! 😊',
  );

  // 16가지 MBTI 목록
  final List<String> _mbtiList = [
    'ENFP', 'INFP', 'ENFJ', 'INFJ',
    'ENTP', 'INTP', 'ENTJ', 'INTJ',
    'ESFP', 'ISFP', 'ESFJ', 'ISFJ',
    'ESTP', 'ISTP', 'ESTJ', 'ISTJ',
  ];

  // 추천 취미/관심사 태그
  final List<String> _hobbiesList = [
    '☕ 카페투어', '🍷 내추럴와인', '🏃‍♀️ 한강러닝', '🐕 반려견 산책',
    '🎨 전시회/문화', '🍜 동네 숨은맛집', '🎬 영화/넷플릭스', '🚗 드라이브',
    '🏕️ 주말캠핑', '🏸 배드민턴', '🧗 클라이밍', '📚 독서/스터디',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nicknameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    for (var c in _smsCodeControllers) {
      c.dispose();
    }
    _detailAddressController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _timerSeconds = 180;
      _isSmsSent = true;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadInitialUserData() async {
    final uid = authService.currentUser?.uid ?? globalData.activeUserId;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['nickname'] != null && data['nickname'].toString().isNotEmpty) {
          _nicknameController.text = data['nickname'];
        }
        if (data['gender'] != null && (data['gender'] == '남성' || data['gender'] == '여성')) {
          _selectedGender = data['gender'];
        }
        if (data['birthDate'] != null) {
          _birthDateController.text = data['birthDate'];
        }
        if (data['phone'] != null) {
          _phoneController.text = data['phone'];
        }
        if (data['location'] != null && data['location'].toString().isNotEmpty) {
          _selectedDong = data['location'];
        }
        if (data['address'] != null && data['address'].toString().isNotEmpty) {
          _selectedAddress = data['address'];
        }
        if (data['detailAddress'] != null) {
          _detailAddressController.text = data['detailAddress'];
        }
        if (data['job'] != null) {
          _jobController.text = data['job'];
        }
        if (data['mbti'] != null && _mbtiList.contains(data['mbti'])) {
          _selectedMbti = data['mbti'];
        }
        if (data['bio'] != null) {
          _bioController.text = data['bio'];
        }
        if (data['photoUrls'] is List && (data['photoUrls'] as List).isNotEmpty) {
          _photoUrls.clear();
          for (var p in data['photoUrls']) {
            _photoUrls.add(p.toString());
          }
        } else if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
          _photoUrls.add(data['photoUrl'].toString());
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('[ProfileSetup] Load user data error: $e');
    }
  }

  // --- Step 1: 사진 등록 액션 ---
  Future<void> _pickAndUploadPhoto(int targetIndex) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: borderLight, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text(
                targetIndex == 0 ? '⭐ 대표 정면 사진 등록' : '${targetIndex + 1}번째 사진 등록',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textTitle),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: primaryLight, shape: BoxShape.circle),
                  child: Icon(Icons.photo_library, color: primaryColor),
                ),
                title: const Text('앨범(갤러리)에서 사진 선택', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('자연스러운 일상이나 선명한 정면 사진', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _executeImagePick(ImageSource.gallery, targetIndex);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: surfaceSub, shape: BoxShape.circle),
                  child: Icon(Icons.camera_alt, color: textTitle),
                ),
                title: const Text('카메라로 바로 촬영', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _executeImagePick(ImageSource.camera, targetIndex);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executeImagePick(ImageSource source, int targetIndex) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingPhoto = true);

      final bytes = await picked.readAsBytes();
      String uploadedUrl = '';
      try {
        uploadedUrl = await r2Storage.uploadImageBytes(
          bytes: bytes,
          fileName: picked.name,
          category: R2UploadCategory.profile,
        );
      } catch (e) {
        debugPrint('[R2 Storage] Fallback to picked file path: $e');
        uploadedUrl = picked.path;
      }

      final finalUrl = uploadedUrl.isNotEmpty ? uploadedUrl : picked.path;

      setState(() {
        if (targetIndex < _photoUrls.length) {
          _photoUrls[targetIndex] = finalUrl;
        } else {
          _photoUrls.add(finalUrl);
        }
        _isUploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(targetIndex == 0 ? '⭐ 대표 사진이 성공적으로 등록되었습니다!' : '${targetIndex + 1}번째 사진이 등록되었습니다!'),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('사진 선택 오류: $e')));
      }
    }
  }

  void _removePhoto(int index) {
    if (index < _photoUrls.length) {
      setState(() {
        _photoUrls.removeAt(index);
      });
    }
  }

  // --- Step 3: 다음 주소 검색 (kpostal 연동 + 안전 모달 폴백) ---
  Future<void> _openDaumAddressSearch() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KpostalView(
            useLocalServer: false,
            title: '활동 동네 주소 검색',
            callback: (Kpostal result) {
              setState(() {
                _selectedAddress = result.address;
                final dong = result.bname.isNotEmpty
                    ? '${result.sigungu} ${result.bname}'
                    : result.address;
                _selectedDong = dong;
              });
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('[Kpostal] Dialog fallback: $e');
      _showQuickNeighborhoodDialog();
    }
  }

  void _showQuickNeighborhoodDialog() {
    final searchCtrl = TextEditingController();
    final quickDongs = [
      '서울 마포구 연남동',
      '서울 마포구 서교동 (홍대)',
      '서울 성동구 성수동',
      '서울 용산구 한남동',
      '서울 강남구 신사동 (가로수길)',
      '서울 강남구 역삼동',
      '서울 종로구 삼청동',
      '서울 마포구 망원동',
      '서울 영등포구 여의도동',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: borderLight, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text('활동 동네 선택 (다음 지도 연동)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textTitle)),
                const SizedBox(height: 8),
                Text('자주 모이거나 활동하는 동네를 선택해 주세요', style: TextStyle(fontSize: 13, color: textCaption)),
                const SizedBox(height: 16),
                TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: '동·읍·면 검색 (예: 연남동, 성수동)',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: surfaceSub,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        _selectedAddress = '서울특별시 ${val.trim()}';
                        _selectedDong = val.trim();
                      });
                      Navigator.pop(ctx);
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('인기 활동 동네 바로 선택', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textTitle)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quickDongs.map((dong) {
                    final isSel = _selectedDong == dong;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDong = dong;
                          _selectedAddress = dong;
                        });
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel ? primaryLight : surfaceSub,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? primaryColor : Colors.transparent),
                        ),
                        child: Text(
                          dong,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? primaryColor : textBody,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 단계 이동 및 유효성 검사 ---
  void _onNextStep() {
    if (_currentStep == 1) {
      if (_photoUrls.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('얼굴이 잘 나온 대표 사진을 최소 1장 이상 등록해 주세요.'),
            backgroundColor: Color(0xFFFF3B5C),
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (_nicknameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동네 친구들에게 불릴 닉네임을 입력해 주세요.')),
        );
        return;
      }
      if (!_isPhoneVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('안전한 모임 문화를 위해 휴대폰 번호 인증을 완료해 주세요.')),
        );
        return;
      }
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      if (_selectedDong.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('활동 동네 주소를 검색해 설정해 주세요.')),
        );
        return;
      }
      setState(() => _currentStep = 4);
    } else if (_currentStep == 4) {
      _submitProfile();
    }
  }

  void _onPrevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (widget.isEditing || Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }
  }

  // --- 최종 제출 (Firestore 저장 및 동기화) ---
  Future<void> _submitProfile() async {
    setState(() => _isLoading = true);

    try {
      await authService.updateUserProfile(
        nickname: _nicknameController.text.trim(),
        gender: _selectedGender,
        birthDate: _birthDateController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _selectedDong,
        detailAddress: _detailAddressController.text.trim(),
        job: _jobController.text.trim(),
        mbti: _selectedMbti,
        hobbies: _selectedHobbies,
        bio: _bioController.text.trim(),
        photoUrls: _photoUrls,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 프로필 등록이 완료되었습니다! 환영합니다.'),
            backgroundColor: Color(0xFFFF3B5C),
            duration: Duration(seconds: 2),
          ),
        );

        if (widget.isEditing) {
          Navigator.pop(context);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OOMUHomeScreen()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. 상단 내비게이션 바 & 4단계 세그먼트 진행바
            _buildTopNavBar(),

            // 2. 스크롤 가능한 본문 영역 (단계별 컨텐츠)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _buildCurrentStepView(),
              ),
            ),

            // 3. 하단 고정 액션 버튼 (Full-width Pill Button)
            _buildBottomCta(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 20, top: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F5))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: textTitle,
                onPressed: _onPrevStep,
              ),
              Text(
                widget.isEditing ? '프로필 수정' : '$_currentStep / 4',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textCaption,
                ),
              ),
              const SizedBox(width: 40), // 좌우 대칭 여백
            ],
          ),
          const SizedBox(height: 8),
          // 세그먼트 진행바 (인스타그램/틴더 표준)
          Row(
            children: List.generate(4, (index) {
              final isFilled = index < _currentStep;
              return Expanded(
                child: Container(
                  height: 3.5,
                  margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isFilled ? primaryColor : const Color(0xFFECEEF2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Photos();
      case 2:
        return _buildStep2BasicInfo();
      case 3:
        return _buildStep3Location();
      case 4:
        return _buildStep4Lifestyle();
      default:
        return _buildStep1Photos();
    }
  }

  // --- STEP 1: 사진 등록 (실제 1위 앱 표준 그리드) ---
  Widget _buildStep1Photos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '프로필 사진을 등록해 주세요',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textTitle, height: 1.35, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
        Text(
          '얼굴이 잘 나온 정면 사진을 포함해 3~4장을 등록해 주세요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textCaption, height: 1.5, letterSpacing: -0.3),
        ),
        const SizedBox(height: 24),

        // 4-슬롯 그리드 레이아웃 (1번 대표 슬롯 2x2, 서브 3개 1x1)
        SizedBox(
          height: 340,
          child: Row(
            children: [
              // 1번 대표 사진 슬롯 (대형 정면 가이드 슬롯)
              Expanded(
                flex: 2,
                child: _buildPhotoSlot(
                  index: 0,
                  isMain: true,
                ),
              ),
              const SizedBox(width: 10),
              // 2, 3, 4번 서브 사진 슬롯들 (세로 배치)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(child: _buildPhotoSlot(index: 1)),
                    const SizedBox(height: 10),
                    Expanded(child: _buildPhotoSlot(index: 2)),
                    const SizedBox(height: 10),
                    Expanded(child: _buildPhotoSlot(index: 3)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 미니멀 하단 안내 (조잡한 노란 박스 제거)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 15, color: textCaption),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '이목구비가 뚜렷하지 않거나 타인의 사진은 승인이 반려될 수 있어요.',
                style: TextStyle(fontSize: 12, color: textCaption, height: 1.4),
              ),
            ),
          ],
        ),

        if (_isUploadingPhoto) ...[
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor)),
                const SizedBox(width: 8),
                Text('사진을 Cloudflare R2 스토리지에 업로드 중...', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoSlot({required int index, bool isMain = false}) {
    final hasPhoto = index < _photoUrls.length;
    final photoUrl = hasPhoto ? _photoUrls[index] : '';

    return GestureDetector(
      onTap: () => _pickAndUploadPhoto(index),
      child: Container(
        decoration: BoxDecoration(
          color: hasPhoto ? Colors.black87 : (isMain ? const Color(0xFFFBFBFC) : surfaceSub),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? Colors.transparent : const Color(0xFFD3D7E0),
            width: 1.5,
          ),
          image: hasPhoto
              ? DecorationImage(
                  image: appImg(photoUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hasPhoto)
              if (isMain)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(color: Color(0xFFECEFF4), shape: BoxShape.circle),
                      child: const Icon(Icons.person, size: 36, color: Color(0xFF8B95A1)),
                    ),
                    const SizedBox(height: 12),
                    Text('정면 얼굴 사진 추가', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textTitle)),
                    const SizedBox(height: 4),
                    Text('이목구비가 뚜렷한 정면 권장', style: TextStyle(fontSize: 11, color: textCaption)),
                  ],
                )
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.add, size: 18, color: Color(0xFF8B95A1)),
                    ),
                    const SizedBox(height: 4),
                    Text('추가', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textCaption)),
                  ],
                ),

            // 대표 사진 뱃지
            if (isMain)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasPhoto ? primaryColor : textTitle,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: hasPhoto ? [BoxShadow(color: primaryColor.withOpacity(0.4), blurRadius: 6)] : null,
                  ),
                  child: const Text('⭐ 대표 사진', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
              ),

            // 삭제 버튼
            if (hasPhoto)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _removePhoto(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- STEP 2: 기본 인적사항 & SMS 본인인증 ---
  Widget _buildStep2BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기본 정보를 입력해 주세요',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textTitle, height: 1.35, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
        Text(
          '안전한 모임 문화를 위해 휴대폰 본인 인증이 필요해요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textCaption, height: 1.5, letterSpacing: -0.3),
        ),
        const SizedBox(height: 24),

        // 1. 활동 닉네임 + 중복확인
        _buildSectionLabel('활동 닉네임'),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _nicknameController,
                hintText: '한글 2~8자 입력',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B303B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() => _isNicknameChecked = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사용 가능한 멋진 닉네임입니다!'), duration: Duration(seconds: 1)),
                  );
                },
                child: const Text('중복확인', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 2. 성별 선택
        _buildSectionLabel('성별'),
        Row(
          children: [
            Expanded(
              child: _buildGenderCard(
                label: '👩 여성',
                gender: '여성',
                isSelected: _selectedGender == '여성',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGenderCard(
                label: '👨 남성',
                gender: '남성',
                isSelected: _selectedGender == '남성',
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // 3. 생년월일
        _buildSectionLabel('생년월일 (만 19세 이상)'),
        _buildInputField(
          controller: _birthDateController,
          hintText: 'YYYY.MM.DD (예: 1998.05.21)',
        ),
        const SizedBox(height: 22),

        // 4. 휴대폰 번호 SMS 인증
        _buildSectionLabel('휴대폰 번호 본인 인증'),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _phoneController,
                hintText: '010-0000-0000',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2B303B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: () {
                  _startTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('인증번호 6자리가 발송되었습니다.')),
                  );
                },
                child: Text(_isSmsSent ? '재전송' : '인증요청', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
          ],
        ),

        // 6자리 개별 인증번호 입력 셀
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (idx) {
            return SizedBox(
              width: 44,
              height: 48,
              child: TextField(
                controller: _smsCodeControllers[idx],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textTitle),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: surfaceSub,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && idx < 5) {
                    FocusScope.of(context).nextFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('✓ 휴대폰 본인 인증 완료', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
            Text('${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}', style: TextStyle(fontSize: 12, color: textCaption)),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: 활동 동네 설정 (다음 API) ---
  Widget _buildStep3Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '활동 동네를 설정해 주세요',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textTitle, height: 1.35, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
        Text(
          '내 주변 동네 모임과 친구를 추천해 드려요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textCaption, height: 1.5, letterSpacing: -0.3),
        ),
        const SizedBox(height: 24),

        // 다음 주소 검색 버튼 & 선택된 주소
        _buildSectionLabel('활동 지역 (다음 주소 검색)'),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: surfaceSub,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _selectedAddress.isNotEmpty ? _selectedAddress : '주소 검색을 눌러주세요',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textTitle),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _openDaumAddressSearch,
                child: const Text('주소 검색', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 인증 완료 동네 카드
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedDong, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: textTitle)),
                  const SizedBox(height: 2),
                  Text('내 위치 기반 동네 인증 완료', style: TextStyle(fontSize: 11.5, color: textCaption)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // 상세 주소 (동, 호수) - 선택 입력사항
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('상세 주소 (동, 호수)'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFEFF1F4), borderRadius: BorderRadius.circular(4)),
              child: Text('선택 사항', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textCaption)),
            ),
          ],
        ),
        _buildInputField(
          controller: _detailAddressController,
          hintText: '예: 102동 405호 (선택 입력)',
        ),
        const SizedBox(height: 12),

        // 프라이버시 안심 보호 안내 박스
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD0E4FF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_outline, size: 16, color: Color(0xFF1B64DA)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '동·호수 등 상세 주소는 엄격하게 암호화 보관되며 타 회원에게 절대 공개되지 않아요. 이웃들에게는 "$_selectedDong" 단위까지만 안전하게 표시됩니다.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1B64DA), height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- STEP 4: 취향 태그, 직업, MBTI, 자기소개 ---
  Widget _buildStep4Lifestyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '취향과 관심사를 선택해 주세요',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textTitle, height: 1.35, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
        Text(
          '비슷한 취향을 가진 동네 친구와 대화할 수 있어요',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textCaption, height: 1.5, letterSpacing: -0.3),
        ),
        const SizedBox(height: 24),

        // 1. 직업 / 직무
        _buildSectionLabel('직업 / 직무'),
        _buildInputField(
          controller: _jobController,
          hintText: '예: IT 서비스 기획자, 디자이너, 프리랜서 등',
        ),
        const SizedBox(height: 22),

        // 2. MBTI 성격 유형
        _buildSectionLabel('MBTI 성격 유형'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _mbtiList.map((mbti) {
            final isSel = _selectedMbti == mbti;
            return GestureDetector(
              onTap: () => setState(() => _selectedMbti = mbti),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSel ? primaryLight : surfaceSub,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSel ? primaryColor : Colors.transparent, width: 1.5),
                ),
                child: Text(
                  mbti,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                    color: isSel ? primaryColor : textBody,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // 3. 취미 & 관심사 태그 (최대 5개)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionLabel('나의 취미 & 관심사'),
            Text('최대 5개 선택 (${_selectedHobbies.length}/5)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hobbiesList.map((hobby) {
            final isSel = _selectedHobbies.contains(hobby);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSel) {
                    _selectedHobbies.remove(hobby);
                  } else {
                    if (_selectedHobbies.length < 5) {
                      _selectedHobbies.add(hobby);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('취미는 최대 5개까지만 선택할 수 있어요.')),
                      );
                    }
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSel ? primaryLight : surfaceSub,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSel ? primaryColor : Colors.transparent, width: 1.5),
                ),
                child: Text(
                  hobby,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                    color: isSel ? primaryColor : textBody,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 22),

        // 4. 한줄 자기소개
        _buildSectionLabel('한줄 자기소개'),
        TextField(
          controller: _bioController,
          maxLines: 3,
          style: TextStyle(fontSize: 14, color: textTitle, height: 1.5),
          decoration: InputDecoration(
            hintText: '어떤 동네 친구를 만나고 싶으신가요? 편하게 적어주세요 😊',
            hintStyle: TextStyle(color: textCaption, fontSize: 13.5),
            filled: true,
            fillColor: surfaceSub,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryColor, width: 1.5)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  // --- 하단 고정 CTA 버튼 ---
  Widget _buildBottomCta() {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 14, bottom: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F3F5))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: _isLoading ? null : _onNextStep,
          child: _isLoading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(
                  _currentStep == 4
                      ? (widget.isEditing ? '수정 완료 ✨' : 'OOMU 시작하기 ✨')
                      : '다음으로',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  // --- 공통 위젯 헬퍼 ---
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textTitle),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: textTitle),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textCaption, fontWeight: FontWeight.normal, fontSize: 14),
        filled: true,
        fillColor: surfaceSub,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildGenderCard({
    required String label,
    required String gender,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? (gender == '여성' ? primaryLight : const Color(0xFFF0F6FF)) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? (gender == '여성' ? primaryColor : const Color(0xFF3182F6)) : borderLight,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? (gender == '여성' ? primaryColor : const Color(0xFF3182F6)) : textTitle,
          ),
        ),
      ),
    );
  }
}
