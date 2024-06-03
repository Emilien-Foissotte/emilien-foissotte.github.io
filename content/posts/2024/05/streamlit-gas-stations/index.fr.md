---
title: "Économiser de l'argent,en créant un Dashboard Data de A à Z"
cover:
  image: "cover.png"
  alt: "Carburoam Front Page"
  relative: true

date: 2024-05-10T14:45:59+02:00
publishDate: 2024-05-10T14:45:59+02:00
draft: true
tags: ["DataEng", "Python", "Streamlit", "Data"]
ShowToc: true
TocOpen: false
---

# TL;DR

Dans ce billet de blog, nous allons voir comment créer de A à Z
un projet de Data engineering, de l'ETL, la création de notre
schéma de données, l'ORM de l'application, son backend et ensuite
son déploiement avec Streamlit Cloud ⚙️ .

Le but est de récupérer la liste des prix de stations essence en France ⛽,
automatiser un job qui va venir mettre à jour les valeurs quotidiennement 📅 et construire un dashboard pour
afficher les prix personnalisés aux utilisateurs du site 📊.

Après la lecture de ce billet de blog, vous aurez les bases pour construire des dashboard data
et pour scrapper vos propres sources de données pour les exposer 🚀.

C'est parti !

## Intro

Je ne prends pas souvent ma voiture (l'avantage du réseau francilien de transports en commun), mais quand je dois le faire,
il me vient toujours un grand dilemme. Avec la multiplicité des stations essences autour de chez moi, et la volatilité
des prix à la pompe ces derniers temps, comment choisir systématiquement la moins chère..? 🤨

En France 🇫🇷 nous avons l'opprotunité d'avoir des APIs publiques maintenues par des services gouvernementaux.
Malheureusement, le site web ne fait qu'exposer les prix et ne permet pas de sauvegarder des stations préférées.

À chaque fois que je devais faire le plein, il fallait alors venir lister les prix de chaque station sur le site,
pas vraiment optimisé pour les mobiles.. 😓

Il y a quelques années, après avoir Dockerizé 2 / 3 choses sur ma Raspberry PI à la maison, et m'être un peu fait la main
sur Flask, j'avais exposé un site très très minimal qui affichait les prix. Le backend était un peu sale (tout était hardcodé),
mais efficace. Par contre aucun moyen de faire évoluer l'app..

Quand je montrais l'app à mes proches et mes amis, à chaque fois je leur disais qu'il m'était impossible de leur créer leur propre
liste de stations, à mon grand désarroi..

L'idée a donc germé, mon nouvel objectif de projet était très clair : créer un dashboard exposé sur le web, en open source, avec
uniquement du free-tier. Ce dashboard devait pouvoir être accessible par n'importe qui, et on devait pouvoir y créer son compte,
gérer ses listes de stations et surtout faire des économies sur le carburant.

_PS : D'ailleurs, l'énergie la moins chère reste toujours celle qu'on ne consomme pas, prenez votre vélo ou votre paire de jambes
dès que possible, c'est bon pour votre corps, votre esprit et pour la planète !_

{{<figure src="frontpage.png" caption="Landing page of the developed dashboard" >}}

## Extraire les données Open Data des prix en France

Pour commencer, comme dans tout projet de Data Engineering et de BI,
la pierre angulaire du travail à effectuer réside dans nos données.

Cette donnée doit être disponible, et de qualité. Travaillons en premier sur cet aspect.

Pour scrapper et récupérer notre donnée,i.e. les prix à la pompe, nous utiliserons la nouvelle
plateforme d'Open Data mise en oeuvre pas les sercives gouvernementaux français platform. Un flux quotidien y est maintenu,
et de relativement bonne qualité.

Le format est relativement simple, cela ne consiste pas en une API Rest comme rencontré classiquement, mais en un fichier
XML exposé sur une URL. Toutes les données de prix, de localisation et de dates de mises à jour y sont contenues.

Voici ci-dessous un extrait du fichier afin d'illustrer le format de donnée :

```xml
<?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
<pdv_liste>
<pdv id="91190012" latitude="4870300" longitude="212800" cp="91190" pop="R">
    <adresse>27 AV DU GENERAL LECLERC</adresse>
    <ville>Gif-sur-Yvette</ville>
    <horaires automate-24-24="1">
      <jour id="1" nom="Lundi" ferme="1"/>
      <jour id="2" nom="Mardi" ferme="1"/>
      <jour id="3" nom="Mercredi" ferme="1"/>
      <jour id="4" nom="Jeudi" ferme="1"/>
      <jour id="5" nom="Vendredi" ferme="1"/>
      <jour id="6" nom="Samedi" ferme="1"/>
      <jour id="7" nom="Dimanche" ferme="1"/>
    </horaires>
    <services>
      <service>Station de gonflage</service>
      <service>Carburant additiv<E9></service>
      <service>Automate CB 24/24</service>
    </services>
    <prix nom="Gazole" id="1" maj="2024-05-08 12:30:00" valeur="1.739"/>
    <prix nom="SP98" id="6" maj="2024-05-11 13:15:00" valeur="1.999"/>
    <rupture nom="E10" id="5" debut="2024-05-10 16:16:02" fin="" type="temporaire"/>
  </pdv>
</pdv_liste>
```

Le premier point qui saute aux yeux d'un Data Eng aguerris sera la bonne nouvelle concernant la manière
de représenter les données de stations. Elles y sont toutes listées par un objet XML bien défini, `pdv` (l'acronyme de
point de vente), qui se paie le luxe d'avoir un indentifiant unique. Cela est un bon présage pour la réconciliation
de donnée à chaque update, même si rien ne présume quant à l'évolution du schéma de donnée.

C'est d'ailleurs le côté négatif de la représentation par fichier, avec une API et une version, les Standard OpenAPI permettent
de facilement voir les évolutions. Ici ce sera quand le script hurlera d'erreurs dans tous les sens (au mieux) quand les
incompatibilités nous apparaîtrons..

Deuxième point rassurant, la latitude et la longitude des stations sont fournies ! C'est parfait afin de pouvoir
représenter les stations sur une carte. Pas besoin de s'embêter avec du Géo-encodage, ou de la réconciliation d'adresse.
J'ai toujours trouvé les cartes plus intuitives dans ces cas-là.

Enfin, nous retrouvons l'objet principal de ce que nous cherchons dans le champ `prix` :

- Une liste de prix pour les types de carburants fournis par la station, ainsi que la date de dernière mise à jour.
- Également la liste des services proposés par la station (lavage, automate 24/24). À noter, mais à priori nous ne nous en servirons pas dans le projet. Laissons ça pour un autre developpeur qui pourra développer 'Find My CarWash' :)

Construisons désormais des entités et des associations entre elles, sur la base de ce que nous avons pu trouver
dans ce fichier de données. Nous y ajouterons les informations contextuelles dont nous avons besoin dans le cadre du projet :
des utilisateurs par exemple..

### Gestion de la base d'utilisateurs

Pour gérer les utilisateurs, la création de comptes avec mots de passe, d'emails, nous définirons une table très simple.
Elle va ne contenir que les emails, noms et pseudos des utilisateurs. Tous les détails de chiffrement, de token d'authentification JWT
seront managés par une libraires externe au référentiel de donnée de l'application [Streamlit-Authenticator](https://github.com/mkhorasani/Streamlit-Authenticator).

L'idée sera simplement de réfléter les utilisateurs référencés par cette librairie, et d'ajouter ceux-ci à la table mentionnée précedemment.
Pour éviter de manipuler en base des choses sensibles comme des mots de passe (même chiffrés avec un système conventionel de hash et de salt),
aucune association ne sera faite dans la base de donnée. Appliquons l'idée de _least priviledge_, et ici rien n'indique le besoin d'avoir
l'accès aux mots de passe.

Malheureusement, dans la manière d'utiliser cette libraire, le fonctionnement classique exposerait chaque utilisateur à
un risque de sécurité.
En effet, en cas d'oubli de mot de passe, la seule option qui est proposée consiste à réinitialiser le mot de passe. Donc n'importe qui
pourrait demander la ré-initialisation de celui-ci.

![password](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNG1lc2Q0ZjY5azV5aHQzcm9vZWpxZzFsdWdrcHRnMDZiN3dieXh1aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l0G17mcoGBEabVgn6/giphy.gif#center)

Afin de coontourner ce risque, l'idée mise en place a été d'utiliser le système de mail pour envoyer un code vérification
envoyé par mail à l'utilisateur. Si ce code correspond à ce qui a été envoyé, alors il peut recevoir un nouveau mot de passe par le
biais de cette adresse mail.

Le stockage de cette logique applicative sera fait dans une table dédiée, contenant les dates de génération (afin de gérer l'expiration),
ainsi que les codes de vérification envoyés.

### Gérer les stations essences recensées et les prix

Pour permettre aux utilisateurs de créer une liste de stations essence personnalisées, une table `Custom_station` sera dérivée de la
`Stations`.
Chaque instance de l'objet `Price` sera associé à une station. Et un prix aura évidemment son association avec un type de carburant.
C'est à dire qu'il pourra être défini comme un diesel, un essence SP95, E10, E85, GPLc...

Pour que les utilisateurs puissent choisir quels types de carburant les intéressent, une table d'association doit être déclarée.
Elle marque le lien au niveau de l'ORM `SQLAlchemy` entre un utilisateur et un type de carburant, de la table `gas_types`

Ci-dessous, un diagramme avec toutes les entités et les associations permet de résumer les objets de notre modèle de donnée.
Les types d'association (1:1 / Many to One) ne sont pas représentés, mais l'ajout des clés primaires et étrangères est indiqué.
Cela devrait être suffisant pour lire le diagramme et comprendre les principales relations.

![EA](EA_GasStations.png#center)

### Déclarer ces entités dans un ORM

Afin d'utiliser facilement toutes ces tables, nous allons déclarer les classes `SQLAlchemy` et les relier entre elles. Pour faire
cela nous allons utiliser la version 2 de cette librairie Python, avec l'implémentation déclarative.

Voici la déclaration de ces différentes classes, sous le module `models.py` de notre application

```python
from typing import List

import sqlalchemy as sa
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


association_table = sa.Table(
    "association_table",
    Base.metadata,
    sa.Column("gastype_id", sa.ForeignKey("gas_types.id"), primary_key=True),
    sa.Column("user_id", sa.ForeignKey("users.id"), primary_key=True),
)


class GasType(Base):
    __tablename__ = "gas_types"
    # id = sa.Column(sa.Integer, primary_key=True)
    id: Mapped[int] = mapped_column(primary_key=True)
    xml_id = sa.Column(sa.String, nullable=False)
    name = sa.Column(sa.String, nullable=False)
    users: Mapped[List["User"]] = relationship(
        secondary=association_table, back_populates="gastypes"
    )

    def __repr__(self):
        return f"<GasType {self.name}>"


class User(Base):
    __tablename__ = "users"
    # id = sa.Column(sa.Integer, primary_key=True)
    id: Mapped[int] = mapped_column(primary_key=True)
    email = sa.Column(sa.String, unique=True, nullable=False)
    username = sa.Column(sa.String, unique=True, nullable=False)
    name = sa.Column(sa.String, nullable=False)
    # add a reference to the stations
    stations = relationship("CustomStation")
    # add a reference to the gas types followed
    gastypes: Mapped[List["GasType"]] = relationship(
        secondary=association_table, back_populates="users"
    )

    def __repr__(self):
        return f"<User {self.username}>"

    def to_dict(self):
        return {
            "id": self.id,
            "email": self.email,
            "username": self.username,
            "name": self.name,
        }

    def to_csv(self):
        return f"{self.id},{self.email},{self.username},{self.name}"


class VerificationCode(Base):
    __tablename__ = "verification_codes"
    id = sa.Column(sa.Integer, primary_key=True)
    user_id = sa.Column(sa.Integer, sa.ForeignKey("users.id"), nullable=False)
    code = sa.Column(sa.String, nullable=False)
    created_at = sa.Column(sa.DateTime, nullable=False)

    def __repr__(self):
        return f"<VerificationCode {self.id}>"


class Station(Base):
    __tablename__ = "stations"
    id = sa.Column(sa.Integer, primary_key=True)
    latitude = sa.Column(sa.Float, nullable=False)
    longitude = sa.Column(sa.Float, nullable=False)
    town = sa.Column(sa.String, nullable=False)
    address = sa.Column(sa.String, nullable=False)
    zip_code = sa.Column(sa.String, nullable=False)
    sa.Index("latitude_longitude_index", latitude, longitude, unique=True)

    def __repr__(self):
        return f"<Station {self.id}>"

    def to_dict(self):
        return {
            "id": self.id,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "town": self.town,
            "address": self.address,
            "zip_code": self.zip_code,
        }


class CustomStation(Base):
    __tablename__ = "custom_stations"
    id = sa.Column(sa.Integer, sa.ForeignKey("stations.id"), primary_key=True)
    user_id = sa.Column(sa.Integer, sa.ForeignKey("users.id"), nullable=False)
    custom_name = sa.Column(sa.String, nullable=False)

    def __repr__(self):
        return f"<CustomStation {self.id}-{self.user_id}>"

    def to_dict(self):
        return {
            "id": self.id,
            "user_id": self.user_id,
            "custom_name": self.custom_name,
        }


class Price(Base):
    __tablename__ = "prices"
    gastype_id = sa.Column(sa.Integer, sa.ForeignKey("gas_types.id"), primary_key=True)
    station_id = sa.Column(sa.Integer, sa.ForeignKey("stations.id"), primary_key=True)
    updated_at = sa.Column(sa.DateTime, nullable=False)
    price = sa.Column(sa.Float, nullable=False)
```

Bien ! Et comment utiliser ces différentes classes dans notre application Streamlit ?

Rien de plus compliqué que d'instancier un objet de type `Session` !

Voici comment déclarer cela sous le module `session.py` :

```python
import logging
from functools import lru_cache
from typing import Generator

import sqlalchemy
import streamlit as st
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy_utils import create_database, database_exists

from models import Base, GasType

logger = logging.getLogger("gas_station_app")
engine = create_engine("sqlite:///db.sqlite3", pool_pre_ping=True)


@lru_cache
def create_session() -> scoped_session:
    """Create a session given the url in settings."""
    Session = scoped_session(
        sessionmaker(autocommit=False, autoflush=False, bind=engine)
    )
    return Session


def get_session() -> Generator[scoped_session, None, None]:
    """Retrieve a session."""
    Session = create_session()
    try:
        yield Session
    finally:
        Session.remove()


database_creation = False
db_session = create_session()
logger.info("session created")
created_engine = db_session.bind
if not database_exists(created_engine.url):
    logger.info("Database does not exist, creating it")
    create_database(created_engine.url)
    database_creation = True
Base.metadata.bind = engine
Base.metadata.create_all(bind=created_engine)


### initialize the database with mandatory data


def create_gastypes(db_session):
    """
    Create the gas types in the database.

    Args:
        db_session: sqlalchemy session

    Returns:
        None
    """
    logger.info("Creating gas types")
    gas_dict = {"Gazole": 1, "SP95": 2, "SP98": 6, "E85": 3, "GPLc": 4, "E10": 5}

    for name, xml_id in gas_dict.items():
        if not db_session.query(GasType).filter(GasType.name == name).first():
            gas_type = GasType(name=name, xml_id=xml_id)
            db_session.add(gas_type)
    try:
        db_session.commit()
    except sqlalchemy.exc.IntegrityError:
        db_session.rollback()


if database_creation:
    create_gastypes(db_session=db_session)
```

Ces différentes lignes peuvent paraître complexes, mais si on les relis séquentiellement, c'est très simple
à comprendre.
Au démarrage de l'application, le module est initialisé par Python (puisqu'il est importé par `home.py`, le main de
notre application). Une instanciation de session est donc effectuée :

`engine = create_engine("sqlite:///db.sqlite3", pool_pre_ping=True)` va venir créer le moteur de l'ORM
sqlalchemy.

Comme nous allons utiliser un cache LRU, les appels seront moins fréquents à la base SQLite, les objets en cache seront
réutilisés par les différents appels de l'application. Python réutilisera le même objet de sortie de la fonction
`get_session` plusieurs fois, jusqu'à expiration du cache.

Désormais, intéressons nous à cette étrange fonction `create_gastypes` ?
Si SQLAlchemy détecte que la base SQLite est vide, sans les tables du schéma, alors il va déclencher la création de ces tables et
du schéma associé dans le module `models.py`.
Pour fonctionner correctement, notre table `gas_types` doit être alimentée avec la donnée du référentiel de l'[API Open Data](https://www.prix-carburants.gouv.fr/rubrique/opendata/).

Ici aucun moyen de récupérer ça de manière automatique, il va falloir hardcoder ces valeurs, et prier pour que cela n'évolue pas sans prévenir
dans le temps..

![specs](specs.png#center)

Et c'est tout ! Tous les autres modules pourront effectuer des appels à l'objet `db_session` de ce module, et
le tour est joué 🚀

Notre DataWarehouse/Entrepôt de donnée est prêt à recevoir la donnée de notre ETL, penchons-nous maintenant sur ce
bloc d'architecture.

_NB: Ici je ne couvrirais pas les éléments de Streamlit-Authenticator, ils sont très bien
illustrés dans la documentation GH du package, allez y jeter un oeil, c'est bien expliqué !_

## Rafraîchissement quotidien de la donnée

Résumons ce dont nous disposons désormais :

- Un workspace Streamlit gratuit, qui peut récupérer quotidiennement de la donnée et la déposer dans une DB SQLite
- Un fichier d'export exposé depuis une API Open Data publique
- Une UI à l'adresse [carburoam.streamlit.app](https://carburoam.streamlit.app/) qui ne peut qu'exposer l'application Streamlit
  (il faut malheureusement abandonner l'idée de pouvoir y brancher un `airflow`, `dagster` et compagnie..)

Donc où est caché notre ETL ici ? En effet, il manque une pièce centrale dans un projet de Data Engineering : l'outil
d'orchestration des flux de traitements de donnée !

Si nous pouvions avoir une instance d'airflow quelque part, alors assurément nous pourrions répondre à ce problème avec
ce genre d'outillage, mais il faut faire une croix dessus ici..

Constuisons alors quelque chose de plus simple. Ce ne sera très résilient, mais à l'échelle du projet, ce
sera amplement suffisant.

### Orchestrateur de jobs en pur Python

We will only leverage the main Python process of the streamlit app, and create a subprocess to run all the
mecanism of update.
It will only contains a Thread with a timer, which will trigger a task to update the prices.

![update](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExY3R5dXFuMjI1MjI5ZXlrb3phazQydmg0cDFleGN3NWpucHJhM3dnbyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/j3WJjjm1OKV73l6E6e/giphy.gif#center)

It's kind of "Hello World" of a CRON job, let's review step by step how it's achieved :
{{<mermaid>}}
flowchart TD
U[User] -->|Load Landing Page| L{Streamlit app}
L -->|pid.txt file </br> exists| PE[Do not trigger subprocess]
L -->|pid.txt file doesn't </br> exists| PN[Read last job execution]
PN -->|lastjob.txt file </br> exists| LE[Check current date]
LE -->|delta between last execution </br> less than threshold| LT[Do not trigger subprocess]
LE -->|delta between last execution </br> more than threshold| MT[Trigger subprocess </br> and delete logs older than 1 day]
PN -->|lastjob.txt file doesn't </br> exists| LN[Trigger subprocess </br> and delete logs older than 1 day]
{{</mermaid>}}

Is that all ? Pretty much, yes. Using the Database could make things a little
bit more complex, so we will only check it the subprocess has created a file `pid.txt`,
containing it's PID and another file, `lastjob.txt`, containing last execution job.

This way, it will not knock the database during development, when we have to redeploy often the app to test
stuff. And if an ETL trouble occurs, we can kill the previous subprocess given it's PID and start a new one, by removing
`pid.txt`.

Additionally, To help a little bit during debugging, the stdout and stderr of the script
will be routed to a text file, under a folder `outputs`.

```python
import logging
import os
import subprocess
import sys
import uuid
from datetime import datetime
from pathlib import Path

import streamlit as st

from utils import WAIT_TIME_SECONDS

logger = logging.getLogger("gas_station_app")


def trigger_etl():
    """
    Trigger the ETL process in a subprocess.
    """
    # create a new uuid for process opening
    str_uuid = str(uuid.uuid4())
    with open(f"outputs/stdout_{str_uuid}.txt", "wb") as out, open(
        f"outputs/stderr_{str_uuid}.txt", "wb"
    ) as err:
        subprocess.Popen([f"{sys.executable}", "utils.py"], stdout=out, stderr=err)
    if not os.path.exists("pid.txt"):
        logger.info("No pid file found, creating one")
        # if it doesn't exist, trigger the subprocess job
        # delete and remove output files under outputs
        for file in Path("outputs").glob("*.txt"):
            # get last modified date
            try:
                last_modified = datetime.fromtimestamp(file.stat().st_mtime)
                # if the file is older than 1 day, remove it
                if (datetime.now() - last_modified).days > 1:
                    logger.info(f"Removing {file}")
                    file.unlink()
            except FileNotFoundError:
                # it means another process has deleted the file
                pass

        if os.path.exists("lastjob.txt"):
            # check the last job date, do not start subprocess if recent
            with open("lastjob.txt", "r") as file:
                date = file.read()
                # parse the date (dumped as datetime.now())
                date = datetime.strptime(date, "%Y-%m-%d %H:%M:%S.%f")
                st.session_state["lastjob"] = date
                # if the detla from now is greater than WAIT_TIME_SECONDS
                if (datetime.now() - date).total_seconds() > WAIT_TIME_SECONDS:
                    logger.info("Last job was not recent, starting new job")
                    trigger_etl()
                else:
                    logger.info("Last job was recent, skipping")
        else:
            trigger_etl()
    if os.path.exists("lastjob.txt"):
        with open("lastjob.txt", "r") as file:
            date = file.read()
            date = datetime.strptime(date, "%Y-%m-%d %H:%M:%S.%f")
            st.session_state["lastjob"] = date
```

This way we can get a nice metric :

![metric_date](metric_date.png#center)

_NB: The sys.executable is very important to be sure that we are using the same Python executable
than streamlit app, with all dependencies installed. Using python directly could cause unexpected bugs_

How about the timed thread implementation ?

Pretty simple too :

```python
import os
import signal
from threading import Timer
import threading

WAIT_TIME_SECONDS = 60 * 60 * 6  # each 6 hours


class ProgramKilled(Exception):
    pass


def signal_handler(signum, ffoorame):
    raise ProgramKilled


class Job(threading.Thread):
    def __init__(self, interval, execute, *args, **kwargs):
        threading.Thread.__init__(self)
        self.daemon = False
        self.stopped = threading.Event()
        self.interval = interval
        self.execute = execute
        self.args = args
        self.kwargs = kwargs

    def stop(self):
        self.stopped.set()
        self.join()

    def run(self):
        while not self.stopped.wait(self.interval.total_seconds()):
            self.execute(*self.args, **self.kwargs)


def main_etl():
    print("Running ETL job at ", datetime.now())
    # print the process pid
    print("Process ID: ", os.getpid())
    with open("lastjob.txt", "w") as file:
        file.write(str(datetime.now()))
    loadXML()
    dump_stations()


def etl_job():
    # check if status file exists
    if not os.path.exists("pid.txt"):
        with open("pid.txt", "w") as file:
            file.write(str(os.getpid()))
        # start etl at beginning of the thread
        main_etl()
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGINT, signal_handler)
        job = Timer(WAIT_TIME_SECONDS, main_etl)
        job.start()

        while True:
            try:
                time.sleep(1)
            except ProgramKilled:
                print("Program killed: running cleanup code")
                # remove the pid file
                if os.path.exists("pid.txt"):
                    os.remove("pid.txt")
                job.cancel()
                break
    else:
        print("PID file already found, job as already started. Exiting...")
        exit(1)

if __name__ == "__main__":
    etl_job()
```

The main routine is under the function `etl_job` which was previously called.
We use a double security check, to verify if the PID file is not created already (with concurrency, multiples users could
try to load the page).

We get the signal handlers to do some cleanup when the process receive the termination signal from the parent process (i.e. the app
is shutdown).

Then we start the timer and launch an infinite loop until an Exception is raised by signal handler.
This way the script will remove the pid file before exiting.

![cleanup](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzdtM2RvcHc2ZTlza2RkeGk3eDI1ZTVndHRvb2IwNDF4c3ZsZWs5aiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l2Je9c6EJAuE7mYMM/giphy.gif#center)

Good ! Now we have a full ETL to load into the database the last prices exposed on the French API.

Let's craft a nice dashboard so that users can :

- A main page, with a price dashboard showing price list and redirection to other pages of the app
- Login into the website, retrieve their password / login if they forgot it automatically
- Modify, Update and Delete their profile, giving full control over it (RGPD), on users fields (mail, name..) and gas related details (gas types)
- Pick some stations to add to their dashboard

As a bonus :

- An about page, in order to show help informations
- A nice sidebar to give a professionnal look to the app, thanks to this <cite>open source app[^1]</cite>, where I borrowed the
  UI design of the sidebar.

[^1]:
    A nice pdf-editing [app](https://github.com/SiddhantSadangi/pdf-workdesk) made by Siddhant Sadangi, have a look to
    his other apps on GH, they are amazing !

## Designing the UI

### Home page

The home page needs to behave differently, wether the user is logged in or not. Based on this assumption, the goal will be
different. Let's review them step by step.

#### Unlogged users

For newcomers, the main ideas are :

1. To provide a way to create an account on the platform
   ![welcome](app_ui/welcome.png#center)
2. View a demo of the dashboard. I would never create an account on something I can't see before, so adding this option is a real bonus.
   ![demo](app_ui/demo.png#center)
3. Show an about page in order to let user have a look about this app
   ![about](app_ui/about.png#center)

#### Logged users

For logged users, the main purpose are, if I put myself into a user shoes, by order of priority :

1. The ability to get an instant glimpse of price of my favorites stations, sorted by ascending price.
   ![pricelist](app_ui/pricelist.png#center)
2. Be able to get information about the freshness of the data
   ![lastdate](app_ui/lastdate.png#center)
3. Get the approximative idea of the expected annual savings using this dashboard, to act like an incentive
   ![savings](app_ui/savings.png#center)
4. Get an overview of the other pages purposes and abilities, to customize profile and so on
   ![pages](app_ui/pages.png#center)

#### Admin user

For the admin user, a landing page shall provide : 5. Insight about app engagement
![admin](app_ui/admin.png#center) 6. Some management option to handle operation for users (password resets, ETL refresh if fails..)
![admin_actions_1](app_ui/admin_actions_1.png#center)
![admin_actions_2](app_ui/admin_actions_2.png#center)

As this page will be accessible to _admin_ user only, no sensitive data will be exposed.

By bundling all theses stuffs into a single app, deploy it on Streamlit Cloud, we have a live running web app !

![tree](tree.png#center)

## Keep the app alive and DB

As it has been explained previously, the DB will bootstrap user objects from S3 storage. However,
the customized stations are only visible in the SQLite DB.

To ensure the application doesn't enter into sleeping mode, some mecanism has to be setup in order
to produce traffic on the app.

![sleeping](sleeping.png#center)

To do this, I borrewed a nice Github action from another very cool made also by a French developer, <cite>Jean Milpied[^2]</cite>

Here is the Github Action YAML file :

```yaml
name: Trigger Probe of Deployed App on a CRON Schedule
on:
  schedule:
    - cron: "0 */48 * * *"

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

jobs:
  build-and-probe:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v2

      - name: Build Docker Image
        run: docker build -t my-probe-image -f probe-action/Dockerfile .

      - name: Run Docker Container
        run: docker run --rm my-probe-image
```

The probe action is a JavaScript script ran by puppeteer:

```js
const puppeteer = require("puppeteer");
const TARGET_URL = "https://carburoam.streamlit.app/";
const WAKE_UP_BUTTON_TEXT = "app back up";
const PAGE_LOAD_GRACE_PERIOD_MS = 8000;

console.log(process.version);

(async () => {
  const browser = await puppeteer.launch({
    headless: true,
    ignoreHTTPSErrors: true,
    args: ["--no-sandbox"],
  });

  const page = await browser.newPage();
  console.log(page); // Print the page object to inspect its properties

  await page.goto(TARGET_URL);

  console.log(page); // Print the page object to inspect its properties

  // Wait a grace period for the application to load
  await page.waitForTimeout(PAGE_LOAD_GRACE_PERIOD_MS);

  const checkForHibernation = async (target) => {
    // Look for any buttons containing the target text of the reboot button
    const [button] = await target.$x(
      `//button[contains(., '${WAKE_UP_BUTTON_TEXT}')]`,
    );
    if (button) {
      console.log("App hibernating. Attempting to wake up!");
      await button.click();
    }
  };

  await checkForHibernation(page);
  const frames = await page.frames();
  for (const frame of frames) {
    await checkForHibernation(frame);
  }

  await browser.close();
})();
```

The script is triggered using a Docker Image of puppeteer :

```Dockerfile
# probe-action/Dockerfile
FROM ghcr.io/puppeteer/puppeteer:17.0.0
COPY ./probe-action/probe.js /home/pptruser/src/probe.js
ENTRYPOINT [ "/bin/bash", "-c", "node -e \"$(</home/pptruser/src/probe.js)\"" ]
```

[^2]:
    Another nice app, showing some BI information about the chance you have to repair your devices. Have a look
    for the probe action [here](https://github.com/JeanMILPIED/reparatorAI/tree/main/probe-action), and deep dive the
    blog post provided by [David Young](https://dcyoung.github.io/post-streamlit-keep-alive/).

Using this technic, every 48 hours, the script will trigger a probe action and ensure the app stays up.
However, the current downside of current version, is the lack of ability to make Green/Blue deployments, meaning that
if the current Streamlit service fails, the app is deployed again elsewhere without the saved Sqlite DB.

Some backup mecanism could be set up, but at this point, using SQlite might be uneffective.

## Conclusion

Streamlit is a very versatile tool, giving the possibility to :

- craft a small app, with a cool and responsive UI
- with some hacks, build up a small ETL to give some daily updates to the data exposed. Do not take it as a
  production battle tested feature, but for some fun side projects, it will be enough.

Make sure your are giving a well designed data schema, in order to retrieve the maximum performances from your ORM.
