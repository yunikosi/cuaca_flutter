import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: WeatherScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const WeatherScreen(
      {super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _location = 'Tangerang Selatan, Indonesia';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() {
    Provider.of<WeatherProvider>(context, listen: false)
        .fetchWeather(_location);
  }

  void _updateLocation() {
    setState(() {
      _location = _searchController.text;
      _searchController.clear();
    });
    _fetchWeather();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d, MMMM yyyy').format(DateTime.now());
    var weatherProvider = Provider.of<WeatherProvider>(context);
    var weatherData = weatherProvider.weatherData;
    var hourlyForecast = weatherProvider.hourlyForecast;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                _location,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.toggle_on : Icons.toggle_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: widget.toggleTheme,
            ),
          ],
        ),
        body: weatherProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari Kota, Negara (Kota dan Negara)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _updateLocation,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        onSubmitted: (value) {
                          _updateLocation();
                        },
                      ),
                      const SizedBox(height: 20),
                      weatherData == null
                          ? const Center(
                              child: Text(
                                'Data not available',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : Column(
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.cloud,
                                            size: 150,
                                            color: Colors.white,
                                          ),
                                          if (weatherData['weather'][0]
                                                  ['main'] ==
                                              'Rain')
                                            const Positioned(
                                              top: 40,
                                              right: 60,
                                              child: Icon(
                                                Icons.beach_access,
                                                size: 40,
                                                color: Colors
                                                    .blue, // Sesuaikan dengan warna yang diinginkan
                                              ),
                                            ),
                                          if (weatherData['weather'][0]
                                                  ['main'] ==
                                              'Clear')
                                            const Positioned(
                                              top: 40,
                                              right: 60,
                                              child: Icon(
                                                Icons.wb_sunny,
                                                size: 40,
                                                color: Colors
                                                    .yellow, // Sesuaikan dengan warna yang diinginkan
                                              ),
                                            ),
                                        ],
                                      ),
                                      Text(
                                        '${weatherData['main']['temp']}°',
                                        style: const TextStyle(
                                          fontSize: 80,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      WeatherInfo(
                                        icon: Icons.air,
                                        label:
                                            '${weatherData['wind']['speed']} km/h',
                                        subtitle: 'Wind',
                                        isDarkMode: widget.isDarkMode,
                                      ),
                                      WeatherInfo(
                                        icon: Icons.opacity,
                                        label:
                                            '${weatherData['main']['humidity']}%',
                                        subtitle: 'Humidity',
                                        isDarkMode: widget.isDarkMode,
                                      ),
                                      WeatherInfo(
                                        icon: Icons.visibility,
                                        label:
                                            '${weatherData['visibility'] / 1000} km',
                                        subtitle: 'Visibility',
                                        isDarkMode: widget.isDarkMode,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: widget.isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Today',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Next 7 Days',
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 82,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: hourlyForecast == null
                                              ? 0
                                              : hourlyForecast.length,
                                          itemBuilder: (context, index) {
                                            var forecast =
                                                hourlyForecast![index];
                                            var forecastTime = DateTime.parse(
                                                forecast['dt_txt']);
                                            if (forecastTime
                                                .isBefore(DateTime.now())) {
                                              return Container();
                                            }
                                            return WeatherForecast(
                                              time: DateFormat('HH:mm')
                                                  .format(forecastTime),
                                              condition: forecast['weather'][0][
                                                  'main'], // Menyampaikan kondisi cuaca
                                              temperature:
                                                  '${forecast['main']['temp']}°',
                                              isDarkMode: widget.isDarkMode,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.blue,
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDarkMode;

  const WeatherInfo({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class WeatherForecast extends StatelessWidget {
  final String time;
  final String condition;
  final String temperature;
  final bool isDarkMode;

  const WeatherForecast({
    super.key,
    required this.time,
    required this.condition,
    required this.temperature,
    required this.isDarkMode,
  });

  IconData getWeatherIcon() {
    switch (condition) {
      case 'Rain':
        return Icons.beach_access; // Menggunakan ikon hujan
      case 'Clouds':
        return Icons.cloud; // Menggunakan ikon awan
      default:
        return Icons.wb_sunny; // Default untuk cuaca cerah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            temperature,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Icon(
            getWeatherIcon(), // Menggunakan fungsi untuk mendapatkan ikon cuaca
            color: isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
