import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/superhero_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/userdisplayname_screen.dart';
import 'theme/nyt_theme.dart';

// Daftarkan akun default sekali saja — tidak akan error jika sudah ada
Future<void> _seedDefaultAccount() async {
  const email = 'maskiryz23@gmail.com';
  const password = 'opet123';
  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    // email-already-in-use → akun sudah ada, tidak masalah
    if (e.code != 'email-already-in-use') {
      debugPrint('Seed account info: ${e.code}');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _seedDefaultAccount(); // daftarkan maskiryz23@gmail.com / opet123
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const HeroTimesApp());
}

class HeroTimesApp extends StatelessWidget {
  const HeroTimesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ap.AuthProvider()),
        ChangeNotifierProvider(create: (_) => SuperheroProvider()),
      ],
      child: MaterialApp(
        title: 'The Hero Times',
        theme: NYTTheme.theme,
        debugShowCheckedModeBanner: false,
        // ── Named Routes (clue no.2) ──────────────────────────
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthGate(),
          UserDisplayNameScreen.id: (_) => const UserDisplayNameScreen(),
        },
      ),
    );
  }
}

// Otomatis arahkan ke Login atau MainScaffold
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: NYTColors.white,
            body: Center(
              child: CircularProgressIndicator(
                  color: NYTColors.black, strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasData) return const MainScaffold();
        return const LoginScreen();
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _activeUser;

  // getCurrentUser — pola sama seperti di modul (clue no.3 & 6)
  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() => _activeUser = user);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    // Jika belum ada display name, arahkan ke halaman set nama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.currentUser;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        // clue no.11 — pushNamed + whenComplete + setState + getCurrentUser
        Navigator.pushNamed(context, UserDisplayNameScreen.id)
            .whenComplete(() => setState(() {
                  getCurrentUser();
                }));
      }
    });
  }

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: NYTColors.midGrey, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedLabelStyle: GoogleFonts.frankRuhlLibre(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: GoogleFonts.frankRuhlLibre(
            fontSize: 10,
            letterSpacing: 0.5,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'FRONT PAGE',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'SEARCH',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'SAVED',
            ),
            BottomNavigationBarItem(
              icon: _activeUser?.photoURL != null
                  ? CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          NetworkImage(_activeUser!.photoURL!),
                    )
                  : const Icon(Icons.person_outline),
              activeIcon: _activeUser?.photoURL != null
                  ? CircleAvatar(
                      radius: 12,
                      backgroundImage:
                          NetworkImage(_activeUser!.photoURL!),
                      foregroundColor: Colors.white,
                    )
                  : const Icon(Icons.person),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }
}
