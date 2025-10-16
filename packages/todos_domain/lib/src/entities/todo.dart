/// =======================
/// Entity: Todo (Domain)
/// =======================
/// - Đại diện cho đối tượng nghiệp vụ cốt lõi trong domain: "một công việc cần làm".
/// - Entity phải "sạch": không chứa code phụ thuộc hạ tầng (DB, HTTP, UI).
/// - Bất biến (immutable): giúp tránh side-effect khó kiểm soát.
///
/// Thuộc tính:
/// - id: định danh duy nhất cho Todo (UUID, Snowflake... do Data layer quyết định).
/// - title: tiêu đề đã được validate bởi Value Object (TitleVO) trước khi gán.
/// - isCompleted: trạng thái hoàn thành.
/// - createdAt: thời điểm tạo, dùng để sắp xếp/paginate ổn định.
class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;

  const Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  /// copyWith cho phép tạo phiên bản mới với thay đổi cục bộ,
  /// vẫn giữ tính bất biến của entity.
  Todo copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'Todo(id: $id, title: $title, isCompleted: $isCompleted, createdAt: $createdAt)';

  /// So sánh bằng theo giá trị để thuận tiện test và quản lý state.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ isCompleted.hashCode ^ createdAt.hashCode;
}
