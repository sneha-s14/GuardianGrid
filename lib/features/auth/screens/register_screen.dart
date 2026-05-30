import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../map/screens/mapscreen.dart';
 
class RegisterScreen extends StatefulWidget { 
  const RegisterScreen({super.key}); 
  @override 
  State<RegisterScreen> createState() => _RegisterScreenState(); 
} 
 
class _RegisterScreenState extends State<RegisterScreen> { 
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false; 
 
  Future<void> _register() async { 
    setState(() => _loading = true); 
    try { 
      final response = await Supabase.instance.client.auth.signUp( 
        email: _emailCtrl.text.trim(), 
        password: _passCtrl.text.trim(), 
      ); 
 
      if (response.user != null) { 
        // Create profile record 
        await Supabase.instance.client.from('profiles').insert({ 
          'id': response.user!.id, 
          'full_name': _nameCtrl.text.trim(), 
        }); 
 
        if (mounted) { 
          Navigator.pushReplacement(context, 
              MaterialPageRoute(builder: (_) => const MapScreen())); 
        } 
      } 
    } on AuthException catch (e) { 
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar( 
          SnackBar(content: Text(e.message), backgroundColor: Colors.red), 
        ); 
      } 
    } finally { 
      setState(() => _loading = false); 
    } 
  } 
 
  @override 
  Widget build(BuildContext context) { 
    return Scaffold( 
      appBar: AppBar(title: const Text('Create Account')), 
      body: Padding( 
        padding: const EdgeInsets.all(24), 
        child: Column( 
          children: [ 
            TextField( 
              controller: _nameCtrl, 
              style: const TextStyle(color: Colors.white), 
              decoration: const InputDecoration( 
                labelText: 'Full Name', 
                prefixIcon: Icon(Icons.person_outline), 
              ), 
            ), 
            const SizedBox(height: 16), 
            TextField( 
              controller: _emailCtrl, 
              style: const TextStyle(color: Colors.white), 
              decoration: const InputDecoration( 
                labelText: 'Email', 
                prefixIcon: Icon(Icons.email_outlined), 
              ), 
            ), 
            const SizedBox(height: 16), 
            TextField( 
              controller: _passCtrl, 
              obscureText: true, 
              style: const TextStyle(color: Colors.white), 
              decoration: const InputDecoration( 
                labelText: 'Password (min 6 characters)', 
                prefixIcon: Icon(Icons.lock_outline), 
              ), 
            ), 
            const SizedBox(height: 24), 
            SizedBox( 
              width: double.infinity, 
              child: ElevatedButton( 
                onPressed: _loading ? null : _register, 
                child: _loading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Create Account', 
                        style: TextStyle(fontSize: 16)), 
              ), 
            ), 
          ], 
        ), 
      ), 
    ); 
  } 
}