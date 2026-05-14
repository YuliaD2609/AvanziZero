import 'package:flutter/material.dart';

class OcrScannerModal extends StatefulWidget {
  const OcrScannerModal({super.key});

  @override
  State<OcrScannerModal> createState() => _OcrScannerModalState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OcrScannerModal(),
    );
  }
}

class _OcrScannerModalState extends State<OcrScannerModal> {
  bool _imageCaptured = false;
  bool _isAnalyzing = false;

  void _simulateCapture() {
    setState(() {
      _imageCaptured = true;
      _isAnalyzing = true;
    });

    // Simula il tempo di caricamento per l'interfaccia verso il modello reale
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Barra superiore di trascinamento
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFEAECE8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Intestazione Modale
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.document_scanner_rounded, color: Color(0xFF5A9E87), size: 28),
                    SizedBox(width: 10),
                    Text(
                      "IA Scanning Scontrini",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C3D32),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF789088)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEAECE8), height: 1),

          // Contenuto Principale
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Area Anteprima Fotocamera / Scontrino
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 240,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBFBF9), // Avorio soft
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _imageCaptured ? const Color(0xFF5A9E87) : const Color(0xFFEAECE8),
                        width: 2,
                      ),
                    ),
                    child: _imageCaptured
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isAnalyzing ? Icons.hourglass_top_rounded : Icons.check_circle_rounded,
                                color: const Color(0xFF5A9E87),
                                size: 50,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _isAnalyzing
                                    ? "Connessione al Modello IA personalizzato..."
                                    : "Scontrino Acquisito Pronto per l'Inferenza OCR",
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1C3D32),
                                ),
                              ),
                              if (_isAnalyzing)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  child: LinearProgressIndicator(
                                    color: Color(0xFF5A9E87),
                                    backgroundColor: Color(0xFFEAECE8),
                                  ),
                                ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: Color(0xFF789088), size: 60),
                              SizedBox(height: 12),
                              Text(
                                "Inquadra lo scontrino della spesa",
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 15,
                                  color: Color(0xFF789088),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Descrizione e coerenza con il feedback utente ("addestrerò un modello vero")
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5), // Menta chiaro
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.model_training_rounded, color: Color(0xFF1C3D32), size: 24),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Integrazione Modello Reale: Questa interfaccia acquisirà l'immagine per passarla al modello di Machine Learning vero in fase di training, che estrarrà e smisterà i prodotti nelle rispettive categorie in automatico.",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              color: Color(0xFF1C3D32),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Pulsanti di Scatto / Galleria
                  if (!_imageCaptured) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _simulateCapture,
                            icon: const Icon(Icons.photo_library_rounded, color: Color(0xFF5A9E87)),
                            label: const Text(
                              "Galleria",
                              style: TextStyle(fontFamily: 'Outfit', color: Color(0xFF5A9E87), fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: Color(0xFF5A9E87), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _simulateCapture,
                            icon: const Icon(Icons.camera_rounded, color: Colors.white),
                            label: const Text(
                              "Scatta Foto",
                              style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5A9E87), // Verde Salvia Intenso
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAnalyzing
                            ? null
                            : () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Immagine pronta per il backend di inferenza!"),
                                    backgroundColor: Color(0xFF5A9E87),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB088), // Accento Pesca Pastello
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Conferma Immagine per Inferenza",
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C3D32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
