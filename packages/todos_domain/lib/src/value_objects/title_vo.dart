import 'package:core/core.dart';

/// ==============================
/// Value Object: TitleVO (Domain)
/// ==============================
/// - VO đại diện cho một "giá trị" trong domain có ràng buộc/luật.
/// - Trách nhiệm của VO là "validate" dữ liệu đầu vào theo luật nghiệp vụ.
/// - Ở đây: tiêu đề Todo không được rỗng và không quá dài.
///
/// Quy ước sử dụng:
/// - Gọi TitleVO.create(raw) để nhận Either<Failure, TitleVO>.
/// - Nếu Right => hợp lệ; nếu Left => có lỗi ValidationFailure.
///
/// Lợi ích:
/// - Dồn logic validate vào 1 nơi, tránh lặp lại.
/// - Entity nhận giá trị đã hợp lệ, giữ domain sạch hơn.
class TitleVO {
  static const int minLength = 1;
  static const int maxLength = 120;

  final String value;

  const TitleVO._(this.value);

  /// Factory có validate, trả về Either:
  /// - Left(ValidationFailure) nếu không đạt yêu cầu
  /// - Right(TitleVO) nếu hợp lệ
  static Either<Failure, TitleVO> create(String raw) {
    final trimmed = raw.trim();

    if (trimmed.length < minLength) {
      return Left(ValidationFailure('Tiêu đề không được để trống'));
    }
    if (trimmed.length > maxLength) {
      return Left(ValidationFailure('Tiêu đề không vượt quá $maxLength ký tự'));
    }
    return Right(TitleVO._(trimmed));
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TitleVO && runtimeType == other.runtimeType && other.value == value;

  @override
  int get hashCode => value.hashCode;
}
