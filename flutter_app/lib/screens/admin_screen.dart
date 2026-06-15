import 'package:flutter/material.dart';
import '../models/app_state.dart';

class AdminScreen extends StatefulWidget {
  final AppState state;

  const AdminScreen({super.key, required this.state});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  
  // State variables for profile form
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  // Mock list of group members
  List<Map<String, String>> _members = [
    {"name": "Tu", "role": "Admin", "id": "1"},
    {"name": "Marco Rossini", "role": "Coinquilino", "id": "2"},
    {"name": "Giulia Bianchi", "role": "Coinquilina", "id": "3"},
  ];

  // Mock list of join requests
  List<Map<String, String>> _requests = [
    {"name": "Davide Neri", "email": "davide.neri@email.com", "id": "req_1"},
    {"name": "Sofia Verdi", "email": "sofia.verdi@email.com", "id": "req_2"},
  ];

  // Check if current user is admin (always true for the mockup view)
  final bool _isGroupAdmin = true;

  @override
  void initState() {
    super.initState();
    // Initialize with values from AppState if available, otherwise mock data
    final userName = widget.state.currentUserData?.name ?? "Studente Fuorisede";
    final userEmail = widget.state.currentUserAuth?.email ?? "studente@avanzizero.it";
    
    _nameController = TextEditingController(text: userName);
    _emailController = TextEditingController(text: userEmail);
    _passwordController = TextEditingController(text: "••••••");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_profileFormKey.currentState!.validate()) {
      await widget.state.updateProfileName(_nameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✨ Profilo aggiornato con successo!"),
            backgroundColor: Color(0xFF5A9E87),
          ),
        );
      }
    }
  }

  void _removeMember(String id, String name) {
    setState(() {
      _members.removeWhere((m) => m["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("🗑️ $name rimosso dal gruppo."),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  void _acceptRequest(String id, String name) {
    setState(() {
      _requests.removeWhere((r) => r["id"] == id);
      _members.add({
        "name": name,
        "role": "Coinquilino/a",
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Richiesta di $name accettata!"),
        backgroundColor: const Color(0xFF5A9E87),
      ),
    );
  }

  void _rejectRequest(String id, String name) {
    setState(() {
      _requests.removeWhere((r) => r["id"] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Richiesta di $name rifiutata."),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupId = widget.state.groupId ?? "NESSUN GRUPPO";

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBF9), // Avorio Soft
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBF9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1C3D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Area Admin & Profilo",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C3D32),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // SEZIONE 1: MODIFICA DATI PERSONALI
              // ==========================================
              _buildSectionTitle("I Miei Dati Personali"),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x051C3D32),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF5A9E87).withOpacity(0.15)),
                ),
                child: Form(
                  key: _profileFormKey,
                  child: Column(
                    children: [
                      // Input Nome
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Nome",
                          prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF5A9E87)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFFBFBF9),
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Inserisci il tuo nome" : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Input Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF5A9E87)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFFBFBF9),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val == null || !val.contains('@') ? "Inserisci una email valida" : null,
                      ),
                      const SizedBox(height: 16),

                      // Input Password
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF5A9E87)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: const Color(0xFFFBFBF9),
                        ),
                        obscureText: true,
                        validator: (val) => val == null || val.isEmpty ? "Inserisci la password" : null,
                      ),
                      const SizedBox(height: 20),

                      // Pulsante Salva
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5A9E87),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Salva Modifiche",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ==========================================
              // SEZIONE 2: MEMBRI DEL GRUPPO
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle("Membri del Gruppo"),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Codice: $activeGroupId",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x051C3D32),
                      blurRadius: 15,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF5A9E87).withOpacity(0.15)),
                ),
                child: _members.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Nessun partecipante nel gruppo.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _members.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final member = _members[index];
                          final isMe = member["name"] == "Tu";
                          final isAdmin = member["role"] == "Admin";

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(
                              member["name"]!,
                              style: const TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1C3D32),
                              ),
                            ),
                            trailing: (_isGroupAdmin && !isMe)
                                ? IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                                    onPressed: () => _removeMember(member["id"]!, member["name"]!),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 28),

              // ==========================================
              // SEZIONE 3: RICHIESTE DI INGRESSO (Solo per Admin)
              // ==========================================
              if (_isGroupAdmin) ...[
                _buildSectionTitle("Richieste di Ingresso"),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x051C3D32),
                        blurRadius: 15,
                        offset: Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFF5A9E87).withOpacity(0.15)),
                  ),
                  child: _requests.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(Icons.mark_email_read_outlined, color: Color(0xFF789088), size: 36),
                              SizedBox(height: 8),
                              Text(
                                "Nessuna richiesta di ingresso in attesa.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                  color: Color(0xFF789088),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _requests.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          itemBuilder: (context, index) {
                            final request = _requests[index];

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFF3F4F6),
                                child: Icon(Icons.hourglass_empty_rounded, color: Color(0xFF789088), size: 18),
                              ),
                              title: Text(
                                request["name"]!,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF1C3D32),
                                ),
                              ),
                              subtitle: Text(
                                request["email"]!,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Accetta (Spunta Verde)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
                                    onPressed: () => _acceptRequest(request["id"]!, request["name"]!),
                                  ),
                                  // Rifiuta (Croce Rossa)
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, color: Color(0xFFEF4444)),
                                    onPressed: () => _rejectRequest(request["id"]!, request["name"]!),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1C3D32),
        ),
      ),
    );
  }
}
