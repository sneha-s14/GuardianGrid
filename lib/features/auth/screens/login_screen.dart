import 'package:flu er/material.dart'; 
import 'package:supabase_flu er/supabase_flu er.dart'; 
import '../../map/screens/map_screen.dart'; 
import 'register_screen.dart'; 
 
class LoginScreen extends StatefulWidget { 
  const LoginScreen({super.key}); 
  @override 
  State<LoginScreen> createState() => _LoginScreenState(); 
} 
 
class _LoginScreenState extends State<LoginScreen> { 
  // Controllers hold the text typed into fields 
  final _emailCtrl = TextEdi ngController(); 
  final _passCtrl = TextEdi ngController(); 
  bool _loading = false; 
 
  Future<void> _signIn() async { 
    // Show loading spinner 
    setState(() => _loading = true); 
    try { 
      await Supabase.instance.client.auth.signInWithPassword( 
        email: _emailCtrl.text.trim(), 
        password: _passCtrl.text.trim(), 
      ); 
      if (mounted) { 
        // Navigate to map screen on success 
        Navigator.pushReplacement( 
          context, 
          MaterialPageRoute(builder: (_) => const MapScreen()), 
        ); 
      } 
    } on AuthExcep on catch (e) { 
      // Show error message 
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
      body: SafeArea( 
        child: Padding( 
          padding: const EdgeInsets.all(24), 
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [ 
              // Logo 
              Container( 
                width: 80, height: 80, 
                decora on: BoxDecora on( 
                  color: const Color(0xFF6C63FF).withOpacity(0.2), 
                  shape: BoxShape.circle, 
                ), 
                child: const Icon(Icons.shield, 
                    size: 48, color: Color(0xFF6C63FF)), 
              ), 
              const SizedBox(height: 16), 
              const Text('GuardianGrid', 
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, 
                      color: Colors.white)), 
              const Text('Urban Safety Intelligence', 
                  style: TextStyle(color: Colors.grey)), 
              const SizedBox(height: 48), 
              TextField( 
                controller: _emailCtrl, 
                keyboardType: TextInputType.emailAddress, 
                style: const TextStyle(color: Colors.white), 
                decora on: const InputDecora on( 
                  labelText: 'Email', 
                  prefixIcon: Icon(Icons.email_outlined), 
                ), 
              ), 
              const SizedBox(height: 16), 
              TextField( 
                controller: _passCtrl, 
                obscureText: true, 
                style: const TextStyle(color: Colors.white), 
                decora on: const InputDecora on( 
                  labelText: 'Password', 
                  prefixIcon: Icon(Icons.lock_outline), 
                ), 
              ), 
              const SizedBox(height: 24), 
              SizedBox( 
                width: double.infinity, 
                child: ElevatedBu on( 
                  onPressed: _loading ? null : _signIn, 
                  child: _loading 
                      ? const SizedBox(height: 20, width: 20, 
                          child: CircularProgressIndicator( 
                              color: Colors.white, strokeWidth: 2)) 
                      : const Text('Sign In', style: TextStyle(fontSize: 16)), 
                ), 
              ), 
              const SizedBox(height: 16), 
              TextBu on( 
                onPressed: () => Navigator.push(context, 
                    MaterialPageRoute(builder: (_) => const RegisterScreen())), 
                child: const Text("Don't have an account? Register", 
                    style: TextStyle(color: Color(0xFF6C63FF))), 
              ), 
            ], 
          ), 
        ), 
      ), 
    ); 
  } 
}