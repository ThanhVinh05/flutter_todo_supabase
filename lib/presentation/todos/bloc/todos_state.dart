import 'package:supabase_flutter_app/data/models/todo.dart';

enum TodosStatus { initial, loading, success, failure }

class TodosState {
  final TodosStatus status;
  final List<Todo> todos;
  final String filterBy;
  final String sortBy;
  final String searchQuery;

  TodosState({
    this.status = TodosStatus.initial,
    this.todos = const [],
    this.filterBy = 'all',
    this.sortBy = 'newest',
    this.searchQuery = '',
  });

  TodosState copyWith({
    TodosStatus? status,
    List<Todo>? todos,
    String? filterBy,
    String? sortBy,
    String? searchQuery,
  }) {
    return TodosState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filterBy: filterBy ?? this.filterBy,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}