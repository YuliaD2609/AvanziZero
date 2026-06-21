import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class WordPieceTokenizer {
  static final WordPieceTokenizer _instance = WordPieceTokenizer._internal();
  factory WordPieceTokenizer() => _instance;
  WordPieceTokenizer._internal();

  Map<String, int> _vocab = {};
  Map<int, String> _invVocab = {};
  int _unkTokenId = 100;
  int _clsTokenId = 101;
  int _sepTokenId = 102;
  int _padTokenId = 0;
  bool _isLoaded = false;

  Future<void> loadVocab(String assetPath) async {
    if (_isLoaded) return;
    try {
      final String vocabString = await rootBundle.loadString(assetPath);
      final List<String> lines = LineSplitter.split(vocabString).toList();
      for (int i = 0; i < lines.length; i++) {
        _vocab[lines[i]] = i;
        _invVocab[i] = lines[i];
      }
      _isLoaded = true;
      print("WordPiece Tokenizer caricato: ${_vocab.length} tokens.");
    } catch (e) {
      print("Errore caricamento vocab.txt: $e");
    }
  }

  String decode(List<int> ids) {
    String result = "";
    for (int id in ids) {
      if (id <= 102) continue; // Skip special tokens like PAD, UNK, CLS, SEP
      String token = _invVocab[id] ?? "";
      if (token.startsWith("##")) {
        result += token.substring(2);
      } else {
        result += " " + token;
      }
    }
    return result.trim();
  }

  bool get isLoaded => _isLoaded;

  List<String> basicTokenize(String text) {
    // Basic whitespace and punctuation split keeping punctuation as separate tokens
    text = text.trim();
    if (text.isEmpty) return [];
    
    // Inseriamo spazi prima e dopo la punteggiatura per separarla
    text = text.replaceAllMapped(RegExp(r'([^\w\s])'), (match) => ' ${match.group(1)} ');
    return text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  }

  List<int> tokenize(String text, {int maxLen = 32}) {
    if (!_isLoaded) return List.filled(maxLen, _padTokenId);

    List<int> tokenIds = [];
    tokenIds.add(_clsTokenId);

    List<String> words = basicTokenize(text);

    for (String word in words) {
      List<int> subTokens = [];
      int start = 0;
      bool isBad = false;

      while (start < word.length) {
        int end = word.length;
        int? curSubstrId;

        while (start < end) {
          String subStr = word.substring(start, end);
          if (start > 0) {
            subStr = "##$subStr";
          }
          
          if (_vocab.containsKey(subStr)) {
            curSubstrId = _vocab[subStr];
            break;
          }
          end--;
        }

        if (curSubstrId == null) {
          isBad = true;
          break;
        }

        subTokens.add(curSubstrId);
        start = end;
      }

      if (isBad) {
        tokenIds.add(_unkTokenId);
      } else {
        tokenIds.addAll(subTokens);
      }
    }

    tokenIds.add(_sepTokenId);

    // Truncate
    if (tokenIds.length > maxLen) {
      tokenIds = tokenIds.sublist(0, maxLen);
      tokenIds[maxLen - 1] = _sepTokenId; // Assicurati che finisca sempre con SEP
    }

    // Pad
    while (tokenIds.length < maxLen) {
      tokenIds.add(_padTokenId);
    }

    return tokenIds;
  }
}
