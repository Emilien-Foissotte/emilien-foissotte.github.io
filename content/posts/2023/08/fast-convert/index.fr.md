---
title: "De Parquet vers CSV en un clin d'oeil"
description: ""
date: 2023-08-26T09:50:14+02:00
publishDate: 2023-08-26T09:50:14+02:00
draft: false
frtags: [DataEng, Craftmanship, DuckDB, Data]
ShowToc: true
TocOpen: false
---

# TL;DR

Dans ce post nous verrons ensemble comment convertir super efficacement et rapidement 🚀
des fichiers au format `Apache Parquet` vers le format `CSV` (et vice-versa), en
utilisant DuckDB 🦆 et en comparant avec Pandas 🐍 comme une base de comparaison.

En bonus, nous verrons comment l'utiliser avec un format CLI super ergonomique et efficace, toujours
à portée de main 👨‍💻

C'est parti !

## Intro

Ces derniers temps j'ai eu de plus en plus l'occasion de travailler sur des tâches relevant plutôt du
Data Engineering pur et dur, avec par exemple des mises en place de Datalake AWS, des conversions de données en tout
genre, des designs de pipelines, du nettoyage de données.. 📊

Et évidemment, je n'ai pas été épargné par la multitude de format existants, j'ai souvent eu à convertir des
données vers le format `.csv` pour m'assurer que le déchiffrage s'est bien déroulé, que mon nettoyage a fonctionné, etc.. 👀

Malheureusement, il serait peu efficace de travailler constamment avec des formats `.csv`, car même s'ils sont
extrêmement pratiques pour lire un morceau de donnée très rapidement, ils sont très gourmand en mémoire de stockage.
Pour essayer d'économiser des coûts de stockage et traitements, il est bien plus adéquat d'utiliser un format de stockage de
type _colonnes_ comme `Apache Parquet`. ⚡

Et donc me revoilà à lancer encore et encore des commandes dans tous les sens, créer des environnements virtuels
pour installer `pandas` et `pyarrow` pour convertir mes fichiers `.parquet`.. J'ai donc tout naturellement cherché
un outil, idéalement en CLI, qui me permet de faire ces conversions rapides. Et malheureusement, rien qui ne
fasse cela sur étagère, du moins pas à ma connaissance après un rapide écumage des ressources de la communauté
Data Engineering, quel dommage.. 🤔

C'est reparti pour les commandes dans tous les sens..

![cat](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbWVxbHpwc2FzNHh2anFtcDRoaXdianJhOGl5bDFwYXJsdW5pNHVzbyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/JIX9t2j0ZTN9S/giphy.gif#center)

Quel rêve d'avoir un outil qui permettrait de visualiser les données en un coup d'oeil, malheureusement
la réalité avec les fichiers `.parquet` est tout autre.. 😥

```sh
❯ head file.parquet
B%R1x,<I/

!
b
B5
 u
:!-
<M=
P(-    bG
```

Et oui, il n'y a pas de repas gratuit, pour reprendre les termes du _no free lunch theorem_, [NFL](https://en.wikipedia.org/wiki/No_free_lunch_theorem)
pour les intimes, on ne peut pas avoir un format directement optimisé pour le stockage et l'accès en lecture,
il faut faire un choix. 🤑

Et puis, il y a quelques temps, m'est revenu à l'esprit un post d'un Data Engineer faisant la promotion de DuckDB,
et repartageant un snippet de code montrant comment cet outil peut faire ce genre d'opération super efficacement !

À vos claviers, on va essayer de reproduire et installer ça sur notre machine ! 🚀

## Rapide comparaison d'outils - Pandas vs DuckDB

Donc quelques mois plus tôt, je tombe sur Linkedin sur ce [post](https://www.linkedin.com/posts/motherduck_csv-to-parquet-using-duckdb-cli-activity-7043982478671306752-z2EK?utm_source=share&utm_medium=member_desktop)
qui montre qu'avec un script en une ligne de commande comment DuckDB peut faire la conversion, d'un CSV vers un parquet.

Ce n'est pas l'opération que je fais le plus mais ça devrait être possible de faire l'inverse,
comparons déjà les performances entre les outils et le procédé, comparativement à `pandas+pyarrow` par exemple.

Téléchargeons d'abord un premier dataset de taille moyenne, par exemple le [MovieLens 25M dataset](https://grouplens.org/datasets/movielens/)

Nous nous en servirons dans un prochain post, orienté ML cette fois, stay tuned ! 😉

```sh
❯ head -n 3 ratings.csv
userId,movieId,rating,timestamp
1,296,5.0,1147880044
1,306,3.5,1147868817
```

Comparaons avec pandas et pyarrow d'installés, nous allons voir où se situe les performances de ce nouvel outil
dans ce genre d'opérations.

Histoire de garder une trace et pouvoir reproduire la situation
voici un extrait d'un `pip freeze` sur mon environnement virtuel :

```sh
❯ pip freeze
numpy==1.25.2
pandas==2.1.0
pyarrow==13.0.0
python-dateutil==2.8.2
pytz==2023.3.post1
six==1.16.0
tzdata==2023.3
```

Les performances sont les suivantes :

```sh
❯ /usr/bin/time -l -h -p python -c "import pandas; df=pandas.read_csv('ratings.csv'); df.to_parquet('ratings.parquet')"
real 14,43
user 9,40
sys 2,80
          1774600192  maximum resident set size
                   0  average shared memory size
                   0  average unshared data size
                   0  average unshared stack size
             1037341  page reclaims
                5284  page faults
                   0  swaps
                   0  block input operations
                   0  block output operations
                   0  messages sent
                   0  messages received
                   0  signals received
                 864  voluntary context switches
               25149  involuntary context switches
         77809521962  instructions retired
         42836239895  cycles elapsed
          2854670336  peak memory footprint
```

Maintenant lançons DuckDB 🦆

Pour installer cet outil, suivez cette [doc](https://duckdb.org/docs/installation/), c'est très simple :

Pour macOS

```sh
brew install duckdb
```

Et pour Linux (ciblez la bonne architecture)

```sh

curl -SL https://github.com/duckdb/duckdb/releases/download/v0.8.1/duckdb_cli-linux-amd64.zip -o /tmp/duckdb.zip
unzip /tmp/duckdb.zip
mv /tmp/duckdb/* /usr/local/bin/
chmod +x /usr/local/bin/duckdb
```

Lançons la conversion de ce fichier `.csv` 🚀 :

```sh
❯ /usr/bin/time -l -h -p duckdb -c "COPY (select * from read_csv_auto('ratings.csv')) TO 'ratings.parquet' (FORMAT PARQUET)"
100% ▕████████████████████████████████████████████████████████████▏
real 9,12
user 24,58
sys 2,36
           603959296  maximum resident set size
                   0  average shared memory size
                   0  average unshared data size
                   0  average unshared stack size
              551447  page reclaims
                1741  page faults
                   0  swaps
                   0  block input operations
                   0  block output operations
                   0  messages sent
                   0  messages received
                   0  signals received
                 761  voluntary context switches
               34911  involuntary context switches
        135618259891  instructions retired
         96669139421  cycles elapsed
           645996544  peak memory footprint
```

Nous pouvons maintenant comparer les performances entre les outils !

![data](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNXNlbDl1dnZnMzVyMHN5MTF5cHQ3MnN1ZXowNXc4NmEzYW9kbnhxZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/LaVp0AyqR5bGsC5Cbm/giphy.gif#center)

Déjà, une première impression : La barre de prgression est top,
toujours agaçant d'attendre un process sans savoir quand il va finir ni s'il tourne effectivement ou non.

Néanmoins il semblerait que le fichier `.parquet` produit par DuckDB
soit légèrement moins compressé que celui par Pandas, (sûrement des options que je n'ai pas activé) :

```sh
❯ du -h ratings*.parquet
225M    ratings_duckdb.parquet
168M    ratings_pandas.parquet
```

Par contre, et ça c'est un gros point en faveur de DuckDB, quand on regarde `peak memory footprint`, la
mémoire RAM maximale utilisée, on voit que Pandas charge l'entièreté du fichier csv en mémoire quand
DuckDB fait le traitement par lots. Sur des systèmes avec des spécs limitées (Raspberry, fonctions Lambda),
cela peut être limitant.

Le pic de mémoire a une valeur `4.4` fois moins importante avec DuckDB comparativement à Pandas. Excellent !

![duck](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExcWUzOGJ0OGpjanJuajg2MTkyemRxY3FqdWV1emRrdmE3cmN5bHNrZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/x4bgmvMlRSYRVcTm29/giphy.gif#center)

## Développement d'un outil CLI - de manière élégante

Il nous suffit de modifier le `.zshrc` ou `.bashrc` avec ces petites fonctions :

```sh
function csv_to_parquet() {
    file_path="$1"
    duckdb -c "COPY (SELECT * FROM read_csv_auto('$file_path')) TO '${file_path%.*}.parquet' (FORMAT PARQUET);"
}

function parquet_to_csv() {
    file_path="$1"
    duckdb -c "COPY (SELECT * FROM '$file_path') TO '${file_path%.*}.csv' (HEADER, FORMAT 'csv');"
}
```

Et on peut charger et transformer les fichiers en une ligne de commande :

```sh
parquet_to_csv file.parquet
```

et boom, on obtient notre `file.csv` 💥

Pour faire l'inverse, rien de plus simple :

```sh
csv_to_parquet file.csv
```

Et voici notre fichier `file.parquet`, si rapide et efficace ! 🏎️

## Conclusion

Nous avons parcouru très rapidement cette fonctionnalité super sympa de DuckDB, mais avons ce petit
exemple on voit tout la puissance de cet outil très polyvalent. En quelques lignes
de CLI vous avez déjà un bref aperçu des capacités de DuckDB, cela vous fera gagner beaucoup
de temps dans vos tâches de Data Engineering !

N'hésitez pas à rajouter vos fonctions `.bashrc` et `.zshrc` super pratiques
en commentaires, toujours cool d'en apprendre de nouvelles !

❤️ à l'équipe de DuckDB team pour le boulot incroyable !

### Liens et références

- [Le post Linkedin](https://www.linkedin.com/posts/motherduck_csv-to-parquet-using-duckdb-cli-activity-7043982478671306752-z2EK?utm_source=share&utm_medium=member_desktop)
- [Repost de Mehdi Ouazza, un Data Eng à suivre !](https://www.linkedin.com/posts/mehd-io_csv-to-parquet-using-duckdb-cli-activity-7043984992632229888-7GJr?utm_source=share&utm_medium=member_desktop)
- [DuckDB documentation](https://duckdb.org/docs/installation/)
- [Discover DuckDB PDF](https://duckdb.org/pdf/SIGMOD2019-demo-duckdb.pdf)
