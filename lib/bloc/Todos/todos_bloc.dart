import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/bloc/Todos/todos_event.dart';
import 'package:supabase_flutter_app/bloc/Todos/todos_state.dart';
import 'package:supabase_flutter_app/models/todo.dart';



class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc() : super(
      TodosState(
          status: TodosStatus.initial
      )) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<ToggleTodoCompletion>(_onToggleTodoCompletion);
    on<DeleteTodo>(_onDeleteTodo);
    on<ChangeFilter>(_onChangeFilter);
    on<ChangeSort>(_onChangeSort);
  }

  final _supabase = sb.Supabase.instance.client;

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodosState> emit) async {
    emit(state.copyWith(status: TodosStatus.loading));
    try {
      final response = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy);
      emit(state.copyWith(status: TodosStatus.success, todos: response));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodosState> emit) async {
    try {
      await _supabase.from('todos').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'task': event.task.trim(),
        'is_completed': false,
      });
      final updatedTodos = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy);
      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onToggleTodoCompletion(ToggleTodoCompletion event, Emitter<TodosState> emit) async {
    try {
      await _supabase
          .from('todos')
          .update({'is_completed': !event.todo.isCompleted}).eq('id', event.todo.id);
      final updatedTodos = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy);
      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodosState> emit) async {
    try {
      await _supabase.from('todos').delete().eq('id', event.id);
      final updatedTodos = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy);
      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onChangeFilter(ChangeFilter event, Emitter<TodosState> emit) async {
    emit(state.copyWith(status: TodosStatus.loading, filterBy: event.filterBy));
    try {
      final response = await _fetchTodos(filterBy: event.filterBy, sortBy: state.sortBy);
      emit(state.copyWith(status: TodosStatus.success, todos: response));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onChangeSort(ChangeSort event, Emitter<TodosState> emit) async {
    emit(state.copyWith(status: TodosStatus.loading, sortBy: event.sortBy));
    try {
      final response = await _fetchTodos(filterBy: state.filterBy, sortBy: event.sortBy);
      emit(state.copyWith(status: TodosStatus.success, todos: response));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<List<Todo>> _fetchTodos({String filterBy = 'all', String sortBy = 'newest'}) async {
    var query = _supabase
        .from('todos')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);

    if (filterBy == 'completed') {
      query = query.eq('is_completed', true);
    } else if (filterBy == 'incomplete') {
      query = query.eq('is_completed', false);
    }

    final finalQuery = sortBy == 'newest'
        ? query.order('created_at', ascending: false)
        : query.order('created_at', ascending: true);

    final response = await finalQuery;
    return (response as List).map((todo) => Todo.fromJson(todo)).toList();
  }
}