import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter_app/presentation/login/pages/login_page.dart';
import 'package:supabase_flutter_app/data/models/todo.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_bloc.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_event.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_state.dart';
import 'package:supabase_flutter_app/presentation/todos/widgets/edit_todo_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosBloc(),
      child: HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageView> {
  final _supabase = Supabase.instance.client;
  final _taskController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<TodosBloc>().add(LoadTodos());
  }
  void _onSearchChanged() {
    // Gửi event SearchTodos khi nội dung search input thay đổi
    context.read<TodosBloc>().add(SearchTodos(query: _searchController.text));
  }

  Future<void> _addTodo() async {
    if (_taskController.text.isNotEmpty) {
      context.read<TodosBloc>().add(AddTodo(
        name: _taskController.text,
        priority: 'Medium',
      ));
      _taskController.clear();
    }
  }

  Future<void> _toggleTodoCompletion(Todo todo) async {
    context.read<TodosBloc>().add(ToggleTodoCompletion(todo: todo));
  }

  Future<void> _deleteTodo(String id) async {
    context.read<TodosBloc>().add(DeleteTodo(id: id));
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('TODO Application', style: TextStyle(color: Colors.white)),
        actions: [
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text('Filter:', style: TextStyle(color: Colors.white70)),
                  SizedBox(width: 8),
                  Expanded(
                    child: BlocBuilder<TodosBloc, TodosState>(
                      builder: (context, state) {
                        return DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: Colors.grey[900],
                          value: state.filterBy.toLowerCase() == 'all'
                              ? 'All'
                              : state.filterBy.toLowerCase() == 'completed'
                              ? 'Completed'
                              : 'Incomplete',
                          style: TextStyle(color: Colors.white),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                          underline: Container(height: 1, color: Colors.white70),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<TodosBloc>().add(ChangeFilter(filterBy: value.toLowerCase()));
                            }
                          },
                          items: [
                            DropdownMenuItem(value: 'All', child: Text('All', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'Incomplete', child: Text('Incomplete', style: TextStyle(color: Colors.white))),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Sort by:', style: TextStyle(color: Colors.white70)),
                  SizedBox(width: 8),
                  Expanded(
                    child: BlocBuilder<TodosBloc, TodosState>(
                      builder: (context, state) {
                        // Determine the displayed value based on the current state.sortBy
                        String displayValue;
                        switch (state.sortBy) {
                          case 'newest':
                            displayValue = 'Newest';
                            break;
                          case 'oldest':
                            displayValue = 'Oldest';
                            break;
                          case 'priority_high_low':
                             displayValue = 'Priority (High-Low)';
                             break;
                          case 'priority_low_high':
                             displayValue = 'Priority (Low-High)';
                             break;
                          default:
                            displayValue = 'Newest'; // Default case
                        }

                        return DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: Colors.grey[900],
                          value: state.sortBy,
                          style: TextStyle(color: Colors.white),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                          underline: Container(height: 1, color: Colors.white70),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<TodosBloc>().add(ChangeSort(sortBy: value));
                            }
                          },
                          items: [
                            DropdownMenuItem(value: 'newest', child: Text('Newest', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'oldest', child: Text('Oldest', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'priority_high_low', child: Text('Priority (High-Low)', style: TextStyle(color: Colors.white))),
                            DropdownMenuItem(value: 'priority_low_high', child: Text('Priority (Low-High)', style: TextStyle(color: Colors.white))),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<TodosBloc, TodosState>(
        listener: (context, state) {
          if (state.status == TodosStatus.failure) {
            _showDialog('Không thực hiện được hành động!');
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController, // Sử dụng _searchController
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Search Content', // Hint text cho tìm kiếm
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey), // Icon search
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: state.searchQuery.isNotEmpty ? IconButton( // Thêm nút clear search
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          // Tự động kích hoạt search khi clear
                        },
                      ) : null,
                    ),
                    // Listener đã được thêm trong initState
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter new Todo',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: _addTodo,
                        child: Text('Add'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text('Current Todos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  state.status == TodosStatus.loading
                      ? Center(child: CircularProgressIndicator())
                      : state.todos.isEmpty
                      ? Center(child: Text('No todos yet.', style: TextStyle(color: Colors.white70)))
                      : ListView.separated(
                    physics: NeverScrollableScrollPhysics(), // Ngăn ListView tự cuộn
                    shrinkWrap: true, // Cho phép ListView co lại vừa đủ nội dung
                    itemCount: state.todos.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<TodosBloc>(context),
                              child: EditTodoDialog(todo: todo),
                            ),
                          );
                        },
                        child: Container(
                          color: todo.status ? Colors.grey[900] : Colors.transparent,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: todo.status,
                                  onChanged: (value) => _toggleTodoCompletion(todo),
                                  activeColor: Colors.blue,
                                  checkColor: Colors.white,
                                ),
                                Expanded(
                                  child: Text(
                                    todo.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      decoration: todo.status ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => _deleteTodo(todo.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}