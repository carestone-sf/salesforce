List<Medienbereich__c> recordsToInsert = new List<Medienbereich__c>();

// Broschüren
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1Ufm4e0PawYPF-EQJDmwAmJaFwAN5NE7H/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail_Imagebroschuere.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Unternehmensbroschüre',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1Ufm4e0PawYPF-EQJDmwAmJaFwAN5NE7H'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1RjcefydodHM2jzlxnvS0iewZPOgvGXUV/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail_Beratungsbroschuere.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Beratungsbroschüre',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1RjcefydodHM2jzlxnvS0iewZPOgvGXUV'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1MNs1Oxh7yjD23ok1zwPcgILaD_KP54CS/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail_Ankaufprofil.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Ankaufprofil',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1MNs1Oxh7yjD23ok1zwPcgILaD_KP54CS'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1oSc47NJqfCEYnDPryiIxo-1QfSyZbOS3/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail_Infoflyer.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Infoflyer',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1oSc47NJqfCEYnDPryiIxo-1QfSyZbOS3'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1yTMV46d5vT31KxH2uV4C3KQKYrf8HXgE/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail-VP-Referenzliste.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Referenzliste: Standorte',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1yTMV46d5vT31KxH2uV4C3KQKYrf8HXgE'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Broschüren',
    VorschauUrl__c = 'https://drive.google.com/file/d/1woyLOs1zNyvOiIlt9SwI_lt2IGw9_vMe/view',
    ThumbnailUrl__c = '/img/medienbereich/broschueren/Thumbnail_Referenzbroschuere_Betreiber.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Referenzliste: Betreiber',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1woyLOs1zNyvOiIlt9SwI_lt2IGw9_vMe'
));

// Formulare
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1TIOwGO-0a2QBW_j0vnsI-bkIuguwJhhQ/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Anlage-TOM.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Anlage TOM zur Auftragsdatenverarbeitung gem. Art. 28 DSGVO',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1TIOwGO-0a2QBW_j0vnsI-bkIuguwJhhQ'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1e7lSp95726_-GKC8MDWL4jHsE1xdZ5Hz/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Verarbeitung-personenbezogener-Daten.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Auftragsdatenverarbeitung gem. Art. 28 DSGVO',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1e7lSp95726_-GKC8MDWL4jHsE1xdZ5Hz'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1-l-GuY8J4DUh3nYsiGNwZVOv6-wn-fIL/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Info-zur-Verarbeitung.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Informationen über die Verarbeitung personenbezogener Daten gem. Art. 13 Datenschutzverordnung (DSGVO)',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1-l-GuY8J4DUh3nYsiGNwZVOv6-wn-fIL'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1Kc9Z6vKRsNCqt7VoByDt7Ne0DQUHqsF-/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Notarauftrag.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Notarauftrag',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1Kc9Z6vKRsNCqt7VoByDt7Ne0DQUHqsF-'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1snuJg9xqC4uvfQA9B02EZwf4SCTtOVGt/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Reservierung.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Reservierung',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1snuJg9xqC4uvfQA9B02EZwf4SCTtOVGt'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1UgktXsTsFeJKfuIkTUsx2ZEEI46h6GM_/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Risikobelehrung.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Risikobelehrung',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1UgktXsTsFeJKfuIkTUsx2ZEEI46h6GM_'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1HxQesxwU2KpmwOhn-oE-3aFRUTy5Gbhl/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_Vertrauliche_Selbstauskunft.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Vertrauliche Selbstauskunft',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1HxQesxwU2KpmwOhn-oE-3aFRUTy5Gbhl'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Formulare',
    VorschauUrl__c = 'https://drive.google.com/file/d/1-EnLko-1uKd5VoltxuE4xz1QHwcmWxQk/view',
    ThumbnailUrl__c = '/img/medienbereich/formulare/Thumbnail_14-Schritte-zur-Kaufabwicklung.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = '14 Schritte zur Kaufabwicklung',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1-EnLko-1uKd5VoltxuE4xz1QHwcmWxQk'
));

// Präsentation
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Präsentation',
    VorschauUrl__c = 'https://drive.google.com/file/d/1_yShhOOp2OeAGbjlc0BMyKR9hiPvHvkt/view',
    ThumbnailUrl__c = '/img/medienbereich/praesentationen/Thumbnail_Praesentation.jpg',
    Dateityp__c = 'Powerpoint',
    Anzeigename__c = 'Vertriebspräsentationen',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1_yShhOOp2OeAGbjlc0BMyKR9hiPvHvkt'
));

// Plakate
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Plakate',
    VorschauUrl__c = 'https://drive.google.com/file/d/1jAsPtZ4RZYf0Y6FLPapgxKggL2S9M62b/view',
    ThumbnailUrl__c = '/img/medienbereich/plakate/Thumbnail_Plakat-Image.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Imageplakat',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1jAsPtZ4RZYf0Y6FLPapgxKggL2S9M62b'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Plakate',
    VorschauUrl__c = 'https://drive.google.com/file/d/1ANOtpX2e6rwdpt_G6aKfWj-q4e6wWh1_/view',
    ThumbnailUrl__c = '/img/medienbereich/plakate/Thumbnail_Plakat-10-gute-Gruende.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = '10 gute Gründe',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1ANOtpX2e6rwdpt_G6aKfWj-q4e6wWh1_'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Plakate',
    VorschauUrl__c = 'https://drive.google.com/file/d/1pV0X92YkwINQSZkFjW7OxgPbBisicP8B/view',
    ThumbnailUrl__c = '/img/medienbereich/plakate/Thumbnail_Plakat-Pflege-vs-Eigentum.jpg',
    Dateityp__c = 'PDF',
    Anzeigename__c = 'Pflege vs Eigentum',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1pV0X92YkwINQSZkFjW7OxgPbBisicP8B'
));

// Infografiken
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/1a-j9JD7gWsufo6mkJd9LLguOpcRhTzfb/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Angebot_und_Nachfrage_von_Pflegeheimplaetzen_bis_2030.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Angebot und Nachfrage von Pflegeheimplätzen bis 2030',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1a-j9JD7gWsufo6mkJd9LLguOpcRhTzfb'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/131rmD2UGFQAwDZobfBnmsK6KCPs2tBOo/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Angebotsluecke_bei_Pflegeheimplaetzen_bis_2030.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Angebotslücke bei Pflegeheimplätzen bis 2030',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=131rmD2UGFQAwDZobfBnmsK6KCPs2tBOo'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/1H2KAQJ53ITeiZhxCvAhdYjBrO7CIxR7w/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Anzahl_der_Pflegebeduerftigen_nach_Altersgruppen_sortiert.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Anzahl der Pflegebedürftigen nach Altersgruppen sortiert',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1H2KAQJ53ITeiZhxCvAhdYjBrO7CIxR7w'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/17UlwjCDROrDP8GFxs5KPoTtTRL2R0tCP/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Entwicklung_der_Pflegeheimplaetze_bis_2060.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Entwicklung der Pflegeheimplätze bis 2060',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=17UlwjCDROrDP8GFxs5KPoTtTRL2R0tCP'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/17qshu4z7QPOwzJwiU3iy3J-FuMxR8aW3/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Zusatzbedarf_an_Pflegeplaetzen_bis_2030.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Zusatzbedarf an Pflegeplätzen bis 2030',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=17qshu4z7QPOwzJwiU3iy3J-FuMxR8aW3'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/1LZJ4csb3M1NjY0SpbS1bt2VtHtLUqJYJ/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Preissteigerungen_bei_Pflegeimmobilien.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Preissteigerungen bei Pflegeimmobilien',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1LZJ4csb3M1NjY0SpbS1bt2VtHtLUqJYJ'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/1MMfrjVT0_X6Q31V2s-O7SW-eWDMVAEz0/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Entwicklung_Transaktionsvolumen_und_Spitzenrendite_der_Pflegeheime.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Entwicklung Transaktionsvolumen und Spitzenrendite der Pflegeheime',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=1MMfrjVT0_X6Q31V2s-O7SW-eWDMVAEz0'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/17i4C5_TPgC21-uEIh2J9q98DGBW62J6T/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Entwicklung_Transaktionsvolumen_und_Spitzenrendite_2018.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Entwicklung Transaktionsvolumen und Spitzenrendite der Pflegeheime 2018',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=17i4C5_TPgC21-uEIh2J9q98DGBW62J6T'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Infografiken',
    VorschauUrl__c = 'https://drive.google.com/file/d/16qQ6fs0V7QaV1UKHF6STv-i6eKdKT6GF/view',
    ThumbnailUrl__c = '/Thumbnail_Grafik_Pflegestufen_und_Pflegegrade.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Pflegestufen und Pflegegrade',
    DownloadUrl__c = 'https://drive.google.com/uc?export=download&id=16qQ6fs0V7QaV1UKHF6STv-i6eKdKT6GF'
));

// Videos
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=D3VXVaRnglY',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_VVP_Grundlagen.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Vertriebspartner Portal Grundlagen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/430659915',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Erklaerfilm.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Erklärfilm'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/430661863',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Erklaerfilm.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Erklärfilm (Kurzversion)'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/755130135/b6215ce5e0',
    ThumbnailUrl__c = '/Thumbnail_Video_Nachhaltigkeit-Kalbach.png',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Nachhaltigkeit & Holzmodulbau'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/872928549',
    ThumbnailUrl__c = '/Thumbnail_Video_Bad-Schussenried.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Bad Schussenried'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/carestone/boxberg',
    ThumbnailUrl__c = '/Thumbnail_Video_Boxberg.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Boxberg'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=jRlsvGVN39A',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Herford_Elverdissen.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Herford Elverdissen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=SC8runAy14g',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Hiddenhausen.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hiddenhausen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=VfTSiBK82Y4',
    ThumbnailUrl__c = '/Thumbnail_Video_Hitzacker.png',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hitzacker'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=k3U3-5XdI1Y',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Ibbenbueren.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Ibbenbüren'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/manage/videos/563121284/2a64768267',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Hohenlockstedt.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hohenlockstedt'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=U623ryhPIiM',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Hohenstein.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hohenstein'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/manage/videos/636136037/7191dc677f',
    ThumbnailUrl__c = '/img/medienbereich/videos/Thumbnail_Video_Huerth.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hürth'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/carestone/seniorenzentrum-kalbach',
    ThumbnailUrl__c = '/Thumbnail_Video_Kalbach.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Kalbach'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://www.youtube.com/watch?v=9oZ14hKXsuc',
    ThumbnailUrl__c = '/Thumbnail_Video_Mommenheim.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Mommenheim'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/834748926',
    ThumbnailUrl__c = '/Thumbnail_Video_Reinhardshagen.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Reinhardshagen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Videos',
    VorschauUrl__c = 'https://vimeo.com/carestone/rodgau',
    ThumbnailUrl__c = '/Thumbnail_Video_Rodgau.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Rodgau'
));

// Rundgang
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'http://rundgang.carestone.com/',
    ThumbnailUrl__c = '/Thumbnail_Video_Bitburg_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Bitburg'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/RySgWRaOQ',
    ThumbnailUrl__c = '/Thumbnail_Video_Boxberg_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Boxberg'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/bv8e8hmh4',
    ThumbnailUrl__c = '/Thumbnail_Video_Ehningen_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Ehningen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/oQFrRGJKy',
    ThumbnailUrl__c = '/Thumbnail_Video_Essen-BW_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Essen-Kettwig BW'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/mszDcTTG8',
    ThumbnailUrl__c = '/Thumbnail_Video_Essen-Pflege_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Essen-Kettwig Pflege'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://bonitas.de/wp-content/rundgang/bonitas/herford-elverdissen/wohnkueche/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Herford_Elverdissen_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Herford Elverdissen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://bonitas.de/wp-content/rundgang/bonitas/herford-herringhausen/wintergarten/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Herford_Herringhausen_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Herford Herringhausen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://bonitas.de/wp-content/rundgang/bonitas/herford-stuckenberg/sitzecke/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Herford_Vlothoer_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Herford Vlothoer'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://bonitas.de/wp-content/rundgang/bonitas/hiddenhausen-schweicheln/garten/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Hiddenhausen_Herforder_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hiddenhausen Herforder'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://carestone.hallo-oau.de/',
    ThumbnailUrl__c = '/Thumbnail_Video_Hitzacker_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Hitzacker'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://titus-intensivpflege.de/wp-content/rundgang/titus/haus-titus-erwachsene-ibbenbueren/garten/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Ibbenbueren_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Ibbenbüren'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/xzfPuNK5y',
    ThumbnailUrl__c = '/Thumbnail_Video_Langelsheim_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Langelsheim'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/foQOnY3UR',
    ThumbnailUrl__c = '/Thumbnail_Video_Rodgau_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Rodgau'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://app.cloudpano.com/tours/qbE3XujF7',
    ThumbnailUrl__c = '/Thumbnail_Video_Petershagen_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Petershagen'
));
recordsToInsert.add(new Medienbereich__c(
    Kategorie__c = 'Rundgang',
    VorschauUrl__c = 'https://bonitas.de/wp-content/rundgang/bonitas/recke/begegnungsraum/index.html',
    ThumbnailUrl__c = '/Thumbnail_Video_Recke_360_Rundgang.jpg',
    Dateityp__c = 'Bild',
    Anzeigename__c = 'Recke'
));

// Insert all records
insert recordsToInsert;
