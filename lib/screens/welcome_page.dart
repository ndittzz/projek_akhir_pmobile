import 'package:flutter/material.dart';
import 'login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00569F),
                Color(0xFF00569F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Aplikasi
                Image.asset(
                  'assets/logos/bg-biru.png',
                  width: 200,
                ),
                const SizedBox(height: 0),

                // Teks Judul
                // const Text(
                //   "WELCOME TO BERITA PEDIA",
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontFamily: 'Poppins',
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //     shadows: [
                //       Shadow(
                //         blurRadius: 4.0,
                //         color: Colors.black38,
                //         offset: Offset(1.0, 1.0),
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 5),

                // Teks Sambutan
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Berita yang Menginspirasi, Fakta yang Terpercaya",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Tombol Mulai
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    "LET'S START",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00569F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
