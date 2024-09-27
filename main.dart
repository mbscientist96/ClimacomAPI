import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'weather_service.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> with SingleTickerProviderStateMixin {
  final WeatherService _weatherService = WeatherService();
  String _city = 'São Paulo'; // Cidade padrão
  String? _temperature;
  String? _description;
  bool _isLoading = false;
  bool _hasError = false;

  late AnimationController _controller;
  late Animation<double> _animation;

  void _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await _weatherService.fetchWeather(_city);
      setState(() {
        _temperature = '${data['main']['temp']}°C';
        _description = data['weather'][0]['description'];
        _isLoading = false;
        _controller.forward(from: 0); // Inicia a animação de fade
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward(); // Inicia a animação de escala no cabeçalho
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Evita o erro de overflow
          child: Column(
            children: [
              _buildAnimatedHeader(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCityInput(),
                    SizedBox(height: 20),
                    _isLoading
                        ? SpinKitFadingCircle(
                            color: Colors.blueAccent,
                            size: 50.0,
                          )
                        : _hasError
                            ? Text(
                                'Erro ao carregar o clima!',
                                style: TextStyle(color: Colors.red, fontSize: 18),
                              )
                            : _temperature != null
                                ? _buildAnimatedWeatherInfo()
                                : Text(
                                    'Insira uma cidade para ver o clima',
                                    style: TextStyle(fontSize: 18),
                                  ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Cabeçalho com animação de escala
  Widget _buildAnimatedHeader() {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wb_sunny,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              'Previsão do Tempo',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              'Clima atualizado ao vivo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget de entrada da cidade
  Widget _buildCityInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Digite o nome da cidade',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: _fetchWeather,
        ),
      ),
      onChanged: (value) {
        _city = value;
      },
    );
  }

  // Animação de fade-in para a exibição do clima
  Widget _buildAnimatedWeatherInfo() {
    return AnimatedOpacity(
      opacity: _temperature != null ? 1.0 : 0.0,
      duration: Duration(seconds: 1),
      child: Column(
        children: [
          Text(
            _city,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _temperature!,
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          Text(
            _description!,
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
