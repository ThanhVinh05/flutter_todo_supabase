import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:supabase_flutter_app/presentation/login/pages/login_page.dart';
import 'package:supabase_flutter_app/data/models/todo.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_bloc.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_event.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_state.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<TodosBloc>().add(LoadTodos());
  }

  Future<void> _addTodo() async {
    if (_taskController.text.isNotEmpty) {
      context.read<TodosBloc>().add(AddTodo(task: _taskController.text));
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text('Filter:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 8),
                BlocBuilder<TodosBloc, TodosState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
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
                SizedBox(width: 16),
                Text('Sort by:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 8),
                BlocBuilder<TodosBloc, TodosState>(
                  builder: (context, state) {
                    return DropdownButton<String>(
                      dropdownColor: Colors.grey[900],
                      value: state.sortBy.toLowerCase() == 'newest' ? 'Newest' : 'Oldest',
                      style: TextStyle(color: Colors.white),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white70),
                      underline: Container(height: 1, color: Colors.white70),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<TodosBloc>().add(ChangeSort(sortBy: value.toLowerCase()));
                        }
                      },
                      items: [
                        DropdownMenuItem(value: 'Newest', child: Text('Newest', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'Oldest', child: Text('Oldest', style: TextStyle(color: Colors.white))),
                      ],
                    );
                  },
                ),
              ],
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
                      : ListView.separated( // Loại bỏ Expanded ở đây
                    physics: NeverScrollableScrollPhysics(), // Ngăn ListView tự cuộn
                    shrinkWrap: true, // Cho phép ListView co lại vừa đủ nội dung
                    itemCount: state.todos.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey),
                    itemBuilder: (context, index) {
                      final todo = state.todos[index];
                      return Container(
                        color: todo.isCompleted ? Colors.grey[900] : Colors.transparent,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) => _toggleTodoCompletion(todo),
                                activeColor: Colors.blue,
                                checkColor: Colors.white,
                              ),
                              Expanded(
                                child: Text(
                                  todo.task,
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
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