import 'package:supabase_flutter_app/models/todo.dart';

enum TodosStatus { initial, loading, success, failure }

class TodosState {
  final TodosStatus status;
  final List<Todo> todos;
  final String filterBy;
  final String sortBy;

  TodosState({
    this.status = TodosStatus.initial,
    this.todos = const [],
    this.filterBy = 'all',
    this.sortBy = 'newest',
  });

  TodosState copyWith({
    TodosStatus? status,
    List<Todo>? todos,
    String? filterBy,
    String? sortBy,
    String? errorMessage,
  }) {
    return TodosState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filterBy: filterBy ?? this.filterBy,
      sortBy: sortBy ?? this.sortBy,
    );
  }

}