import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(title: "Github Activity"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  bool? success;
  List<dynamic> events = [];

  Future<void> fetchData(String username) async {
    setState(() {
      isLoading = true;
      success = null;
    });
    final url = Uri.parse("https://api.github.com/users/$username/events");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
          success = true;
        });
        return;
      } else if (response.statusCode == 404) {
        setState(() {
          events = [];
          success = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("404: user not found.")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (error) {
      setState(() {
        success = false;
        events = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $error")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildItem(dynamic event) {
    final type = event["type"];
    final repoName = event["repo"]?["name"] ?? "Unknown";
    List<String> commitMessages = [];

    if (type == "PushEvent") {
      final commits = event['payload']['commits'] ?? [];
      commitMessages = List<String>.from(commits.map((c) => c['message']));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(repoName),
        leading: CircleAvatar(
          maxRadius: 20,
          child: Image.network(event["actor"]["avatar_url"]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Type: $type"),
            ...commitMessages.map((msg) => Text("• $msg")),
            Text(event['created_at']),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Username"),
                      controller: _controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your Github username here.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _controller.text.trim();
                          if (_formKey.currentState!.validate()) {
                            fetchData(_controller.text.trim());
                          }
                        },
                        child: const Text('Search'),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              if (isLoading)
                Center(child: const CircularProgressIndicator())
              else if (success == true)
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return buildItem(events[index]);
                    },
                  ),
                )
              else if (success == false)
                const Text("No events found."),
            ],
          ),
        ),
      ),
    );
  }
}
