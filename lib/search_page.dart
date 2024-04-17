import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = "";

  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      // İlk oluşturulduğunda yapılacak başlangıç işlemleri burada gerçekleştirilir.
      // Örneğin, GPS verisi alma, kimlik doğrulama, vb.
      print("initState metodu çağrıldı ve başlangıç işlemleri yapıldı.");

      super.initState();
    }

    void dispose() {
      print("initstate metodu calıstı ve gps verisi logout oldu ");
      super.dispose();
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/c.jpg'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: TextField(
                  onChanged: (value) {
                    selectedCity = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Şehir Seçiniz..',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 20),
                    ),
                  ),
                  cursorColor: Colors.white,
                ),
              ),
              TextButton(
                  onPressed: () async {
                    //şehir için response var mı
                    http.Response response = await http.get(Uri.parse(
                        'https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=b6da7f052ad4eca3c6a257158b7dab4e&units=metric'));
                    if (response.statusCode == 200) {
                      Navigator.pop(context, selectedCity);
                    } else {
                      //uyarı
                      _showMyDialog();
                    }
                  },
                  child: Text("Onayla"))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uyarı!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Şehir Bulunamadı.'),
                Text('Lütfen dikkat ediniz.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Geri Dön',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
