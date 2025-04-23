import 'package:supabase_flutter_app/data/models/todo.dart';

abstract class TodosEvent {}

class LoadTodos extends TodosEvent {}

class AddTodo extends TodosEvent {
  final String name;
  final String? description;
  final String priority;

  AddTodo({
    required this.name,
    this.description,
    required this.priority,
  });
}

class ToggleTodoCompletion extends TodosEvent {
  final Todo todo;

  ToggleTodoCompletion({
    required this.todo,
  });
}

class UpdateTodo extends TodosEvent {
  final String id;
  final String name;
  final String? description;
  final bool status;
  final String priority;

  UpdateTodo({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.priority,
  });
}

class DeleteTodo extends TodosEvent {
  final String id;

  DeleteTodo({
    required this.id,
  });
}

class ChangeFilter extends TodosEvent {
  final String filterBy; // 'all', 'completed', 'incomplete'

  ChangeFilter({
    required this.filterBy,
  });
}

class ChangeSort extends TodosEvent {
  // Các giá trị có thể là: 'created_at_newest', 'created_at_oldest', 'name_asc', 'name_desc', 'priority_asc', 'priority_desc'
  final String sortBy;

  ChangeSort({
    required this.sortBy,
  });
}

// Thêm event cho chức năng tìm kiếm
class SearchTodos extends TodosEvent {
  final String query;

  SearchTodos({
    required this.query,
  });
}