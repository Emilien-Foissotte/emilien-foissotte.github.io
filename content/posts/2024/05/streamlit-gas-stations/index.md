---
title: "Saving Money, End to End DataEng dashboard showcase"
description: ""
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

This post will deep dive in the buidling of an end to end
data engineering project ⚙️ .

The idea will be to retrieve a price list of gas stations in France ⛽,
create a job to extract it every day 📅 and craft a dashboard to expose those price to
logged user 📊.

After reading this blog post, you'll have fundamentals on how to build data
dashboard and scrap your own data sources 🚀.

Let's go !

## Intro

I do not take my car often, but when I do, I always have a dilemna when it comes to fill it at the gas station.. 🤨

In France 🇫🇷, we have public APIs exposing price of gas stations each day. However the website is very clunky and there is no
way to store your favorite gas stations.

So each time I had to fullfill my gas tank, I had to grab price of surrounding stations. Not so efficient.. 😓

A few years ago, as I was getting hands on Docker, my Raspberry Pi and Flask, I had the idea to expose a minimal web
page with my own stations. The backend was efficient, but in no way evolutive.

Furthermore, my friends and relatives had no hability to enjoy the dashboard as there were no ability to add new stations, or
add users.

Hence, my new idea was pretty clear : create a web exposed dashboard, using solo Free Tier so that anyone could create an account,
pick his own station and make savings on his gas bill !

{{<figure src="frontpage.png" caption="Landing page of the developed dashboard" >}}

## Extracting price data

First, as on every data engineering, the cornerstone of the project will be the availability of the data.

To scrap and retrieve all gas stations price, we will use an Open Data platform which makes available this
data, every day.

The format is pretty simple, it's not an API but a zipped flat file, containing XML data about all the stations in France, updated
with their prices.

Here is an extract of the file to demonstrate the format :

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

First of all, a good news is that our gas stations, identified by an XML element `pdv` (which stand for 'point de vente' in French,
a sales point) are given an unique Id.

Furthermore, we can see that latitude and longitudes are provided on our stations, which will make perfect for a
display on a map.
Additionally, a list of element `prix` are providing somes prices and date of last update, for the related gas station.
Some data will not be leveraged, as will not be useful for the exposed dashboard, for instance opening hours, services provided by
the station, etc..

Let build up some entities based on the information we can gather in this flat file, and also some information about users.

### Managing users

To manage user, password and accounts, we will use a simple user table, using solely mail, name and username. All the details of encrypted
passwords and JWT are managed by an external Streamlit library [Streamlit-Authenticator](https://github.com/mkhorasani/Streamlit-Authenticator).

In order to mirror each users loaded by this library, this table will be populated by records in the library, but not any credentials.

Unfortunately, in the way I was thinking using it, the initial library had a major security flaw. In fact, if you would like to reset a
password for a user, anyone could do it...

![password](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNG1lc2Q0ZjY5azV5aHQzcm9vZWpxZzFsdWdrcHRnMDZiN3dieXh1aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l0G17mcoGBEabVgn6/giphy.gif#center)

To ensure that the user which is triggering

A table containing verification codes that would be sent to reset password

### Managing Stations and Prices

To let users create somes customized stations, a table `Custom_stations` will be derived from table `Stations`.
Each instance of a `Price` item will be associated to a Station. And a price will be associated also to a type of
gas, i.e. is it diesel, unleaded, ethanol derived fuel..

In order to track which gas type the user would like to be subscribed, an association table will be declared to link a
user to a gas type.

Here is a diagram of all the entities and the association (1:1 or Many to One are not represented,
but PK and FK are, and should be enought to read it).

![EA](EA_GasStations.png#center)

### Mirroring theses entities using an ORM

In order to conveniently use all theses tables, we will declares `Sqlalchemy` classes and link them using the new version declarative
implementation.

Here is the declaration of the previously mentionned classes, stored into a `models.py`

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

Fair enough !

How to bind this with our streamlit app ?

Nothing more complicated than instanciating a session !

Let's deep dive a litlle bit into the code :

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

What's happening here is very simple, at the loading of the app, we do instanciante our app and session.

`engine = create_engine("sqlite:///db.sqlite3", pool_pre_ping=True)` will create the sqlalchemy engine.

As we will be using a LRU cache, less frequent call will be made to the sqlalchemy engine.
Python will use same output from function `get_session` more often.

What is this weird function `create_gastypes` ? If sqlalchemy detects that the Sqlite database is
empty, it will trigger creation of the empty tables.
But to properly work, our gas_type table has to be fed up with data from the specifications of the [Open Data API](https://www.prix-carburants.gouv.fr/rubrique/opendata/).

![specs](specs.png#center)

That's all ! Every other module can call for a `db_session` from this module, and it'll do the trick 🚀

Now all our data warehouse is ready to be filled up with data, let's review the ETL process.

_NB: I wont cover Streamlit-Authenticator related elements as they are well described in the GH documentation of the package,
feel free to have a look to it, very convenient._

## Daily retrieval of data

Let's sum up what do we have for now :

- A streamlit free workspace, which can retrieve data from a local sqlite file
- A flat file with price data
- An UI at [carburoam.streamlit.app](https://carburoam.streamlit.app/) which will display solely the streamlit

Where is the ETL out here ?

Indeed, we miss a crucial part of a data engineering project : an orchestration tool. If I could have
an airflow instance somewhere, I would definetely go for instanciating a simple DAG in here. But we do not
have such element. So we will make something much simple.

### Pure python job orchestrator implementation

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

For logged users, the main purpose are, if I put myself into a user shoes, by order of priority :

1. The ability to get an instant glimpse of price of my favorites stations, sorted by ascending price.
2. Be able to get information about the freshness of the data
3. Get the approximative idea of the expected annual savings using this dashboard, to act like an incentive
4. Get an overview of the other pages purposes and abilities, to customize profile and so on
