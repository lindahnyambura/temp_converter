import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:google_fonts/google_fonts.dart'; 

void main() {
  runApp(TempConverterApp());
}

class TempConverterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Converter',
      theme: ThemeData(
        // Customize the primary color
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Colors.white,
        // Customize the text theme
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        // Customize the elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Customize the InputDecoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.pink[50],
          labelStyle: TextStyle(color: Colors.pinkAccent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.pinkAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.purpleAccent),
          ),
        ),
        // Customize the DropdownButton theme
        dropdownMenuTheme: DropdownButtonThemeData(
          style: TextStyle(color: Colors.purpleAccent, fontSize: 16),
          dropdownColor: Colors.pink[100],
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.purpleAccent),
      ),
      home: TempConverterHomePage(),
      debugShowCheckedModeBanner: false, // Remove debug banner
    );
  }
  
  DropdownButtonThemeData({required TextStyle style, Color? dropdownColor, required BoxDecoration decoration}) {}
}

class TempConverterHomePage extends StatefulWidget {
  @override
  _TempConverterHomePageState createState() => _TempConverterHomePageState();
}

class _TempConverterHomePageState extends State<TempConverterHomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _conversionType = 'F to C';
  String _result = '';
  List<String> _history = [];

  // Animation controller for result animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _convert() {
    HapticFeedback.lightImpact(); // Provide haptic feedback
    double input = double.tryParse(_controller.text) ?? 0;
    double output;
    if (_conversionType == 'F to C') {
      output = (input - 32) * 5 / 9;
    } else {
      output = input * 9 / 5 + 32;
    }
    setState(() {
      _result = output.toStringAsFixed(2);
      _history.insert(0, '$_conversionType: $input => $_result');
    });
    _animationController.forward(from: 0.0); 
  }

  void _clearHistory() {
    setState(() {
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('🌸 Temp Converter 🌸'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Conversion Type Dropdown
              DropdownButton<String>(
                value: _conversionType,
                icon: Icon(Icons.arrow_drop_down_circle),
                iconEnabledColor: Colors.pinkAccent,
                onChanged: (String? newValue) {
                  setState(() {
                    _conversionType = newValue!;
                  });
                },
                items: <String>['F to C', 'C to F']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              // Temperature Input Field
              TextField(
                controller: _controller,
                keyboardType:
                    TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter temperature',
                  hintText: 'e.g., 100',
                  prefixIcon: Icon(Icons.thermostat_outlined),
                ),
              ),
              SizedBox(height: 30),
              // Convert Button with Animation
              ElevatedButton(
                onPressed: _convert,
                child: Text('Convert'),
              ),
              SizedBox(height: 30),
              // Animated Result Display
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _result.isNotEmpty ? 'Result: $_result°' : '',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // History Section Header with Clear Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Conversion History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear_all),
                    color: Colors.purpleAccent,
                    tooltip: 'Clear History',
                    onPressed: _history.isNotEmpty ? _clearHistory : null,
                  ),
                ],
              ),
              Divider(
                color: Colors.pinkAccent,
              ),
              // Conversion History List
              _history.isEmpty
                  ? Text(
                      'No history yet!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            Icons.history,
                            color: Colors.purpleAccent,
                          ),
                          title: Text(_history[index]),
                        );
                      },
                    ),
              SizedBox(height: 20),
            
              
            
              
            
              
              
            ],
          ),
        ),
      ),
    );
  }
}
