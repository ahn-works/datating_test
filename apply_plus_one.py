import io

with io.open('lib/screens/soso_car_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

target = """                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton("""

plus_one_ui = """                  ),
                ),
                const SizedBox(height: 16),
                // [안전 장치] 동반 참석(+1) 시스템
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setModalState) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF19E39).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF19E39).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.group_add, color: const Color(0xFFF19E39)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('지인 1명과 함께 가기 (+1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('낯선 모임이 처음이라면 지인과 함께 참석해 보세요!', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: false, // UI Mock
                            onChanged: (val) {
                              setModalState(() {});
                            },
                            activeColor: const Color(0xFFF19E39),
                          )
                        ],
                      ),
                    );
                  }
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton("""

if target in content:
    content = content.replace(target, plus_one_ui, 1)

with io.open('lib/screens/soso_car_detail_screen.dart', 'w', encoding='utf-8', newline='\n') as f:
    f.write(content)
