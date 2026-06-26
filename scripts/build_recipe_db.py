import os
import sqlite3

def create_db():
    # Definisce i percorsi
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    db_dir = os.path.join(base_dir, 'flutter_app', 'assets', 'db')
    os.makedirs(db_dir, exist_ok=True)
    db_path = os.path.join(db_dir, 'recipes_catalog.db')

    # Rimuove il vecchio DB se esiste per una ricostruzione pulita
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Creazione tabella ricette
    cursor.execute('''
    CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        source TEXT NOT NULL,
        category TEXT NOT NULL,
        prep_time TEXT NOT NULL,
        prep_time_min INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        with_oven BOOLEAN NOT NULL,
        instructions TEXT NOT NULL
    )
    ''')

    # Creazione tabella ingredienti ricetta
    cursor.execute('''
    CREATE TABLE recipe_ingredients (
        recipe_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        normalized_name TEXT NOT NULL,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id)
    )
    ''')

    # Creazione indici per alte prestazioni
    cursor.execute('CREATE INDEX idx_recipes_category ON recipes(category)')
    cursor.execute('CREATE INDEX idx_recipes_with_oven ON recipes(with_oven)')
    cursor.execute('CREATE INDEX idx_recipe_ingredients_norm ON recipe_ingredients(normalized_name)')

    # Dati iniziali curati (GialloZafferano, Cucchiaio d'Argento, Fatto in Casa da Benedetta, ecc.)
    recipes_data = [
        {
            "name": "Spaghetti alla Carbonara",
            "description": "Il classico primo piatto romano cremoso e saporito, perfetto per una cena tra coinquilini.",
            "source": "GialloZafferano",
            "category": "Primi Piatti",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Lessare la pasta. 2. Rosolare il guanciale. 3. Sbattere tuorli e pecorino con pepe nero. 4. Mantecare a fuoco spento.",
            "ingredients": [
                ("Spaghetti", "320g", "pasta"),
                ("Guanciale (o Pancetta)", "150g", "pancetta"),
                ("Tuorli d'uovo", "4", "uova"),
                ("Pecorino Romano (o Grana)", "50g", "parmigiano"),
                ("Pepe nero", "q.b.", "pepe")
            ]
        },
        {
            "name": "Pasta alla Gricia",
            "description": "L'antenata della carbonara, semplice, saporita e velocissima.",
            "source": "Cucchiaio d'Argento",
            "category": "Primi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Cuocere la pasta in acqua bollente salata. 2. Rosolare il guanciale fino a renderlo croccante. 3. Scolare la pasta nel guanciale, aggiungere acqua di cottura e pecorino.",
            "ingredients": [
                ("Rigatoni (o altra pasta)", "320g", "pasta"),
                ("Guanciale (o Pancetta)", "200g", "pancetta"),
                ("Pecorino Romano", "60g", "parmigiano")
            ]
        },
        {
            "name": "Pasta alle Zucchine e Parmigiano",
            "description": "Un primo piatto vegetariano veloce, fresco ed economico per la pausa pranzo estiva.",
            "source": "Fatto in Casa da Benedetta",
            "category": "Primi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Tagliare le zucchine a rondelle e saltarle in padella con un filo d'olio e aglio. 2. Lessare la pasta. 3. Saltare la pasta con le zucchine e abbondante parmigiano.",
            "ingredients": [
                ("Pasta", "300g", "pasta"),
                ("Zucchine", "2", "zucchine"),
                ("Parmigiano Reggiano", "50g", "parmigiano"),
                ("Olio extravergine d'oliva", "2 cucchiai", "olio")
            ]
        },
        {
            "name": "Lasagne al Forno Veloci",
            "description": "La cena perfetta della domenica per studenti fuorisede, ricca e filante.",
            "source": "GialloZafferano",
            "category": "Primi Piatti",
            "prep_time": "40 min",
            "prep_time_min": 40,
            "difficulty": "Media",
            "with_oven": True,
            "instructions": "1. Comporre a strati sfoglie di pasta, besciamella, sugo di pomodoro e mozzarella. 2. Cuocere in forno a 200°C per 25 minuti fino a doratura.",
            "ingredients": [
                ("Sfoglie per lasagne (o pasta)", "250g", "pasta"),
                ("Sugo di pomodoro", "400g", "sugo"),
                ("Mozzarella", "200g", "mozzarella"),
                ("Parmigiano", "50g", "parmigiano")
            ]
        },
        {
            "name": "Pollo al Forno con Patate",
            "description": "Un secondo piatto intramontabile, facile da preparare e amato da tutti.",
            "source": "Tavolartegusto",
            "category": "Secondi Piatti",
            "prep_time": "45 min",
            "prep_time_min": 45,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Condire il pollo e le patate a tocchetti con olio, sale e rosmarino. 2. Disporre in teglia. 3. Infornare a 200°C per 40 minuti.",
            "ingredients": [
                ("Petto o Fusi di Pollo", "500g", "pollo"),
                ("Patate", "4", "patate"),
                ("Olio d'oliva", "q.b.", "olio")
            ]
        },
        {
            "name": "Straccetti di Pollo alle Zucchine",
            "description": "Secondo leggero, proteico e cotto in padella in pochi minuti.",
            "source": "Cucchiaio d'Argento",
            "category": "Secondi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Tagliare il pollo a straccetti e passarlo in padella con olio e zucchine a rondelle. 2. Aggiungere sale e pepe. 3. Cuocere per 12 minuti.",
            "ingredients": [
                ("Petto di Pollo", "400g", "pollo"),
                ("Zucchine", "2", "zucchine"),
                ("Olio d'oliva", "q.b.", "olio")
            ]
        },
        {
            "name": "Frittata di Patate e Cipolle",
            "description": "Il salva-cena per eccellenza, economico, saziante e delizioso sia caldo che freddo.",
            "source": "Fatto in Casa da Benedetta",
            "category": "Secondi Piatti",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Rosolare patate e cipolle in padella. 2. Sbattere le uova con sale e parmigiano. 3. Versare in padella e cuocere con coperchio girando a metà cottura.",
            "ingredients": [
                ("Uova", "5", "uova"),
                ("Patate", "3", "patate"),
                ("Parmigiano", "30g", "parmigiano")
            ]
        },
        {
            "name": "Caprese Ricca con Pomodoro e Basilico",
            "description": "Piatto unico fresco, istantaneo e mediterraneo, ideale quando non si ha voglia di accendere fornelli.",
            "source": "GialloZafferano",
            "category": "Piatti Unici",
            "prep_time": "5 min",
            "prep_time_min": 5,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Affettare pomodori e mozzarella. 2. Alternarli in un piatto. 3. Condire con abbondante olio, origano e sale.",
            "ingredients": [
                ("Mozzarella", "250g", "mozzarella"),
                ("Pomodori", "3", "pomodori"),
                ("Olio d'oliva", "q.b.", "olio")
            ]
        },
        {
            "name": "Toast al Forno Filante",
            "description": "Piatto unico per spuntini notturni di studio, super filante e dorato.",
            "source": "Food.com",
            "category": "Piatti Unici",
            "prep_time": "10 min",
            "prep_time_min": 10,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Disporre pane, mozzarella e pancetta. 2. Infornare a 200°C per 8 minuti fino allo scioglimento del formaggio.",
            "ingredients": [
                ("Pane in cassetta (o altro)", "4 fette", "pane"),
                ("Mozzarella", "100g", "mozzarella"),
                ("Pancetta (o prosciutto)", "80g", "pancetta")
            ]
        },
        {
            "name": "Tiramisù per Studenti Veloce",
            "description": "Il dolce più famoso d'Italia, nella versione express senza cottura per darsi la carica agli esami.",
            "source": "GialloZafferano",
            "category": "Dolci",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Inzuppare i biscotti nel caffè. 2. Montare uova e crema di formaggio/savoiardi. 3. Spolverare con cacao e far riposare in frigo.",
            "ingredients": [
                ("Biscotti / Savoiardi (o frollini)", "200g", "biscotti"),
                ("Uova", "3", "uova"),
                ("Zucchero", "50g", "zucchero")
            ]
        },
        {
            "name": "Torta di Mele Facile della Nonna",
            "description": "Una torta al forno soffice e profumata, perfetta per la colazione di tutta la settimana.",
            "source": "Fatto in Casa da Benedetta",
            "category": "Dolci",
            "prep_time": "50 min",
            "prep_time_min": 50,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Mescolare uova, zucchero, olio e lievito. 2. Aggiungere le mele a fettine. 3. Infornare a 180°C per 40 minuti.",
            "ingredients": [
                ("Mele", "3", "mele"),
                ("Uova", "2", "uova"),
                ("Zucchero", "150g", "zucchero"),
                ("Olio", "100ml", "olio")
            ]
        }
    ]

    for r in recipes_data:
        cursor.execute('''
        INSERT INTO recipes (name, description, source, category, prep_time, prep_time_min, difficulty, with_oven, instructions)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (r['name'], r['description'], r['source'], r['category'], r['prep_time'], r['prep_time_min'], r['difficulty'], r['with_oven'], r['instructions']))
        
        recipe_id = cursor.lastrowid
        
        for name, quantity, norm in r['ingredients']:
            cursor.execute('''
            INSERT INTO recipe_ingredients (recipe_id, name, quantity, normalized_name)
            VALUES (?, ?, ?, ?)
            ''', (recipe_id, name, quantity, norm))

    conn.commit()
    conn.close()
    print(f"=== Database {db_path} generato con successo! ({len(recipes_data)} ricette) ===")

if __name__ == '__main__':
    create_db()
