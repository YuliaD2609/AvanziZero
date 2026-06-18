import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_state.dart';
import '../theme/app_colors.dart';

class AdminScreen extends StatefulWidget {
  final AppState state;

  const AdminScreen({super.key, required this.state});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  
  bool _notificationsEnabled = true;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final userName = widget.state.currentUserData?.name ?? "";
    final userEmail = widget.state.currentUserAuth?.email ?? "";
    
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
    // Funzionalità mockata per il profilo personale (da implementare in futuro)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profilo aggiornato con successo!"),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // ============== GESTIONE GRUPPO E RICHIESTE =================

  Future<void> _removeMember(String uid) async {
    final groupId = widget.state.groupId;
    if (groupId == null) return;
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([uid]),
        'adminIds': FieldValue.arrayRemove([uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'groupIds': FieldValue.arrayRemove([groupId])
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Membro rimosso dal gruppo."), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      print("Errore rimozione membro: $e");
    }
  }

  Future<void> _promoteToAdmin(String uid) async {
    final groupId = widget.state.groupId;
    if (groupId == null) return;
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'adminIds': FieldValue.arrayUnion([uid]),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Membro promosso ad Admin!"), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      print("Errore promozione admin: $e");
    }
  }

  Future<void> _acceptRequest(String uid) async {
    final groupId = widget.state.groupId;
    if (groupId == null) return;
    try {
      final db = FirebaseFirestore.instance;
      // 1. Rimuovi la richiesta
      await db.collection('groups').doc(groupId).collection('requests').doc(uid).delete();
      // 2. Aggiungi il membro al gruppo
      await db.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([uid])
      });
      // 3. Aggiorna l'utente (aggiungi groupIds, rimuovi pending)
      await db.collection('users').doc(uid).update({
        'groupIds': FieldValue.arrayUnion([groupId]),
        'pendingGroupIds': FieldValue.arrayRemove([groupId])
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Richiesta accettata!"), backgroundColor: AppColors.primary),
        );
      }
    } catch (e) {
      print("Errore accettazione: $e");
    }
  }

  Future<void> _rejectRequest(String uid) async {
    final groupId = widget.state.groupId;
    if (groupId == null) return;
    try {
      final db = FirebaseFirestore.instance;
      await db.collection('groups').doc(groupId).collection('requests').doc(uid).delete();
      await db.collection('users').doc(uid).update({
        'pendingGroupIds': FieldValue.arrayRemove([groupId])
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Richiesta rifiutata."), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      print("Errore rifiuto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeGroupId = widget.state.groupId ?? "NESSUN GRUPPO";
    final myUid = widget.state.currentUserAuth?.uid ?? "";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Gruppo & Profilo",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
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
                    BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 4)),
                  ],
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Form(
                  key: _profileFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Nome",
                          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        validator: (val) => val == null || val.isEmpty ? "Inserisci il tuo nome" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Nuova Password",
                          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: AppColors.background,
                        ),
                        validator: (val) {
                          if (val != null && val.isNotEmpty && val.length < 6) {
                            return "La password deve avere almeno 6 caratteri";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text("Salva Modifiche", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ==========================================
              // SEZIONE 1.5: NOTIFICHE
              // ==========================================
              _buildSectionTitle("Impostazioni Notifiche"),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 4)),
                  ],
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        "Ricevi notifiche",
                        style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      subtitle: const Text(
                        "Avvisi per scadenze e attività di gruppo",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      activeColor: AppColors.primary,
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                    if (_notificationsEnabled) ...[
                      const Divider(height: 1, color: AppColors.surfaceLight),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: const Text(
                          "Orario Notifiche",
                          style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        subtitle: const Text(
                          "Scegli l'orario per i promemoria giornalieri",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _notificationTime.format(context),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDarker),
                          ),
                        ),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _notificationTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: Colors.white,
                                    onSurface: AppColors.textPrimary,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              _notificationTime = picked;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Orario notifiche aggiornato: ${picked.format(context)}"),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Se non c'è un gruppo attivo, fermati qui
              if (widget.state.groupId == null) const SizedBox.shrink() else ...[
                // Dati real-time del gruppo
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('groups').doc(activeGroupId).snapshots(),
                  builder: (context, groupSnapshot) {
                    if (!groupSnapshot.hasData || !groupSnapshot.data!.exists) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final groupData = groupSnapshot.data!.data() as Map<String, dynamic>;
                    final membersList = List<String>.from(groupData['members'] ?? []);
                    final adminIds = List<String>.from(groupData['adminIds'] ?? []);
                    final isMeAdmin = adminIds.contains(myUid);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Codice: $activeGroupId",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDarker),
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
                            boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 4))],
                            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: membersList.length,
                            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceLight),
                            itemBuilder: (context, index) {
                              final memberUid = membersList[index];
                              final isMe = memberUid == myUid;
                              final isAdmin = adminIds.contains(memberUid);

                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance.collection('users').doc(memberUid).get(),
                                builder: (context, userSnapshot) {
                                  String name = "Caricamento...";
                                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                    name = userSnapshot.data!.get('name') ?? "Utente Sconosciuto";
                                  }

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                    title: Row(
                                      children: [
                                        Text(
                                          isMe ? "$name (Tu)" : name,
                                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
                                            child: const Text("ADMIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warningDark)),
                                          ),
                                        ]
                                      ],
                                    ),
                                    trailing: (isMeAdmin && !isMe)
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (!isAdmin)
                                                TextButton(
                                                  onPressed: () => _promoteToAdmin(memberUid),
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: AppColors.primary,
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    minimumSize: Size.zero,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: const Text(
                                                    "Promuovi admin",
                                                    style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 12),
                                                  ),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                                tooltip: "Rimuovi Membro",
                                                onPressed: () => _removeMember(memberUid),
                                              ),
                                            ],
                                          )
                                        : null,
                                  );
                                }
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),

                        // ==========================================
                        // SEZIONE 3: RICHIESTE DI INGRESSO
                        // ==========================================
                        if (isMeAdmin) ...[
                          _buildSectionTitle("Richieste di Ingresso"),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('groups').doc(activeGroupId).collection('requests').snapshots(),
                            builder: (context, requestsSnapshot) {
                              if (!requestsSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                              
                              final requests = requestsSnapshot.data!.docs;

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: Offset(0, 4))],
                                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                ),
                                child: requests.isEmpty
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24),
                                        child: Column(
                                          children: [
                                            Icon(Icons.mark_email_read_outlined, color: AppColors.textSecondary, size: 36),
                                            SizedBox(height: 8),
                                            Text("Nessuna richiesta di ingresso in attesa.", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Outfit', fontSize: 14, color: AppColors.textSecondary)),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: requests.length,
                                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surfaceLight),
                                        itemBuilder: (context, index) {
                                          final reqDoc = requests[index];
                                          final reqData = reqDoc.data() as Map<String, dynamic>;
                                          final reqUid = reqDoc.id;

                                          return ListTile(
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                            leading: const CircleAvatar(
                                              backgroundColor: AppColors.surfaceLight,
                                              child: Icon(Icons.hourglass_empty_rounded, color: AppColors.textSecondary, size: 18),
                                            ),
                                            title: Text(reqData['name'] ?? 'Utente', style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                                            subtitle: Text(reqData['email'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.success),
                                                  onPressed: () => _acceptRequest(reqUid),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                                  onPressed: () => _rejectRequest(reqUid),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              );
                            }
                          ),
                        ],
                      ],
                    );
                  }
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
        style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }
}
