import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter_app/data/models/todo.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_event.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_state.dart';




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
    on<SearchTodos>(_onSearchTodos);
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
      await _supabase.from('todosConvert').insert({
        'user_id': _supabase.auth.currentUser!.id,
        'name': event.name.trim(),
        'status': false,
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
          .from('todosConvert')
          .update({'status': !event.todo.status}).eq('id', event.todo.id);

      final updatedTodos = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy);

      emit(state.copyWith(todos: updatedTodos));
    } catch (e) {

      emit(state.copyWith(status: TodosStatus.failure));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodo event, Emitter<TodosState> emit) async {
    try {
      await _supabase.from('todosConvert').delete().eq('id', event.id);
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

  Future<List<Todo>> _fetchTodos({String filterBy = 'all', String sortBy = 'newest', String searchQuery = '',}) async {
    var query = _supabase
        .from('todosConvert')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id);

    if (filterBy == 'completed') {
      query = query.eq('status', true);
    } else if (filterBy == 'incomplete') {
      query = query.eq('status', false);
    }
    // Apply search
    if (searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    final finalQuery = sortBy == 'newest'
        ? query.order('created_at', ascending: false)
        : query.order('created_at', ascending: true);

    final response = await finalQuery;
    return (response as List).map((todo) => Todo.fromJson(todo)).toList();
  }

  Future<void> _onSearchTodos(SearchTodos event, Emitter<TodosState> emit) async {
    emit(state.copyWith(status: TodosStatus.loading, searchQuery: event.query));
    try {
      final response = await _fetchTodos(filterBy: state.filterBy, sortBy: state.sortBy, searchQuery: event.query,
      );
      emit(state.copyWith(status: TodosStatus.success, todos: response));
    } catch (e) {
      emit(state.copyWith(status: TodosStatus.failure));
    }
  }
}