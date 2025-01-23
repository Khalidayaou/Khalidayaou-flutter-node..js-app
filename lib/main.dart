import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ClientForm(),
    );
  }
}

class ClientForm extends StatefulWidget {
  @override
  _ClientFormState createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<Map<String, dynamic>> _clients = [];
  bool _isEditing = false;
  int _editingClientId = -1;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final response = await http.get(Uri.parse('http://192.168.31.188:3000/clients'));
    if (response.statusCode == 200) {
      setState(() {
        _clients = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des clients')),
      );
    }
  }

  Future<void> _ajouterOuModifierClient() async {
    final String nom = _nomController.text;
    final String prenom = _prenomController.text;
    final int age = int.tryParse(_ageController.text) ?? 0;

    if (nom.isEmpty || prenom.isEmpty || age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs correctement')),
      );
      return;
    }

    final url = _isEditing
        ? 'http://192.168.31.188:3000/updateClient/${_editingClientId}'
        : 'http://192.168.31.188:3000/addClient';

    final method = _isEditing ? http.put : http.post;

    final response = await method(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'nom': nom, 'prenom': prenom, 'age': age}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Client modifié avec succès!' : 'Client ajouté avec succès!')),
      );
      _fetchClients();
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de ${_isEditing ? 'la modification' : 'l\'ajout'} du client')),
      );
    }
  }

  Future<void> _supprimerClient(int id) async {
    final response = await http.delete(
      Uri.parse('http://192.168.31.188:3000/deleteClient/$id'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Client supprimé avec succès!')),
      );
      _fetchClients();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression du client')),
      );
    }
  }

  void _editerClient(Map<String, dynamic> client) {
    setState(() {
      _isEditing = true;
      _editingClientId = client['id'];
      _nomController.text = client['nom'];
      _prenomController.text = client['prenom'];
      _ageController.text = client['age'].toString();
    });
  }

  void _resetForm() {
    setState(() {
      _isEditing = false;
      _editingClientId = -1;
      _nomController.clear();
      _prenomController.clear();
      _ageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(labelText: 'Nom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le nom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _prenomController,
                    decoration: InputDecoration(labelText: 'Prenom'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer le prénom';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer l\'âge';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _ajouterOuModifierClient,
                    child: Text(_isEditing ? 'Modifier' : 'Ajouter'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return ListTile(
                    title: Text('${client['nom']} ${client['prenom']}'),
                    subtitle: Text('Âge: ${client['age']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editerClient(client),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _supprimerClient(client['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}