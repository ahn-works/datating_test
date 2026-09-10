import 'package:flutter/material.dart';
class ProfileDetailScreen extends StatefulWidget {
  final String name, age, region, imageUrl, intro; final double mannerTemp;
  const ProfileDetailScreen({super.key, required this.name, required this.age, required this.region, required this.imageUrl, required this.intro, required this.mannerTemp});
  @override State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}
class _ProfileDetailScreenState extends State<ProfileDetailScreen> with SingleTickerProviderStateMixin {
  bool _showHeart = false;
  late AnimationController _anim;
  @override void initState() { super.initState(); _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800)); }
  @override void dispose() { _anim.dispose(); super.dispose(); }

  void _sendLike() {
    setState(() => _showHeart = true);
    _anim.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if(mounted) setState(() => _showHeart = false);
        _anim.reset();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.name}님에게 호감을 보냈습니다!'), backgroundColor: const Color(0xFFFF3B30), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), behavior: SnackBarBehavior.floating));
      });
    });
  }

  @override Widget build(BuildContext context) => Scaffold(backgroundColor: const Color(0xFFF8F9FA), body: Stack(children: [
    CustomScrollView(slivers: [
      SliverAppBar(expandedHeight: 400, pinned: true, backgroundColor: Colors.white, flexibleSpace: FlexibleSpaceBar(background: Stack(fit: StackFit.expand, children: [Image.network('https://picsum.photos/600/800?random=88', fit: BoxFit.cover), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.black.withOpacity(0.8)], begin: Alignment.center, end: Alignment.bottomCenter))), Positioned(bottom: 20, right: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white54)), child: const Row(children: [Icon(Icons.mic, color: Colors.white, size: 18), SizedBox(width: 8), Text('목소리 듣기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))])))]))),
      SliverToBoxAdapter(child: Container(decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))), transform: Matrix4.translationValues(0, -32, 0), child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(widget.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)), const SizedBox(width: 8), Text('${widget.age}세', style: TextStyle(fontSize: 22, color: Colors.grey.shade600, fontWeight: FontWeight.w500)), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFFF3B30).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.whatshot_rounded, color: Color(0xFFFF3B30), size: 18), const SizedBox(width: 4), Text('${widget.mannerTemp}°C', style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.w800, fontSize: 15))]))]), const SizedBox(height: 12),
        Row(children: [const Icon(Icons.location_on, color: Colors.grey, size: 16), const SizedBox(width: 4), Text('${widget.region} · 2km 이내 (방금 접속)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500))]), const SizedBox(height: 32),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))]), child: Row(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.white)), const SizedBox(width: 16), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AI 성향 분석 매칭률 92%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)), SizedBox(height: 4), Text('회원님과 여행/데이트 스타일이 매우 비슷해요!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))]))])), const SizedBox(height: 32),
        const Text('신뢰도 인증 뱃지', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)), const SizedBox(height: 16),
        Row(children: [_trustBadge(Icons.verified_user, 'PASS 인증', Colors.green), const SizedBox(width: 8), _trustBadge(Icons.work, '대기업', Colors.blue), const SizedBox(width: 8), _trustBadge(Icons.monetization_on, '1억+', Colors.amber.shade600)]), const SizedBox(height: 32),
        const Text('MBTI & 관심사', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)), const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [_tag('ENFP', color: const Color(0xFFFF3B30)), _tag('맛집탐방'), _tag('드라이브'), _tag('카페투어'), _tag('즉흥여행')]), const SizedBox(height: 32),
        const Text('자기소개', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)), const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(20), width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20)), child: Text(widget.intro, style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey.shade800, fontWeight: FontWeight.w500))), const SizedBox(height: 120),
      ])))
    ]),
    Positioned(bottom: 30, left: 24, right: 24, child: ElevatedButton.icon(onPressed: _sendLike, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3B30), minimumSize: const Size(double.infinity, 64), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 10, shadowColor: const Color(0xFFFF3B30).withOpacity(0.5)), icon: const Icon(Icons.favorite, color: Colors.white, size: 28), label: const Text('호감 보내기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)))),
    if (_showHeart) Positioned.fill(child: IgnorePointer(child: Center(child: ScaleTransition(scale: CurvedAnimation(parent: _anim, curve: Curves.elasticOut), child: const Icon(Icons.favorite, color: Color(0xFFFF3B30), size: 150))))),
  ]));
  Widget _trustBadge(IconData icon, String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))), child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 6), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13))]));
  Widget _tag(String text, {Color color = Colors.black54}) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: color == Colors.black54 ? Colors.grey.shade100 : color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: color == Colors.black54 ? Colors.grey.shade700 : color, fontWeight: FontWeight.w800, fontSize: 14)));
}
