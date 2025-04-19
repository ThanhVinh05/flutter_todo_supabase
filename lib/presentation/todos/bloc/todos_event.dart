import 'package:supabase_flutter_app/data/models/todo.dart';

abstract class TodosEvent  {}

class LoadTodos extends TodosEvent {}

class AddTodo extends TodosEvent {
  final String task;

  AddTodo({
    required this.task
  });
}

class ToggleTodoCompletion extends TodosEvent {
  final Todo todo;

  ToggleTodoCompletion({
    required this.todo
  });
}

class DeleteTodo extends TodosEvent {
  final String id;

  DeleteTodo({
    required this.id
  });
}

class ChangeFilter extends TodosEvent {
  final String filterBy;

  ChangeFilter({
    required this.filterBy
  });
}

class ChangeSort extends TodosEvent {
  final String sortBy;

  ChangeSort({
    required this.sortBy
  });
}