/// Profile completion is explicit. A default nickname and location are not proof
/// that someone completed onboarding. Existing explicit completions are retained.
bool hasCompletedProfile(Map<String, dynamic>? data) {
  return data?['isProfileComplete'] == true;
}

bool hasAllRequiredProfileFields(Map<String, dynamic>? d) {
  if (d == null) return false;
  final nick = (d['nickname'] ?? '').toString().trim();
  final rawAge = d['age'];
  final age = rawAge is num
      ? rawAge.toInt()
      : int.tryParse((rawAge ?? '').toString().trim()) ?? 0;
  final gender = (d['gender'] ?? '').toString().trim();
  final location = (d['location'] ?? '').toString().trim();
  return nick.isNotEmpty &&
      age >= 19 &&
      age <= 99 &&
      gender.isNotEmpty &&
      location.isNotEmpty;
}

String? normalizeKoreanMobile(String value) {
  var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('82')) digits = '0${digits.substring(2)}';
  if (digits.startsWith('10')) digits = '0$digits';
  if (!RegExp(r'^010[0-9]{8}$').hasMatch(digits)) return null;
  return '+82${digits.substring(1)}';
}
