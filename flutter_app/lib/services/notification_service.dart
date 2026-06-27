import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import '../models/app_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inizializza il plugin delle notifiche
  Future<void> init() async {
    // Carica i fusi orari
    tz.initializeTimeZones();
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZone.identifier));
    } catch (e) {
      print('Errore caricamento fuso orario locale: $e');
    }

    // Imposta l'icona Android per le notifiche
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings);
  }

  // Richiede i permessi all'utente
  Future<void> requestPermissions() async {
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // Pianifica il controllo giornaliero della dispensa
  Future<void> scheduleDailyPantryCheck(
      TimeOfDay time, List<ItemModel> items) async {
    await requestPermissions();
    await flutterLocalNotificationsPlugin.cancelAll();

    // Filtra gli elementi in scadenza
    final expiringItems =
        items.where((i) => i.urgencyLevel >= 1 && i.isPantry).toList();
    if (expiringItems.isEmpty) return;

    // Calcola la data programmata
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Costruisce il messaggio della notifica
    String body =
        "Hai ${expiringItems.length} prodotti vicini alla scadenza! Controlla la dispensa per non sprecare cibo.";
    if (expiringItems.length <= 2) {
      body =
          "Attenzione, in scadenza: ${expiringItems.map((e) => e.name).join(', ')}.";
    }

    // Definisce i dettagli del canale Android
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'pantry_expiration_channel',
      'Scadenze Dispensa',
      channelDescription: 'Notifiche giornaliere per i prodotti in scadenza',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Schedula la notifica ricorrente
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0,
      title: 'AvanziZero - Promemoria Scadenze 🚨',
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Annulla tutte le notifiche programmate
  Future<void> cancelNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
