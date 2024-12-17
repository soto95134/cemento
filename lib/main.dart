import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cálculo de Hormigón',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
      ),
      home: const HormigonCalculator(title: 'Calculadora de Hormigón'),
    );
  }
}

class HormigonCalculator extends StatefulWidget {
  const HormigonCalculator({super.key, required this.title});

  final String title;

  @override
  State<HormigonCalculator> createState() => _HormigonCalculatorState();
}

class _HormigonCalculatorState extends State<HormigonCalculator> {
  final TextEditingController altoController = TextEditingController();
  final TextEditingController anchoController = TextEditingController();
  final TextEditingController largoController = TextEditingController();
  final TextEditingController pesoSacoController = TextEditingController();
  final TextEditingController contenedorController = TextEditingController();
  String selectedHormigon = "G-05";
  String selectedUnidad = "Litros"; // Unidad inicial
  String unidadContenedor = "Litros"; // Unidad mostrada para contenedor

  void toggleUnidad() {
    setState(() {
      if (unidadContenedor == "Kilogramos") {
        unidadContenedor = "Litros";
        selectedUnidad = "Litros"; // Asegúrate de que el valor de selectedUnidad cambie
      } else {
        unidadContenedor = "Kilogramos";
        selectedUnidad = "Kilogramos"; // Y aquí también actualizas selectedUnidad
      }
    });
  }


  final Map<String, double> densidades = {
    "gravilla": 1.6, // Ejemplo: 1.6 kg por litro
    "arena": 1.5, // Ejemplo: 1.5 kg por litro
    "agua": 1.0, // Ejemplo: 1 kg por litro
  };

  final Map<String, Map<String, double>> tablaHormigon = {
    // Hormigones tipo G (No estructurales)
    "G-05": {"cemento": 150, "gravilla": 900, "arena": 700, "agua": 250},
    "G-10": {"cemento": 190, "gravilla": 950, "arena": 780, "agua": 220},
    "G-15": {"cemento": 230, "gravilla": 1050, "arena": 820, "agua": 210},
    "G-20": {"cemento": 280, "gravilla": 1150, "arena": 860, "agua": 200},
    "G-25": {"cemento": 330, "gravilla": 1200, "arena": 900, "agua": 190},
    "G-30": {"cemento": 380, "gravilla": 1250, "arena": 940, "agua": 180},
    "G-35": {"cemento": 400, "gravilla": 1300, "arena": 950, "agua": 170},
    "G-40": {"cemento": 420, "gravilla": 1320, "arena": 960, "agua": 160},
    "G-45": {"cemento": 450, "gravilla": 1350, "arena": 970, "agua": 150},
    "G-50": {"cemento": 470, "gravilla": 1370, "arena": 980, "agua": 140},
    "G-55": {"cemento": 490, "gravilla": 1400, "arena": 990, "agua": 130},
    "G-60": {"cemento": 500, "gravilla": 1420, "arena": 1000, "agua": 120},

    // Hormigones tipo H (Estructurales)
    "H-15": {"cemento": 220, "gravilla": 970, "arena": 850, "agua": 220},
    "H-20": {"cemento": 270, "gravilla": 1070, "arena": 870, "agua": 200},
    "H-25": {"cemento": 320, "gravilla": 1170, "arena": 890, "agua": 190},
    "H-30": {"cemento": 360, "gravilla": 1220, "arena": 920, "agua": 180},
    "H-35": {"cemento": 400, "gravilla": 1270, "arena": 950, "agua": 170},
    "H-40": {"cemento": 450, "gravilla": 1320, "arena": 980, "agua": 160},

    // Otros tipos de hormigón especializados
    "HAC-30": {"cemento": 350, "gravilla": 1240, "arena": 930, "agua": 180}, // Hormigón autocompactante
    "HAR-50": {"cemento": 500, "gravilla": 1400, "arena": 1000, "agua": 150}, // Hormigón de alta resistencia
    "Permeable": {"cemento": 250, "gravilla": 1100, "arena": 400, "agua": 200}, // Hormigón permeable
    "Celular": {"cemento": 200, "gravilla": 0, "arena": 500, "agua": 300}, // Hormigón celular (liviano)
  };

  String resultado = '';

  double obtenerFactorConversion(String material, String unidadSeleccionada, double cantidadContenedor) {
    if (unidadSeleccionada == "Kilogramos") {
      // Para kilogramos, usamos la densidad del material
      if (densidades.containsKey(material)) {
        return densidades[material]!;  // Densidad en kg por litro
      }
    } else if (unidadSeleccionada == "Litros") {
      // Para Litros, retornamos el volumen, que ya está en litros.
      return cantidadContenedor; // Aquí simplemente utilizamos el valor del volumen
    }
    return 1;  // Valor por defecto si no se encuentra la unidad
  }

  void calcularMateriales() {
    final double alto = double.tryParse(altoController.text) ?? 0;
    final double ancho = double.tryParse(anchoController.text) ?? 0;
    final double largo = double.tryParse(largoController.text) ?? 0;
    final double pesoSaco = double.tryParse(pesoSacoController.text) ?? 0;
    final double cantidadContenedor = double.tryParse(contenedorController.text) ?? 0;

    // Asegurarse de que todos los valores sean mayores a 0
    if (alto > 0 && ancho > 0 && largo > 0 && pesoSaco > 0 && cantidadContenedor > 0) {
      final double volumen = alto * ancho * largo;

      final Map<String, double>? proporciones = tablaHormigon[selectedHormigon];
      if (proporciones != null) {
        final double sacosCemento = (proporciones["cemento"]! * volumen) / pesoSaco;

        // Calcular los factores de conversión de materiales según la unidad seleccionada
        double factorConversionGravilla = obtenerFactorConversion("gravilla", selectedUnidad, cantidadContenedor);
        double factorConversionArena = obtenerFactorConversion("arena", selectedUnidad, cantidadContenedor);
        double factorConversionAgua = obtenerFactorConversion("agua", selectedUnidad, cantidadContenedor);

        // Cálculos de contenedores con el factor de conversión
        final double contenedoresGravilla = (proporciones["gravilla"]! * volumen) / factorConversionGravilla;
        final double contenedoresArena = (proporciones["arena"]! * volumen) / factorConversionArena;
        final double contenedoresAgua = (proporciones["agua"]! * volumen) / factorConversionAgua;

        setState(() {
          resultado = '''
        Volumen: ${volumen.toStringAsFixed(2)} m³
        Sacos de Cemento: ${sacosCemento.toStringAsFixed(1)}
        Contenedores de Gravilla: ${contenedoresGravilla.toStringAsFixed(1)}
        Contenedores de Arena: ${contenedoresArena.toStringAsFixed(1)}
        Contenedores de Agua: ${contenedoresAgua.toStringAsFixed(1)}
        ''';
        });
      }
    } else {
      setState(() {
        resultado = 'Por favor, ingrese valores válidos en todos los campos.';
      });
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aquí se agregan los campos de entrada de alto, ancho, largo, etc.
              ..._buildInputFields(), // Esto incluye todos los campos de entrada
              // Selector de unidades con toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Unidad de contenedor: $unidadContenedor',
                    style: TextStyle(fontSize: 16),
                  ),
                  ElevatedButton(
                    onPressed: toggleUnidad,
                    child: Text('Cambiar a ${unidadContenedor == "Kilogramos" ? "Litros" : "Kilogramos"}'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Botón para calcular
              ElevatedButton.icon(
                onPressed: calcularMateriales,
                icon: const Icon(Icons.calculate),
                label: const Text('Calcular'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              // Mostrar el resultado aquí
              if (resultado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    resultado,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputFields() {
    return [
      _buildTextField(altoController, 'Alto (m)', Icons.height),
      _buildTextField(anchoController, 'Ancho (m)', Icons.straighten),
      _buildTextField(largoController, 'Largo (m)', Icons.square_foot),
      _buildTextField(
          pesoSacoController, 'Peso del saco de cemento (kg)', Icons.shopping_bag),
      _buildTextField(
          contenedorController, 'Capacidad del contenedor', Icons.format_paint,),
    ];
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ),
    );
  }
}
