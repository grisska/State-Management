import 'package:flutter/material.dart'; // Mengimpor library material dari Flutter untuk membangun UI.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor Flutter Bloc untuk mengelola state aplikasi.
import 'package:http/http.dart' as http; // Mengimpor library http untuk melakukan HTTP requests.
import 'dart:convert'; // Mengimpor library dart:convert untuk mengelola JSON.

// Class untuk menyimpan informasi tentang sebuah universitas
class UnivPage {
  String name; // Nama universitas
  String alphaTwoCode; // Kode dua huruf universitas
  String country; // Negara universitas
  List<String> domains; // Domain universitas
  List<String> webPages; // Halaman web universitas

  // Konstruktor untuk menginisialisasi objek UnivPage
  UnivPage({
    required this.name,
    required this.alphaTwoCode,
    required this.country,
    required this.domains,
    required this.webPages,
  });
}

// Cubit untuk mengelola state aplikasi
class UnivCubit extends Cubit<List<UnivPage>> {
  UnivCubit() : super([]); // Inisialisasi state awal dengan list kosong

  // Fungsi untuk mengambil data universitas dari API berdasarkan negara
  Future<void> fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL API untuk mengambil data universitas berdasarkan negara.
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request ke URL API.
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body); 
      // Mengupdate state dengan data universitas yang diperoleh dari API
      emit(json.map((val) => UnivPage(
        name: val["name"],
        alphaTwoCode: val["alpha_two_code"],
        country: val["country"],
        domains: List<String>.from(val["domains"]),
        webPages: List<String>.from(val["web_pages"]),
      )).toList());
    } else {
      // Memicu Exception jika gagal mengambil data dari API
      throw Exception('Gagal memuat data');
    }
  }
}

void main() {
  runApp(MyApp()); // Menjalankan aplikasi Flutter.
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Populasi Universitas', // Judul aplikasi.
      home: BlocProvider(
        create: (context) => UnivCubit(), // Membuat instance UnivCubit dan memberikannya ke BlocProvider.
        child: UnivScreen(), // Menampilkan UnivScreen sebagai home page.
      ),
    );
  }
}

class UnivScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Populasi Universitas'), // Judul AppBar.
      ),
      body: Column(
        children: [
          CountrySelector(), // Menampilkan CountrySelector untuk memilih negara.
          Expanded(
            child: UnivList(), // Menampilkan UnivList untuk menampilkan daftar universitas.
          ),
        ],
      ),
    );
  }
}

class CountrySelector extends StatefulWidget {
  @override
  _CountrySelectorState createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  String selectedCountry = "Indonesia"; // Negara yang dipilih default.
  List<String> countries = ["Indonesia", "Malaysia", "Singapore"]; // Daftar negara yang tersedia.

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCountry, // Nilai yang dipilih pada DropdownButton.
      items: countries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(country), // Menampilkan nama negara pada dropdown.
        );
      }).toList(),
      onChanged: (String? newValue) {
        // Mendapatkan instance dari UnivCubit
        final univCubit = BlocProvider.of<UnivCubit>(context);
        if (newValue != null) {
          setState(() {
            // Mengubah nilai selectedCountry dan memanggil fetchData dari univCubit
            selectedCountry = newValue;
            univCubit.fetchData(newValue);
          });
        }
      },
    );
  }
}

class UnivList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnivCubit, List<UnivPage>>(
      builder: (context, univPages) {
        return ListView.builder(
          itemCount: univPages.length, // Jumlah item dalam daftar universitas.
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
