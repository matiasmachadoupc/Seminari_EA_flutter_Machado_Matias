import 'package:flutter/material.dart';
import 'package:seminari_flutter/provider/users_provider.dart'; // Corregido
import 'package:provider/provider.dart';
import 'package:seminari_flutter/widgets/Layout.dart';
import 'package:seminari_flutter/models/user.dart'; // Correct import path

class EditarScreen extends StatefulWidget {
  final User user; // Recibe el usuario autenticado

  const EditarScreen({super.key, required this.user});

  @override
  State<EditarScreen> createState() => _EditarScreenState();
}

class _EditarScreenState extends State<EditarScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController nomController;
  late TextEditingController edatController;
  late TextEditingController emailController;
  late TextEditingController passwordController; // Definido correctamente
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.user.name);
    edatController = TextEditingController(text: widget.user.age.toString());
    emailController = TextEditingController(text: widget.user.email);
    passwordController = TextEditingController(); // Inicializado
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nomController.dispose();
    edatController.dispose();
    emailController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormField(controller: nomController, label: 'Nombre', icon: Icons.person),
                  const SizedBox(height: 16),
                  _buildFormField(controller: edatController, label: 'Edad', icon: Icons.cake, keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _buildFormField(controller: emailController, label: 'Correo Electrónico', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      print('Botón "Guardar Cambios" presionado');
                      if (_formKey.currentState!.validate()) {
                        print('Nombre: ${nomController.text}');
                        print('Edad: ${edatController.text}');
                        print('Correo Electrónico: ${emailController.text}');

                        if (nomController.text.isEmpty ||
                            edatController.text.isEmpty ||
                            emailController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Todos los campos son obligatorios'),
                            ),
                          );
                          return;
                        }

                        final provider = Provider.of<UserProvider>(context, listen: false);
                        final updatedUser = User(
                          id: widget.user.id, // Asegúrate de que 'id' no sea null
                          name: nomController.text,
                          age: int.tryParse(edatController.text) ?? 0,
                          email: emailController.text,
                          password: widget.user.password, // Obtiene la contraseña del usuario autenticado
                        );
                        try {
                          final success = await provider.updateUser(updatedUser);
                          if (success) {
                            print('Perfil actualizado correctamente.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil actualizado correctamente')),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } else {
                            throw Exception(provider.error ?? "Error desconocido");
                          }
                        } catch (e) {
                          print('Error al actualizar perfil: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al actualizar: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Guardar Cambios'),
                  ),
                  const Divider(height: 40),
                  _buildFormField(
                    controller: oldPasswordController,
                    label: 'Contraseña Actual',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: newPasswordController,
                    label: 'Nueva Contraseña',
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      print('Botón "Guardar Contraseña" presionado');
                      print('Nueva Contraseña: ${newPasswordController.text}');

                      if (newPasswordController.text.isEmpty) {
                        print('Error: Nueva contraseña vacía');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('La nueva contraseña no puede estar vacía')),
                        );
                        return;
                      }

                      final provider = Provider.of<UserProvider>(context, listen: false);
                      try {
                        final success = await provider.changePassword(widget.user.id!, newPasswordController.text);
                        if (success) {
                          print('Contraseña cambiada correctamente.');

                          // Actualizar los datos del usuario autenticado
                          final updatedUser = User(
                            id: widget.user.id,
                            name: widget.user.name,
                            age: widget.user.age,
                            email: widget.user.email,
                            password: newPasswordController.text, // Actualizar la contraseña
                          );
                          provider.setLoggedInUser(updatedUser.toJson());

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contraseña cambiada correctamente')),
                          );
                          oldPasswordController.clear();
                          newPasswordController.clear();
                        } else {
                          throw Exception(provider.error ?? "Error desconocido");
                        }
                      } catch (e) {
                        print('Error al cambiar contraseña: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al cambiar contraseña: $e')),
                        );
                      }
                    },
                    child: const Text('Guardar Contraseña'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  void _updateUser(BuildContext context) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final updatedUser = User(
      id: widget.user.id,
      name: nomController.text,
      age: int.parse(edatController.text),
      email: emailController.text,
      password: widget.user.password, 
    );

    final success = await provider.updateUser(updatedUser);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile.')));
    }
  }

}