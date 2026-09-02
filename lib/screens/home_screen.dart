import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'cadastro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _restaurantes = [];

  @override
  void initState() {
    super.initState();
    _carregarRestaurantes();
  }

  void _carregarRestaurantes() async {
    var dados = await DatabaseHelper.instancia.consultarDados('restaurante');

    setState(() {
      _restaurantes = dados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Restaurantes'),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
        itemCount: _restaurantes.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            color: Colors.orange[50],
            child: ListTile(
              leading: Icon(
                Icons.fastfood,
                color: Colors.orange,
              ),
              title: Text(
                _restaurantes[index]['res_nm_restaurante'],
              ),
              subtitle: Text(
                'Culinária: ${_restaurantes[index]['res_ds_tipo_culinaria']}',
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CadastroScreen(),
            ),
          );
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }
}