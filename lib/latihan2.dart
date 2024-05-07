import 'package:flutter/material.dart'; // Import package untuk membuat aplikasi Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Import package untuk menggunakan Flutter Bloc
import 'package:http/http.dart' as http; // Import package untuk melakukan permintaan HTTP
import 'dart:convert'; // Import package untuk mengubah data JSON ke Dart

// Kelas untuk menyimpan informasi tentang sebuah universitas
class UnivPage {
  String name; // Variabel untuk menyimpan nama universitas
  String alphaTwoCode; // Variabel untuk menyimpan kode dua huruf universitas
  String country; // Variabel untuk menyimpan negara universitas
  List<String> domains; // Variabel untuk menyimpan domain universitas
  List<String> webPages; // Variabel untuk menyimpan halaman web universitas

  // Konstruktor untuk menginisialisasi objek UnivPage
  UnivPage({required this.name, required this.alphaTwoCode, required this.country, required this.domains, required this.webPages});
}

// Enum untuk menentukan event
enum UnivEvent { fetch }

// Kelas untuk mengelola state aplikasi dengan Bloc
class UnivBloc extends Bloc<UnivEvent, List<UnivPage>> {
  UnivBloc() : super([]); // Inisialisasi state awal dengan list kosong

  @override
  Stream<List<UnivPage>> mapEventToState(UnivEvent event) async* {
    if (event == UnivEvent.fetch) {
      try {
        // Ambil data universitas dari API
        final List<UnivPage> univList = await _fetchUnivData("Indonesia");
        yield univList; // Pemicuan state dengan data universitas
      } catch (e) {
        yield state; // Pemicuan state jika terjadi error
      }
    }
  }

  // Fungsi untuk mengambil data universitas dari API berdasarkan negara
  Future<List<UnivPage>> _fetchUnivData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL API untuk mengambil data universitas berdasarkan negara.
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request ke URL API.
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body); // Mendekode JSON response menjadi list dynamic.
      return json.map((val) => UnivPage(
        name: val["name"],
        alphaTwoCode: val["alpha_two_code"],
        country: val["country"],
        domains: List<String>.from(val["domains"]),
        webPages: List<String>.from(val["web_pages"]),
      )).toList(); // Mengembalikan list UnivPage dari data JSON
    } else {
      throw Exception('Gagal memuat data');
    }
  }
}

void main() {
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Populasi Universitas', // Judul aplikasi
      home: BlocProvider(
        create: (context) => UnivBloc()..add(UnivEvent.fetch), // Membuat instance UnivBloc dan memberikannya ke BlocProvider
        child: UnivScreen(), // Menampilkan UnivScreen sebagai home page
      ),
    );
  }
}

class UnivScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Populasi Universitas'), // Judul untuk appBar
      ),
      body: Column(
        children: [
          CountrySelector(), // Menampilkan CountrySelector untuk memilih negara
          Expanded(
            child: UnivList(), // Menampilkan UnivList untuk menampilkan daftar universitas
          ),
        ],
      ),
    );
  }
}

class CountrySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final univBloc = BlocProvider.of<UnivBloc>(context); // Mendapatkan instance dari UnivBloc
    List<String> countries = ["Indonesia", "Malaysia", "Singapore"]; // Daftar negara ASEAN

    return DropdownButtonFormField<String>(
      value: countries[0], // Nilai yang dipilih pada DropdownButton
      items: countries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(country), // Menampilkan nama negara pada dropdown
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          // Ketika negara dipilih, kirim event untuk mengambil data universitas berdasarkan negara yang dipilih
          univBloc.add(UnivEvent.fetch);
        }
      },
    );
  }
}

class UnivList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnivBloc, List<UnivPage>>(
      builder: (context, univPages) {
        return ListView.builder(
          itemCount: univPages.length, // Jumlah item dalam daftar universitas
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 234, 250, 187),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 233, 241, 168).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Menampilkan data universitas dalam bentuk teks
                  Text(
                    'Nama: ${univPages[index].name}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Kode: ${univPages[index].alphaTwoCode}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Negara: ${univPages[index].country}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Domains: ${univPages[index].domains.join(', ')}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Web Pages: ${univPages[index].webPages.join(', ')}',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
