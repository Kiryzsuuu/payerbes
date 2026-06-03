import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/superhero_provider.dart';
import 'providers/auth_provider.dart' as ap;
import 'providers/admin_provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/userdisplayname_screen.dart';
import 'theme/nyt_theme.dart';

// Daftarkan akun default sekali saja
Future<void> _seedAccounts() async {
  final accounts = [
    {'email': 'maskiryz23@gmail.com', 'password': 'opet123'},
    {'email': 'kiryzsu@gmail.com', 'password': 'opet123'},
  ];
  for (final acc in accounts) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: acc['email']!,
        password: acc['password']!,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code != 'email-already-in-use') {
        debugPrint('Seed ${acc['email']}: ${e.code}');
      }
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _seedAccounts();
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
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'The Hero Times',
        theme: NYTTheme.theme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthGate(),
          UserDisplayNameScreen.id: (_) => const UserDisplayNameScreen(),
        },
      ),
    );
  }
}

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

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) setState(() => _activeUser = user);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.currentUser;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        Navigator.pushNamed(context, UserDisplayNameScreen.id)
            .whenComplete(() => setState(() => getCurrentUser()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, admin, _) {
        final isAdmin = admin.isAdmin;

        final screens = [
          const HomeScreen(),
          const SearchScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
          if (isAdmin) const AdminScreen(),
        ];

        // Pastikan index tidak out of range saat role berubah
        final safeIndex = _currentIndex.clamp(0, screens.length - 1);

        return Scaffold(
          body: IndexedStack(
            index: safeIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(color: NYTColors.midGrey, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              onTap: (i) => setState(() => _currentIndex = i),
              selectedLabelStyle: GoogleFonts.frankRuhlLibre(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
              unselectedLabelStyle: GoogleFonts.frankRuhlLibre(
                  fontSize: 10, letterSpacing: 0.5),
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
                              NetworkImage(_activeUser!.photoURL!))
                      : const Icon(Icons.person_outline),
                  activeIcon: _activeUser?.photoURL != null
                      ? CircleAvatar(
                          radius: 12,
                          backgroundImage:
                              NetworkImage(_activeUser!.photoURL!))
                      : const Icon(Icons.person),
                  label: 'PROFILE',
                ),
                if (isAdmin)
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.admin_panel_settings_outlined),
                    activeIcon: Icon(Icons.admin_panel_settings),
                    label: 'ADMIN',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
