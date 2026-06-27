import os
import sqlite3

def create_db():
    # Calcola i percorsi
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    db_dir = os.path.join(base_dir, 'flutter_app', 'assets', 'db')
    os.makedirs(db_dir, exist_ok=True)
    db_path = os.path.join(db_dir, 'recipes_catalog.db')

    # Rimuove il vecchio DB
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Crea la tabella ricette
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

    # Crea la tabella ingredienti
    cursor.execute('''
    CREATE TABLE recipe_ingredients (
        recipe_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        normalized_name TEXT NOT NULL,
        FOREIGN KEY(recipe_id) REFERENCES recipes(id)
    )
    ''')

    # Crea gli indici per ottimizzare le query
    cursor.execute('CREATE INDEX idx_recipes_category ON recipes(category)')
    cursor.execute('CREATE INDEX idx_recipes_with_oven ON recipes(with_oven)')
    cursor.execute('CREATE INDEX idx_recipe_ingredients_norm ON recipe_ingredients(normalized_name)')

    # Maxi-Dataset Curato (Fatto in Casa da Benedetta)
    recipes_data = [
        # --- PRIMI PIATTI ---
        {
            "name": "Spaghetti alla Carbonara",
            "description": "Il classico primo piatto romano cremoso e saporito, perfetto per una cena tra coinquilini.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/spaghetti-alla-carbonara/",
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
                ("Pepe nero", "q.b.", "pepe"),
                ("Sale grosso", "q.b.", "sale")
            ]
        },
        {
            "name": "Pasta alla Gricia",
            "description": "L'antenata della carbonara, semplice, saporita e velocissima.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/pasta-alla-gricia/",
            "category": "Primi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Cuocere la pasta in acqua bollente salata. 2. Rosolare il guanciale fino a renderlo croccante. 3. Scolare la pasta nel guanciale, aggiungere acqua di cottura e pecorino.",
            "ingredients": [
                ("Rigatoni (o altra pasta)", "320g", "pasta"),
                ("Guanciale (o Pancetta)", "200g", "pancetta"),
                ("Pecorino Romano", "60g", "parmigiano"),
                ("Pepe nero macinato", "q.b.", "pepe"),
                ("Sale grosso", "q.b.", "sale")
            ]
        },
        {
            "name": "Pasta alle Zucchine e Parmigiano",
            "description": "Un primo piatto vegetariano veloce, fresco ed economico per la pausa pranzo estiva.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/pasta-con-crema-di-zucchine/",
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
                ("Olio extravergine d'oliva", "2 cucchiai", "olio"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Pepe nero", "q.b.", "pepe"),
                ("Sale", "q.b.", "sale"),
                ("Basilico fresco", "qualche foglia", "basilico")
            ]
        },
        {
            "name": "Lasagne al Forno Veloci",
            "description": "La cena perfetta della domenica per studenti fuorisede, ricca e filante.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/lasagna-alla-bolognese/",
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
                ("Parmigiano", "50g", "parmigiano"),
                ("Carne macinata (per ragù)", "300g", "carne"),
                ("Besciamella o panna", "200ml", "panna"),
                ("Burro", "20g", "burro"),
                ("Sale e pepe", "q.b.", "sale")
            ]
        },
        {
            "name": "Penne all'Arrabbiata",
            "description": "Un classico piccante, veloce ed economico, perfetto per spaghettate notturne.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/penne-all-arrabbiata/",
            "category": "Primi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Soffriggere aglio e peperoncino nell'olio. 2. Aggiungere la passata di pomodoro e cuocere 10 min. 3. Saltare le penne al dente nel sugo.",
            "ingredients": [
                ("Penne (o altra pasta)", "320g", "pasta"),
                ("Passata di Pomodoro", "400g", "sugo"),
                ("Peperoncino piccante", "1", "peperoncino"),
                ("Olio d'oliva", "4 cucchiai", "olio"),
                ("Aglio", "2 spicchi", "aglio"),
                ("Prezzemolo tritato", "1 ciuffo", "prezzemolo"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Spaghetti al Tonno e Limone",
            "description": "Primo salva-cena per eccellenza, aromatico e pronto nel tempo di cottura della pasta.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/spaghetti-al-tonno-e-limone/",
            "category": "Primi Piatti",
            "prep_time": "12 min",
            "prep_time_min": 12,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Sgocciolare il tonno e scaldarlo in padella con olio e buccia di limone grattugiata. 2. Scolare la pasta e saltarla con succo di limone e prezzemolo.",
            "ingredients": [
                ("Spaghetti", "320g", "pasta"),
                ("Tonno in scatola", "160g", "tonno"),
                ("Limone (succo e scorza)", "1", "limone"),
                ("Olio d'oliva", "3 cucchiai", "olio"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Prezzemolo fresco", "1 ciuffo", "prezzemolo"),
                ("Sale", "q.b.", "sale"),
                ("Pepe nero", "q.b.", "pepe")
            ]
        },
        {
            "name": "Risotto allo Zafferano (Milanese)",
            "description": "Elegante, cremoso e saporito, ottimo per fare bella figura con gli ospiti.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/risotto-allo-zafferano/",
            "category": "Primi Piatti",
            "prep_time": "25 min",
            "prep_time_min": 25,
            "difficulty": "Media",
            "with_oven": False,
            "instructions": "1. Tostare il riso con cipolla e olio. 2. Sfumare e cuocere aggiungendo brodo bollente. 3. A fine cottura unire lo zafferano e mantecare con burro e parmigiano.",
            "ingredients": [
                ("Riso (Arborio o Carnaroli)", "300g", "riso"),
                ("Zafferano in bustina", "1 bustina", "zafferano"),
                ("Burro", "40g", "burro"),
                ("Parmigiano Reggiano", "50g", "parmigiano"),
                ("Cipolla", "mezzo trito", "cipolla"),
                ("Brodo di carne o vegetale", "500ml", "brodo"),
                ("Vino bianco", "mezzo bicchiere", "vino"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Spaghetti Aglio, Olio e Peperoncino",
            "description": "La regina delle spaghettate di mezzanotte, velocissima e a costo quasi zero.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/spaghetti-aglio-olio-e-peperoncino/",
            "category": "Primi Piatti",
            "prep_time": "10 min",
            "prep_time_min": 10,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Scaldare dolcemente olio, aglio e peperoncino in padella. 2. Lessare gli spaghetti al dente. 3. Saltare in padella con un mestolo di acqua di cottura per creare l'emulsione.",
            "ingredients": [
                ("Spaghetti", "320g", "pasta"),
                ("Aglio", "2 spicchi", "aglio"),
                ("Peperoncino", "q.b.", "peperoncino"),
                ("Olio d'oliva", "5 cucchiai", "olio"),
                ("Prezzemolo", "1 ciuffo", "prezzemolo"),
                ("Sale grosso", "q.b.", "sale")
            ]
        },
        {
            "name": "Gnocchi alla Sorrentina",
            "description": "Gnocchi filanti passati al forno con pomodoro, mozzarella e basilico fresco.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/gnocchi-alla-sorrentina/",
            "category": "Primi Piatti",
            "prep_time": "25 min",
            "prep_time_min": 25,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Cuocere gli gnocchi per 1-2 minuti. 2. Condirli con sugo di pomodoro e cubetti di mozzarella. 3. Gratinare in forno a 220°C per 10 minuti.",
            "ingredients": [
                ("Gnocchi di patate", "500g", "gnocchi"),
                ("Passata o Sugo di pomodoro", "400g", "sugo"),
                ("Mozzarella", "200g", "mozzarella"),
                ("Parmigiano Reggiano", "50g", "parmigiano"),
                ("Basilico fresco", "1 ciuffo", "basilico"),
                ("Olio d'oliva", "2 cucchiai", "olio"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Pasta e Fagioli Cremosa",
            "description": "Primo piatto corposo, nutriente e confortante per le fredde giornate invernali.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/pasta-e-fagioli/",
            "category": "Primi Piatti",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Soffriggere aglio/cipolla con olio. 2. Unire i fagioli e un po' d'acqua. 3. Frullare una parte dei fagioli. 4. Cuocere la pasta corta direttamente nel brodo di fagioli.",
            "ingredients": [
                ("Pasta mista (o tubetti)", "250g", "pasta"),
                ("Fagioli precotti in scatola", "400g", "fagioli"),
                ("Olio d'oliva", "3 cucchiai", "olio"),
                ("Sale e pepe", "q.b.", "pepe"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Sedano", "1 costa", "sedano"),
                ("Carota", "1", "carote"),
                ("Rosmarino", "1 rametto", "rosmarino")
            ]
        },

        # --- SECONDI PIATTI ---
        {
            "name": "Pollo al Forno con Patate",
            "description": "Un secondo piatto intramontabile, facile da preparare e amato da tutti.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/pollo-al-forno-con-patate/",
            "category": "Secondi Piatti",
            "prep_time": "45 min",
            "prep_time_min": 45,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Condire il pollo e le patate a tocchetti con olio, sale e rosmarino. 2. Disporre in teglia. 3. Infornare a 200°C per 40 minuti.",
            "ingredients": [
                ("Petto o Fusi di Pollo", "500g", "pollo"),
                ("Patate", "4", "patate"),
                ("Olio d'oliva", "4 cucchiai", "olio"),
                ("Rosmarino fresco", "2 rametti", "rosmarino"),
                ("Aglio", "2 spicchi", "aglio"),
                ("Sale", "q.b.", "sale"),
                ("Pepe nero", "q.b.", "pepe")
            ]
        },
        {
            "name": "Straccetti di Pollo alle Zucchine",
            "description": "Secondo leggero, proteico e cotto in padella in pochi minuti.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/straccetti-di-pollo-con-zucchine-e-zafferano/",
            "category": "Secondi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Tagliare il pollo a straccetti e passarlo in padella con olio e zucchine a rondelle. 2. Aggiungere sale e pepe. 3. Cuocere per 12 minuti.",
            "ingredients": [
                ("Petto di Pollo", "400g", "pollo"),
                ("Zucchine", "2", "zucchine"),
                ("Olio d'oliva", "3 cucchiai", "olio"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Farina", "q.b.", "farina"),
                ("Vino bianco", "mezzo bicchiere", "vino"),
                ("Sale", "q.b.", "sale"),
                ("Pepe", "q.b.", "pepe")
            ]
        },
        {
            "name": "Frittata di Patate e Cipolle",
            "description": "Il salva-cena per eccellenza, economico, saziante e delizioso sia caldo che freddo.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/frittata-di-patate-e-cipolle/",
            "category": "Secondi Piatti",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Rosolare patate e cipolle in padella. 2. Sbattere le uova con sale e parmigiano. 3. Versare in padella e cuocere con coperchio girando a metà cottura.",
            "ingredients": [
                ("Uova", "5", "uova"),
                ("Patate", "3", "patate"),
                ("Parmigiano", "30g", "parmigiano"),
                ("Cipolle", "1", "cipolla"),
                ("Olio d'oliva", "2 cucchiai", "olio"),
                ("Sale", "q.b.", "sale"),
                ("Pepe nero", "q.b.", "pepe")
            ]
        },
        {
            "name": "Polpette al Sugo della Nonna",
            "description": "Morbide polpette cotte lentamente nel sugo di pomodoro, perfette per fare la scarpetta.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/polpette-al-sugo/",
            "category": "Secondi Piatti",
            "prep_time": "30 min",
            "prep_time_min": 30,
            "difficulty": "Media",
            "with_oven": False,
            "instructions": "1. Mescolare carne trita, uova, formaggio, pane ammollato e sale. 2. Formare le polpette. 3. Cuocere nel sugo di pomodoro in padella per 20 minuti.",
            "ingredients": [
                ("Carne Macinata (manzo/maiale)", "400g", "carne"),
                ("Passata di Pomodoro", "400g", "sugo"),
                ("Uova", "1", "uova"),
                ("Parmigiano o Pecorino", "50g", "parmigiano"),
                ("Pangrattato o pane ammollato", "80g", "pane"),
                ("Aglio", "1 spicchio", "aglio"),
                ("Prezzemolo tritato", "1 ciuffo", "prezzemolo"),
                ("Olio d'oliva", "2 cucchiai", "olio"),
                ("Sale e pepe", "q.b.", "pepe")
            ]
        },
        {
            "name": "Scaloppine al Limone",
            "description": "Tenere fettine di carne con una cremina profumata al limone, pronte in padella in 10 minuti.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/scaloppine-al-limone/",
            "category": "Secondi Piatti",
            "prep_time": "10 min",
            "prep_time_min": 10,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Infarinate le fettine di carne. 2. Rosolarle nel burro o olio in padella. 3. Aggiungere il succo di limone e far restringere la cremina.",
            "ingredients": [
                ("Fettine di Maiale o Vitello", "400g", "carne"),
                ("Limone (succo)", "1", "limone"),
                ("Farina", "q.b.", "farina"),
                ("Burro", "30g", "burro"),
                ("Olio d'oliva", "1 cucchiaio", "olio"),
                ("Prezzemolo tritato", "q.b.", "prezzemolo"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Tranci di Salmone Croccanti",
            "description": "Salmone gustoso cotto in padella con pelle croccante e un filo di olio d'oliva.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/salmone-in-padella/",
            "category": "Secondi Piatti",
            "prep_time": "12 min",
            "prep_time_min": 12,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Asciugare i tranci di salmone. 2. Scaldare la padella con poco olio. 3. Cuocere prima sul lato della pelle fino a croccantezza, poi girare per 3 minuti.",
            "ingredients": [
                ("Tranci di Salmone", "400g", "salmone"),
                ("Olio d'oliva", "q.b.", "olio"),
                ("Sale e pepe", "q.b.", "pepe"),
                ("Limone", "1 a spicchi", "limone"),
                ("Timo o rosmarino", "q.b.", "rosmarino")
            ]
        },
        {
            "name": "Omelette Prosciutto e Formaggio",
            "description": "Classica francese, morbida all'esterno e filante all'interno, facilissima e istantanea.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/omelette-classica/",
            "category": "Secondi Piatti",
            "prep_time": "8 min",
            "prep_time_min": 8,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Sbattere le uova con sale e un cucchiaio di latte. 2. Cuocere in padella imburrata. 3. Farcire con prosciutto e formaggio, poi piegare a metà.",
            "ingredients": [
                ("Uova", "3", "uova"),
                ("Prosciutto Cotto", "50g", "prosciutto"),
                ("Formaggio a Fette (Emmental/Fondente)", "50g", "formaggio"),
                ("Burro (o olio)", "10g", "burro"),
                ("Latte", "1 cucchiaio", "latte"),
                ("Sale", "q.b.", "sale"),
                ("Pepe", "q.b.", "pepe")
            ]
        },
        {
            "name": "Melanzane alla Parmigiana",
            "description": "Iconico piatto unico o secondo ricco, con strati di melanzane fritte o grigliate, pomodoro e formaggio.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/parmigiana-di-melanzane/",
            "category": "Secondi Piatti",
            "prep_time": "50 min",
            "prep_time_min": 50,
            "difficulty": "Media",
            "with_oven": True,
            "instructions": "1. Grigliare o friggere le melanzane. 2. Disporre in teglia alternando melanzane, sugo, mozzarella e parmigiano. 3. Cuocere in forno a 200°C per 30 min.",
            "ingredients": [
                ("Melanzane", "2", "melanzane"),
                ("Passata di Pomodoro", "500g", "sugo"),
                ("Mozzarella", "250g", "mozzarella"),
                ("Parmigiano", "80g", "parmigiano"),
                ("Cipolla", "mezza trita", "cipolla"),
                ("Basilico fresco", "1 ciuffo", "basilico"),
                ("Olio d'oliva", "q.b.", "olio"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Cotoletta di Pollo Croccante",
            "description": "Petto di pollo panato e fritto o cotto in padella, dorato e amatissimo dagli studenti.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/cotolette-di-pollo/",
            "category": "Secondi Piatti",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Passare le fette di pollo nell'uovo sbattuto e poi nel pangrattato. 2. Friggere in padella con olio ben caldo fino a doratura.",
            "ingredients": [
                ("Petto di Pollo a fette", "400g", "pollo"),
                ("Uova", "1", "uova"),
                ("Pangrattato", "100g", "pane"),
                ("Olio di semi per friggere (o d'oliva)", "q.b.", "olio"),
                ("Farina", "q.b.", "farina"),
                ("Parmigiano (da mischiare al pane)", "30g", "parmigiano"),
                ("Sale", "q.b.", "sale")
            ]
        },

        # --- PIATTI UNICI ---
        {
            "name": "Caprese Ricca con Pomodoro e Basilico",
            "description": "Piatto unico fresco, istantaneo e mediterraneo, ideale quando non si ha voglia di accendere fornelli.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/caprese-di-mozzarella-e-pomodoro/",
            "category": "Piatti Unici",
            "prep_time": "5 min",
            "prep_time_min": 5,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Affettare pomodori e mozzarella. 2. Alternarli in un piatto. 3. Condire con abbondante olio, origano e sale.",
            "ingredients": [
                ("Mozzarella", "250g", "mozzarella"),
                ("Pomodori", "3", "pomodori"),
                ("Olio d'oliva", "3 cucchiai", "olio"),
                ("Basilico fresco", "1 ciuffo", "basilico"),
                ("Origano", "q.b.", "origano"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Toast al Forno Filante",
            "description": "Piatto unico per spuntini notturni di studio, super filante e dorato.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/rotolini-di-pancarre-farciti-al-forno/",
            "category": "Piatti Unici",
            "prep_time": "10 min",
            "prep_time_min": 10,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Disporre pane, mozzarella e pancetta. 2. Infornare a 200°C per 8 minuti fino allo scioglimento del formaggio.",
            "ingredients": [
                ("Pane in cassetta (o altro)", "4 fette", "pane"),
                ("Mozzarella", "100g", "mozzarella"),
                ("Pancetta (o prosciutto)", "80g", "pancetta"),
                ("Burro", "10g", "burro"),
                ("Origano", "q.b.", "origano")
            ]
        },
        {
            "name": "Insalata di Riso Ricca",
            "description": "L'emblema dell'estate e dei pranzi al sacco in università. Facile da conservare in frigo per giorni.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/insalata-di-riso-classica/",
            "category": "Piatti Unici",
            "prep_time": "25 min",
            "prep_time_min": 25,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Lessare il riso e farlo raffreddare. 2. Condire con tonno, verdurine sott'olio, uova sode e olive. 3. Conservare in frigo.",
            "ingredients": [
                ("Riso per insalate", "300g", "riso"),
                ("Tonno in scatola", "160g", "tonno"),
                ("Uova (da fare sode)", "2", "uova"),
                ("Verdure sott'olio / Giardiniera", "100g", "verdure"),
                ("Olive nere o verdi", "50g", "olive"),
                ("Formaggio a cubetti (Emmental/Scamorza)", "100g", "formaggio"),
                ("Pomodorini", "150g", "pomodorini"),
                ("Olio d'oliva", "q.b.", "olio"),
                ("Sale", "q.b.", "sale")
            ]
        },
        {
            "name": "Cous Cous Estivo Verdure e Tonno",
            "description": "Piatto unico espresso senza cottura ai fornelli (basta acqua bollente), profumato e sano.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/cous-cous-con-tonno-e-verdure/",
            "category": "Piatti Unici",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Sgranare il cous cous con acqua calda e olio. 2. Aggiungere tonno, pomodori a cubetti e verdure a piacere.",
            "ingredients": [
                ("Cous Cous", "200g", "cous cous"),
                ("Tonno in scatola", "160g", "tonno"),
                ("Pomodori", "2", "pomodori"),
                ("Olio d'oliva e sale", "q.b.", "olio"),
                ("Zucchine", "1", "zucchine"),
                ("Carote", "1", "carote"),
                ("Basilico", "q.b.", "basilico"),
                ("Acqua", "200ml", "acqua")
            ]
        },
        {
            "name": "Crostoni Salsiccia e Stracchino",
            "description": "Rusticissimo piatto unico o antipasto per serate in allegria, gratinato al forno.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/crostoni-salsiccia-e-stracchino/",
            "category": "Piatti Unici",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Spalmare lo stracchino mischiato con la salsiccia sgranata sulle fette di pane. 2. Infornare a 200°C per 10 minuti fino a doratura.",
            "ingredients": [
                ("Pane a fette", "4 fette", "pane"),
                ("Salsiccia", "200g", "salsiccia"),
                ("Stracchino (o formaggio spalmabile)", "150g", "stracchino"),
                ("Pepe nero", "q.b.", "pepe"),
                ("Olio d'oliva", "q.b.", "olio")
            ]
        },
        {
            "name": "Uova al Tegamino con Pancetta",
            "description": "Colazione salata o pranzo fulmineo, proteico e ultra-saporito.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/uovo-fritto/",
            "category": "Piatti Unici",
            "prep_time": "6 min",
            "prep_time_min": 6,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Rosolare la pancetta in padella. 2. Aprire le uova direttamente sulla pancetta croccante. 3. Cuocere per 3 minuti fino alla cottura dell'albume.",
            "ingredients": [
                ("Uova", "2", "uova"),
                ("Pancetta o guanciale", "80g", "pancetta"),
                ("Olio o burro", "q.b.", "olio"),
                ("Pane per scarpetta", "2 fette", "pane"),
                ("Sale e pepe", "q.b.", "pepe")
            ]
        },
        {
            "name": "Piadina Romagnola Classica",
            "description": "Lo street food italiano per eccellenza, perfetto per un pranzo rapido in periodo di esami.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/piadina-romagnola/",
            "category": "Piatti Unici",
            "prep_time": "5 min",
            "prep_time_min": 5,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Scaldare la piadina su una padella ben calda. 2. Farcire con prosciutto, formaggio e insalata. 3. Piegare a metà e gustare.",
            "ingredients": [
                ("Piadina romagnola", "1", "piadina"),
                ("Prosciutto crudo (o cotto)", "70g", "prosciutto"),
                ("Formaggio o Squacquerone", "50g", "formaggio"),
                ("Insalata o rucola", "50g", "insalata"),
                ("Olio d'oliva", "q.b.", "olio")
            ]
        },

        # --- DOLCI ---
        {
            "name": "Tiramisù per Studenti Veloce",
            "description": "Il dolce più famoso d'Italia, nella versione express senza cottura per darsi la carica agli esami.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/tiramisu-senza-uova/",
            "category": "Dolci",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Inzuppare i biscotti nel caffè. 2. Montare uova e crema di formaggio/savoiardi. 3. Spolverare con cacao e far riposare in frigo.",
            "ingredients": [
                ("Biscotti / Savoiardi (o frollini)", "200g", "biscotti"),
                ("Uova", "3", "uova"),
                ("Zucchero", "50g", "zucchero"),
                ("Mascarpone (o ricotta)", "250g", "mascarpone"),
                ("Caffè espresso", "1 tazza", "caffè"),
                ("Cacao amaro in polvere", "30g", "cacao")
            ]
        },
        {
            "name": "Torta di Mele Facile della Nonna",
            "description": "Una torta al forno soffice e profumata, perfetta per la colazione di tutta la settimana.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/torta-di-mele-soffice/",
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
                ("Olio", "100ml", "olio"),
                ("Farina", "200g", "farina"),
                ("Lievito in polvere per dolci", "1 bustina", "lievito"),
                ("Latte", "50ml", "latte"),
                ("Cannella in polvere", "q.b.", "cannella"),
                ("Limone (scorza grattugiata)", "1", "limone")
            ]
        },
        {
            "name": "Mug Cake al Cioccolato (in Tazza)",
            "description": "Torta monoporzione pronta in 3 minuti di microonde. Perfetta per le voglie improvvise di dolce in notturna.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/torta-in-tazza-al-cioccolato/",
            "category": "Dolci",
            "prep_time": "5 min",
            "prep_time_min": 5,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Mescolare in una tazza farina, zucchero, cacao, olio e latte. 2. Cuocere in microonde (o cuocere a vapore in padella coperta) per 2 minuti.",
            "ingredients": [
                ("Cacao in polvere (o cioccolato)", "2 cucchiai", "cioccolato"),
                ("Farina", "3 cucchiai", "farina"),
                ("Zucchero", "2 cucchiai", "zucchero"),
                ("Olio o latte", "q.b.", "olio"),
                ("Lievito in polvere", "1 pizzico", "lievito"),
                ("Cioccolato a pezzetti", "20g", "cioccolato")
            ]
        },
        {
            "name": "Crepes Dolci alla Nutella",
            "description": "Crespelle sottili ed eleganti farcite di morbida crema di nocciole. Amate in tutto il mondo.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/crepes-dolci-e-salate/",
            "category": "Dolci",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Pastellare farina, latte e uova. 2. Cuocere un mestolo alla volta in padella antiaderente. 3. Farcire con nutella e ripiegare.",
            "ingredients": [
                ("Latte", "250ml", "latte"),
                ("Farina", "100g", "farina"),
                ("Uova", "1", "uova"),
                ("Crema alle nocciole / Nutella", "q.b.", "nutella"),
                ("Zucchero", "1 cucchiaio", "zucchero"),
                ("Burro (per la padella)", "10g", "burro")
            ]
        },
        {
            "name": "Salame di Cioccolato Senza Cottura",
            "description": "Il dolce facilissimo da preparare in compagnia, senza accendere né forno né fornelli.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/salame-di-cioccolato/",
            "category": "Dolci",
            "prep_time": "20 min",
            "prep_time_min": 20,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Sminuzzare i biscotti secchi. 2. Mescolarli con burro fuso, cacao e zucchero. 3. Arrotolare a forma di salame in carta stagnola e tenere in frigo per 3 ore.",
            "ingredients": [
                ("Biscotti secchi", "300g", "biscotti"),
                ("Burro", "150g", "burro"),
                ("Cacao amaro in polvere", "50g", "cacao"),
                ("Zucchero", "100g", "zucchero"),
                ("Latte", "2 cucchiai", "latte"),
                ("Nocciole tritate (opzionali)", "50g", "nocciole")
            ]
        },
        {
            "name": "Pancakes Americani Soffici",
            "description": "Frittelle alte e spumose ideali per i brunch del weekend o colazioni super energetiche.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/pancake-classici/",
            "category": "Dolci",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Miscelare uova, farina, latte, zucchero e lievito. 2. Cuocere a gocce in padella calda per 2 min per lato. 3. Guarnire con miele o sciroppo d'acero.",
            "ingredients": [
                ("Farina", "150g", "farina"),
                ("Latte", "200ml", "latte"),
                ("Uova", "1", "uova"),
                ("Zucchero", "30g", "zucchero"),
                ("Lievito in bustina", "1 cucchiaino", "lievito"),
                ("Burro (per la padella)", "10g", "burro"),
                ("Miele o sciroppo d'acero", "q.b.", "miele")
            ]
        },
        {
            "name": "Biscotti al Burro Facilissimi",
            "description": "Frollini classici al burro, friabili e deliziosi da tuffare nel latte o nel the.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/biscotti-al-burro/",
            "category": "Dolci",
            "prep_time": "25 min",
            "prep_time_min": 25,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Impastare burro morbido, zucchero e farina. 2. Formare delle palline e disporle su teglia. 3. Cuocere in forno a 180°C per 15 min.",
            "ingredients": [
                ("Burro", "100g", "burro"),
                ("Farina", "200g", "farina"),
                ("Zucchero", "100g", "zucchero"),
                ("Uova", "1", "uova"),
                ("Vaniglia o scorza di limone", "1 pizzico", "vaniglia"),
                ("Lievito per dolci", "mezzo cucchiaino", "lievito")
            ]
        },
        {
            "name": "Muffin alle Gocce di Cioccolato",
            "description": "Dolcetti monoporzione morbidissimi, con golose pepite di cioccolato fondente.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/muffin-soffici-con-gocce-di-cioccolato/",
            "category": "Dolci",
            "prep_time": "30 min",
            "prep_time_min": 30,
            "difficulty": "Facile",
            "with_oven": True,
            "instructions": "1. Mescolare ingredienti liquidi (uova, olio, latte) con farina, zucchero, lievito e gocce di cioccolato. 2. Versare nei pirottini. 3. Infornare a 180°C per 20 min.",
            "ingredients": [
                ("Farina", "200g", "farina"),
                ("Zucchero", "100g", "zucchero"),
                ("Gocce di Cioccolato", "80g", "cioccolato"),
                ("Latte / Olio / Uova", "q.b.", "uova"),
                ("Burro fuso", "50g", "burro"),
                ("Lievito per dolci", "1 bustina", "lievito"),
                ("Vaniglia", "1 cucchiaino", "vaniglia")
            ]
        },
        {
            "name": "Panna Cotta al Cacao Veloce",
            "description": "Dessert al cucchiaio delicato ed elegante, pronto in pochissimi passaggi.",
            "source": "https://www.fattoincasadabenedetta.it/ricetta/panna-cotta-al-cacao/",
            "category": "Dolci",
            "prep_time": "15 min",
            "prep_time_min": 15,
            "difficulty": "Facile",
            "with_oven": False,
            "instructions": "1. Scaldare la panna con zucchero e cacao. 2. Aggiungere colla di pesce ammollata. 3. Versare negli stampini e porre in frigo per 4 ore.",
            "ingredients": [
                ("Panna liquida per dolci", "500ml", "panna"),
                ("Zucchero", "100g", "zucchero"),
                ("Cacao o Cioccolato", "50g", "cioccolato"),
                ("Latte", "100ml", "latte"),
                ("Gelatina in fogli", "6g", "gelatina"),
                ("Vaniglia", "1 baccello", "vaniglia")
            ]
        }
    ]

    # Popola il database iterando sulle ricette
    for r in recipes_data:
        # Inserisce i dati della singola ricetta
        cursor.execute('''
        INSERT INTO recipes (name, description, source, category, prep_time, prep_time_min, difficulty, with_oven, instructions)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (r['name'], r['description'], r['source'], r['category'], r['prep_time'], r['prep_time_min'], r['difficulty'], r['with_oven'], r['instructions']))
        
        recipe_id = cursor.lastrowid
        
        # Inserisce gli ingredienti associati
        for name, quantity, norm in r['ingredients']:
            cursor.execute('''
            INSERT INTO recipe_ingredients (recipe_id, name, quantity, normalized_name)
            VALUES (?, ?, ?, ?)
            ''', (recipe_id, name, quantity, norm))

    # Salva le modifiche
    conn.commit()
    conn.close()
    print(f"=== Database {db_path} generato con successo! ({len(recipes_data)} ricette) ===")

if __name__ == '__main__':
    create_db()
