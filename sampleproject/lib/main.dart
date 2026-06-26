import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StudentFormScreen(),
    );
  }
}

class StudentFormScreen extends StatefulWidget {
  const StudentFormScreen({super.key});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers to grab text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();

  List<dynamic> _studentsList = [];
  bool _showDetails = false;

  // Change "localhost" to "10.0.2.2" if using an Android Emulator
  final String insertUrl = "http://localhost/student_api/insert_student.php";
  final String fetchUrl = "http://localhost/student_api/fetch_students.php";

  // POST Request to submit student details
  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse(insertUrl),
          body: {
            "name": _nameController.text,
            "roll_number": _rollController.text,
            "email_id": _emailController.text,
            "cgpa": _cgpaController.text,
          },
        );

        final result = json.decode(response.body);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Status received')),
        );

        if (result['status'] == 'success') {
          _nameController.clear();
          _rollController.clear();
          _emailController.clear();
          _cgpaController.clear();
          if (_showDetails) _fetchData(); // Refresh list if open
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error connecting to backend: $e")),
        );
      }
    }
  }

  // GET Request to fetch student records
  Future<void> _fetchData() async {
    try {
      final response = await http.get(Uri.parse(fetchUrl));
      setState(() {
        _studentsList = json.decode(response.body);
        _showDetails = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching records: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Info Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  TextFormField(
                    controller: _rollController,
                    decoration: const InputDecoration(labelText: 'Roll Number'),
                    validator: (v) => v!.isEmpty ? 'Enter roll number' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email ID'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Enter valid email' : null,
                  ),
                  TextFormField(
                    controller: _cgpaController,
                    decoration: const InputDecoration(labelText: 'CGPA'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => double.tryParse(v!) == null ? 'Enter valid CGPA' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _submitData,
                        child: const Text('Submit'),
                      ),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Show Details'),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const Divider(height: 40),
            if (_showDetails) ...[
              const Text(
                "Stored Student Records",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _studentsList.isEmpty
                  ? const Text("No records found.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _studentsList.length,
                      itemBuilder: (context, index) {
                        final student = _studentsList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text("${student['name']} (${student['roll_number']})"),
                            subtitle: Text("Email: ${student['email_id']}\nCGPA: ${student['cgpa']}"),
                          ),
                        );
                      },
                    ),
            ]
          ],
        ),
      ),
    );
  }
}