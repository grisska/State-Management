import 'package:flutter/material.dart'; // Mengimpor package 'material.dart' yang merupakan bagian dari Flutter SDK untuk membangun antarmuka pengguna yang kaya.
import 'package:http/http.dart' as http; // Mengimpor package 'http.dart' dengan alias 'http', yang digunakan untuk melakukan permintaan HTTP.
import 'dart:convert'; // Mengimpor library 'dart:convert' untuk mengonversi data JSON.
import 'package:provider/provider.dart'; // Mengimpor package 'provider.dart', yang digunakan untuk manajemen state.

class UnivPage { // Mendefinisikan kelas 'UnivPage' yang memiliki properti untuk menyimpan informasi tentang sebuah universitas.
  String name;
  String alphaTwoCode;
  String country;
  List<String> domains;
  List<String> webPages;

  UnivPage({
    required this.name,
    required this.alphaTwoCode,
    required this.country,
    required this.domains,
    required this.webPages,
  });
}

class Univ with ChangeNotifier { // Mendefinisikan kelas 'Univ' yang mengimplementasikan 'ChangeNotifier'. Kelas ini digunakan untuk menyimpan daftar informasi universitas dan untuk melakukan permintaan HTTP untuk mengambil data universitas.
  List<UnivPage> ListPop = <UnivPage>[];

  Future<void> fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // Menyiapkan URL untuk permintaan API berdasarkan negara yang dipilih.
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP untuk mendapatkan data universitas berdasarkan URL.
    if (response.statusCode == 200) { // Memeriksa apakah permintaan berhasil.
      List<dynamic> json = jsonDecode(response.body); // Mengonversi respon JSON menjadi list dynamic.
      ListPop.clear(); // Menghapus data universitas sebelumnya dari daftar.
      for (var val in json) { // Looping melalui data JSON untuk setiap universitas.
        var name = val["name"];
        var alphaTwoCode = val["alpha_two_code"];
        var country = val["country"];
        var domains = List<String>.from(val["domains"]);
        var webPages = List<String>.from(val["web_pages"]);
        ListPop.add( // Menambahkan informasi universitas ke dalam daftar 'ListPop'.
          UnivPage(
            name: name,
            alphaTwoCode: alphaTwoCode,
            country: country,
            domains: domains,
            webPages: webPages,
          ),
        );
      }
      notifyListeners(); // Memberitahu listener bahwa data telah berubah.
    } else {
      throw Exception('Gagal memuat data'); // Melemparkan exception jika permintaan tidak berhasil.
    }
  }
}

void main() { // Fungsi 'main()' yang menjalankan aplikasi.
  runApp(
    ChangeNotifierProvider( // Membungkus widget 'MyApp' dengan 'ChangeNotifierProvider' untuk menyediakan instance dari 'Univ' ke seluruh aplikasi.
      create: (_) => Univ(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget { // Mendefinisikan kelas 'MyApp' yang merupakan root widget dari aplikasi.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Populasi Universitas',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Populasi Universitas'),
        ),
        body: Column(
          children: [
            CountrySelector(), // Menampilkan widget 'CountrySelector' untuk memilih negara.
            Expanded(
              child: UnivList(), // Menampilkan widget 'UnivList' untuk menampilkan daftar universitas.
            ),
          ],
        ),
      ),
    );
  }
}

class CountrySelector extends StatefulWidget { // Mendefinisikan kelas 'CountrySelector' yang merupakan stateful widget.
  @override
  _CountrySelectorState createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> { // Mendefinisikan kelas '_CountrySelectorState' yang merupakan state dari widget 'CountrySelector'.
  String selectedCountry = "Indonesia"; // Variabel untuk menyimpan negara yang dipilih.
  List<String> countries = ["Indonesia", "Malaysia", "Singapore"]; 

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>( // Menampilkan dropdown button untuk memilih negara.
      value: selectedCountry,
      items: countries.map((String country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(country),
        );
      }).toList(),
      onChanged: (String? newValue) { // Menangani perubahan nilai dropdown.
        if (newValue != null) {
          setState(() { // Memperbarui state dengan negara yang baru dipilih.
            selectedCountry = newValue;
            Provider.of<Univ>(context, listen: false).fetchData(newValue); // Memuat data universitas berdasarkan negara yang baru dipilih.
          });
        }
      },
    );
  }
}

class UnivList extends StatelessWidget { // Mendefinisikan kelas 'UnivList' yang merupakan stateless widget.
  @override
  Widget build(BuildContext context) {
    final univData = Provider.of<Univ>(context); // Mendapatkan data universitas dari provider.
    return Center(
      child: univData.ListPop.isEmpty // Menampilkan spinner jika data universitas belum tersedia.
          ? CircularProgressIndicator()
          : ListView.builder( // Menampilkan daftar universitas dalam bentuk list view.
              itemCount: univData.ListPop.length,
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
                      Text(
                        'Nama: ${univData.ListPop[index].name}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Kode: ${univData.ListPop[index].alphaTwoCode}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Negara: ${univData.ListPop[index].country}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Domains: ${univData.ListPop[index].domains.join(', ')}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Web Pages: ${univData.ListPop[index].webPages.join(', ')}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
