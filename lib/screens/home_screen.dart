import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherServices _weatherService = WeatherServices();
  final TextEditingController _cityController = TextEditingController();

  String _city = 'London';
  Map<String, dynamic>? _currentWeather;
  List<dynamic>? _forecast;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _errorMessage = null; // Clear previous error
    });

    try {
      final current = await _weatherService.fetchCurrentWeather(_city);
      final forecast = await _weatherService.fetch7Weather(_city);

      setState(() {
        _currentWeather = current;
        _forecast = forecast['forecast']['forecastday'];
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'City not found. Please try another city.';
        _currentWeather = null;
        _forecast = null;
      });

      // Optional: Show Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _onCitySubmitted(String value) {
    if (value.trim().isEmpty) return;

    setState(() {
      _city = value.trim();
      _currentWeather = null;
      _forecast = null;
      _errorMessage = null;
    });
    _fetchWeatherData();
  }

  Widget _weatherInfoTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast?.length ?? 0,
        itemBuilder: (context, index) {
          final day = _forecast![index];
          final date = day['date'];
          final icon = day['day']['condition']['icon'];
          final temp = day['day']['avgtemp_c'].round();

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(date,
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 12)),
                const SizedBox(height: 5),
                Image.network('http:$icon', width: 50, height: 50),
                const SizedBox(height: 5),
                Text('$temp°C',
                    style: GoogleFonts.lato(color: Colors.white)),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A2344),
          Color.fromARGB(255, 125, 32, 142),
          Colors.purple,
          Color.fromARGB(255, 151, 44, 170),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildGradient(),
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _cityController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter city name',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                errorText: _errorMessage,
              ),
              onSubmitted: _onCitySubmitted,
            ),
            const SizedBox(height: 20),

            if (_errorMessage != null)
              Center(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.lato(
                    color: Colors.redAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (_currentWeather == null)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else ...[
              Center(
                child: Column(
                  children: [
                    Text(
                      _city,
                      style: GoogleFonts.lato(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Image.network(
                      'http:${_currentWeather!['current']['condition']['icon']}',
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      '${_currentWeather!['current']['temp_c'].round()}°C',
                      style: GoogleFonts.lato(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentWeather!['current']['condition']['text'],
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _weatherInfoTile(
                            'Wind', '${_currentWeather!['current']['wind_kph']} km/h'),
                        _weatherInfoTile(
                            'Humidity', '${_currentWeather!['current']['humidity']}%'),
                        _weatherInfoTile('Feels Like',
                            '${_currentWeather!['current']['feelslike_c'].round()}°C'),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '7-Day Forecast',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildForecastList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
