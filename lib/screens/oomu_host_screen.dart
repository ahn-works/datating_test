import 'dart:async';
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
import 'login_screen.dart';
import 'oomu_home_screen.dart';
import 'oomu_chat_room_screen.dart';

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
  final bool allowGuestFormPreview;

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
    this.allowGuestFormPreview = false,
  });

  @override
  State<OOMUHostScreen> createState() => _OOMUHostScreenState();
}

class _OOMUHostScreenState extends State<OOMUHostScreen> {
  final ScrollController _formScrollController = ScrollController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _locationFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();

  String? _titleError;
  String? _locationError;
  String? _descError;
  String? _scheduleError;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isScheduleFlexible = false;

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
      _selectedPlaceDistanceLabel =
          KakaoMapService.formatDistanceFromNeighborhood(
        widget.initialLat!,
        widget.initialLng!,
      );
    } else if (widget.initialLocation != null && widget.initialLocation!.isNotEmpty) {
      _autoResolveLocation(widget.initialLocation!);
    }
  }

  @override
  void dispose() {
    _placeDebounce?.cancel();
    _formScrollController.dispose();
    _titleFocusNode.dispose();
    _locationFocusNode.dispose();
    _descFocusNode.dispose();
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _autoResolveLocation(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    try {
      final resolved = await KakaoMapService.resolveVerifiedPlace(clean);
      if (resolved != null &&
          mounted &&
          _locationController.text.trim() == clean) {
        setState(() {
          _selectedPlaceLat = resolved.lat;
          _selectedPlaceLng = resolved.lng;
          _selectedPlaceResolvedName = clean;
          _selectedPlaceAddress = resolved.roadAddress.isNotEmpty
              ? resolved.roadAddress
              : resolved.address;
          _selectedPlaceDistanceLabel =
              KakaoMapService.formatDistanceFromNeighborhood(
            resolved.lat,
            resolved.lng,
          );
        });
      }
    } catch (_) {}
  }

  Timer? _placeDebounce;
  double? _selectedPlaceLat;
  double? _selectedPlaceLng;
  String? _selectedPlaceResolvedName;
  String _selectedPlaceAddress = '';
  String _selectedPlaceDistanceLabel = '';
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
  String _depositOption = '각자 결제';

  bool _isSaving = false;

  void _showBottomSheetPicker(String title, List<String> options,
      String currentValue, Function(String) onSelected) {
    showModalBottomSheet(
        context: context,
        backgroundColor: OomuTokens.surface,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
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

  String _coverImageUrl = '';

  int _parseMaxMembers() {
    final nums = RegExp(r'(\d+)')
        .allMatches(_memberCount)
        .map((m) => int.tryParse(m.group(1)!) ?? 0)
        .where((n) => n >= 2 && n <= 20)
        .take(2)
        .toList();
    if (nums.isEmpty) return 4;
    return nums.reduce((a, b) => a > b ? a : b);
  }

  String _formattedScheduleLabel() {
    if (_isScheduleFlexible) return '일정 협의';
    if (_selectedDate == null || _selectedTime == null) return '';
    final d = _selectedDate!;
    final t = _selectedTime!;
    final amPm = t.hour < 12 ? '오전' : '오후';
    final hour12 = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minStr = t.minute > 0 ? ' ${t.minute}분' : '';
    return '${d.month}월 ${d.day}일 $amPm $hour12시$minStr';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null && !_selectedDate!.isBefore(today)
          ? _selectedDate!
          : today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _isScheduleFlexible = false;
        if (_selectedTime != null) {
          _scheduleError = null;
        }
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 19, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _isScheduleFlexible = false;
        if (_selectedDate != null) {
          _scheduleError = null;
        }
      });
    }
  }

  void _showCoverImagePickerBottomSheet() {
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: OomuTokens.surface,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(OomuTokens.r24))),
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
                        content: Text('사진 파일(JPG, PNG, WEBP 등)만 업로드할 수 있습니다.')),
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

              final String finalCover;
              if (uploadedUrl.isNotEmpty && !uploadedUrl.startsWith('blob:')) {
                finalCover = await R2StorageService.compressDataUrlIfOversized(
                  uploadedUrl,
                  maxDimension: 720,
                  maxChars: 140000,
                );
              } else {
                finalCover = await R2StorageService.toCompressedDataUrl(
                  bytes,
                  file.name,
                  maxDimension: 720,
                  maxChars: 140000,
                );
              }
              if (mounted) {
                setState(() => _coverImageUrl = finalCover);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(source == ImageSource.camera
                        ? '카메라로 촬영한 모임 커버 사진이 등록되었습니다.'
                        : '갤러리에서 선택한 모임 커버 사진이 등록되었습니다.'),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('커버 사진 등록',
                            style: TextStyle(
                                fontSize: OomuTokens.fs18,
                                fontWeight: FontWeight.w800,
                                color: textPrimary)),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.close_rounded, color: textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r16),
                                border: Border.all(
                                    color: OomuTokens.primary
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.photo_camera_rounded,
                                      color: OomuTokens.primary, size: 24),
                                  const SizedBox(height: 6),
                                  Text('사진 찍기',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: OomuTokens.fs13,
                                          color: textPrimary)),
                                  Text('카메라 촬영',
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs11,
                                          color: textSecondary)),
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
                                color: OomuTokens.surfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(OomuTokens.r16),
                                border: Border.all(
                                    color: OomuTokens.primary
                                        .withValues(alpha: 0.35)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.photo_library_rounded,
                                      color: OomuTokens.primary, size: 24),
                                  const SizedBox(height: 6),
                                  Text('사진 불러오기',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: OomuTokens.fs13,
                                          color: textPrimary)),
                                  Text('갤러리 / 앨범',
                                      style: TextStyle(
                                          fontSize: OomuTokens.fs11,
                                          color: textSecondary)),
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
                          color: OomuTokens.primarySubtle,
                          borderRadius: BorderRadius.circular(OomuTokens.r12),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: OomuTokens.primary)),
                            const SizedBox(width: 10),
                            Text('사진 업로드 중...',
                                style: TextStyle(
                                    color: OomuTokens.primary,
                                    fontSize: OomuTokens.fs12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
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
    final title = _titleController.text.trim();
    final locText = _locationController.text.trim();
    final descText = _descController.text.trim();
    final scheduleOk =
        _isScheduleFlexible || (_selectedDate != null && _selectedTime != null);

    setState(() {
      _titleError = title.isEmpty ? '모임 제목을 입력해 주세요.' : null;
      _locationError = locText.isEmpty ? '모임 장소를 입력해 주세요.' : null;
      _descError = descText.isEmpty ? '상세 소개를 입력해 주세요.' : null;
      _scheduleError = scheduleOk ? null : '모임 날짜와 시간을 선택하거나 일정 협의를 체크해 주세요.';
    });

    if (_titleError != null ||
        _locationError != null ||
        _descError != null ||
        _scheduleError != null) {
      if (_titleError != null) {
        _titleFocusNode.requestFocus();
      } else if (_locationError != null) {
        _locationFocusNode.requestFocus();
      } else if (_descError != null) {
        _descFocusNode.requestFocus();
      }
      if (_formScrollController.hasClients) {
        _formScrollController.animateTo(
          300,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
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
        } catch (e) {
          debugPrint('[OOMUHostScreen] verify place error: $e');
          saveLat = null;
          saveLng = null;
        }
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('로그인 후 모임을 열 수 있어요.');
      final db = FirebaseFirestore.instance;
      final docRef = db.collection('meetups').doc();
      final batch = db.batch();
      final maxMembersInt = _parseMaxMembers();
      final scheduleLabel = _formattedScheduleLabel();
      DateTime? scheduledDateTime;
      if (!_isScheduleFlexible &&
          _selectedDate != null &&
          _selectedTime != null) {
        scheduledDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }
      assert(maxMembersInt >= 2);
      batch.set(docRef, {
        'title': title,
        'hostUid': user.uid,
        'participantIds': [user.uid],
        if (widget.sourceEventId != null) 'sourceEventId': widget.sourceEventId,
        if (widget.sourceEventTitle != null)
          'sourceEventTitle': widget.sourceEventTitle,
        'description': descText,
        'location': locText,
        'lat': saveLat,
        'lng': saveLng,
        'category': _selectedSubCategory,
        'mainCategory': _selectedMainCategory,
        'vibe': _selectedVibe,
        'tags': [
          _selectedMainCategory,
          _selectedSubCategory,
          _selectedVibe,
          ..._selectedCustomTags,
        ],
        'capacityLabel': _memberCount,
        'maxMembers': maxMembersInt,
        'genderLimit': _genderLimit,
        'ageLimit': _ageLimit,
        'host': globalData.userNickname.value.isNotEmpty
            ? globalData.userNickname.value
            : '모임 호스트',
        'hostAvatar': globalData.userAvatar.value,
        'imageUrl': _coverImageUrl,
        'photos': _coverImageUrl.isNotEmpty ? [_coverImageUrl] : <String>[],
        'members': [user.uid],
        'memberAvatars': globalData.userAvatar.value.isNotEmpty
            ? [globalData.userAvatar.value]
            : <String>[],
        'deadline':
            (scheduledDateTime ?? DateTime.now().add(const Duration(days: 7)))
                .subtract(const Duration(days: 1))
                .toUtc()
                .toIso8601String(),
        'closedByHost': false,
        'status': 'open',
        'manner': globalData.temperature.value,
        'mannerTemp': globalData.temperature.value,
        'price': _depositOption,
        'transport': '각자 이동',
        'isFemaleOnly': _genderLimit.toString().contains('여'),
        'date': scheduleLabel,
        if (scheduledDateTime != null)
          'scheduledAt': Timestamp.fromDate(scheduledDateTime),
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
        'date': scheduleLabel,
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(OomuTokens.r24)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.celebration, color: OomuTokens.primary, size: 64),
                  const SizedBox(height: 24),
                  Text('모임이 개설되었습니다!',
                      style: TextStyle(
                          fontSize: OomuTokens.fs20,
                          fontWeight: FontWeight.bold,
                          color: textPrimary)),
                  const SizedBox(height: 12),
                  Text('새로운 사람들과의 만남을 기대해보세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textSecondary, fontSize: OomuTokens.fs14)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r12))),
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

  bool get _isGuestSession {
    final activeUid = globalData.currentUserId.value.trim();
    if (activeUid.isNotEmpty && activeUid != 'guest') return false;
    try {
      final authUid = FirebaseAuth.instance.currentUser?.uid;
      if (authUid != null && authUid.isNotEmpty) return false;
    } catch (_) {}
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.allowGuestFormPreview && _isGuestSession) {
      return Scaffold(
        backgroundColor: OomuTokens.surface,
        appBar: AppBar(
          backgroundColor: OomuTokens.surface,
          elevation: 0,
          title: Text('새로운 모임 열기',
              style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: OomuTokens.fs18)),
          leading: IconButton(
            icon: Icon(Icons.close, color: textPrimary),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 48, color: textSecondary),
                const SizedBox(height: 16),
                Text(
                  '로그인 후 모임을 열 수 있어요',
                  style: TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '이웃들과 안전하게 모임을 진행하려면 먼저 로그인해 주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: OomuTokens.fs14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(OomuTokens.r12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen(initialStage: 2)),
                      );
                    },
                    child: Text(
                      '로그인하러 가기',
                      style: TextStyle(
                        color: OomuTokens.surface,
                        fontSize: OomuTokens.fs16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OomuTokens.surface,
      appBar: AppBar(
        backgroundColor: OomuTokens.surface,
        elevation: 0,
        title: Text('새로운 모임 열기',
            style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: OomuTokens.fs18)),
        leading: IconButton(
          icon: Icon(Icons.close, color: textPrimary),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const OOMUHomeScreen())),
        ),
      ),
      body: SingleChildScrollView(
        controller: _formScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image (스톡 기본 이미지 없이 사용자 직접 업로드만 지원)
            GestureDetector(
              onTap: _showCoverImagePickerBottomSheet,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(OomuTokens.r16),
                  border: Border.all(color: OomuTokens.border),
                  image: _coverImageUrl.isNotEmpty
                      ? DecorationImage(
                          image: appImg(_coverImageUrl, fallback: ''),
                          fit: BoxFit.cover,
                          colorFilter: const ColorFilter.mode(
                              Colors.black26, BlendMode.darken),
                        )
                      : null,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: _coverImageUrl.isNotEmpty
                            ? OomuTokens.surface
                            : textSecondary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _coverImageUrl.isNotEmpty
                            ? '커버 사진 변경'
                            : '모임 대표 사진 추가 (선택)',
                        style: TextStyle(
                          color: _coverImageUrl.isNotEmpty
                              ? OomuTokens.surface
                              : textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: OomuTokens.fs14,
                        ),
                      ),
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
                        color: isSelected
                            ? OomuTokens.primarySubtle
                            : OomuTokens.surface,
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
                          Text(cat.icon,
                              style: TextStyle(fontSize: OomuTokens.fs22)),
                          const SizedBox(height: 6),
                          Text(
                            cat.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  isSelected ? OomuTokens.primary : textPrimary,
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
                    fontSize: OomuTokens.fs14,
                  ),
                  onSelected: (val) {
                    if (val) setState(() => _selectedVibe = v.title);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // 3. Meetup Info
            Text('모임의 기본 정보',
                style: TextStyle(
                    fontSize: OomuTokens.fs18,
                    fontWeight: FontWeight.w800,
                    color: textPrimary)),
            const SizedBox(height: 16),
            _buildTextField(
              '모임 제목',
              _titleController,
              '예) 퇴근 후 동네에서 커피 한잔 하실 분!',
              focusNode: _titleFocusNode,
              errorText: _titleError,
              onChanged: (v) {
                if (_titleError != null && v.trim().isNotEmpty) {
                  setState(() => _titleError = null);
                }
              },
            ),
            _buildScheduleSection(),
            _buildLocationField(context),
            _buildTextField(
              '상세 소개',
              _descController,
              '어떤 사람들과 어떤 시간을 보내고 싶은지 자세히 적어주세요.',
              maxLines: 4,
              focusNode: _descFocusNode,
              errorText: _descError,
              onChanged: (v) {
                if (_descError != null && v.trim().isNotEmpty) {
                  setState(() => _descError = null);
                }
              },
            ),

            const SizedBox(height: 32),

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
            _buildSettingRow('비용 안내', _depositOption, () {
              _showBottomSheetPicker(
                  '비용 안내',
                  [
                    '각자 결제',
                    '참가비 없음',
                    '실비 별도 안내',
                  ],
                  _depositOption,
                  (val) => setState(() => _depositOption = val));
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: SafeArea(
        top: false,
        child: Container(
          color: OomuTokens.surface,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submitMeetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(OomuTokens.r12)),
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
      ),
    );
  }

  Widget _buildScheduleSection() {
    final dateText = _selectedDate != null
        ? '${_selectedDate!.month}월 ${_selectedDate!.day}일'
        : '날짜 선택';
    final timeText = _selectedTime != null
        ? '${_selectedTime!.hour < 12 ? "오전" : "오후"} ${_selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : '시간 선택';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '모임 일시',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: OomuTokens.fs14,
                  color: textSecondary,
                ),
              ),
              FilterChip(
                label: const Text('일정 협의'),
                selected: _isScheduleFlexible,
                selectedColor: OomuTokens.primarySubtle,
                onSelected: (val) {
                  setState(() {
                    _isScheduleFlexible = val;
                    if (val) _scheduleError = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(OomuTokens.r12),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(
                        color: _scheduleError != null
                            ? OomuTokens.error
                            : OomuTokens.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            fontWeight: FontWeight.w600,
                            color: _selectedDate != null
                                ? textPrimary
                                : OomuTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  borderRadius: BorderRadius.circular(OomuTokens.r12),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(OomuTokens.r12),
                      border: Border.all(
                        color: _scheduleError != null
                            ? OomuTokens.error
                            : OomuTokens.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_rounded,
                            size: 18, color: accentColor),
                        const SizedBox(width: 8),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: OomuTokens.fs14,
                            fontWeight: FontWeight.w600,
                            color: _selectedTime != null
                                ? textPrimary
                                : OomuTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_scheduleError != null) ...[
            const SizedBox(height: 6),
            Text(
              _scheduleError!,
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                color: OomuTokens.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openPlaceSearchModal() async {
    final result = await showModalBottomSheet<PlaceSearchResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaceSearchMapModal(
        initialQuery: _locationController.text.trim(),
      ),
    );

    if (result != null && mounted) {
      final lat = result.latLng.latitude;
      final lng = result.latLng.longitude;
      setState(() {
        _locationController.text = result.name;
        _locationError = null;
        _selectedPlaceLat = lat;
        _selectedPlaceLng = lng;
        _selectedPlaceResolvedName = result.name;
        _selectedPlaceAddress = result.address;
        _selectedPlaceDistanceLabel =
            KakaoMapService.formatDistanceFromNeighborhood(lat, lng);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("'${result.name}' 네이버 지도 위치가 지정되었습니다."),
        backgroundColor: OomuTokens.primary,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Widget _buildLocationField(BuildContext context) {
    final hasError = _locationError != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('모임 장소',
              style: TextStyle(
                  fontSize: OomuTokens.fs14,
                  fontWeight: FontWeight.bold,
                  color: textSecondary)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(OomuTokens.r12),
              border: Border.all(
                color: hasError ? OomuTokens.error : OomuTokens.border,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    focusNode: _locationFocusNode,
                    style: TextStyle(
                        fontSize: OomuTokens.fs14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary),
                    decoration: InputDecoration(
                      hintText: '장소 직접 입력 (예: 스타벅스 홍대점)',
                      hintStyle: TextStyle(
                          fontSize: OomuTokens.fs14,
                          color: OomuTokens.textMuted),
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
                    onChanged: (val) {
                      setState(() {
                        _selectedPlaceLat = null;
                        _selectedPlaceLng = null;
                        _selectedPlaceResolvedName = null;
                        _selectedPlaceAddress = '';
                        if (_locationError != null && val.trim().isNotEmpty) {
                          _locationError = null;
                        }
                      });
                      _placeDebounce?.cancel();
                      if (val.trim().length >= 2) {
                        _placeDebounce = Timer(
                          const Duration(milliseconds: 420),
                          () => _autoResolveLocation(val),
                        );
                      }
                    },
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
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              _locationError!,
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                color: OomuTokens.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_locationController.text.trim().isNotEmpty &&
              (_selectedPlaceLat == null || _selectedPlaceLng == null)) ...[
            const SizedBox(height: 6),
            Text(
              '장소를 확인하지 못하면 지도와 거리는 표시되지 않아요.',
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                color: OomuTokens.textSecondary,
              ),
            ),
          ],
          if (_selectedPlaceLat != null && _selectedPlaceLng != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: OomuTokens.surface,
                borderRadius: BorderRadius.circular(OomuTokens.r16),
                border: Border.all(color: OomuTokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(OomuTokens.r16),
                    ),
                    child: SizedBox(
                      height: 175,
                      width: double.infinity,
                      child: KakaoMapView(
                        locationName: _locationController.text.trim().isNotEmpty
                            ? _locationController.text.trim()
                            : (globalData.userLocation.value.isNotEmpty
                                ? globalData.userLocation.value
                                : '모임 장소 위치'),
                        lat: _selectedPlaceLat!,
                        lng: _selectedPlaceLng!,
                        height: 175,
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
                            size: 16, color: OomuTokens.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _locationController.text.trim().isNotEmpty
                                    ? _locationController.text.trim()
                                    : (globalData.userLocation.value.isNotEmpty
                                        ? '${globalData.userLocation.value} 중심 위치'
                                        : '장소를 입력하면 마커가 자동 이동합니다'),
                                style: TextStyle(
                                    fontSize: OomuTokens.fs14,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_selectedPlaceAddress.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    _selectedPlaceAddress,
                                    style: TextStyle(
                                      fontSize: OomuTokens.fs12,
                                      color: textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_selectedPlaceDistanceLabel.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: OomuTokens.primarySubtle,
                              borderRadius:
                                  BorderRadius.circular(OomuTokens.r8),
                            ),
                            child: Text(
                              _selectedPlaceDistanceLabel,
                              style: TextStyle(
                                fontSize: OomuTokens.fs11,
                                fontWeight: FontWeight.w700,
                                color: OomuTokens.primary,
                              ),
                            ),
                          ),
                      ],
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
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    FocusNode? focusNode,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null;
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
            focusNode: focusNode,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
                color: textPrimary,
                fontSize: OomuTokens.fs14,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: OomuTokens.textMuted,
                  fontSize: OomuTokens.fs14,
                  fontWeight: FontWeight.normal),
              fillColor: surfaceColor,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                borderSide: BorderSide(
                  color: hasError ? OomuTokens.error : OomuTokens.border,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                borderSide: BorderSide(
                  color: hasError ? OomuTokens.error : OomuTokens.border,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(OomuTokens.r12),
                borderSide: BorderSide(
                  color: hasError ? OomuTokens.error : accentColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
          if (hasError) ...[
            const SizedBox(height: 6),
            Text(
              errorText,
              style: TextStyle(
                fontSize: OomuTokens.fs12,
                color: OomuTokens.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
          backgroundColor:
              isAdded ? OomuTokens.textPrimary : OomuTokens.surface,
          side: BorderSide(
              color: isAdded ? OomuTokens.textPrimary : OomuTokens.border),
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
