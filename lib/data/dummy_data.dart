
class DummyUser {
  final String id, name, age, region, imageUrl, intro;
  final double mannerTemp;
  const DummyUser({required this.id, required this.name, required this.age, required this.region, required this.imageUrl, required this.intro, required this.mannerTemp});
}

final dummyUsers = [
  DummyUser(id:'1', name:'지은', age:'26', region:'광주', imageUrl:'https://i.pravatar.cc/300?img=47', intro:'여행 좋아하는 평범한 직장인', mannerTemp:38.5),
  DummyUser(id:'2', name:'민서', age:'25', region:'목포', imageUrl:'https://i.pravatar.cc/300?img=45', intro:'카페와 독서를 좋아한다요', mannerTemp:36.9),
  DummyUser(id:'3', name:'유스', age:'28', region:'전주', imageUrl:'https://i.pravatar.cc/300?img=12', intro:'웃음 많다고 들었는 28쓸', mannerTemp:37.2),
  DummyUser(id:'4', name:'수현', age:'24', region:'여수', imageUrl:'https://i.pravatar.cc/300?img=48', intro:'바다와 요리를 사랑해요', mannerTemp:39.1),
];
