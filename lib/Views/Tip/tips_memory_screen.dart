import 'package:flutter/material.dart';
import '../../Components/section_card.dart';
import '../../Components/note_box.dart';

class TipsMemoryScreen extends StatelessWidget {
  const TipsMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MẸO ghi nhớ 600 câu GPLX'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // ===== Section 1: Nồng độ cồn =====
          SectionCard(
            title: 'Nồng độ cồn',
            subtitle: '1 mẹo',
            colors: const [Color(0xFFEC6F66), Color(0xFFF3A183)],
            children: [
              TipBlock(
                title: 'Bị nghiêm cấm',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
          ),

          // ===== Section 2: Khoảng cách an toàn =====
          SectionCard(
            title: 'Khoảng cách an toàn',
            subtitle: '2 mẹo',
            colors: const [Color(0xFF56CCF2), Color(0xFF2F80ED)],
            children: [
              TipBlock(
                title: 'Công thức nhớ nhanh',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
              TipBlock(
                title: 'Dưới 60km/h',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
          ),

          // ===== Section 3: Các hạng GPLX =====
          SectionCard(
            title: 'Các hạng GPLX',
            subtitle: '4 mẹo',
            colors: const [Color(0xFF9C27B0), Color(0xFFE91E63)],
            children: [
              TipBlock(
                title: 'Hạng A1',
                body: const Text(
                  'Xe mô tô hai bánh ≤ 125 cm³ hoặc ≤ 11 kW.',
                ),
              ),
              TipBlock(
                title: 'Hạng A',
                body: const Text(
                  'Xe mô tô hai bánh > 125 cm³ hoặc > 11 kW + xe hạng A1.',
                ),
              ),
              TipBlock(
                title: 'Hạng B',
                body: const Text(
                  'Xe ≤ 08 chỗ (không kể lái xe); ô tô tải & chuyên dùng ≤ 3.500 kg; kéo rơ moóc ≤ 750 kg.',
                ),
              ),
              TipBlock(
                title: 'Mẹo nhớ hạng C, D',
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
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
          ),

          // ===== Các nhóm / mẹo khác (mẫu thêm nhanh) =====
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
        ],
      ),
    );
  }

  // ==== BELOW: các khối mở rộng – dữ liệu hardcode gọn gàng ====

  static SectionCard _buildAgeSection() {
    return SectionCard(
      title: 'Hỏi về tuổi (T)',
      subtitle: '1 nhóm mẹo',
      colors: const [Color(0xFF00B09B), Color(0xFF96C93D)],
      children: [
        TipBlock(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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

  static SectionCard _buildProhibitionsSection() {
    return SectionCard(
      title: 'Cao tốc / đường hầm / nơi hạn chế',
      subtitle: 'Mẹo không được làm',
      colors: const [Color(0xFFfbab66), Color(0xFFf7418c)],
      children: const [
        TipBlock(
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

  static SectionCard _buildPrioritySection() {
    return SectionCard(
      title: 'Nhất chớm – Nhì ưu – Tam đường – Tứ hướng',
      subtitle: 'Thứ tự ưu tiên',
      colors: const [Color(0xFF36D1DC), Color(0xFF5B86E5)],
      children: const [
        TipBlock(
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

  static SectionCard _buildSignsSection() {
    return SectionCard(
      title: 'Biển báo & nhóm biển',
      subtitle: '5 nhóm chính',
      colors: const [Color(0xFFf7971e), Color(0xFFffd200)],
      children: const [
        TipBlock(
          title: 'Biển cấm – chuỗi ghi nhớ',
          body: _Bullets([
            'Cấm ô tô (gồm mô tô 3 bánh, Xe Lam, xe khách) → Cấm xe tải → Cấm máy kéo → Cấm rơ moóc/sơ mi rơ moóc.',
          ]),
        ),
        TipBlock(
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

  static SectionCard _buildSpeedSection() {
    return SectionCard(
      title: 'Tốc độ tối đa',
      subtitle: 'Trong/ngoài KDC & cao tốc',
      colors: const [Color(0xFFee0979), Color(0xFFff6a00)],
      children: const [
        TipBlock(
          title: 'TRONG khu vực đông dân cư',
          body: _Bullets([
            '60 km/h: Đường đôi hoặc 1 chiều ≥ 2 làn cơ giới.',
            '50 km/h: Đường 2 chiều hoặc 1 chiều 1 làn cơ giới.',
          ]),
        ),
        TipBlock(
          title: 'NGOÀI khu vực đông dân cư – đường đôi / 1 chiều ≥ 2 làn',
          body: _Bullets([
            '90: ô tô con; khách ≤30 chỗ; tải ≤3.5t.',
            '80: khách >30 chỗ; tải >3.5t (trừ xi téc).',
            '70: buýt, đầu kéo kéo sơ mi rơ moóc, mô tô, chuyên dùng.',
            '60: kéo rơ moóc/xe khác, trộn vữa/bê tông, xi téc.',
          ]),
        ),
        TipBlock(
          title: 'NGOÀI KDC – đường 2 chiều / 1 chiều 1 làn',
          body: _Bullets([
            '80: ô tô con; khách ≤30 chỗ; tải ≤3.5t.',
            '70: khách >30 chỗ; tải >3.5t (trừ xi téc).',
            '60: buýt, đầu kéo kéo sơ mi rơ moóc, mô tô, chuyên dùng.',
            '50: kéo rơ moóc/xe khác, trộn vữa/bê tông, xi téc.',
          ]),
        ),
        TipBlock(
          title: 'Khác',
          body: _Bullets([
            'Xe gắn máy / máy chuyên dùng (trừ cao tốc): 40 km/h.',
            'Trên cao tốc: tuân thủ tốc độ tối đa/tối thiểu và không vượt quá 120 km/h.',
          ]),
        ),
      ],
    );
  }

  static SectionCard _buildConceptsSection() {
    return SectionCard(
      title: 'Khái niệm & quy tắc nhanh',
      subtitle: 'Mẹo chọn đáp án',
      colors: const [Color(0xFF12c2e9), Color(0xFFc471ed)],
      children: const [
        TipBlock(
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

  static SectionCard _buildTransportOpsSection() {
    return SectionCard(
      title: 'Nghiệp vụ vận tải',
      subtitle: 'Quy định thời gian',
      colors: const [Color(0xFF43cea2), Color(0xFF185a9d)],
      children: const [
        TipBlock(
          body: _Bullets([
            'Không lái liên tục quá 4 giờ; không làm việc quá 10 giờ/ngày.',
            'Không tự ý thay đổi vị trí đón/trả khách.',
            'Hàng nguy hiểm phải có giấy phép.',
          ]),
        ),
      ],
    );
  }

  static SectionCard _buildDrivingTechniqueSection() {
    return SectionCard(
      title: 'Kỹ thuật lái xe',
      subtitle: 'Mẹo thao tác',
      colors: const [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
      children: const [
        TipBlock(
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

  static SectionCard _buildMechanicsSection() {
    return SectionCard(
      title: 'Cấu tạo & sửa chữa',
      subtitle: 'Thông số hay hỏi',
      colors: const [Color(0xFF00c6ff), Color(0xFF0072ff)],
      children: const [
        TipBlock(
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

  static SectionCard _buildIntersectionSection() {
    return SectionCard(
      title: 'Các quy tắc sa hình khác',
      subtitle: 'Ưu tiên & dốc',
      colors: const [Color(0xFFff9966), Color(0xFFff5e62)],
      children: const [
        TipBlock(
          body: _Bullets([
            'Không vòng xuyến: Xe vào trước – Xe ưu tiên – Đường ưu tiên – Cùng cấp (phải trống → rẽ phải → thẳng → rẽ trái).',
            'Giao nhau cùng cấp có vòng xuyến: chưa vào ưu tiên bên phải; đã vào ưu tiên xe từ trái tới.',
            'Xe xuống dốc phải nhường xe đang lên dốc.',
          ]),
        ),
      ],
    );
  }
}

/// Bullet đơn
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
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Nhiều bullet gộp nhanh
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
