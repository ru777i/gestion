import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginSreen extends ConsumerStatefulWidget {
  const LoginSreen({super.key});

  @override
  ConsumerState<LoginSreen> createState() => _LoginSreenState();
}

class _LoginSreenState extends ConsumerState<LoginSreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.teal),

        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                      },
                      icon: const Icon(
                        Icons.qr_code_sharp,
                        size: 100,
                        color: Colors.white,
                      ),
                      padding: EdgeInsetsGeometry.all(10),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.deepOrange,), ),
                    ),
                    Text(
                      'StockPro',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Gestion de stock et Vente',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formkey,
                  child: Column(
                    spacing: 15,
                    children: [
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),

                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Entrer votre nom',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _passwordController,
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          hintText: 'Entrer votre mots de passe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsetsGeometry.all(10),
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      Center(child: Text('Pas de compte ? Créer un compte')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
