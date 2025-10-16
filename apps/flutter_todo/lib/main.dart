import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:get_it/get_it.dart';
import 'package:core/core.dart';
import 'package:todos_data/todos_data.dart';
import 'package:todos_application/todos_application.dart';
import 'package:todos_domain/todos_domain.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Đẩy initializer của các module vào Core
  registerModuleInitializer(registerTodosDataModule);
  registerModuleInitializer(registerTodosApplicationModule);

  // Khởi tạo core (logger) và chạy lần lượt các module initializer ở trên
  await configureCoreDependencies(
    enableLogging: true,
    minLevel: LogLevel.debug,
  );

  // Khóa orientation dọc cho gọn
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Mini',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: BlocProvider(
        create: (_) => sl<TodosBloc>()..add(const TodosInitialLoadRequested(limit: 5)),
        child: const TodosPage(),
      ),
    );
  }
}

/// ===============================
/// UI: TodosPage 
/// ===============================
/// - Thêm todo (TextField + nút Add)
/// - Hiển thị danh sách + checkbox toggle
/// - Vuốt để xóa (Dismissible)
/// - Nhấn giữ để sửa tiêu đề (dialog)
/// - Nút "Load more" khi còn dữ liệu
/// - Kéo xuống để refresh
class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTodo(BuildContext context) {
    final raw = _controller.text;
    if (raw.trim().isEmpty) return;
    context.read<TodosBloc>().add(TodosAddRequested(raw));
    _controller.clear();
  }

  Future<void> _editTodoDialog(BuildContext context, Todo todo) async {
    final tmp = TextEditingController(text: todo.title);
    final updated = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sửa tiêu đề'),
        content: TextField(
          controller: tmp,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nhập tiêu đề mới',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, tmp.text), child: const Text('Lưu')),
        ],
      ),
    );
    if (updated != null && updated.trim().isNotEmpty) {
      context
          .read<TodosBloc>()
          .add(TodosUpdateRequested(id: todo.id, newRawTitle: updated.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodosBloc, TodosState>(
      listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
      listener: (context, state) {
        final err = state.error;
        if (err != null && err.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), behavior: SnackBarBehavior.floating),
          );
        }
      },
      builder: (context, state) {
        final bloc = context.read<TodosBloc>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo Mini'),
            actions: [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: () =>
                    bloc.add(TodosRefreshRequested(limit: state.limit)),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _addTodo(context),
                        decoration: const InputDecoration(
                          labelText: 'Thêm công việc...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () => _addTodo(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    bloc.add(TodosRefreshRequested(limit: state.limit));
                  },
                  child: CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: state.items.length,
                        itemBuilder: (context, index) {
                          final todo = state.items[index];
                          return Dismissible(
                            key: ValueKey('todo-${todo.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.redAccent,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) =>
                                bloc.add(TodosDeleteRequested(todo.id)),
                            child: InkWell(
                              onLongPress: () => _editTodoDialog(context, todo),
                              child: CheckboxListTile(
                                value: todo.isCompleted,
                                onChanged: (_) =>
                                    bloc.add(TodosToggleRequested(todo.id)),
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  'Tạo lúc: ${todo.createdAt.toLocal()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            children: [
                              if (state.status == TodosStatus.loading &&
                                  state.items.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (state.items.isNotEmpty && state.hasMore)
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: state.status == TodosStatus.loading
                                        ? null
                                        : () => bloc.add(
                                              TodosLoadMoreRequested(limit: state.limit),
                                            ),
                                    icon: const Icon(Icons.expand_more),
                                    label: state.status == TodosStatus.loading
                                        ? const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8),
                                            child: SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : const Text('Load more'),
                                  ),
                                ),
                              if (!state.hasMore && state.items.isNotEmpty)
                                const Text(
                                  'Hết dữ liệu.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              if (state.items.isEmpty &&
                                  state.status == TodosStatus.success)
                                const Padding(
                                  padding: EdgeInsets.only(top: 24),
                                  child: Text(
                                    'Danh sách trống. Thêm việc mới đi chứ.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
