import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController _nomeController =
      TextEditingController();

  final TextEditingController _culinariaController =
      TextEditingController();

  File? _fotoPrato;

  final String _latitude = '';
  final String _longitude = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _tirarFoto() async {
    final XFile? fotoCapturada =
        await _picker.pickImage(source: ImageSource.camera);

    if (fotoCapturada != null) {
      setState(() {
        _fotoPrato = File(fotoCapturada.path);
      });
    }
  }

  Future<void> _salvarCadastro() async {
    Map<String, dynamic> dadosRestaurante = {
      'res_nm_restaurante': _nomeController.text,
      'res_ds_tipo_culinaria': _culinariaController.text,
      'res_nu_latitude': _latitude,
      'res_nu_longitude': _longitude,
    };
    await DatabaseHelper.instancia.inserirDados(
      'restaurante',
      dadosRestaurante,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Restaurante cadastrado!'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo Cadastro'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do Restaurante',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _culinariaController,
              decoration: InputDecoration(
                labelText: 'Tipo de Culinária',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Foto do Prato:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: _fotoPrato != null
                  ? Image.file(
                      _fotoPrato!,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Text('Nenhuma foto selecionada'),
                    ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _tirarFoto,
              icon: Icon(Icons.camera_alt),
              label: Text('Tirar Foto do Prato'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _salvarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: Text('Salvar Restaurante'),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}