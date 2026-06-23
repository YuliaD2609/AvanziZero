import 'dart:math';
import '../models/app_state.dart';

class LocalReceiptParser {
  // Dizionario OMNICOMPRENSIVO ispirato a dataset OpenFoodFacts e cataloghi GDO Italiani (Esselunga, Coop, Conad)
  static final Map<String, Map<String, String>> _productDictionary = {
    // ================= FRUTTA & VERDURA =================
    // Frutta comune
    'mela': {'name': 'Mele', 'category': 'Frutta & Verdura'},
    'mele': {'name': 'Mele', 'category': 'Frutta & Verdura'},
    'banana': {'name': 'Banane', 'category': 'Frutta & Verdura'},
    'banane': {'name': 'Banane', 'category': 'Frutta & Verdura'},
    'pera': {'name': 'Pere', 'category': 'Frutta & Verdura'},
    'pere': {'name': 'Pere', 'category': 'Frutta & Verdura'},
    'pesca': {'name': 'Pesche', 'category': 'Frutta & Verdura'},
    'pesche': {'name': 'Pesche', 'category': 'Frutta & Verdura'},
    'albicocca': {'name': 'Albicocche', 'category': 'Frutta & Verdura'},
    'albicocche': {'name': 'Albicocche', 'category': 'Frutta & Verdura'},
    'susina': {'name': 'Susine', 'category': 'Frutta & Verdura'},
    'susine': {'name': 'Susine', 'category': 'Frutta & Verdura'},
    'prugna': {'name': 'Prugne', 'category': 'Frutta & Verdura'},
    'prugne': {'name': 'Prugne', 'category': 'Frutta & Verdura'},
    'ciliegia': {'name': 'Ciliegie', 'category': 'Frutta & Verdura'},
    'ciliegie': {'name': 'Ciliegie', 'category': 'Frutta & Verdura'},
    'amarena': {'name': 'Amarene', 'category': 'Frutta & Verdura'},
    'amarene': {'name': 'Amarene', 'category': 'Frutta & Verdura'},
    'fragola': {'name': 'Fragole', 'category': 'Frutta & Verdura'},
    'fragole': {'name': 'Fragole', 'category': 'Frutta & Verdura'},
    'melone': {'name': 'Melone', 'category': 'Frutta & Verdura'},
    'anguria': {'name': 'Anguria', 'category': 'Frutta & Verdura'},
    'cocomero': {'name': 'Anguria', 'category': 'Frutta & Verdura'},
    'uva': {'name': 'Uva', 'category': 'Frutta & Verdura'},
    'kiwi': {'name': 'Kiwi', 'category': 'Frutta & Verdura'},
    'cachi': {'name': 'Cachi', 'category': 'Frutta & Verdura'},
    'fichi': {'name': 'Fichi', 'category': 'Frutta & Verdura'},
    'datteri': {'name': 'Datteri', 'category': 'Frutta & Verdura'},
    
    // Agrumi
    'arancia': {'name': 'Arance', 'category': 'Frutta & Verdura'},
    'arance': {'name': 'Arance', 'category': 'Frutta & Verdura'},
    'limone': {'name': 'Limoni', 'category': 'Frutta & Verdura'},
    'limoni': {'name': 'Limoni', 'category': 'Frutta & Verdura'},
    'mandarino': {'name': 'Mandarini', 'category': 'Frutta & Verdura'},
    'mandarini': {'name': 'Mandarini', 'category': 'Frutta & Verdura'},
    'clementina': {'name': 'Clementine', 'category': 'Frutta & Verdura'},
    'clementine': {'name': 'Clementine', 'category': 'Frutta & Verdura'},
    'pompelmo': {'name': 'Pompelmo', 'category': 'Frutta & Verdura'},
    'cedro': {'name': 'Cedro', 'category': 'Frutta & Verdura'},
    'bergamotto': {'name': 'Bergamotto', 'category': 'Frutta & Verdura'},
    'lime': {'name': 'Lime', 'category': 'Frutta & Verdura'},

    // Frutti rossi & Esotici
    'mirtilli': {'name': 'Mirtilli', 'category': 'Frutta & Verdura'},
    'lamponi': {'name': 'Lamponi', 'category': 'Frutta & Verdura'},
    'more': {'name': 'More', 'category': 'Frutta & Verdura'},
    'ribes': {'name': 'Ribes', 'category': 'Frutta & Verdura'},
    'ananas': {'name': 'Ananas', 'category': 'Frutta & Verdura'},
    'mango': {'name': 'Mango', 'category': 'Frutta & Verdura'},
    'papaya': {'name': 'Papaya', 'category': 'Frutta & Verdura'},
    'avocado': {'name': 'Avocado', 'category': 'Frutta & Verdura'},
    'cocco': {'name': 'Cocco', 'category': 'Frutta & Verdura'},
    'melograno': {'name': 'Melograno', 'category': 'Frutta & Verdura'},

    // Frutta Secca
    'noci': {'name': 'Noci', 'category': 'Frutta & Verdura'},
    'mandorle': {'name': 'Mandorle', 'category': 'Frutta & Verdura'},
    'nocciole': {'name': 'Nocciole', 'category': 'Frutta & Verdura'},
    'arachidi': {'name': 'Arachidi', 'category': 'Frutta & Verdura'},
    'pistacchi': {'name': 'Pistacchi', 'category': 'Frutta & Verdura'},
    'pinoli': {'name': 'Pinoli', 'category': 'Frutta & Verdura'},
    'castagne': {'name': 'Castagne', 'category': 'Frutta & Verdura'},
    'anacardi': {'name': 'Anacardi', 'category': 'Frutta & Verdura'},

    // Verdura
    'pomodoro': {'name': 'Pomodori', 'category': 'Frutta & Verdura'},
    'pomodori': {'name': 'Pomodori', 'category': 'Frutta & Verdura'},
    'ciliegino': {'name': 'Pomodorini', 'category': 'Frutta & Verdura'},
    'pachino': {'name': 'Pomodorini Pachino', 'category': 'Frutta & Verdura'},
    'insalata': {'name': 'Insalata', 'category': 'Frutta & Verdura'},
    'lattuga': {'name': 'Lattuga', 'category': 'Frutta & Verdura'},
    'iceberg': {'name': 'Insalata Iceberg', 'category': 'Frutta & Verdura'},
    'valeriana': {'name': 'Valeriana', 'category': 'Frutta & Verdura'},
    'songino': {'name': 'Songino', 'category': 'Frutta & Verdura'},
    'rucola': {'name': 'Rucola', 'category': 'Frutta & Verdura'},
    'radicchio': {'name': 'Radicchio', 'category': 'Frutta & Verdura'},
    'indivia': {'name': 'Indivia', 'category': 'Frutta & Verdura'},
    'scarola': {'name': 'Scarola', 'category': 'Frutta & Verdura'},
    'patata': {'name': 'Patate', 'category': 'Frutta & Verdura'},
    'patate': {'name': 'Patate', 'category': 'Frutta & Verdura'},
    'cipolla': {'name': 'Cipolle', 'category': 'Frutta & Verdura'},
    'cipolle': {'name': 'Cipolle', 'category': 'Frutta & Verdura'},
    'scalogno': {'name': 'Scalogno', 'category': 'Frutta & Verdura'},
    'porri': {'name': 'Porri', 'category': 'Frutta & Verdura'},
    'carota': {'name': 'Carote', 'category': 'Frutta & Verdura'},
    'carote': {'name': 'Carote', 'category': 'Frutta & Verdura'},
    'zucchine': {'name': 'Zucchine', 'category': 'Frutta & Verdura'},
    'zucchina': {'name': 'Zucchine', 'category': 'Frutta & Verdura'},
    'melanzana': {'name': 'Melanzane', 'category': 'Frutta & Verdura'},
    'melanzane': {'name': 'Melanzane', 'category': 'Frutta & Verdura'},
    'peperone': {'name': 'Peperoni', 'category': 'Frutta & Verdura'},
    'peperoni': {'name': 'Peperoni', 'category': 'Frutta & Verdura'},
    'aglio': {'name': 'Aglio', 'category': 'Frutta & Verdura'},
    'broccoli': {'name': 'Broccoli', 'category': 'Frutta & Verdura'},
    'spinaci': {'name': 'Spinaci', 'category': 'Frutta & Verdura'},
    'spinacino': {'name': 'Spinacino', 'category': 'Frutta & Verdura'},
    'cavolo': {'name': 'Cavolo', 'category': 'Frutta & Verdura'},
    'verza': {'name': 'Verza', 'category': 'Frutta & Verdura'},
    'cavolfiore': {'name': 'Cavolfiore', 'category': 'Frutta & Verdura'},
    'cavolini': {'name': 'Cavolini di Bruxelles', 'category': 'Frutta & Verdura'},
    'finocchi': {'name': 'Finocchi', 'category': 'Frutta & Verdura'},
    'cetrioli': {'name': 'Cetrioli', 'category': 'Frutta & Verdura'},
    'champignon': {'name': 'Funghi Champignon', 'category': 'Frutta & Verdura'},
    'champ': {'name': 'Funghi Champignon', 'category': 'Frutta & Verdura'},
    'porcini': {'name': 'Funghi Porcini', 'category': 'Frutta & Verdura'},
    'funghi': {'name': 'Funghi', 'category': 'Frutta & Verdura'},
    'asparagi': {'name': 'Asparagi', 'category': 'Frutta & Verdura'},
    'carciofi': {'name': 'Carciofi', 'category': 'Frutta & Verdura'},
    'bietola': {'name': 'Bietola', 'category': 'Frutta & Verdura'},
    'bietole': {'name': 'Bietole', 'category': 'Frutta & Verdura'},
    'sedano': {'name': 'Sedano', 'category': 'Frutta & Verdura'},
    'zucca': {'name': 'Zucca', 'category': 'Frutta & Verdura'},
    'fagiolini': {'name': 'Fagiolini', 'category': 'Frutta & Verdura'},
    'piselli': {'name': 'Piselli', 'category': 'Frutta & Verdura'},
    'fave': {'name': 'Fave', 'category': 'Frutta & Verdura'},
    'catalogna': {'name': 'Catalogna', 'category': 'Frutta & Verdura'},
    'daikon': {'name': 'Daikon', 'category': 'Frutta & Verdura'},
    'topinambur': {'name': 'Topinambur', 'category': 'Frutta & Verdura'},
    
    // Erbe Aromatiche
    'prezzemolo': {'name': 'Prezzemolo', 'category': 'Frutta & Verdura'},
    'basilico': {'name': 'Basilico', 'category': 'Frutta & Verdura'},
    'salvia': {'name': 'Salvia', 'category': 'Frutta & Verdura'},
    'rosmarino': {'name': 'Rosmarino', 'category': 'Frutta & Verdura'},
    'menta': {'name': 'Menta', 'category': 'Frutta & Verdura'},
    'erba cipollina': {'name': 'Erba Cipollina', 'category': 'Frutta & Verdura'},

    // ================= LATTICINI E UOVA =================
    'latte': {'name': 'Latte', 'category': 'Latticini'},
    'scremato': {'name': 'Latte Scremato', 'category': 'Latticini'},
    'parzialmente': {'name': 'Latte Parzialmente Scremato', 'category': 'Latticini'},
    'intero': {'name': 'Latte Intero', 'category': 'Latticini'},
    'mozzarella': {'name': 'Mozzarella', 'category': 'Latticini'},
    'bufala': {'name': 'Mozzarella di Bufala', 'category': 'Latticini'},
    'burro': {'name': 'Burro', 'category': 'Latticini'},
    'yogurt': {'name': 'Yogurt', 'category': 'Latticini'},
    'greco': {'name': 'Yogurt Greco', 'category': 'Latticini'},
    'formaggio': {'name': 'Formaggio', 'category': 'Latticini'},
    'form': {'name': 'Formaggio', 'category': 'Latticini'},
    'pastore': {'name': 'Formaggio del Pastore', 'category': 'Latticini'},
    'parmigiano': {'name': 'Parmigiano Reggiano', 'category': 'Latticini'},
    'grana': {'name': 'Grana Padano', 'category': 'Latticini'},
    'uova': {'name': 'Uova', 'category': 'Latticini'},
    'panna': {'name': 'Panna', 'category': 'Latticini'},
    'panna montata': {'name': 'Panna Montata', 'category': 'Latticini'},
    'stracchino': {'name': 'Stracchino', 'category': 'Latticini'},
    'ricotta': {'name': 'Ricotta', 'category': 'Latticini'},
    'ricotta salata': {'name': 'Ricotta Salata', 'category': 'Latticini'},
    'sottiletta': {'name': 'Sottilette', 'category': 'Latticini'},
    'sottilette': {'name': 'Sottilette', 'category': 'Latticini'},
    'sottil': {'name': 'Sottilette', 'category': 'Latticini'},
    'mascarpone': {'name': 'Mascarpone', 'category': 'Latticini'},
    'pecorino': {'name': 'Pecorino', 'category': 'Latticini'},
    'gorgonzola': {'name': 'Gorgonzola', 'category': 'Latticini'},
    'provolone': {'name': 'Provolone', 'category': 'Latticini'},
    'kefir': {'name': 'Kefir', 'category': 'Latticini'},
    'scamorza': {'name': 'Scamorza', 'category': 'Latticini'},
    'caciocavallo': {'name': 'Caciocavallo', 'category': 'Latticini'},
    'asiago': {'name': 'Asiago', 'category': 'Latticini'},
    'fontina': {'name': 'Fontina', 'category': 'Latticini'},
    'taleggio': {'name': 'Taleggio', 'category': 'Latticini'},
    'brie': {'name': 'Brie', 'category': 'Latticini'},
    'camembert': {'name': 'Camembert', 'category': 'Latticini'},
    'emmental': {'name': 'Emmental', 'category': 'Latticini'},
    'gouda': {'name': 'Gouda', 'category': 'Latticini'},
    'cheddar': {'name': 'Cheddar', 'category': 'Latticini'},
    'feta': {'name': 'Feta', 'category': 'Latticini'},
    'halloumi': {'name': 'Halloumi', 'category': 'Latticini'},
    'robiola': {'name': 'Robiola', 'category': 'Latticini'},
    'crescenza': {'name': 'Crescenza', 'category': 'Latticini'},
    'philadelphia': {'name': 'Philadelphia', 'category': 'Latticini'},
    'galbanino': {'name': 'Galbanino', 'category': 'Latticini'},
    'burrata': {'name': 'Burrata', 'category': 'Latticini'},
    'cacioricotta': {'name': 'Cacioricotta', 'category': 'Latticini'},
    'caprino': {'name': 'Caprino', 'category': 'Latticini'},
    'certosa': {'name': 'Certosa', 'category': 'Latticini'},
    'fiocchi': {'name': 'Fiocchi di Latte', 'category': 'Latticini'},
    'jocca': {'name': 'Jocca', 'category': 'Latticini'},
    'leerdammer': {'name': 'Leerdammer', 'category': 'Latticini'},
    'provola': {'name': 'Provola', 'category': 'Latticini'},
    'quartirolo': {'name': 'Quartirolo', 'category': 'Latticini'},
    'stracciatella': {'name': 'Stracciatella', 'category': 'Latticini'},
    'toma': {'name': 'Toma', 'category': 'Latticini'},
    'tomino': {'name': 'Tomino', 'category': 'Latticini'},
    'zola': {'name': 'Zola', 'category': 'Latticini'},
    'actimel': {'name': 'Actimel', 'category': 'Latticini'},
    'activia': {'name': 'Activia', 'category': 'Latticini'},
    'danone': {'name': 'Yogurt Danone', 'category': 'Latticini'},
    'muller': {'name': 'Yogurt Muller', 'category': 'Latticini'},
    'parmalat': {'name': 'Latte Parmalat', 'category': 'Latticini'},
    'granarolo': {'name': 'Latte Granarolo', 'category': 'Latticini'},
    'yomo': {'name': 'Yogurt Yomo', 'category': 'Latticini'},
    'vipiteno': {'name': 'Yogurt Vipiteno', 'category': 'Latticini'},

    // ================= CARNE & PESCE =================
    // Carni Rosse e Bianche
    'pollo': {'name': 'Pollo', 'category': 'Carne'},
    'manzo': {'name': 'Manzo', 'category': 'Carne'},
    'maiale': {'name': 'Maiale', 'category': 'Carne'},
    'carne': {'name': 'Carne', 'category': 'Carne'},
    'hamburger': {'name': 'Hamburger', 'category': 'Carne'},
    'wurstel': {'name': 'Wurstel', 'category': 'Carne'},
    'salsiccia': {'name': 'Salsiccia', 'category': 'Carne'},
    'tacchino': {'name': 'Tacchino', 'category': 'Carne'},
    'tacc': {'name': 'Tacchino', 'category': 'Carne'},
    'lonza': {'name': 'Lonza', 'category': 'Carne'},
    'vitello': {'name': 'Vitello', 'category': 'Carne'},
    'coniglio': {'name': 'Coniglio', 'category': 'Carne'},
    'agnello': {'name': 'Agnello', 'category': 'Carne'},
    'fesa': {'name': 'Fesa', 'category': 'Carne'},
    'girello': {'name': 'Girello', 'category': 'Carne'},
    'macinato': {'name': 'Carne Macinata', 'category': 'Carne'},
    'ossobuco': {'name': 'Ossobuco', 'category': 'Carne'},
    'arista': {'name': 'Arista', 'category': 'Carne'},
    'braciola': {'name': 'Braciola', 'category': 'Carne'},
    'capocollo': {'name': 'Capocollo', 'category': 'Carne'},
    'costine': {'name': 'Costine', 'category': 'Carne'},
    'stinco': {'name': 'Stinco', 'category': 'Carne'},
    'faraona': {'name': 'Faraona', 'category': 'Carne'},
    'quaglia': {'name': 'Quaglia', 'category': 'Carne'},
    'scamone': {'name': 'Scamone', 'category': 'Carne'},
    'filetto': {'name': 'Filetto', 'category': 'Carne'},
    'controfiletto': {'name': 'Controfiletto', 'category': 'Carne'},
    'costata': {'name': 'Costata', 'category': 'Carne'},
    'fiorentina': {'name': 'Fiorentina', 'category': 'Carne'},
    'fegato': {'name': 'Fegato', 'category': 'Carne'},
    'trippa': {'name': 'Trippa', 'category': 'Carne'},
    'muscolo': {'name': 'Muscolo', 'category': 'Carne'},
    'pancia': {'name': 'Pancia', 'category': 'Carne'},

    // Salumi e Insaccati
    'salame': {'name': 'Salame', 'category': 'Carne'},
    'prosciutto': {'name': 'Prosciutto', 'category': 'Carne'},
    'crudo': {'name': 'Prosciutto Crudo', 'category': 'Carne'},
    'cotto': {'name': 'Prosciutto Cotto', 'category': 'Carne'},
    'mortadella': {'name': 'Mortadella', 'category': 'Carne'},
    'pancetta': {'name': 'Pancetta', 'category': 'Carne'},
    'bresaola': {'name': 'Bresaola', 'category': 'Carne'},
    'cotechino': {'name': 'Cotechino', 'category': 'Carne'},
    'zampone': {'name': 'Zampone', 'category': 'Carne'},
    'coppa': {'name': 'Coppa', 'category': 'Carne'},
    'speck': {'name': 'Speck', 'category': 'Carne'},
    'guanciale': {'name': 'Guanciale', 'category': 'Carne'},
    'lardo': {'name': 'Lardo', 'category': 'Carne'},
    
    // Brand Carni e Salumi
    'aia': {'name': 'Aia', 'category': 'Carne'},
    'amadori': {'name': 'Amadori', 'category': 'Carne'},
    'rovagnati': {'name': 'Salumi Rovagnati', 'category': 'Carne'},
    'negroni': {'name': 'Salumi Negroni', 'category': 'Carne'},
    'citterio': {'name': 'Salumi Citterio', 'category': 'Carne'},
    'beretta': {'name': 'Salumi Beretta', 'category': 'Carne'},
    'fiorucci': {'name': 'Salumi Fiorucci', 'category': 'Carne'},
    'wuber': {'name': 'Wurstel Wuber', 'category': 'Carne'},

    // Pesce, Crostacei e Molluschi
    'pesce': {'name': 'Pesce', 'category': 'Carne'},
    'tonno': {'name': 'Tonno', 'category': 'Carne'},
    'salmone': {'name': 'Salmone', 'category': 'Carne'},
    'sgombro': {'name': 'Sgombro', 'category': 'Carne'},
    'gamberi': {'name': 'Gamberi', 'category': 'Carne'},
    'calamari': {'name': 'Calamari', 'category': 'Carne'},
    'cozza': {'name': 'Cozze', 'category': 'Carne'},
    'cozze': {'name': 'Cozze', 'category': 'Carne'},
    'vongola': {'name': 'Vongole', 'category': 'Carne'},
    'vongole': {'name': 'Vongole', 'category': 'Carne'},
    'polpo': {'name': 'Polpo', 'category': 'Carne'},
    'seppia': {'name': 'Seppia', 'category': 'Carne'},
    'seppie': {'name': 'Seppie', 'category': 'Carne'},
    'calamaro': {'name': 'Calamaro', 'category': 'Carne'},
    'gambero': {'name': 'Gambero', 'category': 'Carne'},
    'scampo': {'name': 'Scampi', 'category': 'Carne'},
    'scampi': {'name': 'Scampi', 'category': 'Carne'},
    'astice': {'name': 'Astice', 'category': 'Carne'},
    'aragosta': {'name': 'Aragosta', 'category': 'Carne'},
    'branzino': {'name': 'Branzino', 'category': 'Carne'},
    'orata': {'name': 'Orata', 'category': 'Carne'},
    'merluzzo': {'name': 'Merluzzo', 'category': 'Carne'},
    'baccala': {'name': 'Baccalà', 'category': 'Carne'},
    'stoccafisso': {'name': 'Stoccafisso', 'category': 'Carne'},
    'alice': {'name': 'Alici', 'category': 'Carne'},
    'alici': {'name': 'Alici', 'category': 'Carne'},
    'acciuga': {'name': 'Acciughe', 'category': 'Carne'},
    'acciughe': {'name': 'Acciughe', 'category': 'Carne'},
    'sarda': {'name': 'Sarde', 'category': 'Carne'},
    'sardina': {'name': 'Sardine', 'category': 'Carne'},
    'sardine': {'name': 'Sardine', 'category': 'Carne'},
    'platessa': {'name': 'Platessa', 'category': 'Carne'},
    'trota': {'name': 'Trota', 'category': 'Carne'},
    'aringa': {'name': 'Aringa', 'category': 'Carne'},
    'carpa': {'name': 'Carpa', 'category': 'Carne'},
    'cernia': {'name': 'Cernia', 'category': 'Carne'},
    'dentice': {'name': 'Dentice', 'category': 'Carne'},
    'gallinella': {'name': 'Gallinella', 'category': 'Carne'},
    'mazzancolle': {'name': 'Mazzancolle', 'category': 'Carne'},
    'moscardini': {'name': 'Moscardini', 'category': 'Carne'},
    'nasello': {'name': 'Nasello', 'category': 'Carne'},
    'ombrina': {'name': 'Ombrina', 'category': 'Carne'},
    'ostriche': {'name': 'Ostriche', 'category': 'Carne'},
    'palombo': {'name': 'Palombo', 'category': 'Carne'},
    'persico': {'name': 'Persico', 'category': 'Carne'},
    'ricciola': {'name': 'Ricciola', 'category': 'Carne'},
    'rombo': {'name': 'Rombo', 'category': 'Carne'},
    'sogliola': {'name': 'Sogliola', 'category': 'Carne'},
    'spigola': {'name': 'Spigola', 'category': 'Carne'},
    'triglia': {'name': 'Triglia', 'category': 'Carne'},
    'sarago': {'name': 'Sarago', 'category': 'Carne'},
    'pagello': {'name': 'Pagello', 'category': 'Carne'},
    'mormora': {'name': 'Mormora', 'category': 'Carne'},
    'scorfano': {'name': 'Scorfano', 'category': 'Carne'},
    'halibut': {'name': 'Halibut', 'category': 'Carne'},
    'luccio': {'name': 'Luccio', 'category': 'Carne'},
    'anguilla': {'name': 'Anguilla', 'category': 'Carne'},
    'murena': {'name': 'Murena', 'category': 'Carne'},
    'grongo': {'name': 'Grongo', 'category': 'Carne'},
    'granchio': {'name': 'Granchio', 'category': 'Carne'},
    'granseola': {'name': 'Granseola', 'category': 'Carne'},
    'canocchia': {'name': 'Canocchia', 'category': 'Carne'},
    'totano': {'name': 'Totano', 'category': 'Carne'},
    'tellina': {'name': 'Telline', 'category': 'Carne'},
    'fasolaro': {'name': 'Fasolari', 'category': 'Carne'},
    'capasanta': {'name': 'Capasanta', 'category': 'Carne'},
    'tartufo di mare': {'name': 'Tartufo di mare', 'category': 'Carne'},
    'cannolicchio': {'name': 'Cannolicchi', 'category': 'Carne'},
    
    // Brand Surgelati
    'findus': {'name': 'Surgelati Findus', 'category': 'Carne'},
    'frosta': {'name': 'Surgelati Frosta', 'category': 'Carne'},
    'bofrost': {'name': 'Surgelati Bofrost', 'category': 'Carne'},

    // ================= SECCO, PASTA & CONSERVE =================
    // Pasta e Farinacei
    'pasta': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'spaghetti': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'penne': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'fusilli': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'maccheroni': {'name': 'Pasta', 'category': 'Secco & Pasta'},
    'tagliatelle': {'name': 'Tagliatelle', 'category': 'Secco & Pasta'},
    'tagliat': {'name': 'Tagliatelle', 'category': 'Secco & Pasta'},
    'bucatini': {'name': 'Bucatini', 'category': 'Secco & Pasta'},
    'linguine': {'name': 'Linguine', 'category': 'Secco & Pasta'},
    'ziti': {'name': 'Ziti', 'category': 'Secco & Pasta'},
    'rigatoni': {'name': 'Rigatoni', 'category': 'Secco & Pasta'},
    'tortiglioni': {'name': 'Tortiglioni', 'category': 'Secco & Pasta'},
    'ditalini': {'name': 'Ditalini', 'category': 'Secco & Pasta'},
    'farfalle': {'name': 'Farfalle', 'category': 'Secco & Pasta'},
    'orecchiette': {'name': 'Orecchiette', 'category': 'Secco & Pasta'},
    'trofie': {'name': 'Trofie', 'category': 'Secco & Pasta'},
    'gnocchi': {'name': 'Gnocchi', 'category': 'Secco & Pasta'},
    'ravioli': {'name': 'Ravioli', 'category': 'Secco & Pasta'},
    'tortellini': {'name': 'Tortellini', 'category': 'Secco & Pasta'},
    'agnolotti': {'name': 'Agnolotti', 'category': 'Secco & Pasta'},
    'lasagne': {'name': 'Lasagne', 'category': 'Secco & Pasta'},
    'cannelloni': {'name': 'Cannelloni', 'category': 'Secco & Pasta'},
    'pizzoccheri': {'name': 'Pizzoccheri', 'category': 'Secco & Pasta'},
    'maltagliati': {'name': 'Maltagliati', 'category': 'Secco & Pasta'},
    'trenette': {'name': 'Trenette', 'category': 'Secco & Pasta'},
    'stelline': {'name': 'Stelline (Pastina)', 'category': 'Secco & Pasta'},
    'filini': {'name': 'Filini (Pastina)', 'category': 'Secco & Pasta'},
    'tempestine': {'name': 'Tempestine (Pastina)', 'category': 'Secco & Pasta'},
    
    // Cereali e Farine
    'riso': {'name': 'Riso', 'category': 'Secco & Pasta'},
    'farro': {'name': 'Farro', 'category': 'Secco & Pasta'},
    'orzo': {'name': 'Orzo', 'category': 'Secco & Pasta'},
    'avena': {'name': 'Avena', 'category': 'Secco & Pasta'},
    'quinoa': {'name': 'Quinoa', 'category': 'Secco & Pasta'},
    'cous cous': {'name': 'Cous Cous', 'category': 'Secco & Pasta'},
    'polenta': {'name': 'Polenta', 'category': 'Secco & Pasta'},
    'farina': {'name': 'Farina', 'category': 'Secco & Pasta'},
    'manitoba': {'name': 'Farina Manitoba', 'category': 'Secco & Pasta'},
    'pane': {'name': 'Pane', 'category': 'Secco & Pasta'},
    'piadina': {'name': 'Piadina', 'category': 'Secco & Pasta'},
    'sfoglia': {'name': 'Pasta Sfoglia', 'category': 'Secco & Pasta'},
    'lievito': {'name': 'Lievito', 'category': 'Secco & Pasta'},
    'vanillina': {'name': 'Vanillina', 'category': 'Secco & Pasta'},
    'cacao': {'name': 'Cacao', 'category': 'Secco & Pasta'},
    'fecola': {'name': 'Fecola', 'category': 'Secco & Pasta'},
    'amido': {'name': 'Amido', 'category': 'Secco & Pasta'},

    // Condimenti e Salse
    'zucchero': {'name': 'Zucchero', 'category': 'Secco & Pasta'},
    'sale': {'name': 'Sale', 'category': 'Secco & Pasta'},
    'olio': {'name': 'Olio', 'category': 'Secco & Pasta'},
    'aceto': {'name': 'Aceto', 'category': 'Secco & Pasta'},
    'balsamico': {'name': 'Aceto Balsamico', 'category': 'Secco & Pasta'},
    'passata': {'name': 'Passata di Pomodoro', 'category': 'Secco & Pasta'},
    'sugo': {'name': 'Sugo', 'category': 'Secco & Pasta'},
    'ragu': {'name': 'Ragù', 'category': 'Secco & Pasta'},
    'pesto': {'name': 'Pesto', 'category': 'Secco & Pasta'},
    'maionese': {'name': 'Maionese', 'category': 'Secco & Pasta'},
    'ketchup': {'name': 'Ketchup', 'category': 'Secco & Pasta'},
    'senape': {'name': 'Senape', 'category': 'Secco & Pasta'},
    'salsa': {'name': 'Salsa', 'category': 'Secco & Pasta'},
    'rubra': {'name': 'Salsa Rubra', 'category': 'Secco & Pasta'},
    'soia': {'name': 'Salsa di Soia', 'category': 'Secco & Pasta'},
    
    // Spezie ed Aromi
    'pepe': {'name': 'Pepe', 'category': 'Secco & Pasta'},
    'peperoncino': {'name': 'Peperoncino', 'category': 'Secco & Pasta'},
    'origano': {'name': 'Origano', 'category': 'Secco & Pasta'},
    'cannella': {'name': 'Cannella', 'category': 'Secco & Pasta'},
    'noce moscata': {'name': 'Noce Moscata', 'category': 'Secco & Pasta'},
    'chiodi di garofano': {'name': 'Chiodi di Garofano', 'category': 'Secco & Pasta'},
    'zafferano': {'name': 'Zafferano', 'category': 'Secco & Pasta'},
    'dadi': {'name': 'Dado Brodo', 'category': 'Secco & Pasta'},
    'dado': {'name': 'Dado Brodo', 'category': 'Secco & Pasta'},
    'brodo': {'name': 'Brodo Preparato', 'category': 'Secco & Pasta'},

    // Conserve e Sottoli
    'olive': {'name': 'Olive', 'category': 'Secco & Pasta'},
    'capperi': {'name': 'Capperi', 'category': 'Secco & Pasta'},
    'sottaceti': {'name': 'Sottaceti', 'category': 'Secco & Pasta'},
    'carciofini': {'name': 'Carciofini Sott\'olio', 'category': 'Secco & Pasta'},
    'funghetti': {'name': 'Funghetti', 'category': 'Secco & Pasta'},
    'mais': {'name': 'Mais', 'category': 'Secco & Pasta'},
    'marmellata': {'name': 'Marmellata', 'category': 'Secco & Pasta'},
    'confettura': {'name': 'Confettura', 'category': 'Secco & Pasta'},
    'miele': {'name': 'Miele', 'category': 'Secco & Pasta'},
    'nutella': {'name': 'Nutella', 'category': 'Secco & Pasta'},

    // Legumi
    'fagioli': {'name': 'Fagioli', 'category': 'Secco & Pasta'},
    'borlotti': {'name': 'Fagioli Borlotti', 'category': 'Secco & Pasta'},
    'cannellini': {'name': 'Fagioli Cannellini', 'category': 'Secco & Pasta'},
    'ceci': {'name': 'Ceci', 'category': 'Secco & Pasta'},
    'lenticchie': {'name': 'Lenticchie', 'category': 'Secco & Pasta'},
    'lent': {'name': 'Lenticchie', 'category': 'Secco & Pasta'},
    'piselli': {'name': 'Piselli', 'category': 'Secco & Pasta'},
    'pisellini': {'name': 'Pisellini', 'category': 'Secco & Pasta'},
    'lupini': {'name': 'Lupini', 'category': 'Secco & Pasta'},

    // Brand Pasta & Conserve
    'barilla': {'name': 'Pasta Barilla', 'category': 'Secco & Pasta'},
    'de cecco': {'name': 'Pasta De Cecco', 'category': 'Secco & Pasta'},
    'voiello': {'name': 'Pasta Voiello', 'category': 'Secco & Pasta'},
    'rummo': {'name': 'Pasta Rummo', 'category': 'Secco & Pasta'},
    'garofalo': {'name': 'Pasta Garofalo', 'category': 'Secco & Pasta'},
    'divella': {'name': 'Pasta Divella', 'category': 'Secco & Pasta'},
    'buitoni': {'name': 'Buitoni', 'category': 'Secco & Pasta'},
    'star': {'name': 'Star', 'category': 'Secco & Pasta'},
    'knorr': {'name': 'Knorr', 'category': 'Secco & Pasta'},
    'mutti': {'name': 'Mutti', 'category': 'Secco & Pasta'},
    'cirio': {'name': 'Cirio', 'category': 'Secco & Pasta'},
    'pomi': {'name': 'Pomì', 'category': 'Secco & Pasta'},
    'valfrutta': {'name': 'Valfrutta', 'category': 'Secco & Pasta'},
    'sacla': {'name': 'Saclà', 'category': 'Secco & Pasta'},
    'ponti': {'name': 'Ponti', 'category': 'Secco & Pasta'},
    'calve': {'name': 'Calvé', 'category': 'Secco & Pasta'},
    'heinz': {'name': 'Heinz', 'category': 'Secco & Pasta'},
    'maille': {'name': 'Senape Maille', 'category': 'Secco & Pasta'},
    'tabasco': {'name': 'Tabasco', 'category': 'Secco & Pasta'},
    'kikkoman': {'name': 'Salsa di Soia Kikkoman', 'category': 'Secco & Pasta'},
    'rio mare': {'name': 'Tonno Rio Mare', 'category': 'Secco & Pasta'},
    'as do mar': {'name': 'Tonno As do Mar', 'category': 'Secco & Pasta'},
    'nostromo': {'name': 'Tonno Nostromo', 'category': 'Secco & Pasta'},
    'mareblu': {'name': 'Tonno Mareblu', 'category': 'Secco & Pasta'},
    'consorcio': {'name': 'Tonno Consorcio', 'category': 'Secco & Pasta'},
    'palmera': {'name': 'Tonno Palmera', 'category': 'Secco & Pasta'},
    'zarotti': {'name': 'Zarotti', 'category': 'Secco & Pasta'},
    'simmenthal': {'name': 'Simmenthal', 'category': 'Secco & Pasta'},
    'montana': {'name': 'Carne Montana', 'category': 'Secco & Pasta'},
    'manzotin': {'name': 'Manzotin', 'category': 'Secco & Pasta'},
    'spam': {'name': 'Spam', 'category': 'Secco & Pasta'},
    'bonduelle': {'name': 'Bonduelle', 'category': 'Secco & Pasta'},
    'aucy': {'name': 'D\'Aucy', 'category': 'Secco & Pasta'},

    // ================= SNACK & DOLCI =================
    // Salati
    'patatine': {'name': 'Patatine', 'category': 'Snack'},
    'salatini': {'name': 'Salatini', 'category': 'Snack'},
    'taralli': {'name': 'Taralli', 'category': 'Snack'},
    'popcorn': {'name': 'Popcorn', 'category': 'Snack'},
    'crackers': {'name': 'Crackers', 'category': 'Snack'},
    'cracker': {'name': 'Crackers', 'category': 'Snack'},
    'grissini': {'name': 'Grissini', 'category': 'Snack'},

    // Dolci e Colazione
    'biscotti': {'name': 'Biscotti', 'category': 'Snack'},
    'cereali': {'name': 'Cereali', 'category': 'Snack'},
    'fette biscottate': {'name': 'Fette Biscottate', 'category': 'Snack'},
    'cioccolato': {'name': 'Cioccolato', 'category': 'Snack'},
    'cioccolata': {'name': 'Cioccolata', 'category': 'Snack'},
    'merendine': {'name': 'Merendine', 'category': 'Snack'},
    'croissant': {'name': 'Croissant', 'category': 'Snack'},
    'brioche': {'name': 'Brioche', 'category': 'Snack'},
    'cornetto': {'name': 'Cornetto', 'category': 'Snack'},
    'pandoro': {'name': 'Pandoro', 'category': 'Snack'},
    'panettone': {'name': 'Panettone', 'category': 'Snack'},
    'colomba': {'name': 'Colomba', 'category': 'Snack'},
    
    // Nomi Biscotti e Dolci Iconici
    'savoiardi': {'name': 'Savoiardi', 'category': 'Snack'},
    'pavesini': {'name': 'Pavesini', 'category': 'Snack'},
    'pan di stelle': {'name': 'Pan di Stelle', 'category': 'Snack'},
    'gocciole': {'name': 'Gocciole', 'category': 'Snack'},
    'ringo': {'name': 'Ringo', 'category': 'Snack'},
    'oreo': {'name': 'Oreo', 'category': 'Snack'},
    'macine': {'name': 'Macine', 'category': 'Snack'},
    'abbracci': {'name': 'Abbracci', 'category': 'Snack'},
    'tarallucci': {'name': 'Tarallucci', 'category': 'Snack'},
    'galletti': {'name': 'Galletti', 'category': 'Snack'},
    'campagnole': {'name': 'Campagnole', 'category': 'Snack'},
    'rigoli': {'name': 'Rigoli', 'category': 'Snack'},
    'molinetti': {'name': 'Molinetti', 'category': 'Snack'},
    'bucaneve': {'name': 'Bucaneve', 'category': 'Snack'},
    'osvego': {'name': 'Osvego', 'category': 'Snack'},

    // Brand Snack e Dolci
    'mulino bianco': {'name': 'Mulino Bianco', 'category': 'Snack'},
    'pavesi': {'name': 'Pavesi', 'category': 'Snack'},
    'bauli': {'name': 'Bauli', 'category': 'Snack'},
    'motta': {'name': 'Motta', 'category': 'Snack'},
    'melegatti': {'name': 'Melegatti', 'category': 'Snack'},
    'tre marie': {'name': 'Tre Marie', 'category': 'Snack'},
    'balocco': {'name': 'Balocco', 'category': 'Snack'},
    'paluani': {'name': 'Paluani', 'category': 'Snack'},
    'loacker': {'name': 'Loacker', 'category': 'Snack'},
    'ritter sport': {'name': 'Ritter Sport', 'category': 'Snack'},
    'milka': {'name': 'Milka', 'category': 'Snack'},
    'novi': {'name': 'Novi', 'category': 'Snack'},
    'perugina': {'name': 'Perugina', 'category': 'Snack'},
    'baci': {'name': 'Baci Perugina', 'category': 'Snack'},
    'lindor': {'name': 'Lindor', 'category': 'Snack'},
    'toblerone': {'name': 'Toblerone', 'category': 'Snack'},
    'nestle': {'name': 'Nestlé', 'category': 'Snack'},
    'mars': {'name': 'Mars', 'category': 'Snack'},
    'twix': {'name': 'Twix', 'category': 'Snack'},
    'snickers': {'name': 'Snickers', 'category': 'Snack'},
    'bounty': {'name': 'Bounty', 'category': 'Snack'},
    'lion': {'name': 'Lion', 'category': 'Snack'},
    'kitkat': {'name': 'KitKat', 'category': 'Snack'},
    'smarties': {'name': 'Smarties', 'category': 'Snack'},
    'm&m': {'name': 'M&M\'s', 'category': 'Snack'},
    'skittles': {'name': 'Skittles', 'category': 'Snack'},
    'galatine': {'name': 'Galatine', 'category': 'Snack'},
    'sperlari': {'name': 'Sperlari', 'category': 'Snack'},
    'goleador': {'name': 'Goleador', 'category': 'Snack'},
    'haribo': {'name': 'Caramelle Haribo', 'category': 'Snack'},
    'tic tac': {'name': 'Tic Tac', 'category': 'Snack'},
    'brooklyn': {'name': 'Brooklyn', 'category': 'Snack'},
    'vigorsol': {'name': 'Vigorsol', 'category': 'Snack'},
    'vivident': {'name': 'Vivident', 'category': 'Snack'},
    'daygum': {'name': 'Daygum', 'category': 'Snack'},
    'kinder': {'name': 'Kinder', 'category': 'Snack'},
    'ferrero': {'name': 'Ferrero', 'category': 'Snack'},
    'lindt': {'name': 'Lindt', 'category': 'Snack'},
    'doritos': {'name': 'Doritos', 'category': 'Snack'},
    'fonzies': {'name': 'Fonzies', 'category': 'Snack'},
    'pringles': {'name': 'Pringles', 'category': 'Snack'},
    'cipster': {'name': 'Cipster', 'category': 'Snack'},
    'tuc': {'name': 'Tuc', 'category': 'Snack'},
    'ritz': {'name': 'Ritz', 'category': 'Snack'},
    'san carlo': {'name': 'San Carlo', 'category': 'Snack'},
    'amica chips': {'name': 'Amica Chips', 'category': 'Snack'},
    'lays': {'name': 'Lay\'s', 'category': 'Snack'},
    'pai': {'name': 'Patatine Pai', 'category': 'Snack'},
    'rodeo': {'name': 'Rodeo', 'category': 'Snack'},

    // ================= BEVANDE =================
    // Acqua
    'acqua': {'name': 'Acqua', 'category': 'Bevande'},
    'levissima': {'name': 'Acqua Levissima', 'category': 'Bevande'},
    'sant anna': {'name': 'Acqua Sant\'Anna', 'category': 'Bevande'},
    'rocchetta': {'name': 'Acqua Rocchetta', 'category': 'Bevande'},
    'ferrarelle': {'name': 'Acqua Ferrarelle', 'category': 'Bevande'},
    'lete': {'name': 'Acqua Lete', 'category': 'Bevande'},
    'uliveto': {'name': 'Acqua Uliveto', 'category': 'Bevande'},
    'san pellegrino': {'name': 'Acqua San Pellegrino', 'category': 'Bevande'},

    // Bibite
    'coca': {'name': 'Coca Cola', 'category': 'Bevande'},
    'pepsi': {'name': 'Pepsi', 'category': 'Bevande'},
    'fanta': {'name': 'Fanta', 'category': 'Bevande'},
    'sprite': {'name': 'Sprite', 'category': 'Bevande'},
    '7up': {'name': '7 Up', 'category': 'Bevande'},
    'chinotto': {'name': 'Chinotto', 'category': 'Bevande'},
    'gassosa': {'name': 'Gassosa', 'category': 'Bevande'},
    'cedrata': {'name': 'Cedrata', 'category': 'Bevande'},
    'tassoni': {'name': 'Cedrata Tassoni', 'category': 'Bevande'},
    'spuma': {'name': 'Spuma', 'category': 'Bevande'},
    'aranciata': {'name': 'Aranciata', 'category': 'Bevande'},
    'limonata': {'name': 'Limonata', 'category': 'Bevande'},
    'ginger ale': {'name': 'Ginger Ale', 'category': 'Bevande'},
    'ginger beer': {'name': 'Ginger Beer', 'category': 'Bevande'},
    'tonica': {'name': 'Acqua Tonica', 'category': 'Bevande'},
    'cola': {'name': 'Cola', 'category': 'Bevande'},
    'crodo': {'name': 'Crodo', 'category': 'Bevande'},
    'schweppes': {'name': 'Schweppes', 'category': 'Bevande'},

    // Succhi ed Energy Drink
    'succo': {'name': 'Succo di frutta', 'category': 'Bevande'},
    'santal': {'name': 'Succo Santal', 'category': 'Bevande'},
    'yoga': {'name': 'Succo Yoga', 'category': 'Bevande'},
    'bravo': {'name': 'Succo Bravo', 'category': 'Bevande'},
    'zuegg': {'name': 'Succo Zuegg', 'category': 'Bevande'},
    'sciroppo': {'name': 'Sciroppo', 'category': 'Bevande'},
    'red bull': {'name': 'Red Bull', 'category': 'Bevande'},
    'monster': {'name': 'Monster Energy', 'category': 'Bevande'},
    'powerade': {'name': 'Powerade', 'category': 'Bevande'},
    'gatorade': {'name': 'Gatorade', 'category': 'Bevande'},
    'energade': {'name': 'Energade', 'category': 'Bevande'},

    // Tè e Infusi (Caldi/Freddi)
    'the': {'name': 'Tè', 'category': 'Bevande'},
    'te': {'name': 'Tè', 'category': 'Bevande'},
    'estathe': {'name': 'Estathe', 'category': 'Bevande'},
    'fuze': {'name': 'Fuze Tea', 'category': 'Bevande'},
    'lipton': {'name': 'Lipton Ice Tea', 'category': 'Bevande'},
    'camomilla': {'name': 'Camomilla', 'category': 'Bevande'},
    'tisana': {'name': 'Tisana', 'category': 'Bevande'},
    'infuso': {'name': 'Infuso', 'category': 'Bevande'},
    'karkade': {'name': 'Karkadè', 'category': 'Bevande'},
    'mate': {'name': 'Mate', 'category': 'Bevande'},

    // Caffetteria
    'caffe': {'name': 'Caffè', 'category': 'Bevande'},
    'decaffeinato': {'name': 'Decaffeinato', 'category': 'Bevande'},
    'ginseng': {'name': 'Caffè al Ginseng', 'category': 'Bevande'},
    'cicoria': {'name': 'Caffè di Cicoria', 'category': 'Bevande'},
    'cappuccino': {'name': 'Cappuccino', 'category': 'Bevande'},
    'marocchino': {'name': 'Marocchino', 'category': 'Bevande'},
    'mocaccino': {'name': 'Mocaccino', 'category': 'Bevande'},

    // Birre
    'birra': {'name': 'Birra', 'category': 'Bevande'},
    'ichnusa': {'name': 'Birra Ichnusa', 'category': 'Bevande'},
    'pils': {'name': 'Birra Pils', 'category': 'Bevande'},
    'premium': {'name': 'Birra Premium', 'category': 'Bevande'},
    'heineken': {'name': 'Birra Heineken', 'category': 'Bevande'},
    'peroni': {'name': 'Birra Peroni', 'category': 'Bevande'},
    'moretti': {'name': 'Birra Moretti', 'category': 'Bevande'},
    'corona': {'name': 'Birra Corona', 'category': 'Bevande'},
    'tennent': {'name': 'Birra Tennent\'s', 'category': 'Bevande'},
    'guinness': {'name': 'Birra Guinness', 'category': 'Bevande'},
    'beck': {'name': 'Birra Beck\'s', 'category': 'Bevande'},
    'poretti': {'name': 'Birra Poretti', 'category': 'Bevande'},
    'ceres': {'name': 'Birra Ceres', 'category': 'Bevande'},
    'dreher': {'name': 'Birra Dreher', 'category': 'Bevande'},
    'tuborg': {'name': 'Birra Tuborg', 'category': 'Bevande'},
    'carlsberg': {'name': 'Birra Carlsberg', 'category': 'Bevande'},
    'messina': {'name': 'Birra Messina', 'category': 'Bevande'},
    'menabrea': {'name': 'Birra Menabrea', 'category': 'Bevande'},
    'forst': {'name': 'Birra Forst', 'category': 'Bevande'},
    'leffe': {'name': 'Birra Leffe', 'category': 'Bevande'},
    'hoegaarden': {'name': 'Birra Hoegaarden', 'category': 'Bevande'},
    'franziskaner': {'name': 'Birra Franziskaner', 'category': 'Bevande'},
    'paulaner': {'name': 'Birra Paulaner', 'category': 'Bevande'},
    'kilkenny': {'name': 'Birra Kilkenny', 'category': 'Bevande'},
    'murphy': {'name': 'Birra Murphy\'s', 'category': 'Bevande'},

    // Vini e Spumanti
    'vino': {'name': 'Vino', 'category': 'Bevande'},
    'spumante': {'name': 'Spumante', 'category': 'Bevande'},
    'prosecco': {'name': 'Prosecco', 'category': 'Bevande'},
    'champagne': {'name': 'Champagne', 'category': 'Bevande'},
    'franciacorta': {'name': 'Franciacorta', 'category': 'Bevande'},
    'asti': {'name': 'Asti Spumante', 'category': 'Bevande'},
    'brachetto': {'name': 'Brachetto', 'category': 'Bevande'},
    'lambrusco': {'name': 'Lambrusco', 'category': 'Bevande'},
    'passito': {'name': 'Passito', 'category': 'Bevande'},
    'vin santo': {'name': 'Vin Santo', 'category': 'Bevande'},
    'marsala': {'name': 'Marsala', 'category': 'Bevande'},
    'porto': {'name': 'Vino Porto', 'category': 'Bevande'},
    'sherry': {'name': 'Sherry', 'category': 'Bevande'},
    'madeira': {'name': 'Madeira', 'category': 'Bevande'},
    'vermouth': {'name': 'Vermouth', 'category': 'Bevande'},

    // Aperitivi & Amari
    'martini': {'name': 'Martini', 'category': 'Bevande'},
    'campari': {'name': 'Campari', 'category': 'Bevande'},
    'aperol': {'name': 'Aperol', 'category': 'Bevande'},
    'crodino': {'name': 'Crodino', 'category': 'Bevande'},
    'sanbitter': {'name': 'Sanbittèr', 'category': 'Bevande'},
    'amaro': {'name': 'Amaro', 'category': 'Bevande'},
    'montenegro': {'name': 'Amaro Montenegro', 'category': 'Bevande'},
    'averna': {'name': 'Amaro Averna', 'category': 'Bevande'},
    'lucano': {'name': 'Amaro Lucano', 'category': 'Bevande'},
    'jagermeister': {'name': 'Jägermeister', 'category': 'Bevande'},
    'fernet': {'name': 'Fernet', 'category': 'Bevande'},
    
    // Liquori
    'sambuca': {'name': 'Sambuca', 'category': 'Bevande'},
    'molinari': {'name': 'Sambuca Molinari', 'category': 'Bevande'},
    'grappa': {'name': 'Grappa', 'category': 'Bevande'},
    'acquavite': {'name': 'Acquavite', 'category': 'Bevande'},
    'limoncello': {'name': 'Limoncello', 'category': 'Bevande'},
    'villa massa': {'name': 'Limoncello Villa Massa', 'category': 'Bevande'},
    'mirto': {'name': 'Mirto', 'category': 'Bevande'},
    'nocino': {'name': 'Nocino', 'category': 'Bevande'},
    'baileys': {'name': 'Baileys', 'category': 'Bevande'},
    'amaretto': {'name': 'Amaretto', 'category': 'Bevande'},
    'disaronno': {'name': 'Disaronno', 'category': 'Bevande'},
    'anisetta': {'name': 'Anisetta', 'category': 'Bevande'},
    'mistra': {'name': 'Mistrà', 'category': 'Bevande'},
    'pastis': {'name': 'Pastis', 'category': 'Bevande'},
    'ouzo': {'name': 'Ouzo', 'category': 'Bevande'},
    'raki': {'name': 'Raki', 'category': 'Bevande'},
    'arak': {'name': 'Arak', 'category': 'Bevande'},
    'assenzio': {'name': 'Assenzio', 'category': 'Bevande'},

    // Superalcolici
    'vodka': {'name': 'Vodka', 'category': 'Bevande'},
    'absolut': {'name': 'Vodka Absolut', 'category': 'Bevande'},
    'smirnoff': {'name': 'Vodka Smirnoff', 'category': 'Bevande'},
    'grey goose': {'name': 'Vodka Grey Goose', 'category': 'Bevande'},
    'belvedere': {'name': 'Vodka Belvedere', 'category': 'Bevande'},
    'gin': {'name': 'Gin', 'category': 'Bevande'},
    'bombay': {'name': 'Gin Bombay', 'category': 'Bevande'},
    'tanqueray': {'name': 'Gin Tanqueray', 'category': 'Bevande'},
    'gordon': {'name': 'Gin Gordon\'s', 'category': 'Bevande'},
    'hendrick': {'name': 'Gin Hendrick\'s', 'category': 'Bevande'},
    'rum': {'name': 'Rum', 'category': 'Bevande'},
    'rhum': {'name': 'Rum', 'category': 'Bevande'},
    'havana club': {'name': 'Rum Havana Club', 'category': 'Bevande'},
    'bacardi': {'name': 'Rum Bacardi', 'category': 'Bevande'},
    'pampero': {'name': 'Rum Pampero', 'category': 'Bevande'},
    'zacapa': {'name': 'Rum Zacapa', 'category': 'Bevande'},
    'cachaca': {'name': 'Cachaça', 'category': 'Bevande'},
    'tequila': {'name': 'Tequila', 'category': 'Bevande'},
    'don julio': {'name': 'Tequila Don Julio', 'category': 'Bevande'},
    'jose cuervo': {'name': 'Tequila Jose Cuervo', 'category': 'Bevande'},
    'mezcal': {'name': 'Mezcal', 'category': 'Bevande'},
    'whisky': {'name': 'Whisky', 'category': 'Bevande'},
    'whiskey': {'name': 'Whisky', 'category': 'Bevande'},
    'bourbon': {'name': 'Bourbon Whiskey', 'category': 'Bevande'},
    'chivas': {'name': 'Whisky Chivas', 'category': 'Bevande'},
    'jack daniel': {'name': 'Jack Daniel\'s', 'category': 'Bevande'},
    'jim beam': {'name': 'Jim Beam', 'category': 'Bevande'},
    'maker': {'name': 'Maker\'s Mark', 'category': 'Bevande'},
    'johnnie walker': {'name': 'Johnnie Walker', 'category': 'Bevande'},
    'macallan': {'name': 'Macallan', 'category': 'Bevande'},
    'talisker': {'name': 'Talisker', 'category': 'Bevande'},
    'lagavulin': {'name': 'Lagavulin', 'category': 'Bevande'},
    'oban': {'name': 'Oban', 'category': 'Bevande'},
    'glenfiddich': {'name': 'Glenfiddich', 'category': 'Bevande'},
    'glenlivet': {'name': 'Glenlivet', 'category': 'Bevande'},
    'brandy': {'name': 'Brandy', 'category': 'Bevande'},
    'cognac': {'name': 'Cognac', 'category': 'Bevande'},
    'armagnac': {'name': 'Armagnac', 'category': 'Bevande'},
    'calvados': {'name': 'Calvados', 'category': 'Bevande'},

    // ================= IGIENE PERSONALE E COSMETICA =================
    // Detergenti Base
    'bagnoschiuma': {'name': 'Bagnoschiuma', 'category': 'Altro'},
    'docciaschiuma': {'name': 'Docciaschiuma', 'category': 'Altro'},
    'shampoo': {'name': 'Shampoo', 'category': 'Altro'},
    'balsamo': {'name': 'Balsamo', 'category': 'Altro'},
    'maschera': {'name': 'Maschera', 'category': 'Altro'},
    'sapone': {'name': 'Sapone', 'category': 'Altro'},
    'saponetta': {'name': 'Saponetta', 'category': 'Altro'},
    'intimo': {'name': 'Detergente Intimo', 'category': 'Altro'},
    'deodorante': {'name': 'Deodorante', 'category': 'Altro'},
    'borotalco': {'name': 'Borotalco', 'category': 'Altro'},
    'profumo': {'name': 'Profumo', 'category': 'Altro'},
    'crema': {'name': 'Crema Viso/Corpo', 'category': 'Altro'},

    // Brand Igiene Persona
    'nivea': {'name': 'Nivea', 'category': 'Altro'},
    'dove': {'name': 'Dove', 'category': 'Altro'},
    'felce azzurra': {'name': 'Felce Azzurra', 'category': 'Altro'},
    'palmolive': {'name': 'Palmolive', 'category': 'Altro'},
    'bionsen': {'name': 'Bionsen', 'category': 'Altro'},
    'neutromed': {'name': 'Neutromed', 'category': 'Altro'},
    'infasil': {'name': 'Infasil', 'category': 'Altro'},
    'chilly': {'name': 'Chilly', 'category': 'Altro'},
    'fissan': {'name': 'Pasta Fissan', 'category': 'Altro'},
    'johnson': {'name': 'Johnson\'s', 'category': 'Altro'},
    'garnier': {'name': 'Garnier', 'category': 'Altro'},
    'loreal': {'name': 'L\'Oréal', 'category': 'Altro'},
    'pantene': {'name': 'Pantene', 'category': 'Altro'},
    'sunsilk': {'name': 'Sunsilk', 'category': 'Altro'},
    'clear': {'name': 'Clear', 'category': 'Altro'},
    'fructis': {'name': 'Fructis', 'category': 'Altro'},
    'elvive': {'name': 'Elvive', 'category': 'Altro'},
    'herbal essences': {'name': 'Herbal Essences', 'category': 'Altro'},
    'batiste': {'name': 'Batiste Dry Shampoo', 'category': 'Altro'},
    'spuma di sciampagna': {'name': 'Spuma di Sciampagna', 'category': 'Altro'},
    'neutro roberts': {'name': 'Neutro Roberts', 'category': 'Altro'},
    'malizia': {'name': 'Malizia', 'category': 'Altro'},
    'vidal': {'name': 'Vidal', 'category': 'Altro'},
    'pino silvestre': {'name': 'Pino Silvestre', 'category': 'Altro'},
    'mantovani': {'name': 'Mantovani', 'category': 'Altro'},
    'lycia': {'name': 'Lycia', 'category': 'Altro'},
    'derma': {'name': 'Neutroderma', 'category': 'Altro'},
    'bionike': {'name': 'Bionike', 'category': 'Altro'},
    'eucerin': {'name': 'Eucerin', 'category': 'Altro'},
    'aveeno': {'name': 'Aveeno', 'category': 'Altro'},
    'neutrogena': {'name': 'Neutrogena', 'category': 'Altro'},
    'leocrema': {'name': 'Leocrema', 'category': 'Altro'},
    'venus': {'name': 'Venus', 'category': 'Altro'},
    'cien': {'name': 'Cien', 'category': 'Altro'},
    'omia': {'name': 'Omia', 'category': 'Altro'},
    'bioten': {'name': 'Bioten', 'category': 'Altro'},

    // Prodotti Igienici Intimi e Baby
    'pannolini': {'name': 'Pannolini', 'category': 'Altro'},
    'pampers': {'name': 'Pannolini Pampers', 'category': 'Altro'},
    'baby dry': {'name': 'Pampers Baby Dry', 'category': 'Altro'},
    'progressi': {'name': 'Pampers Progressi', 'category': 'Altro'},
    'huggies': {'name': 'Pannolini Huggies', 'category': 'Altro'},
    'salvaslip': {'name': 'Salvaslip', 'category': 'Altro'},
    'assorbenti': {'name': 'Assorbenti', 'category': 'Altro'},
    'lines': {'name': 'Assorbenti Lines', 'category': 'Altro'},
    'lines seta': {'name': 'Lines Seta', 'category': 'Altro'},
    'nuvenia': {'name': 'Assorbenti Nuvenia', 'category': 'Altro'},
    'tampax': {'name': 'Tampax', 'category': 'Altro'},
    'ob': {'name': 'Assorbenti OB', 'category': 'Altro'},
    'carefree': {'name': 'Carefree', 'category': 'Altro'},
    'tena': {'name': 'Tena Lady', 'category': 'Altro'},

    // Rasatura
    'rasoio': {'name': 'Rasoio', 'category': 'Altro'},
    'gillette': {'name': 'Gillette', 'category': 'Altro'},
    'wilkinson': {'name': 'Wilkinson', 'category': 'Altro'},
    'bic': {'name': 'Bic Rasoio', 'category': 'Altro'},
    'schick': {'name': 'Schick', 'category': 'Altro'},
    'braun': {'name': 'Braun', 'category': 'Altro'},
    'philips': {'name': 'Philips', 'category': 'Altro'},
    'schiuma da barba': {'name': 'Schiuma da barba', 'category': 'Altro'},
    'proraso': {'name': 'Proraso', 'category': 'Altro'},
    'dopobarba': {'name': 'Dopobarba', 'category': 'Altro'},

    // Igiene Orale e Accessori
    'dentifricio': {'name': 'Dentifricio', 'category': 'Altro'},
    'colgate': {'name': 'Colgate', 'category': 'Altro'},
    'mentadent': {'name': 'Mentadent', 'category': 'Altro'},
    'az': {'name': 'AZ', 'category': 'Altro'},
    'oral b': {'name': 'Oral B', 'category': 'Altro'},
    'elmex': {'name': 'Elmex', 'category': 'Altro'},
    'meridol': {'name': 'Meridol', 'category': 'Altro'},
    'aquafresh': {'name': 'Aquafresh', 'category': 'Altro'},
    'parodontax': {'name': 'Parodontax', 'category': 'Altro'},
    'sensodyne': {'name': 'Sensodyne', 'category': 'Altro'},
    'listerine': {'name': 'Listerine', 'category': 'Altro'},
    'curaprox': {'name': 'Curaprox', 'category': 'Altro'},
    'collutorio': {'name': 'Collutorio', 'category': 'Altro'},
    'spazzolino': {'name': 'Spazzolino', 'category': 'Altro'},
    'filo interdentale': {'name': 'Filo Interdentale', 'category': 'Altro'},
    'cotton fioc': {'name': 'Cotton Fioc', 'category': 'Altro'},
    'dischetti': {'name': 'Dischetti Struccanti', 'category': 'Altro'},
    'salviette': {'name': 'Salviette', 'category': 'Altro'},

    // ================= IGIENE CASA E CARTA =================
    // Detersivi
    'detersivo': {'name': 'Detersivo', 'category': 'Altro'},
    'dash': {'name': 'Detersivo Dash', 'category': 'Altro'},
    'dixan': {'name': 'Detersivo Dixan', 'category': 'Altro'},
    'bio presto': {'name': 'Bio Presto', 'category': 'Altro'},
    'omino bianco': {'name': 'Omino Bianco', 'category': 'Altro'},
    'chanteclair': {'name': 'Chanteclair', 'category': 'Altro'},
    'sgrassatore': {'name': 'Sgrassatore', 'category': 'Altro'},
    'candeggina': {'name': 'Candeggina', 'category': 'Altro'},
    'ace': {'name': 'Candeggina Ace', 'category': 'Altro'},
    'smac': {'name': 'Smac', 'category': 'Altro'},
    'viakal': {'name': 'Viakal', 'category': 'Altro'},
    'lysoform': {'name': 'Lysoform', 'category': 'Altro'},
    'cif': {'name': 'Cif', 'category': 'Altro'},
    'vetril': {'name': 'Vetril', 'category': 'Altro'},
    'ajax': {'name': 'Ajax', 'category': 'Altro'},
    'fabuloso': {'name': 'Fabuloso', 'category': 'Altro'},
    'rio': {'name': 'Rio', 'category': 'Altro'},
    'amuchina': {'name': 'Amuchina', 'category': 'Altro'},
    'napisan': {'name': 'Napisan', 'category': 'Altro'},
    'wc net': {'name': 'WC Net', 'category': 'Altro'},
    'anitra wc': {'name': 'Anitra WC', 'category': 'Altro'},
    'emulsio': {'name': 'Emulsio', 'category': 'Altro'},
    'pronto': {'name': 'Pronto Legno', 'category': 'Altro'},
    'mastro lindo': {'name': 'Mastro Lindo', 'category': 'Altro'},
    'sole': {'name': 'Sole Detersivo', 'category': 'Altro'},
    'winni': {'name': 'Winni\'s', 'category': 'Altro'},
    'nelsen': {'name': 'Nelsen', 'category': 'Altro'},
    'svelto': {'name': 'Svelto', 'category': 'Altro'},
    'fairy': {'name': 'Fairy', 'category': 'Altro'},
    'finish': {'name': 'Finish', 'category': 'Altro'},
    'pril': {'name': 'Pril', 'category': 'Altro'},
    'calgon': {'name': 'Calgon', 'category': 'Altro'},
    'vanish': {'name': 'Vanish', 'category': 'Altro'},
    'grey': {'name': 'L\'Acchiappacolore Grey', 'category': 'Altro'},
    'coloreria': {'name': 'Coloreria Italiana', 'category': 'Altro'},
    'vernel': {'name': 'Vernel', 'category': 'Altro'},
    'coccolino': {'name': 'Coccolino', 'category': 'Altro'},
    'lenor': {'name': 'Lenor', 'category': 'Altro'},
    'glade': {'name': 'Glade', 'category': 'Altro'},
    'ammorbidente': {'name': 'Ammorbidente', 'category': 'Altro'},
    
    // Carta e Accessori Casalinghi
    'domopak': {'name': 'Domopak', 'category': 'Altro'},
    'cuki': {'name': 'Cuki', 'category': 'Altro'},
    'pellicola': {'name': 'Pellicola Trasparente', 'category': 'Altro'},
    'alluminio': {'name': 'Carta Alluminio', 'category': 'Altro'},
    'carta forno': {'name': 'Carta Forno', 'category': 'Altro'},
    'carta casa': {'name': 'Carta Casa', 'category': 'Altro'},
    'scottex': {'name': 'Scottex', 'category': 'Altro'},
    'asciugatutto': {'name': 'Asciugatutto', 'category': 'Altro'},
    'carta igienica': {'name': 'Carta Igienica', 'category': 'Altro'},
    'rotoloni': {'name': 'Rotoloni', 'category': 'Altro'},
    'regina': {'name': 'Carta Regina', 'category': 'Altro'},
    'foxy': {'name': 'Carta Foxy', 'category': 'Altro'},
    'tenderly': {'name': 'Tenderly', 'category': 'Altro'},
    'nicky': {'name': 'Nicky', 'category': 'Altro'},
    'tempo': {'name': 'Fazzoletti Tempo', 'category': 'Altro'},
    'fazzoletti': {'name': 'Fazzoletti', 'category': 'Altro'},
    'tovaglioli': {'name': 'Tovaglioli', 'category': 'Altro'},
    'spugna': {'name': 'Spugna', 'category': 'Altro'},
    'vileda': {'name': 'Vileda', 'category': 'Altro'},
    'arix': {'name': 'Arix', 'category': 'Altro'},
    'scotch brite': {'name': 'Scotch Brite', 'category': 'Altro'},
    'guanti': {'name': 'Guanti', 'category': 'Altro'},
    'scopa': {'name': 'Scopa', 'category': 'Altro'},
    'paletta': {'name': 'Paletta', 'category': 'Altro'},
    'mocio': {'name': 'Mocio', 'category': 'Altro'},
    'swiffer': {'name': 'Swiffer', 'category': 'Altro'},
    'sacchetti': {'name': 'Sacchetti Spazzatura', 'category': 'Altro'},
    'immondizia': {'name': 'Sacchetti Spazzatura', 'category': 'Altro'},
  };

  // Parole spazzatura OCR e marchi della GDO da rifuggire
  static final List<String> _garbageKeywords = [
    // Parole di servizio
    'totale', 'resto', 'contanti', 'bancomat', 'carta', 'euro', 'iva',
    'scontrino', 'reparto', 'sconto', 'pagamento', 'importo', 'sacchetto', 'sacch', 'ortofrutta',
    'eur', 'piva', 'via', 'telefono', 'tel', 'grazie', 'arrivederci', 'documento', 'commerciale',
    'cassa', 'pos', 'transazione', 'bio', 'it', 'prec', 'vendita', 'prestazione', 'descrizione',
    'prezzo', 'di cui', 'complessivo', 'elettronico', 'pagato', 'sottototale', 'arrotondamento',
    'corrispettivo', 'c.f.', 'cf', 'partita iva', 's.r.l.', 'srl', 's.p.a.', 'spa', 'viale',
    'piazza', 'cap', 'prov', 'restante', 'reso', 'scadenza', 'scad', 'lotto', 'barcode', 'codice',
    'art', 'articolo', 'art.', 'rep', 'rep.',
    
    // Circuiti pagamento
    'mastercard', 'visa', 'maestro', 'pagobancomat', 'american express', 'amex',

    // Typo OCR
    'iotale', 'coplesio', 'logo', 'u2s', 'rt eyo', 'rt', 'eyo', 'pt',
    'vverdeb', 'loriana', 'doc', 'dop', 'igp', 'igt', 'parentesi', '(', ')', '[', ']', 'n.', 'nr',
    'q.ta', 'qta', 'quantita', '%',

    // Nomi supermercati (Ignorati se in mezzo ad altre parole)
    'coop', 'maxi', 'conad', 'esselunga', 'pam', 'lidl',
    'eurospin', 'carrefour', 'md', 'penny', 'aldi', 'crai', 'despar', 'iper',
    'ipercoop', 'famila', 'tigros', 'unes', 'panorama', 'il gigante', 'deco',
    'basko', 'sisa', 'todis', 'tuodi', 'incoop', 'offerta', 'promozione', 'promo',
    'punti', 'fidaty', 'fidelita', 'soci', 'socio', 'auchan', 'bennet', 'iperal', 'tigota',
    'acquaesapone', 'maury', 'basko', 'peq', 'supermercato', 'minimarket'
  ];

  /// Calcola la distanza di Levenshtein tra due stringhe
  static int _levenshteinDistance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    List<int> v0 = List<int>.filled(b.length + 1, 0);
    List<int> v1 = List<int>.filled(b.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < a.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < b.length; j++) {
        int cost = (a[i] == b[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[b.length];
  }

  /// Restituisce un punteggio di similarità da 0.0 a 1.0
  static double _similarityScore(String a, String b) {
    int maxLen = max(a.length, b.length);
    if (maxLen == 0) return 1.0;
    int distance = _levenshteinDistance(a, b);
    return 1.0 - (distance / maxLen);
  }

  static List<ItemModel> parseReceiptText(String rawText) {
    List<ItemModel> extractedItems = [];
    List<String> lines = rawText.split('\n');

    for (String line in lines) {
      String cleanLine = line.toLowerCase().trim();
      if (cleanLine.length < 3) continue;

      // 1. Filtraggio Garbage Totale (Riga interamente da scartare)
      bool isGarbageLine = false;
      List<String> discardWords = ['sconto', 'totale', 'resto', 'contanti', 'bancomat', 'carta', 'pagamento', 'sacchetto', 'sacch', 'transazione', 'cassa', 'iva', 'iotale', 'coplesio', 'logo', 'u2s', 'rt eyo', 'rt', 'documento', 'commerciale', 'vendita', 'prestazione', 'descrizione', 'prezzo'];
      for (String garbage in discardWords) {
        if (cleanLine.contains(garbage)) {
          isGarbageLine = true;
          break;
        }
      }
      if (isGarbageLine) continue;

      if (RegExp(r'^[\d\s\W]+$').hasMatch(cleanLine)) continue;

      // 2. Pulizia Prezzi, IVA e Codici di Calibro (es. 14-2, 7585) dal testo puro
      String textWithoutPrice = cleanLine
          .replaceAll(RegExp(r'\s*\d+[,\.]\d{2}\s*(€|eur|e)?\s*[a-zA-Z]?\s*$'), '')
          .trim();
          
      // Rimuove pesi e calibri (es. 14-2, 75-85, 250g, 400g, ml, cl, litri)
      textWithoutPrice = textWithoutPrice
          .replaceAll(RegExp(r'\b\d+-\d+\b'), '')
          .replaceAll(RegExp(r'\b\d{4,}\b'), '') // Rimuove numeri grossi come 7585
          .replaceAll(RegExp(r'\b\d+\s*(g|kg|gr|ml|cl|l|litri)\b'), '')
          .replaceAll(RegExp(r'\(.*\)'), '') // Rimuove parentesi tonde
          .replaceAll(RegExp(r'\[.*\]'), '') // Rimuove parentesi quadre
          .replaceAll('%', '')
          .trim();

      // 3. Estrazione Quantità (dopo aver rimosso calibri e codici)
      int quantity = _extractQuantity(textWithoutPrice);

      String productNameRaw = textWithoutPrice
          .replaceAll(RegExp(r'\b\d+[\s]*[xX]?\b'), '') // Rimuove la quantità estratta dal nome
          .trim();

      // Rimuove garbage words specifiche dal nome prodotto
      for (String garbage in _garbageKeywords) {
        productNameRaw = productNameRaw.replaceAll(RegExp(r'\b' + garbage + r'\b'), ' ').trim();
      }

      productNameRaw =
          productNameRaw.replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

      if (productNameRaw.isEmpty || productNameRaw.length < 3) continue;

      // 4. Intelligenza Artificiale Matematica (Fuzzy Matching)
      String finalName = productNameRaw;
      String finalCategory = 'Altro';

      double bestSimilarity = 0.0;
      String bestMatchKey = '';

      // Confrontiamo la riga "sporca" con tutte le parole del dizionario
      for (String dictKey in _productDictionary.keys) {
        List<String> words = productNameRaw.split(' ');
        for (String word in words) {
          if (word.length < 3) continue;
          double sim = _similarityScore(word, dictKey);
          if (sim > bestSimilarity) {
            bestSimilarity = sim;
            bestMatchKey = dictKey;
          }
        }
      }

      // Se c'è una similarità > 70% consideriamo la parola corretta
      if (bestSimilarity >= 0.70) {
        finalName = _productDictionary[bestMatchKey]!['name']!;
        finalCategory = _productDictionary[bestMatchKey]!['category']!;
      } else {
        // Fallback: capitalizza il nome originale
        finalName = finalName
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
            .join(' ')
            .trim();
      }

      extractedItems.add(ItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString() +
            finalName.hashCode.toString(),
        name: finalName,
        quantity: quantity,
        category: finalCategory,
        isPantry: true,
      ));
    }

    // 5. Raggruppamento duplicati
    Map<String, ItemModel> groupedItems = {};
    for (var item in extractedItems) {
      if (groupedItems.containsKey(item.name)) {
        var existing = groupedItems[item.name]!;
        groupedItems[item.name] = ItemModel(
            id: existing.id,
            name: existing.name,
            expireDate: existing.expireDate,
            quantity: existing.quantity + item.quantity,
            category: existing.category,
            isPantry: true);
      } else {
        groupedItems[item.name] = item;
      }
    }

    return groupedItems.values.toList();
  }

  static int _extractQuantity(String text) {
    RegExp regex = RegExp(r'\b(\d+)[\s]*[xX]?\b');
    var match = regex.firstMatch(text);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '1') ?? 1;
    }
    return 1;
  }
}
