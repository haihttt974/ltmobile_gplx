import 'package:flutter/material.dart';
import '../../Components/note_box.dart';
import '../../Styles/app_theme.dart';

class TipsMemoryScreen extends StatefulWidget {
  /// Nếu truyền [onlySectionKey], màn hình chỉ hiển thị **một** chủ đề tương ứng.
  final String? onlySectionKey;
  const TipsMemoryScreen({super.key, this.onlySectionKey});

  @override
  State<TipsMemoryScreen> createState() => _TipsMemoryScreenState();
}

class _TipsMemoryScreenState extends State<TipsMemoryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mở từ list: render 1 section
    if (widget.onlySectionKey != null) {
      final section = _sectionByKey(widget.onlySectionKey!);
      final title = _titleOf(widget.onlySectionKey!);
      return Scaffold(
        appBar: AppBar(title: Text(title), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [section],
        ),
      );
    }

    // Mở trực tiếp: hiển thị tất cả + thanh tìm kiếm
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Tìm mẹo...',
            border: InputBorder.none,
          ),
          onChanged: (q) => setState(() => _searchQuery = q.trim().toLowerCase()),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchCtrl.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
      body: _buildAllSectionsWithSearch(),
    );
  }

  // ===================== Xử lý dữ liệu & tìm kiếm ======================

  List<_SectionCard> _allSections() {
    return [
      _alcoholSection(),
      _distanceSection(),
      _licenseSection(),
      _buildAgeSection(),
      _buildProhibitionsSection(),
      _buildPrioritySection(),
      _buildSignsSection(),
      _buildSpeedSection(),
      _buildConceptsSection(),
      _buildTransportOpsSection(),
      _buildDrivingTechniqueSection(),
      _buildMechanicsSection(),
      _buildIntersectionSection(),
    ];
  }

  Widget _buildAllSectionsWithSearch() {
    final all = _allSections();

    // Chỉ mục text đơn giản để tìm sâu vào nội dung
    final Map<String, String> sectionTexts = {
      'Nồng độ cồn':
      'Người điều khiển xe mô tô ô tô máy kéo trong máu hoặc hơi thở có nồng độ cồn bị nghiêm cấm.',
      'Khoảng cách an toàn':
      '35m nếu V=60, 55m nếu 60<V≤80, 70m nếu 80<V≤100, 100m nếu 100<V≤120. Dưới 60 không có quy định cụ thể.',
      'Các hạng GPLX':
      'A1 A B C D. Số chỗ càng lớn hạng càng cao. Xe ≤8 chỗ hạng B, tải ≤3.5 tấn. D1 8–16 chỗ, D2 16–29 chỗ.',
      'Hỏi về tuổi (T)':
      'Xe dưới 50cm³: 16 tuổi. A1 A B1 B C1: 18 tuổi. C BE: 21 tuổi. D1 D2 C1E CE: 24 tuổi. D D1E D2E DE: 27 tuổi.',
      'Cao tốc / đường hầm / nơi hạn chế':
      'Không quay đầu không lùi không vượt. Không vượt cầu hẹp một làn. Cấm lùi nơi giao nhau.',
      'Nhất chớm – Nhì ưu – Tam – Tứ':
      'Nhất chớm, Nhì ưu, Tam đường, Tứ hướng: bên phải trống → rẽ phải → đi thẳng → rẽ trái.',
      'Biển báo & nhóm biển':
      '5 nhóm: Nguy hiểm, Cấm, Hiệu lệnh, Chỉ dẫn, Biển phụ. Biển cấm chuỗi nhớ Cấm ô tô → Cấm xe tải → Cấm máy kéo → Cấm rơ moóc.',
      'Tốc độ tối đa':
      'Trong KDC: 60 và 50. Ngoài KDC: 90/80/70/60 và 80/70/60/50 tùy loại đường. Cao tốc tối đa 120.',
      'Khái niệm & quy tắc nhanh':
      'Câu có “bị nghiêm cấm/không được phép” → chọn. Dừng đỗ ≤0.25m, ưu tiên đường sắt, nhường người đi bộ.',
      'Nghiệp vụ vận tải':
      'Không lái liên tục quá 4 giờ, không làm việc quá 10 giờ/ngày, không tự ý thay đổi điểm đón trả.',
      'Kỹ thuật lái xe':
      'Mô tô xuống dốc dùng cả phanh trước & sau, khởi hành AT đạp phanh, qua đường sắt dừng 5m.',
      'Cấu tạo & sửa chữa':
      'Còi 90–115 dB, kính an toàn, động cơ 4 kỳ, dây đai an toàn có cơ cấu hãm, niên hạn 20/25 năm.',
      'Các quy tắc sa hình khác':
      'Không vòng xuyến: xe vào trước đi trước. Vòng xuyến: chưa vào ưu tiên bên phải; đã vào ưu tiên xe từ trái tới. Xuống dốc nhường lên dốc.',
    };

    final filtered = _searchQuery.isEmpty
        ? all
        : all.where((s) {
      final combined =
      (s.title + ' ' + s.subtitle + ' ' + (sectionTexts[s.title] ?? ''))
          .toLowerCase();
      return combined.contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: filtered,
    );
  }

  // ===================== Map khóa -> Section & Tiêu đề ======================

  _SectionCard _sectionByKey(String key) {
    switch (key) {
      case 'alcohol':
        return _alcoholSection();
      case 'distance':
        return _distanceSection();
      case 'license':
        return _licenseSection();
      case 'age':
        return _buildAgeSection();
      case 'rules':
        return _buildProhibitionsSection();
      case 'priority':
        return _buildPrioritySection();
      case 'signs':
        return _buildSignsSection();
      case 'speed':
        return _buildSpeedSection();
      case 'concept':
        return _buildConceptsSection();
      case 'transport':
        return _buildTransportOpsSection();
      case 'technic':
        return _buildDrivingTechniqueSection();
      case 'mechanic':
        return _buildMechanicsSection();
      default:
        return _buildPrioritySection();
    }
  }

  String _titleOf(String key) {
    switch (key) {
      case 'alcohol':
        return 'Nồng độ cồn';
      case 'distance':
        return 'Khoảng cách an toàn';
      case 'license':
        return 'Các hạng GPLX';
      case 'age':
        return 'Hỏi về tuổi (T)';
      case 'rules':
        return 'Cao tốc / đường hầm / nơi hạn chế';
      case 'priority':
        return 'Nhất chớm – Nhì ưu – Tam – Tứ';
      case 'signs':
        return 'Biển báo & nhóm biển';
      case 'speed':
        return 'Tốc độ tối đa';
      case 'concept':
        return 'Khái niệm & quy tắc nhanh';
      case 'transport':
        return 'Nghiệp vụ vận tải';
      case 'technic':
        return 'Kỹ thuật lái xe';
      case 'mechanic':
        return 'Cấu tạo & sửa chữa';
      default:
        return 'Mẹo ghi nhớ';
    }
  }

  // ===================== 3 Section đầu =====================

  _SectionCard _alcoholSection() {
    return _SectionCard(
      title: 'Nồng độ cồn',
      subtitle: '1 mẹo',
      colors: const [Color(0xFFEC6F66), Color(0xFFF3A183)],
      children: const [
        _TipBlock(
          title: 'Bị nghiêm cấm',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người điều khiển xe mô tô, ô tô, máy kéo trên đường mà '
                    'trong máu hoặc hơi thở có nồng độ cồn: BỊ NGHIÊM CẤM.',
              ),
              SizedBox(height: 10),
              NoteBox(
                text: 'Nghiêm cấm tuyệt đối!',
                type: NoteType.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _SectionCard _distanceSection() {
    return _SectionCard(
      title: 'Khoảng cách an toàn',
      subtitle: '2 mẹo',
      colors: const [Color(0xFF56CCF2), Color(0xFF2F80ED)],
      children: const [
        _TipBlock(
          title: 'Công thức nhớ nhanh',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bullet('35m nếu V = 60 km/h'),
              _Bullet('55m nếu 60 < V ≤ 80'),
              _Bullet('70m nếu 80 < V ≤ 100'),
              _Bullet('100m nếu 100 < V ≤ 120'),
              SizedBox(height: 10),
              NoteBox(
                text: 'Mẹo: 35-55-70-100 (tăng dần 20-15-30)',
                type: NoteType.info,
                icon: Icons.tips_and_updates,
              ),
            ],
          ),
        ),
        _TipBlock(
          title: 'Dưới 60km/h',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chủ động và đảm bảo khoảng cách'),
              SizedBox(height: 10),
              NoteBox(
                text: 'Không có quy định cụ thể',
                type: NoteType.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _SectionCard _licenseSection() {
    return _SectionCard(
      title: 'Các hạng GPLX',
      subtitle: '4 mẹo',
      colors: const [Color(0xFF9C27B0), Color(0xFFE91E63)],
      children: const [
        _TipBlock(
          title: 'Hạng A1',
          body: Text('Xe mô tô hai bánh ≤ 125 cm³ hoặc ≤ 11 kW.'),
        ),
        _TipBlock(
          title: 'Hạng A',
          body: Text('Xe mô tô hai bánh > 125 cm³ hoặc > 11 kW + xe hạng A1.'),
        ),
        _TipBlock(
          title: 'Hạng B',
          body: Text(
              'Xe ≤ 08 chỗ (không kể lái xe); ô tô tải & chuyên dùng ≤ 3.500 kg; kéo rơ moóc ≤ 750 kg.'),
        ),
        _TipBlock(
          title: 'Mẹo nhớ hạng C, D',
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bullet('C1 > B (3.500–7.500 kg)'),
              _Bullet('C > C1 (>7.500 kg)'),
              _Bullet('D1: 08–16 chỗ'),
              _Bullet('D2: 16–29 chỗ'),
              _Bullet('D: >29 chỗ'),
              SizedBox(height: 10),
              NoteBox(
                text: 'Số chỗ càng lớn thì hạng càng cao!',
                type: NoteType.info,
                icon: Icons.lightbulb,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===================== Các section còn lại =====================

  _SectionCard _buildAgeSection() {
    return _SectionCard(
      title: 'Hỏi về tuổi (T)',
      subtitle: '1 nhóm mẹo',
      colors: const [Color(0xFF00B09B), Color(0xFF96C93D)],
      children: const [
        _TipBlock(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Bullet('Tối đa lái xe >29 chỗ: Nam 57, Nữ 55.'),
              _Bullet('Độ tuổi lấy bằng theo hạng: cách nhau 3 tuổi.'),
              _Bullet('Xe dưới 50cm³: 16 tuổi.'),
              _Bullet('A1, A, B1, B, C1: 18 tuổi.'),
              _Bullet('C, BE: 21 tuổi.'),
              _Bullet('D1, D2, C1E, CE: 24 tuổi.'),
              _Bullet('D, D1E, D2E, DE: 27 tuổi.'),
            ],
          ),
        ),
      ],
    );
  }

  _SectionCard _buildProhibitionsSection() {
    return _SectionCard(
      title: 'Cao tốc / đường hầm / nơi hạn chế',
      subtitle: 'Mẹo không được làm',
      colors: const [Color(0xFFfbab66), Color(0xFFf7418c)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Không quay đầu, không lùi, không vượt.',
            'Không vượt trên cầu hẹp một làn.',
            'Không quay đầu tại phần đường dành cho người đi bộ.',
            'Cấm lùi ở khu vực cấm dừng và nơi giao nhau.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildPrioritySection() {
    return _SectionCard(
      title: 'Nhất chớm – Nhì ưu – Tam đường – Tứ hướng',
      subtitle: 'Thứ tự ưu tiên',
      colors: const [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Nhất chớm: Xe nào chớm vạch trước thì đi trước.',
            'Nhì ưu: Xe ưu tiên (Hỏa–Sự–An–Thương).',
            'Tam đường: Xe ở đường chính/ưu tiên.',
            'Tứ hướng: Bên phải trống – Rẽ phải – Đi thẳng – Rẽ trái.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildSignsSection() {
    return _SectionCard(
      title: 'Biển báo & nhóm biển',
      subtitle: '5 nhóm chính',
      colors: const [Color(0xFFf7971e), Color(0xFFffd200)],
      children: const [
        _TipBlock(
          title: 'Biển cấm – chuỗi ghi nhớ',
          body: _Bullets([
            'Cấm ô tô (gồm mô tô 3 bánh, Xe Lam, xe khách) → Cấm xe tải → Cấm máy kéo → Cấm rơ moóc/sơ mi rơ moóc.',
          ]),
        ),
        _TipBlock(
          title: '5 nhóm biển báo hiệu',
          body: _Bullets([
            'Nguy hiểm: tam giác vàng.',
            'Cấm: vòng tròn đỏ.',
            'Hiệu lệnh: vòng tròn xanh.',
            'Chỉ dẫn: vuông/ chữ nhật xanh.',
            'Biển phụ: trắng đen – hiệu lực nằm ở biển phụ khi có đặt.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildSpeedSection() {
    return _SectionCard(
      title: 'Tốc độ tối đa',
      subtitle: 'Trong/ngoài KDC & cao tốc',
      colors: const [Color(0xFFee0979), Color(0xFFff6a00)],
      children: const [
        _TipBlock(
          title: 'TRONG khu vực đông dân cư',
          body: _Bullets([
            '60 km/h: Đường đôi hoặc 1 chiều ≥ 2 làn cơ giới.',
            '50 km/h: Đường 2 chiều hoặc 1 chiều 1 làn cơ giới.',
          ]),
        ),
        _TipBlock(
          title: 'NGOÀI khu vực đông dân cư – đường đôi / 1 chiều ≥ 2 làn',
          body: _Bullets([
            '90: ô tô con; khách ≤30 chỗ; tải ≤3.5t.',
            '80: khách >30 chỗ; tải >3.5t (trừ xi téc).',
            '70: buýt, đầu kéo kéo sơ mi rơ moóc, mô tô, chuyên dùng.',
            '60: kéo rơ moóc/xe khác, trộn vữa/bê tông, xi téc.',
          ]),
        ),
        _TipBlock(
          title: 'NGOÀI KDC – đường 2 chiều / 1 chiều 1 làn',
          body: _Bullets([
            '80: ô tô con; khách ≤30 chỗ; tải ≤3.5t.',
            '70: khách >30 chỗ; tải >3.5t (trừ xi téc).',
            '60: buýt, đầu kéo kéo sơ mi rơ moóc, mô tô, chuyên dùng.',
            '50: kéo rơ moóc/xe khác, trộn vữa/bê tông, xi téc.',
          ]),
        ),
        _TipBlock(
          title: 'Khác',
          body: _Bullets([
            'Xe gắn máy / máy chuyên dùng (trừ cao tốc): 40 km/h.',
            'Trên cao tốc: tuân thủ tốc độ tối đa/tối thiểu và không vượt quá 120 km/h.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildConceptsSection() {
    return _SectionCard(
      title: 'Khái niệm & quy tắc nhanh',
      subtitle: 'Mẹo chọn đáp án',
      colors: const [Color(0xFF12c2e9), Color(0xFFc471ed)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Câu có “bị nghiêm cấm/không cho phép/không được phép”: chọn đáp án đó.',
            'Tốc độ chậm đi về bên phải; chỉ bấm còi 05:00–22:00; trong đô thị dùng đèn chiếu gần.',
            'Không lắp còi/đèn sai thiết kế; mô tô không kéo xe khác; 05 năm không cấp lại nếu khai báo mất bằng rồi dùng.',
            'Chuyển làn phải có tín hiệu; xe thô sơ đi làn trong cùng.',
            'Ưu tiên đường sắt tại giao cắt; nhường xe ưu tiên có tín hiệu.',
            'Không vượt ở đường vòng/khuất tầm nhìn; có vạch người đi bộ thì nhường.',
            'Dừng/đỗ cách lề ≤0.25m; trên đường hẹp cách xe khác 20m.',
            'Đường có giải phân cách = đường đôi.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildTransportOpsSection() {
    return _SectionCard(
      title: 'Nghiệp vụ vận tải',
      subtitle: 'Quy định thời gian',
      colors: const [Color(0xFF43cea2), Color(0xFF185a9d)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Không lái liên tục quá 4 giờ; không làm việc quá 10 giờ/ngày.',
            'Không tự ý thay đổi vị trí đón/trả khách.',
            'Hàng nguy hiểm phải có giấy phép.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildDrivingTechniqueSection() {
    return _SectionCard(
      title: 'Kỹ thuật lái xe',
      subtitle: 'Mẹo thao tác',
      colors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Mô tô xuống dốc dài: dùng cả phanh trước & sau.',
            'Khởi hành AT: đạp phanh chân hết hành trình; MT: đạp côn hết hành trình.',
            'Phanh tay: bóp khóa hãm, đẩy cần về phía trước.',
            'Qua đường sắt không rào: dừng cách 5m, hạ kính, tắt âm thanh, quan sát.',
            'Mở cửa xe: quan sát rồi hé mở.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildMechanicsSection() {
    return _SectionCard(
      title: 'Cấu tạo & sửa chữa',
      subtitle: 'Thông số hay hỏi',
      colors: const [Color(0xFF00c6ff), Color(0xFF0072ff)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Kính chắn gió: loại kính an toàn.',
            'Còi: 90–115 dB.',
            'Diesel không nổ: nhiên liệu lẫn tạp chất.',
            'Dây đai an toàn có cơ cấu hãm khi giật đột ngột.',
            'Động cơ 4 kỳ: pít tông 4 hành trình.',
            'Hệ bôi trơn giảm ma sát; Ắc quy tích trữ điện.',
            'Niên hạn ô tô >9 chỗ: 20 năm; ô tô tải: 25 năm.',
            'Truyền lực truyền mô-men tới bánh; ly hợp truyền/ngắt từ động cơ tới hộp số; hộp số đảm bảo số lùi.',
            'Hệ thống lái đổi hướng; hệ thống phanh giúp giảm tốc.',
            'Khởi động xe tự động: phải đạp phanh.',
          ]),
        ),
      ],
    );
  }

  _SectionCard _buildIntersectionSection() {
    return _SectionCard(
      title: 'Các quy tắc sa hình khác',
      subtitle: 'Ưu tiên & dốc',
      colors: const [Color(0xFFff9966), Color(0xFFff5e62)],
      children: const [
        _TipBlock(
          body: _Bullets([
            'Không vòng xuyến: Xe vào trước – Xe ưu tiên – Đường ưu tiên – Cùng cấp (phải trống → rẽ phải → đi thẳng → rẽ trái).',
            'Giao nhau cùng cấp có vòng xuyến: chưa vào ưu tiên bên phải; đã vào ưu tiên xe từ trái tới.',
            'Xe xuống dốc phải nhường xe đang lên dốc.',
          ]),
        ),
      ],
    );
  }
}

// ===================== Local widgets (có giãn full-width) ====================

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle; // ví dụ: "1 mẹo", "2 mẹo"
  final List<Widget> children;
  final List<Color> colors; // 2 màu để tạo gradient

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            // Header gradient giống hình mẫu
            Container(
              decoration: AppTheme.headerGradient(colors[0], colors[1]),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            )),
                        const SizedBox(height: 2),
                        Text(subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.expand_more, color: Colors.white),
                ],
              ),
            ),
            // Body (GIÃN FULL-WIDTH CHO Ô CON)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch, // cho ô con full-width, bằng nhau
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Khối nội dung (trắng, bo tròn) – dùng cho mỗi “mẹo”
class _TipBlock extends StatelessWidget {
  final String? title;
  final Widget body;

  const _TipBlock({this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.softSurface(context),
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 8),
          ],
          body,
        ],
      ),
    );
  }
}

// ===================== Bullets helper =======================================

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets(this.items);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => _Bullet(e)).toList(),
    );
  }
}
