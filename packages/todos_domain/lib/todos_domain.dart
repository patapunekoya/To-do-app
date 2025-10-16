/// Barrel file cho module todos_domain
/// - Nơi export tập trung để bên ngoài import gọn gàng.
/// - Ví dụ: `import 'package:todos_domain/todos_domain.dart';`
library todos_domain;

export 'src/entities/todo.dart';
export 'src/value_objects/title_vo.dart';
export 'src/repositories/todos_repository.dart';

export 'src/usecases/add_todo.dart';
export 'src/usecases/update_todo.dart';
export 'src/usecases/toggle_complete.dart';
export 'src/usecases/delete_todo.dart';
export 'src/usecases/get_todos_paginated.dart';
