---
title: "Saving Money, End to End DataEng dashboard showcase"
description: ""
cover:
  image: "cover.png"
  alt: "Carburoam Front Page"
  relative: true
date: 2024-06-09T18:53:22+0200
publishDate: 2024-06-09T18:53:22+0200
draft: false
tags: ["DataEng", "Python", "Streamlit", "Data"]
ShowToc: true
TocOpen: false
---

# TL;DR

This post will deep dive in the buidling of an end to end
data engineering project ⚙️ .

The idea will be to retrieve a price list of gas stations in France ⛽,
create a job to extract it every day 📅 and craft a dashboard to expose those price to
logged user 📊

After reading this blog post, you'll have fundamentals on how to build data
dashboard and scrap your own data sources 🚀

Just a reader not interested into the technicals details ? Have a look to the dashboard,
you'll save on the gas bill 🤑 And reinvest the remainings into ecological transition towards
[a carbon-free world](https://green-got.com/)(get 1 month for free with discount voucher `emilien-foissotte`) 😇

Let's go !

## Intro

I do not take my car often, but when I do, I always have a dilemna when it comes to fill it at the gas station.. 🤨

In France 🇫🇷, we have public APIs exposing price of gas stations each day. However the website is very clunky and there is no
way to store your favorite gas stations. 😭

So each time I had to fullfill my gas tank, I had to grab price of surrounding stations, on a mobile UI unfriendly website.
Not so efficient.. 😓

A few years ago, as I was getting hands on Docker, my Raspberry Pi and Flask, I had the idea to expose a minimal web
page with my own stations. The backend was efficient, but in no way evolutive. 💀

My friends and relatives had no hability to enjoy the dashboard as there were no ability to add new stations, or
add users. I was that close to tell them to open a ticket on the project board, just a casual job habit 😇. I wasn't lacking
of motivation or time to do it, but the codebase was way too monolithic to make a few evolution possible, at all.. 🫠

Hence, my new idea was pretty clear : create a web exposed dashboard, using solo Free Tier so that anyone could create an account,
pick his own station and make savings on his gas bill ! ⛽

_PS : BTW, the cheapest energy will always be the one you will not consume. Take your bike or your legs when you can,
that's better for your health, your wallet, your mind and for the planet!_ 🌱

{{<figure src="frontpage.png" caption="Landing page of the developed dashboard" >}}

Live version availabe here [https://carburoam.streamlit.app/](https://carburoam.streamlit.app/) ! 🚀

## Extracting price data

First, as on every data engineering, the cornerstone of the project will be the availability of the data.

To scrap and retrieve all gas stations price, we will use an Open Data platform which makes available this
data, every day.

The format is pretty simple, it's not an API but a zipped dump file, containing XML data about all the stations in France, updated
with their prices. On a daily basis, the platform updates it, and the quality is rather good !

![francais](https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExamRud3FicTkxdnloZHRkMWt1MXo4bms5bXcwcmo1NDQyeHc2aXZ3ZyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KcFV1Hm2vFMAolcHbu/giphy-downsized.gif#center)

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
a sales point) are given an unique Id. All the objects are well defined, nonetheless, a savage evolution of the format could happen.

That's the downside of using a file API, some Rest protocols ensure that the routes will not drastically evolve over time, without a
major version increment. Here the only we will catch this evolution, will be when the ETL will broke..

Anyway, there is still some good news on the record. We can see that latitude and longitudes are provided on our stations, which will make
it perfect for a nice display on a map. I always have found, from a user perspective, that maps are better to pick some locations than
streets nor towns names.

Additionally, a list of element `prix` are providing somes prices and date of last update, for the related gas station.
Some data will not be leveraged, as will not be useful for the exposed dashboard, for instance opening hours, services provided by
the station, etc..

Let build up some entities based on the information we can gather in this flat file, and also some information about users.

### Managing users

To manage user, password and accounts, we will use a simple user table, using solely mail, name and username. All the details of encrypted
passwords and JWT are managed by an external Streamlit library : [Streamlit-Authenticator](https://github.com/mkhorasani/Streamlit-Authenticator).

In order to mirror each users loaded by this library, this table will be populated by records in the library, but not any credentials.
Let's apply the _least priviledge_ principle, there is absolutely no need for a hashed password storing in the DB here, so let's lighthen
the data schema on this side.

Unfortunately, in the way I was thinking using it, the initial library had a major security flaw. In fact, if you would like to reset a
password for a user, anyone could do it. So anyone could reset another user password, without applying some confirmation mecanism.

![password](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExNG1lc2Q0ZjY5azV5aHQzcm9vZWpxZzFsdWdrcHRnMDZiN3dieXh1aCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l0G17mcoGBEabVgn6/giphy.gif#center)

To ensure that the user which is triggering the password reset operation, we will send a confirmation code to the user by email,
which he will have to enter to proceed into password reset finalization.

To store and enable this application logic, a table containing verification codes that would be sent to reset password has to be
created. Password will never be stored, they will only be transmitted on the fly to the users by mail, upon reset.

### Managing Stations and Prices

To let users create somes customized stations, a table `Custom_stations` will be derived from table `Stations`.
Each instance of a `Price` item will be associated to a Station. And a price will be associated also to a type of
gas, i.e. is it diesel, unleaded, ethanol derived fuel..

In order to track which gas type the user would like to be subscribed, an association table will be declared to link a
user to a gas type. This table creates a bounded link at the ORM `SQLAlchemy` level between a user and a type of fuel, from
table `gas_types`.

Here is bellow a diagram of all the entities and the association (1:1 or Many to One are not represented,
but PK and FK are, and should be enought to read it).

![EA](EA_GasStations.png#center)

### Mirroring theses entities using an ORM

In order to conveniently use all theses tables, we will declares `SQLAlchemy` classes and link them using the version `2` declarative
implementation.

Here is the declaration of the previously mentionned classes, stored into a `models.py` module of our application.

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

Nothing more complicated than instanciating a `Session` type object !

Let's deep dive a little bit into the code, under `session.py` module of the app :

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

What's happening here is very simple, at the loading of the app, we do instanciante our app and session (as it is imported by
`home.py` module, the main of the application).

A session instanciation is done :
`engine = create_engine("sqlite:///db.sqlite3", pool_pre_ping=True)` will create the sqlalchemy engine.

As we will be using a LRU cache, less frequent call will be made to the sqlalchemy engine.
Python will use same output from function `get_session` more often, until the cache expires.

What is this weird function `create_gastypes` ? 

If sqlalchemy detects that the Sqlite database is
empty, it will trigger creation of the empty tables.
But to properly work, our gas_type table has to be fed up with data from the specifications of the [Open Data API](https://www.prix-carburants.gouv.fr/rubrique/opendata/).

![specs](specs.png#center)

No way to create a smart logic here, so let's hardcode them, and hope that they will not evolve over time..

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

This way we can get a nice metric to display the last time the ETL has ran :

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
is shutdown), so that the thread can remove the pid file and so on.

Then we start the timer and launch an infinite loop until an Exception is raised by signal handler.
This way the script will remove the pid file before exiting.

![cleanup](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExYzdtM2RvcHc2ZTlza2RkeGk3eDI1ZTVndHRvb2IwNDF4c3ZsZWs5aiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l2Je9c6EJAuE7mYMM/giphy.gif#center)

Good ! Now we have a full ETL to load into the database the last prices exposed on the French API.

Let's craft a nice and UX friendly dashboard so that users can :

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
   ![demo1](app_ui/demo_1.png#center)
   ![demo2](app_ui/demo_2.png#center)
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

For the admin user, a landing page shall provide :

5. Insight about app engagement
   ![admin](app_ui/admin.png#center)

6. Some management option to handle operation for users (password resets, ETL refresh if fails..)
   ![admin_actions_1](app_ui/admin_actions_1.png#center)
   ![admin_actions_2](app_ui/admin_actions_2.png#center)

As this page will be accessible to _admin_ user only, no sensitive data will be exposed.

By bundling all theses stuffs into a single app, deploy it on Streamlit Cloud, we have a live running web app !

And everything is managed by streamlit, no headache !

![tree](tree.png#center)

## Keep the app alive and DB on the local filesystem accross time

As it has been explained previously, the DB will bootstrap `Users` objects from S3 storage. However,
the instances of `CustomStation`, `Price` and `Stations` are only visible in the SQLite DB.
There is a risk that we loose the SQLite file (in case of reboot of the Streamlit environment, they explicitely
express that they will not maintain a local filesystem, it's up to the developer to setup some workaround mecanism)

To ensure the application doesn't enter into sleeping mode, and that the Streamlit orchestrator removes the
container/VM or server where the app resides, some application logic has to be setup in order
to produce traffic on the app. This way we feel safe about these eventuality.

![sleeping](sleeping.png#center)

To do this, and ensure that at least 1 visit will be produced on the website I borrewed a nice Github action from
another very cool app made also by a French developer, <cite>Jean Milpied[^2]</cite>

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

The script is triggered using a Docker Image of puppeteer, and probe the website and click on
wake up if it's sleeping :

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

This happened a few time during development, but for a side project without any particular ambition, It seems
rather enough to me !

Some backup mecanism could be set up, but at this point, using SQlite might be uneffective. I will add a TODO note in the project for the future
to implement some backup logic.

## Conclusion

Streamlit is a very versatile tool, giving the possibility to :

- craft a small app, with a cool and responsive UI
- with some hacks, build up a small ETL to give some daily updates to the data exposed. Do not take it as a
  production battle tested feature, but for some fun side projects, it will be enough.

Make sure your are giving a well designed data schema, in order to retrieve the maximum performances from your ORM, implementing
the app logic will be so easy and straightforward !

Besides, you will have fancy ORM objects, always nice when implementing a backend !

A lot of❤️ to various developers who Open sourced their apps ([pdf-workdesk](https://pdfworkdesk.streamlit.app/),
[reparatorAI](https://reparatorai.streamlit.app/), librairies ([Streamlit-Authenticator](https://github.com/mkhorasani/Streamlit-Authenticator/)),
without them the work would have been way much harder, or maybe impossible.
Give them a lot of 🌟, it will please them a lot !

My thanks goes also to Streamlit teams, thanks a lot for making possible for developers to expose their
crafted dashboards for free. Very appreciated !
