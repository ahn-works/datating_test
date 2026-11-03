/// Profile completion is explicit. A default nickname and location are not proof
/// that someone completed onboarding. Existing explicit completions are retained.
bool hasCompletedProfile(Map<String, dynamic>? data) {
  return data?['isProfileComplete'] == true;
}

String? normalizeKoreanMobile(String value) {
  var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('82')) digits = '0${digits.substring(2)}';
  if (digits.startsWith('10')) digits = '0$digits';
  if (!RegExp(r'^010[0-9]{8}$').hasMatch(digits)) return null;
  return '+82${digits.substring(1)}';
}
