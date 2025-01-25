---
title: "Coder hors ligne efficacement"
date: 2025-01-11T09:04:03+01:00
publishDate: 2025-01-11T09:04:03+01:00
cover:
  image: "cover.jpg"
  relative: true
  alt: "Coder à la campagne"
draft: false
tags: ["DataEng", "LLM", "Duckdb", "Python"]
ShowToc: true
TocOpen: false
---

# TL;DR

Cet article montrera quelques astuces pour travailler efficacement en tant que Data Engineer 🚀, que ce soit en naviguant dans la documentation
ou en utilisant un LLM local pour faciliter son expérience de développement (si vous êtes l'heureux propriétaire d'une puce Mac M2 ou M3).
Profitez d'un instant au calme, à la campagne, durant un voyage sans transiger sur votre abilité à débugger 👨‍💻

C'est parti !

## Introduction

De nos jours, travailler avec une connexion Internet limitée peut arriver et il y a un énorme écart par rapport à une configuration
de poste de travail de développement. 🦾

Dans ces cas, la vitesse de connexion peut devenir très lente, avec une bande passante instable.
Cela peut rendre très difficile le travail dans ces environnements, mais avec un peu de préparation, vous pourriez
être aussi efficace qu'avant ! 💥

![paresseux](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbzN1eTJlY2Y5cndiaGdydDdhZW9iZjE3bzhpZ3VtczZwODhyY3p5NyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oz8xOu5Gw81qULRh6/giphy.gif#center)

Préparez-vous à booster votre productivité, dans un train, dans un bus ou en profitant d'un voyage en famille à la campagne ! 🚜

## Garder une documentation consultable, partout

Vous n'avez jamais reçu un RTFM en soulevant un problème ? Faites-vous un cadeau, lisez la documentation lorsque vous abordez un
nouveau concept ou une nouvelle fonctionnalité d'un package ! 📖

### Problèmes Unix

Un très bon outil à utiliser lorsque vous travaillez sur des ordinateurs UNIX est `man`, un simple outil de documentation qui vous donne tous les détails des logiciels installés.

Cependant, il peut être difficile de naviguer dans toute la documentation. Et il est assez difficile de trouver exactement ce que vous cherchez.

Pour résoudre ce problème, un outil communautaire a émergé : `tldr`.

En quelques lignes de documentation, vous découvrirez l'utilisation principale du logiciel et sa syntaxe.

Par exemple, pour la commande `xargs` :

![xargs_tldr](tldr_xargs.png#center)

Plutôt sympa, non ? 🔥

Pour l'installer, rendez-vous dans le [repository](https://github.com/tldr-pages/tldr).

### Naviguer dans la documentation Python

Python devenant le premier langage de programmation, vous rencontrerez sûrement des problèmes en travaillant dessus !
Vous avez du mal à utiliser un objet d'une librairie ou d'un package de Python ? 🐍

Une exploration approfondie en utilisant de magicien Pythonista comme `yourobject.__dict__` ne vous a fourni aucune information utile ?

Lancez le serveur de documentation intégré associé à votre version de Python avec :

```sh
pydoc -p 0
```

et tapez `b` pour ouvrir automatiquement une page de navigateur 🌐

Tous les packages installés auront leur documentation fournie ici, avec des docstrings et des exemples.

Par exemple, voici la docstring de `pyspark` avec la fonction `agg` :

![pyspark_agg](pyspark_agg.png#center)

## Naviguer dans la documentation Duckdb hors ligne

Parfois, avec la bonne préparation, un ingénieur de données peut travailler en toute sécurité sur des projets `dbt`
en utilisant des `tests unitaires` ou des `tests de données` avec des sources simulées 📊

Par exemple, j'ai récemment travaillé avec [lea](https://github.com/carbonfact/lea), une alternative légère à
`dbt` qui est plug and play avec `duckdb`.

Mes modèles de staging étaient utilisés pour récupérer des données locales qui n'étaient pas trop volumineuses pour surcharger mon disque dur.

Je déclare des vues comme suit :

```txt
.
├── seeds
│   ├── inventory.sql
│   ├── raw_animals.csv
│   └── raw_inventory.parquet
├── views
│   ├── analytics
│   │   └── stats.sql
│   ├── core
│   │   └── wrangled_inventory.sql
│   ├── gold
│   │   ├── animals.sql
│   │   └── inventory.sql
│   └── staging
│       ├── animals.py
│       └── inventory.py
├── wrangling.db
```

Le modèle `seeds/inventory.sql` contient :

```sql
CALL load_aws_credentials('my-profile');
DROP TABLE IF EXISTS inventory;
 COPY (
   SELECT * FROM 's3://mylarge-bucket/inventory.parquet'
 ) TO 'seeds/raw_inventory.parquet' (FORMAT PARQUET);
```

Quand je suis encore en ligne, je fais un :

```sh
duckdb < seeds/inventory.sql
```

Cela génère un dump du fichier _raw_inventory.parquet_ ⚙️

Et plus tard, je peux déclarer le modèle `staging`, qui contient :

```py
from __future__ import annotations

import pathlib

import pandas as pd

here = pathlib.Path(__file__).parent
inventory = pd.read_parquet(here.parent.parent / "seeds" / "raw_inventory.parquet")
```

Vous avez besoin de consulter la documentation de duckdb sur un cas particulier pour une fonction ?

Avant votre voyage hors ligne, téléchargez la dernière <cite> documentation [^1] </cite>
sous forme de fichier zip à [https://duckdb.org/duckdb-docs.zip](https://duckdb.org/duckdb-docs.zip).

[^1]: L'équipe Duckdb propose plusieurs façons de consulter la documentation hors ligne, rendez-vous sur la [page de documentation hors ligne](https://duckdb.org/docs/guides/offline-copy.html) pour plus d'informations.

Téléchargez-la, décompressez-la :

```sh
mkdir ~/duckdb-offline && mv ~/Downloads/duckdb-docs.zip ~/duckdb-offline
cd duckdb-offline && unzip duckdb-docs.zip
```

Une fois décompressée, chargez le serveur web intégré de Python, il sera disponible partout
hors ligne, même avec la barre de recherche, très pratique ! 🦆

```sh
python -m http.server
```

![duckdb-docs](duckdb_docs.png#center)

## Vous tournez en rond sur un problème difficile ? Demandez de l'aide à un LLM local !

Utiliser des services gérés comme Github Copilot est super pratique, mais cela peut être
coûteux (~100$/an) et pas adapté lorsque vous développez dans des environnements à bande passante limitée. 🐌

Pour surmonter ces défis, si vous êtes un heureux propriétaire d'une puce Apple M2 ou M3,
vous aurez suffisamment de puissance de calcul pour exécuter un LLM local, avec des poids de 1 à 3B.

Heureusement, l'architecture ARM de la puce nous évitera également de vider complètement la
batterie à vitesse grand V. 🔋

Pour ce faire, avant votre première session hors ligne, rendez-vous sur la [documentation de tabby](https://tabby.tabbyml.com/docs/quick-start/installation/apple/),
un framework qui rend disponible les LLM locaux aux serveurs LSP

Installez tabby et lancez-le avec :

```sh
tabby serve --port 8889 --device metal --model StarCoder-1B --chat-model Qwen2-1.5B-Instruct
```

Utilisez le plugin sur l'<cite> IDE [^2] </cite> de votre choix, par exemple `vim-tabby` sur neovim,
avec quelques configurations pour ne pas entrer en conflit avec la configuration de Copilot :

[^2]: L'équipe Tabby a également développé des plugins pour Visual Studio Code, IntelliJ. Consultez la [documentation](https://tabby.tabbyml.com/docs/extensions/troubleshooting/).

Configuration Lazy.nvim :

```lua
return {
	"TabbyML/vim-tabby",
	lazy = false,
	dépendances = {
		"neovim/nvim-lspconfig",
	},
	init = function()
		vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
		vim.g.tabby_inline_completion_trigger = "manual"
		vim.g.tabby_inline_completion_keybinding_accept = "<leader>%"
	end,
}
```

et utilisez leader + % pour accepter l'autocomplétion de tabby à partir du LLM.

Si vous êtes plus à l'aise avec une interface de chat, rendez-vous sur [http://0.0.0.0:8889/](http://0.0.0.0:8889/) pour
utiliser l'application web de chat ! 💬

Voici un résultat sur la fonction fibonacci :

![tabby_suggestions](tabby.png#center)

Pas mal du tout !

## Conclusion

Aller hors ligne est toujours une occasion de réaliser une bonne session de Deepwork, même si la connexion réseau n'est pas si bonne.
Cela ne signifie pas que vous devez échouer à chaque problème et essayer de le déboguer sans documentation.

C'est un excellent moyen de <cite> _se tenir sur les épaules des géants_[^3] </cite>, des tonnes de développeurs ont essayé de fournir la documentation la plus
efficace, RTFM. Et de nos jours, avoir un copilote est un excellent moyen d'obtenir des suggestions de code précises, ne sous-estimez pas cette
force !

[^3]: Le savoir est cumulatif, [wikipedia](https://fr.wikipedia.org/wiki/Des_nains_sur_des_%C3%A9paules_de_g%C3%A9ants)
