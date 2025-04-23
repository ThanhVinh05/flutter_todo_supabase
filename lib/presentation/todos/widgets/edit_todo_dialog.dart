import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter_app/data/models/todo.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_bloc.dart';
import 'package:supabase_flutter_app/presentation/todos/bloc/todos_event.dart';

class EditTodoDialog extends StatefulWidget {
  final Todo todo;

  const EditTodoDialog({super.key, required this.todo});

  @override
  _EditTodoDialogState createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _status;
  late String _priority;
  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.todo.name);
    _descriptionController = TextEditingController(text: widget.todo.description ?? '');
    _status = widget.todo.status;
    _priority = widget.todo.priority;
    // Ensure the initial priority is valid, default to Medium if not
    if (!_priorityOptions.contains(_priority)) {
      _priority = 'Medium';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_nameController.text.trim().isEmpty) {
      // Optional: Show an error if the name is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todo name cannot be empty.')),
      );
      return;
    }

    context.read<TodosBloc>().add(
      UpdateTodo(
        id: widget.todo.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null, // Send null if description is empty
        status: _status,
        priority: _priority,
      ),
    );
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('Edit Todo', style: TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Status:', style: TextStyle(color: Colors.grey[400])),
                Checkbox(
                  value: _status,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _status = value;
                      });
                    }
                  },
                  activeColor: Colors.blue,
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.grey[600]!),
                ),
                Text(_status ? 'Completed' : 'Incomplete', style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Priority:', style: TextStyle(color: Colors.grey[400])),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _priority,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                  underline: Container(height: 1, color: Colors.grey[600]!),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _priority = newValue;
                      });
                    }
                  },
                  items: _priorityOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Close dialog
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}