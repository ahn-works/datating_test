import '../data/oomu_categories.dart';

({String main, String sub})? eventMeetupCategory(String category) {
  for (final main in OOMUCategoryData.mainCategories) {
    if (main.subCategoryNames.contains(category)) {
      return (main: main.name, sub: category);
    }
  }
  if (RegExp('카페|디저트|베이커리').hasMatch(category)) {
    return (main: '일상 & 푸드', sub: '카페 & 디저트');
  }
  if (RegExp('전시|팝업').hasMatch(category)) {
    return (main: '문화 & 엔터', sub: '전시 & 팝업스토어');
  }
  if (RegExp('공연|뮤지컬|콘서트|페스티벌').hasMatch(category)) {
    return (main: '문화 & 엔터', sub: '페스티벌 & 공연');
  }
  return null;
}
