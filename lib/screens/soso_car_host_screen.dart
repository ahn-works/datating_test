import 'package:flutter/material.dart';
import 'package:kpostal/kpostal.dart';

class SosoCarHostScreen extends StatefulWidget {
  const SosoCarHostScreen({super.key});

  @override
  State<SosoCarHostScreen> createState() => _SosoCarHostScreenState();
}

class _SosoCarHostScreenState extends State<SosoCarHostScreen> {
  final Color darkGreen = const Color(0xFF1B4D3E);
  final Color badgeGreen = const Color(0xFFA5D6A7);
  final Color terracotta = const Color(0xFFC04020);
  final Color surfaceContainer = const Color(0xFFF9F9F7);
  final Color background = const Color(0xFFFBF9F6);

  int _seats = 3;
  
  bool _isNonSmoking = true;
  bool _isPetFriendly = true;
  bool _hasTrunkSpace = true;

  final List<String> _allTags = [
    '#?붿옍?쒖닔??, '#?뚯븙媛먯긽 ?렦', '#移댄럹?ъ뼱 ??, 
    '#留쏆엳?붿떇???쪟', '#?ъ쭊?숉뻾 ?벝', '#?ъ깋利먭? ?뙼'
  ];
  final Set<String> _selectedTags = {'#?붿옍?쒖닔??, '#?뚯븙媛먯긽 ?렦', '#移댄럹?ъ뼱 ??, '#留쏆엳?붿떇???쪟'};

  final TextEditingController _titleController = TextEditingController(text: '異섏쿇 ?뚯뼇媛??쒕씪?대툕 & ??컝鍮??ъ뼱 ?뛻');
  final TextEditingController _destController = TextEditingController(text: '媛뺤썝 異섏쿇???뚯뼇媛??ㅼ뭅?댁썙??);

  void _submitForm() {
    // Return structured data back to Home Screen
    Navigator.pop(context, {
      'title': _titleController.text,
      'location': _destController.text.replaceAll('媛뺤썝 異섏쿇??', ''),
      'tags': _selectedTags.toList(),
      'driverName': '?щ━??誘쇱슦', // Placeholder for current user
      'price': '9,000',
      'image': 'https://picsum.photos/600/300?random=50',
      'badge': '?ъ쑀?먮━',
      'time': '?대쾲 二쇰쭚',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressBar(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('?대뼡 ?쒕씪?대툕瑜?n?④퍡 ?좊굹蹂쇨퉴??', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.3)),
                  const SizedBox(height: 8),
                  const Text('?숇꽕 ?댁썐怨??뚯냼?섍퀬 ?ъ쑀濡쒖슫 濡쒕뱶?몃┰???댁뼱蹂댁꽭??', style: TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('?ы뻾 ?쒕ぉ', trailing: '理쒕? 30??),
                  _buildTextField(_titleController, false),
                  const SizedBox(height: 32),

                  _buildSectionTitle('異쒕컻 諛?紐⑹쟻吏', trailing: '?뺣났 ?ъ젙', icon: Icons.explore_outlined),
                  _buildLocationBox(),
                  const SizedBox(height: 32),

                  _buildSeatSection(),
                  const SizedBox(height: 32),

                  _buildCarSection(),
                  const SizedBox(height: 32),

                  _buildTagSection(),
                  const SizedBox(height: 32),

                  _buildCostSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      leadingWidth: 100,
      leading: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.directions_car, color: darkGreen, size: 20),
          const SizedBox(width: 4),
          const Text('?뚯냼移?, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('留덊룷援??곕궓??, style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.black87, size: 14),
          ],
        ),
      ),
      centerTitle: false,
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: (){}),
            Positioned(top: 12, right: 12, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: CircleAvatar(radius: 14, backgroundColor: darkGreen, child: const Icon(Icons.emoji_people, color: Colors.white, size: 16)),
        )
      ],
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: badgeGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                    child: Text('Step 1 / 3', style: TextStyle(color: darkGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  const Text('湲곕낯 ?ы뻾 ?뺣낫', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const Text('33% ?꾨즺', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            ],
          ),
        ),
        Stack(
          children: [
            Container(height: 2, width: double.infinity, color: Colors.grey.shade200),
            FractionallySizedBox(
              widthFactor: 0.33,
              child: Container(height: 2, color: darkGreen),
            )
          ],
        )
      ],
    );
  }

  Widget _buildSectionTitle(String title, {String? trailing, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 18, color: Colors.black87), const SizedBox(width: 8)],
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool hasSearchIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          suffixIcon: hasSearchIcon ? const Icon(Icons.search, color: Colors.black54) : null,
        ),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLocationBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('異쒕컻 吏묎껐 ?μ냼', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: darkGreen, shape: BoxShape.circle)),
                const SizedBox(width: 12),
                const Expanded(child: Text('留덊룷援ъ껌??1踰?異쒓뎄 吏??踰꾩뒪踰좎씠', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('紐⑹쟻吏 (?꾩갑 ?μ냼)', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFC04020), shape: BoxShape.circle)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _destController,
                    decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      Kpostal? result = await Navigator.push(context, MaterialPageRoute(builder: (_) => KpostalView()));
                      if (result != null) {
                        setState(() {
                          _destController.text = result.address;
                        });
                      }
                    } catch (e) {
                      print("Kpostal error: `$e");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.search, color: Colors.black87, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('異쒕컻 ?쇱떆', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('10??28??(??', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('?ㅼ쟾 09:30', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          Icon(Icons.calendar_today, size: 16, color: Colors.black54)
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('蹂듦? ?덉젙', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('?뱀씪 蹂듦?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFC04020))),
                              const Text('?ㅽ썑 18:00', style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                          const Icon(Icons.access_time, size: 16, color: Colors.black54)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSeatSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('紐⑥쭛 ?몄썝 ?ㅼ젙', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('?쒕씪?대쾭 蹂몄씤???쒖쇅???묒듅 ?댁썐', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
              Container(
                decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      onPressed: () => setState(() { if(_seats > 1) _seats--; }),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    Text('', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: darkGreen),
                      onPressed: () => setState(() { if(_seats < 3) _seats++; }),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSeatIcon('?쒕씪?대쾭 (??', Icons.airline_seat_recline_extra, true, true),
                _buildSeatIcon('蹂댁“??, Icons.looks_one, _seats >= 1, false),
                _buildSeatIcon('?룹쥖??醫?, Icons.looks_two, _seats >= 2, false),
                _buildSeatIcon('?룹쥖????, Icons.looks_3, _seats >= 3, false),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: terracotta.withOpacity(0.05), border: Border.all(color: terracotta.withOpacity(0.2)), borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: terracotta, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('苡뚯쟻???대룞怨??댁깋???녿뒗 ??붾? ?꾪빐 理쒕? 3~4???뚭퇋紐??숈듅?쇰줈留??댁쁺?⑸땲??', style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSeatIcon(String label, IconData icon, bool isActive, bool isDriver) {
    return Column(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isActive ? (isDriver ? badgeGreen.withOpacity(0.5) : darkGreen) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? (isDriver ? darkGreen : Colors.white) : Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? Colors.black87 : Colors.grey)),
      ],
    );
  }

  Widget _buildCarSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('?댄뻾 李⑤웾 ?뺣낫', trailing: '湲곕낯 ?깅줉李⑤웾', icon: Icons.directions_car_outlined),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: const Icon(Icons.directions_car, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('湲곗븘 EV6 Long Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 6),
                          Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Color(0xFFA5D6A7), borderRadius: BorderRadius.all(Radius.circular(10))), child: Text('?꾧린李?, style: TextStyle(fontSize: 9, color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold))),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text('留덊룷援??몄쬆 李⑤웾 쨌 苡뚯쟻???ㅻ궡 泥?냼??, style: TextStyle(fontSize: 11, color: Colors.black54)),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('?묒듅 諛곕젮 諛??몄쓽 ?듭뀡', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 8),
          _buildCheckbox(Icons.smoke_free, '苡뚯쟻???꾩쟾 湲덉뿰 李⑤웾', _isNonSmoking, (val) => setState(() => _isNonSmoking = val!)),
          _buildCheckbox(Icons.pets, '?뚰삎 諛섎젮?숇Ъ 耳?댁? ?숇컲 媛??, _isPetFriendly, (val) => setState(() => _isPetFriendly = val!)),
          _buildCheckbox(Icons.luggage, '?몃쟻??吏?蹂닿? ?ъ쑀 (諛깊뙥 / ?쇳겕??諛붽뎄??', _hasTrunkSpace, (val) => setState(() => _hasTrunkSpace = val!)),
        ],
      ),
    );
  }

  Widget _buildCheckbox(IconData icon, String title, bool value, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(8)),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 16, color: value ? terracotta : Colors.black54),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
          ],
        ),
        activeColor: darkGreen,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildTagSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('?쒕씪?대툕 遺꾩쐞湲?痍⑦뼢 ?쒓렇', trailing: '蹂듭닔 ?좏깮', icon: Icons.local_offer_outlined),
          const Text('?대뼡 遺꾩쐞湲곕줈 ?④퍡 ?대룞?섍퀬 ?띕굹?? ?묒듅 ?댁썐 留ㅼ묶??諛섏쁺?⑸땲??', style: TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _allTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) _selectedTags.remove(tag);
                  else _selectedTags.add(tag);
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? darkGreen : Colors.white,
                    border: Border.all(color: isSelected ? darkGreen : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                      if (isSelected) const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.check, color: Colors.white, size: 14)),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildCostSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long, size: 18),
                  SizedBox(width: 8),
                  Text('?덉긽 ?뺤궛 湲덉븸 ?곗텧', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: surfaceContainer, borderRadius: BorderRadius.circular(12)), child: const Text('?먮룞 1/N ?뺤궛', style: TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 16),
          _buildCostRow('?덉긽 ?꾧린李?異⑹쟾鍮?(?뺣났 210km)', '18,500??),
          const SizedBox(height: 8),
          _buildCostRow('怨좎냽?꾨줈 ?듯뻾猷?(?쒖슱-異섏쿇 ?뺣났)', '13,600??),
          const SizedBox(height: 8),
          _buildCostRow('?뚯뼇媛?怨듭쁺二쇱감???덉긽鍮?, '4,000??),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Colors.black12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1???덉긽 ?뺤궛湲?, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('珥?36,100??첨 4紐??쒕씪?대쾭 ?ы븿)', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('??9,000??, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: terracotta)),
                  const SizedBox(height: 4),
                  const Text('?대룞 ?꾨즺 ??????媛꾪렪寃곗젣', style: TextStyle(fontSize: 10, color: Colors.black54)),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          const Text('* ?뚯냼移대뒗 ?쒖닔 ?ㅻ퉬(?좊쪟鍮??듯뻾猷?留뚯쓣 ?숈듅?먯뿉寃??섎닏?덈떎. ?댁쟾?먯쓽 ?곷━ 紐⑹쟻 ?섏닔猷뚮뒗 ?ы븿?섏? ?딆뒿?덈떎.', style: TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        Text(amount, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      color: background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('?ㅼ쓬 ?④퀎 (?쇱젙 ?곸꽭 & ?쇳몴 ?깅줉)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text('?댁썐 移쒗솕&留ㅻ꼫 ?쒕씪?대쾭 ?덉떖 ?깅줉 以?, style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1, // "紐⑥쭛?섍린" tab
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '?먯깋'),
        const BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: '紐⑥쭛?섍린'),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.chat_bubble_outline),
              Positioned(
                right: -4, top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFB53D25), shape: BoxShape.circle),
                  child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
          label: '?숉뻾梨꾪똿',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: '?댁뿬??),
      ],
    );
  }
}
