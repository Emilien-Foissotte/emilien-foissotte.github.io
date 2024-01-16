---
title: "Optimisation, 1984 et Algorithmes Génétiques"
description: ""
cover:
    image: "coverfr.png"
    alt: "DNA Genetic Engineering Big Brother Stable Diffusion"
    relative: true
date: 2023-10-07T09:01:23+02:00
publishDate: 2024-01-16T07:00:00+01:00
draft: true
tags: [Machine Learning, Python]
ShowToc: true
TocOpen: false
---

# TL;DR

Dans ce billet de blog, nous allons utiliser et étudier le
fonctionnement des algorithmes génétiques, pour résoudre un problème
d'optimisation. Ce problème hypothétique prendra corps dans la narration
de George Orwell et de son roman dystopique 1984. Nous verrons les 
concepts généraux de ce genre de problème et essaierons de les appliquer
à notre situation.

Ainsi, vous serez à même vous aussi, d'utiliser les si puissants 
algorithmes génétiques dans vos problèmes d'optimisation.

C'est parti !

## Intro

Il y a quelques années, j'étais tombé sur un excellent billet de <cite>blog[^1]</cite>,
de Max Halford qui évoquait un type d'algorithme connu pour être très puissant dans 
le cas où l'objectif du problème posé pouvait changer assez rapidement 🎯

L'auteur avait expliqué à merveille le fonctionnement sur un cas 
mathématique (trouver les coefficients d'une fonction polynomiale).
Tout le fonctionnement de ce genre d'algorithme puise 
ses concepts fondamentaux dans la théorie de l'évolution du Darwinisme 🧬

Ayant toujours été séduit par la biologie et l'étude du vivant (je vous 
conseille par ailleurs cet excellent <cite>podcast[^2]</cite> qui explore le thème 
de la compétition dans nos vies,
cela m'a semblé être un excellent sujet à creuser sur un billet de blog ! 💡


J'ai récemment eu la chance de lire de nouveau, le très dystopique
**1984** de George Orwell adapté en [bande dessinée](https://www.fnac.com/a15640726/George-Orwell-1984)
, un chouette cadeau de départ de mes collègues de chez SITA. 👁️


À la relecture des lignes glaçantes du roman, une idée de situation où 
ce genre d'algorithme pourrait survenir m'est venue à l'esprit.
Comme vous pouvez vous y attendre avec le thème du roman, l'histoire
ne sera pas joyeuse ni merveilleuse, mais elle démontrera très bien l'intérêt
de ce genre d'algorithme évolutif. ⚙️

Faisons un peu de place à la narration.. 

La narration ne vous intéresse pas ? 
Rendez-vous [ici](#rapide-bilan-de-linterrogatoire-à-mener) pour le détail
mathématique du problème à résoudre ! 🚀

### Par un froid matin d'hiver..

![walking](story_illustrations/coldmorning.png#center)

Le froid vous glace les poumons mais n'empêche pas vos nombreuses 
pensées de tourner à toute vitesse dans votre tête, à l'abri des 
regards de Big Brother, pour l'instant..


Ces derniers mois le régime en place, l'IngSoc lutte toujours contre
les dissidents de la Résistance. Les hommes de l'ombre, menés par 
Goldstein cherchent toujours à assassiner Big Brother, le dirigeant
suprême du pays. 

Quelques semaines plus tôt, vous avez entendu l'annonce au __télécran__
de l'arrestation de Winston Smith et de plusieurs autres fauteurs de trouble.

Lors de l'annonce de la nouvelle, cela vous avait relativement surpris, 
car Winston Smith était un membre sérieux du parti. Mais peu importe, 
depuis le travail au Ministère de la Vérité vous occupait constamment et
vous n'aviez pas le temps de penser à quoi que ce soit d'autres que toutes ces 
informations à ré-actualiser à la gloire du régime. 

Le bâtiment du Ministère apparaît à l'angle de la rue, il est temps de 
se ressaisir pour qu'aucun des agents ne remarque ces pensées dissidentes
sur votre visage...

![building](story_illustrations/ministry.jpg#center)

Étonnamment l'atmosphère morose ce matin dans le département laissait place 
à une frénésie qui plane dans l'air.

Les télécrans annonçait tous que la veille la police de la pensée avait effectué 
une descente à quelques blocs d'ici, et un grand nombre de dissidents 
avaient été arrêtés, mais personne ne savait encore le nombre exact !  

Une fièvre houleuse agitait les esprits et la rumeur courait dans les couloirs
du ministère. Une série de groupes murmurants et lançant des regards tantôt accusateurs, 
tantôt effrayés, s'égrainent au fur et à mesure des angles des longs corridors.

Le venin de la peur commençait à instiller son poison dans tous les départements du Ministère,
pas un agent n'avait pu manquer la nouvelle..

A peine passé les portiques de sécurité du bâtiment, vous apercevez une 
grosse berline s'arrêtant devant le bâtiement. Sur le capot le logo de la Police de la
pensée jeta un froid et fit taire tous les chuchotements. 

Un grand personnage, le chef de la Police ouvrit la porte et au même instant, 
une voie stridente annonçait une réunion d'urgence à tout le Ministère dans les hauts-parleurs.

Tout le bâtiment se dirigeait désormais dans un mutisme glaçant vers l'immense 
assemblée du ministère, seuls quelques regards furtifs d'angoisse 
transperçent la sombre masse humaine, dans sa longue marche silencieuse vers la grande salle.

Après un bref silence, quelques phrases sont jetées à l'audience,
déguisées de **Double Pensée** rendant l'ensemble difficile à comprendre pour 
tout non initié. 

Mais très vite votre oreille aguerrie attrappe des noms de code que vous reconaissez
entre les lignes, vous comprenez qu'il s'agit du fruit de votre travail..

![announcement](story_illustrations/announcement.png#center)

Quel cauchemar, il ne pouvait arriver pire évènement..

Votre sang ne fait qu'un tour, le dossier sur lequel vous étiez en train de 
travailler depuis des semaines a donc porté ses fruits. Les dissidents que 
vous traquiez sont tombés, mais dans quelles circonstances..

Le doute vous ronge, est-ce que votre couverture est grillée ?

Mais c'est extrêmement délicat et loin d'être une bonne nouvelle. 

Très vite vous comprenez que cela va être à vous d'organiser
les interrogatoires. Mission très dangereuse, de nombreux agents ont disparus
ces derniers mois après avoir assumé cette lourde responsabilité. 

À la moindre erreur, on peut croire que vous travaillez pour l'ennemi, et vous 
faire disparaître à votre tour.

Votre intuition ne vous avait pas trompée, après avoir fini d'aboyer 
ses ordres frénétiques et dégoulinants de haine, le supérieur croise votre regard.

Il désigne de son regard la salle du poste de commandement, dans l'arrière du Ministère
et par le langage codé du Parti, vous indique de le rejoindre.

![backroom](story_illustrations/backroom.jpg#center)

En passant sur le seuil de la porte, une sueur froide coule dans votre dos.

"Bravo Matthew, votre travail va permettre d'arrêter un grand nombre 
de dissidents sur le point de commettre une série d'attentats sur l'IngSoc. 
Big Brother est très fier de vous." commence par vous asséner le haut cadre.

Étonnamment il semble de bonne humeur.

Fièrement il continue :
"Hier, nous avons arrêté 30 résistants hautement armés.
Ils sont désormais désarmés et à notre merci, bravo pour votre travail." 


Sans prévenir, il se met alors à hurler
"Comment avez-vous pu manquer que lors de leur entraînement,
ils n'ont appris à ne communiquer qu'en langage crypté !"

Il continue, d'un regard inquisiteur : " Tous les plans 
pour emprisonner ces individus sont foutus. Il faut tout refaire avant leur
transfert. C'est votre mission, je veux les plans de la prison
pour les transmettre au Ministère de la Vérité d'ici 3 heures."

![order](story_illustrations/order.png#center)

D'un doigt furieux, il vous tance

"Toute communication 
entre les membres de cette poche de résistance leur permettrait de construire
un récit crédible, c'est le seul point faible de la double pensée.

Vous devez les faire parler et empêcher au maximum les échanges entre eux."


Tout tourne très vite dans votre tête, pour essayer de recoller 
les morceaux de votre mission. Cela va être compliqué, il y a 
plein de paramètre à prendre en compte, le nombre d'individus, le nombre
de langages cryptés, le nombre de cellules..

La tâche est immense.

Il faut faire appel au experts du Ministère du Désapprentissage Machine
et leurs algorithmes si puissants..

![thinking](story_illustrations/thinking.png#center)

Hier, le parti a arrêté 30 hommes armés. Ils font partis des unités d'élite
de Goldstein que vous connaissez bien. Ils sont organisés en escouade plus 
petites, qui savent communiquer en langage chiffré. 

Chaque escouade a accès à certaines informations que les autres escouades n'ont
pas, mais les membres d'autres escouades peuvent comprendre le langage chiffré
des autres escouades. Heureusement ils ne peuvent pas le parler, simplement 
le comprendre. 

Vous allez devoir emprisonner ces hommes au Ministère de la Vérité, 
où heureusement les cellules sont équipées de brouilleurs de communications. 

Attention, les brouilleurs ne peuvent perturber qu'un seul type de langage
à la fois et les cellules ont une capacité limité, et ne peuvent 
pas brouiller tous les types de communications..

Vous devez à tout prix éviter que les escouades communiquent entre elles, 
et mettre en prison le maximum d'hommes. 

Vous savez que si les cellules ne sont pas assez grandes, vous 
pouvez mettre des dissidents dans la cour de promenade du Ministère, 
mais comme il n'y a pas de brouilleurs, vous ne pourrez empêcher les 
membres des escouades de parler entre eux. Toute informations sera donc 
perdue. 

![cell](story_illustrations/crowded_cell.png#center)

Il vous faut agir vite et trouver un plan d'organisation pour mener ces 
interrogatoires. Votre vie en dépend Matthew.

## Rapide bilan de l'interrogatoire à mener

- Une arrestation de 30 hommes a été menée hier

- Ces 30 hommes sont organisés en escouades, des sous-unités plus 
petites de différentes tailles chacunes. `Escouade_0`, `Escouade_1`..

- Chaque escouade parle un langage chiffré, et comprend le langage chiffré
des autres. Elle ne peut cependant pas le parler. 

- Vous avez à votre disposition une liste de Cellules, `Cellule_0`, 
`Cellule_1`, `Cellule_2` ...

- Chaque cellule peut brouiller un langage chiffré, parmi un nombre 
pré-déterminé de langage, différents pour chacune des cellules. 

- Pour mener à bien les interrogatoires, chaque cellule doit contenir des 
membres que d'une seule escouade afin de brouiller toutes communications. 

- Chaque cellule peut contenir un nombre pré-défini de prisonniers. 

- Si un prisonnier échange une information cryptée, alors son interrogatoire
est corrompu et toute information est perdue. 

- En cas de manque de place dans les cellules, vous disposez de la cour
de promenade, un lieu non brouillé. Tout homme qui y est placé pourra 
échanger avec les autres, ainsi son information sera perdue..

Objectif : Vous devez maximiser l'information récupérée, au nom de
Big Brother.  

## Conversion en un problème matriciel

Pour faciliter les manipulations, il est possible de représenter notre
problème en une matrice. 

Pour stocker l'information, nous allons utiliser une matrice dont chaque
ligne représente une cellule et chaque colonne une escouade. 

La dernière ligne sera un peu spéciale car elle contiendra la cour de 
promenade.

Pour illustrer le propos, prenons un exemple : 

Nous avons arrêté 4 escouades. Voici la liste issue du bulletin 
d'arrestation, avec le nombre de membres par escouade :

```md
- escouade 1 : 5
- escouade 2 : 8
- escouade 3 : 6
- escouade 4 : 6
```

Vos collègues du Ministère de l'Amour viennent de vous transmettre la 
configuration des cellules d'interrogatoire.

|  Cellule  | Brouillage | Capacité   |
|-----------|------------|------------|
| Cellule 1 |  1 / 3     | 3          |
| Cellule 2 |  3 / 4     | 4          |
| Cellule 3 |  2 / 4     | 4          |
| Cellule 4 |  1 / 4     | 6          |

Une première solution pour incarcérer et interroger tous
ces renégats serait cette disposition : 

|  Cellule  | Escouade 1 | Escouade 2 | Escouade 3 | Escouade 4 |
|-----------|------------|------------|------------|------------|
| Cellule 1 | 0          | 0          | 3          | 0          |
| Cellule 2 | 0          | 0          | 0          | 4          |
| Cellule 3 | 0          | 0          | 0          | 2          |
| Cellule 4 | 5          | 0          | 0          | 0          |
| Cour      | 0          | 8          | 3          | 0          |


En disposant ainsi les différents prisonniers, vous 
allez récupérer l'information de 14 prisonniers, mais
comme 11 d'entre eux sont dans la cour de promenade, 
ils ne seront pas surveillés et vous allez perdre toute
information de ces 11 sources. 


Avec un peu plus de réflexion, vous vous rendez compte
qu'une disposition pourrait maximiser encore plus
l'information récupérer. 

En terme d'optimisation, il s'agit ici de minimiser 
le nombre de prisonniers dans la cour de promenade (cela
équivaut à maximiser le nombre de prisonniers en cellule).

Voici une solution plus optimale que la précédente :

| Cellule   | Escouade 1 | Escouade 2 | Escouade 3 | Escouade 4 |
|-----------|------------|------------|------------|------------|
| Cellule 1 | 3          | 0          | 0          | 0          |
| Cellule 2 | 0          | 0          | 4          | 0          |
| Cellule 3 | 0          | 4          | 0          | 0          |
| Cellule 4 | 0          | 0          | 0          | 6          |
| Cour      | 2          | 4          | 2          | 0          |

Mais est-ce la meilleure des solutions ? À l'évidence, 
elle est meilleure que la précédente, mais existe-t-il 
une solution possible pour laquelle on pourrait récupérer 
plus d'informations ?


C'est exactement cette recherche d'optimum locaux que 
va effectuer un algorithme génétique !

## Passons aux algorithmes génétiques

### Définir la fonction objectif

Les algorithmes génétiques sont une manière de résoudre des problèmes
d'optimisation, souvent trop complexes pour se permettre de trouver
une solution exacte en un temps raisonnable. On peut penser au problème
NP-difficile du voyageur de commerce par exemple. 

Ici, dans le cadre de ce problème, l'optimisation est basée sur la 
maximisation du nombre de prisonniers en cellule, et donc par équivalent 
la minimisation du nombre de renégats dans la cour de promenade.

La fonction objectif est donc la somme des coefficients de la ligne 
associée à la cour. Le but est de minimiser cette quantité. 

La puissance des algorithmes réside dans la rapidité d'évaluation de 
la fonction objectif, dans le sens où c'est quelque chose qui va être
effectué un grand nombre de fois.

### Description du processus évolutionnaire


Les différentes étapes de fonctionnement sont les suivantes. Nous ferons
le parallèle avec un code orienté objet par la suite pour illustrer 
les différentes méthodes. 

- Premièrement, un ensemble d'individus est généré au hasard. Chaque 
individu est décrit intégralement par l'ensemble de ses gènes, 
l'équivalent de l'ADN dans le domaine de la biologie. Chaque gène encode
une fonctionnalité particulière, ici on peut définir chaque gène `X_ij` comme
étant le nombre de prisonniers de l'escouade `j` dans la cellule `i`. Notez
que la représentation matricielle du problème équivaut ainsi à représenter
l'ADN.

- Ensuite, on va sélectionner chaque individu et évaluer sa performance
grâce à la fonction objective. La population est ensuite triée en fonction
de sa performance, pour simuler "la sélection naturelle". 

- Un sous-ensemble des meilleurs individus est sélectionné. Il y a différentes
manières de sélectionner les individus, on peut prendre par exemple le 
système de sélection par roulette, où les meilleurs individus ont 
plus de chance d'être sélectionné.

- On croise les différents individu en altérant leur ADN, soit au 
sein d'un même individu soit en croisant l'ADN de 2 individus performants. 

- Ce nouveau pool d'individus est ainsi utilisé et évalué pour
recommencer une nouvelle itération d'évolution. 

- On recommence le processus jusqu'à une condition d'arrêt, qui peut-être
soit la stagnation de la performance des candidats, soit un nombre de 
générations donnés (i.e on s'arrête à la 500 ème génération d'individus) ou 
alors on peut essayer de fixer un critère quantitatif sur la fonction objectif,
dès qu'un individu atteint cette performance, on s'arrête (ce qui peut ne 
jamais arriver).

![process](schema_ga.jpg#center)

### Encoder une manière d'altérer l'ADN

Classiquement en biologie, on parle de deux types de modifications bien
connues de l'ADN :

- **La mutation** : un processus aléatoire qui modifie une portion d'un gène
et vient altérer son fonctionnement, qui arrive lors de la réplication de
l'ADN. Ce processus peut alors engendrer une modification du comportement
de l'individu, pouvant conférer un avantage évolutif ou non. 

![mutation](http://www.lewrockwell.com/assets/2014/07/12.png#center)

- **Le croisement**: Ce processus, mélange classiquement lors de la 
reproduction les gènes de 2 individus parents A et B, pour former un 
nouvel individu, C. L'individu C peut alors bénéficier des avantages 
évolutifs du parent A et du parent B, et cela peut créer des effets 
inattendus liés au croisement des gènes. 

![crossover](https://genetics.thetech.org/sites/default/files/CrossOver.gif#center)

## Et les algorithmes dans tout ça ?

Rien de plus adapté qu'un ordinateur pour générer un grand nombre
d'éléments aléatoires et d'effectuer de multiples fois des
calculs mathématiques pour évaluer la fonction objectif. 

Encodons tout ça. 

Nous allons utiliser les objets Python pour générer nos éléments. 

Représentons le problème sous la forme d'un dictionnaire de contraintes
simple : 
- **Ci** : Représente nos cellules (Cell_i), seule 'Courtyard' est mise de 
côté comme étant la cour de promenade.
- **Si**: Représente nos escouades (Squad_i).
- **compatibility** : Cette clé croise la compatibilité de brouillage
entre les cellules et le langage codé de chaque escouade. 
- **capacity** : Cette clé relie la quantité maximale de prisonniers
que chaque squad peut stocker.
- **consumption** : Cette clé contient le nombre de rebelle arrêté 
par escouade
- **squads**: Cette clé contient la liste des escouades
- **cellules** : Cette clé contient la liste des cellules

Voici la représentation de notre problème précédent :

Pour des raisons évidente, je vais développer 
les différents snippets en anglais

```python
problem = {
    "compatibility": {
        "C1": ["S1", "S3"],
        "C2": ["S3", "S4"],
        "C3": ["S2", "S4"],
        "C4": ["S1", "S4"],
        "courtyard": ["S1", "S2", "S3"],
    },
    "capacity": {"C1": 3, "C2": 4, "C3": 4, "C4":6, "courtyard": "1000"},
    "arrest": {
        "S1": 5,
        "S2": 8,
        "S3": 6,
        "S4": 6
    },
    "squads": ["S1", "S2", "S3", "S4"],
    "cells": ["C1", "C2", "C3", "C4", "courtyard"],
}
```

_NB: 1000 est simplement utilisé comme une valeur arbitrairement haute._

### Générer des individus

Maintenant la principale étape consiste à générer 
une générations d'individus qui pourrait répondre aux contraintes
du problème. 

Pour commencer, initions un objet qui va représenter cet individu. 

L'idée de cette méthode va être de répartir au hasard les différents 
membres de chaque squad dans les cellules


```python
class matIndividual:
    def __init__(self, problem):
        # loading all problems elements
        self.compatibility = deepcopy(problem["compatibility"])
        self.capacity = deepcopy(problem["capacity"])
        self.toimprison = deepcopy(problem["arrest"])
        arrested = 0 
        for key in problem["arrest"].keys():
            arrested+=problem["arrest"][key]
        self.arrested = arrested
        self.squads = deepcopy(problem["squads"])
        self.squad2indice = {squad: i for i, squad in enumerate(self.squads)}
        self.cell_list = problem["cells"]
        self.cell2indice = {cell: i for i, cell in enumerate(self.cell_list)}
        self.cell2choice = {cell: None for cell in self.cell_list}
        del self.cell2choice["courtyard"]
        # reverse compatibility between cells and squads
        self.rev_compatibility = self.make_revcompatibility(self.compatibility)

        self.state = np.zeros((len(self.cell_list), len(self.squads)))
        rand_cell_list = deepcopy(list(self.cell_list[:-1]))
        rand.shuffle(rand_cell_list)
        # initialize the cells with a random value
        for cell in rand_cell_list:
            # fix squad
            squad = random.choice(problem["compatibility"][cell])
            self.cell2choice[cell] = squad
            cell_line = np.zeros( (1, len(self.squads)))
            # define max quantity for cell as min of his own capacity and remaining arrested number in the squad
            max_qty = min(self.toimprison[squad], self.capacity[cell])
            qty = random.randint(0, max_qty)
            #print(f"cell {cell} holds squad {squad}, {qty}/{max_qty} units.")
            cell_line[0][self.squad2indice[squad]] = qty

            self.state[self.cell2indice[cell]] = cell_line
            self.toimprison[squad] -= qty
        # compensate with courtyard for possible remaining squads members 
        courtyard_line = np.zeros( (1, len(self.squads)))
        for squad in self.squads:
            courtyard_line[0][self.squad2indice[squad]] = self.toimprison[squad]
        self.state[self.cell2indice["courtyard"]] = courtyard_line

    def make_revcompatibility(self, compatibility):
        """
        Creates the reverse compatibility of Squad --> Cell
        from Cell --> Squad
        """
        rev_compat = {}
        for squad in self.toimprison.keys():
            rev_compat[squad] = []
            for cell, squads_list in compatibility.items():
                if squad in squads_list:
                    rev_compat[squad].append(cell)
        return rev_compat
```

Créons un individu, au hasard, à partir de 
l'objet plus haut et de notre problème

Et voici un exemple d'individu, généré au hasard :
```python
>>> i1 = matIndividual(problem=problem)
>>> i1.state
array([[0., 0., 1., 0.],
       [0., 0., 0., 4.],
       [0., 4., 0., 0.],
       [2., 0., 0., 0.],
       [3., 4., 5., 2.]])
```
### Les évaluer

Maintenant, il faut désormais implémenter la fonction objectif qui
va nous permettre d'évaluer la performance d'un individu donné. 

Pour cela, rien de plus, on va pouvoir ajouter cette fonction 
sur la classe Objet de notre individu : 

```python
def evaluate(self):
    # The objective function is the amount of prisoners in cells
    self.fitness = 0
    sum = self.state[self.cell2indice["courtyard"]].sum()

   self.fitness = self.arrested - sum
```

Évaluons l'individu précédémment généré :

```python
>>> i1.evaluate()
>>> i1.fitness
11
```

### Générer une population entière

Pour agréger une population d'individus, rien de plus
simple, je vais créer une classe avec un nouvel Objet.

```python
class matPopulation:
    def __init__(self, problem, size=100, rate_prop=0.5, rate_amount=1):
        # Create individuals
        self.individuals = []
        for i in range(size):
            self.individuals.append(matIndividual(problem=problem))
            #print(f"created {i} individuals")
            #print(f"generated in individual {i}")
        self.individuals = [matIndividual(problem=problem) for _ in range(size)]
        # Store the best individuals
        self.best = [matIndividual(problem)]
        # Mutation rate
        # self.base_rate = rate
        self.rate_prop = rate_prop
        self.rate_amount = rate_amount
        

    def sort(self):
        self.individuals = sorted(self.individuals, key=lambda indi: indi.fitness, reverse=True)

    def evaluate(self):
        for indi in self.individuals:
            indi.evaluate()
```

Voici la génération de 100 individus et l'affichage du plus 
performant d'entre eux :

```python
>>> size=100
>>> jail_fillings = matPopulation(size=size, problem=problem)
>>> jail_fillings.evaluate()
>>> jail_fillings.sort()
>>> jail_fillings.individuals[0].state
array([[0., 0., 2., 0.],
       [0., 0., 4., 0.],
       [0., 3., 0., 0.],
       [0., 0., 0., 6.],
       [5., 5., 0., 0.]])
```

### Créer des mutations


Pour créer des mutations, rien de plus simple

Il suffit de déplacer, au hasard des prisonniers depuis
la cour (censée avoir une capacité illimitée de prisonniers)
ou vers la cour. 

Afin de maximiser l'exploration des individus possibles, on va aussi 
laisser la possibilité aux mutations de réinitialiser le choix d'une cellule
en déplaçant tous les détenus vers la cour de promenade. Afin de limiter la
pénalité de ce choix, on va ensuite venir, si c'est possible, rapatrier 
des détenus en cour de promenade dans la cellule, dans la limite du possible.

Voici le flowchart des possibilités

{{<mermaid>}}

flowchart TD
    S0[Original </br> Individual] -->|For each cell </br> influenced by rates| C{Mutation type </br> applied }
    C --> D[Move prisoners from </br> cell to courtyard]
    C --> E[Move prisoners from </br> courtyard to cell]
    C --> F[Move all prisoners from </br> cell to courtyard, </br> and move in other squad to Cell]

{{</mermaid>}}

Chaque condition de mutation est évaluée pour s'assurer que les contraintes
du problème sont respectées.

Voici le snippet de génération du nouvel individu muté 

```python
def mutate(self, rate_amount, rate_prop):
        """
        Create a mutated individual from this base individual.

        Args:
            rate_amount: Apply a percentage of amount of value to increase the amount of change in cells population
            rate_prop: Apply a percentage of coverage of cell that might be mutated

        Returns:
           Logs of mutated individual

        """
        # move out or move in some prisoners with courtyard
        # rate_amout change the amout of prisoners than can be exchanged
        # rate prop is the amount of cells that are choosen randomely for modification
        rand_cell_list = deepcopy(list(self.cell_list[:-1]))
        rand.shuffle(rand_cell_list)
        logs = []
        for i in range(int(len(rand_cell_list) * rate_prop)):
            cell = rand_cell_list[i]
            squad = self.cell2choice[cell]
            amount_in_cell = self.state[self.cell2indice[cell]][
                self.squad2indice[squad]
            ]
            # amount_in_courtyard = self.state[self.cell2indice["courtyard"]][self.squad2indice[squad]]

            choices = ["in", "out", "reset_choice"]

            choice = random.choice(choices)
            logs.append(f"Mutation cell {cell} containing squad {squad} - event {choice}")

            if choice == "out":
                # print(f"move out from cell {cell}, squad {squad}, amount {amout_in_cell}/{self.capacity[cell]}, courtyard {amount_in_courtyard}")
                # move out matter from cell to courtyard
                left_courtyard_capa = int(self.capacity["courtyard"]) - int(
                    self.state[self.cell2indice["courtyard"]].sum()
                )
                max_amount = min(amount_in_cell, left_courtyard_capa)
                min_amount = 0
                if max_amount > min_amount:
                    qty_to_move_out = random.randint(
                        min_amount, int(max_amount * rate_amount)
                    )
                    self.state[self.cell2indice[cell]][
                        self.squad2indice[squad]
                    ] -= qty_to_move_out
                    self.state[self.cell2indice["courtyard"]][
                        self.squad2indice[squad]
                    ] += qty_to_move_out
                    # print(f"Quantity to move {qty_to_move}")
                    logs.append(
                        f"Moving out {qty_to_move_out} of squad {squad} from cell {cell} to courtyard"
                    )
            elif choice == "in":
                # move in matter from courtyard to cell
                left_cell_capa = (
                    self.capacity[cell] - self.state[self.cell2indice[cell]].sum()
                )
                amount_in_courtyard = self.state[self.cell2indice["courtyard"]][
                    self.squad2indice[squad]
                ]
                max_amount = min(amount_in_courtyard, left_cell_capa)
                min_amount = 0
                if max_amount > min_amount:
                    qty_to_move_in = random.randint(
                        min_amount, int(max_amount * rate_amount)
                    )
                    self.state[self.cell2indice["courtyard"]][
                        self.squad2indice[squad]
                    ] -= qty_to_move_in
                    self.state[self.cell2indice[cell]][
                        self.squad2indice[squad]
                    ] += qty_to_move_in
                    logs.append(
                        f"Moving in {qty_to_move_in} of squad {squad} from courtyard to cell {cell}"
                    )
            elif choice == "reset_choice":
                # move out all matter from cell to courtyard, and take in from other squad in courtyard
                # first, move out all prisoners to courtyard
                left_courtyard_capa = int(self.capacity["courtyard"]) - int(
                    self.state[self.cell2indice["courtyard"]].sum()
                )
                if left_courtyard_capa >= amount_in_cell:
                    qty_to_move_out = int(amount_in_cell)
                    self.state[self.cell2indice[cell]][
                        self.squad2indice[squad]
                    ] -= qty_to_move_out
                    self.state[self.cell2indice["courtyard"]][
                        self.squad2indice[squad]
                    ] += qty_to_move_out
                    logs.append(
                        f"Reset out, Moving out {qty_to_move_out} of squad {squad} from cell {cell} to courtyard"
                    )
                # check if compatibility squads have elements in courtyard
                compatible_squads = deepcopy(self.compatibility[cell])
                compatible_squads.remove(squad)
                if len(compatible_squads) > 0 :
                    new_squad = random.choice(compatible_squads)
                    squad = new_squad
                    self.cell2choice[cell] = squad
                    # move in some data if possible
                    left_cell_capa = self.capacity[cell]
                    amount_in_courtyard = self.state[self.cell2indice["courtyard"]][
                        self.squad2indice[squad]
                    ]
                    max_amount = min(amount_in_courtyard, left_cell_capa)
                    min_amount = 0
                    qty_to_move_in = random.randint(
                        min_amount, int(max_amount * rate_amount)
                    )
                    self.state[self.cell2indice["courtyard"]][
                        self.squad2indice[new_squad]
                    ] -= qty_to_move_in
                    self.state[self.cell2indice[cell]][
                        self.squad2indice[squad]
                    ] += qty_to_move_in
                    logs.append(
                        f"Reset in, Moving in {qty_to_move_in} of squad {squad} from courtyard to cell {cell}"
                    )
            logs.append(" -- ")
        return logs
```

Étudions un individu muté.
On va utiliser un taux de mutation en proportion de 50%, c'est à dire qu'on
va pouvoir déplacer jusqu'à 50% des prisonniers d'une cellule pour les 
placer ailleurs (ou la moitié de l'escouade présente s'il s'agit de la 
cour de promenade).

On va utiliser un taux de mutation en quantité de 100%, 
c'est à dire que toutes les cellules vont pouvoir être re-distribuées 
aléatoirement.

Mettons ça en pratique ! 

Initialement, 
on génère un individus

```python
>>> i_origin = matIndividual(problem=problem)
>>> i_origin.state
array([[0., 0., 2., 0.],
       [0., 0., 0., 4.],
       [0., 3., 0., 0.],
       [0., 0., 0., 0.],
       [5., 5., 4., 2.]])
>>>i_origin.evaluate()
>>>i_origin.fitness
9
```

Avec cet individu,9 prisonniers sont en cellule seulement, pas terrible..

Effectuons une mutation 

```python
>>> i_new = deepcopy(i_origin)
>>> i_new.mutate(rate_prop=0.5, rate_amount=1)
>>> i_new.evaluate()
>>> i_new.state
array([[0., 0., 2., 0.],
       [0., 0., 0., 4.],
       [0., 3., 0., 0.],
       [0., 0., 0., 1.],
       [5., 5., 4., 1.]])
>>> i_new.fitness
10
```

Le nouvel individu généré est un peu plus performant, 
pas mal! 

_NB: On semble permettre d'empirer la situation en 
transferant des prisonniers de la cellule vers la cour 
mais c'est pour permettre les transferts entre cellules, parfois 
il vaut mieux perdre un peu en performance pour ne pas se retrouver bloqué
dans un optimum local._

### Recombinons les individus

L'idée désormais est de mélanger un individu à un autre, afin
de permettre le mélange des gènes de 2 individus performants
pour créer un individus enfant ayant les attributs de l'un et
de l'autre des parents.

L'idée derrière ce snippet de choisir aléatoirement pour chaque cellule
s'il la récupère de l'individu parent 1 ou de l'individu parent 2. 

La cour fera office d'élément compensateur s'il y a des prisonniers qui ne peuvent
pas se retrouver dans la cellule (prisonniers en trop ou en moins), 
alors on les ajoutera ou on les prendra depuis la cour, si c'est possible.

Si ça n'est pas possible alors on ne fait pas le croisement. 

Voici le flowchart du Feature Crossing 

{{<mermaid>}}

flowchart TD
    S0[Parent </br> Individual 1] --->|Originating invidivual </br> for each cell </br> influenced by rates| C{Feature Crossing </br>type applied}
    S1[Parent </br> Individual 2] -->|Considered for mixin| C
    C --> D[Take prisoners from Parent 1]
    C --> E[Take prisoners from Parent 2 </br> Compensate difference with Courtyard]

{{</mermaid>}}

```python
def crossover(self, mixinInd, rate_prop):
    """
    Create a crossover individual, based on object and other parent.
    Args:
        mixinInd: Other individual to mix in to create the child individual
        rate_prop: Percentage to apply to increase the chance that individual get mixed up

    Returns:
       An individual resulting from the crossover
    """
    # to crossover features between cells, take randomely a cell
    # from one individual and the other cell from mix in individual
    rand_cell_list = deepcopy(list(self.cell_list[:-1]))
    rand.shuffle(rand_cell_list)
    logs = []
    for i in range(int(len(rand_cell_list) * rate_prop)):
        cell = rand_cell_list[i]
        choice = random.choice(["self", "other"])
        if choice == "other":
            logs.append(f"Crossover {cell} - {choice}")
            old_cell = self.state[self.cell2indice[cell]]
            new_cell = mixinInd.state[mixinInd.cell2indice[cell]]
            diff_quantities = old_cell - new_cell
            projected_courtyard = (
                self.state[self.cell2indice["courtyard"]] + diff_quantities
            )
            logs.append(
                f"New {new_cell} - Old {old_cell} - Diff {diff_quantities} - CW {projected_courtyard}"
            )
            # courtyard must always be above zero, constraint
            test_above_zero = projected_courtyard >= np.zeros(
                (1, len(projected_courtyard))
            )
            test_below_capa = projected_courtyard.sum() < self.capacity["courtyard"]
            if test_above_zero.all() and test_below_capa:
                self.state[self.cell2indice[cell]] = new_cell
                self.state[self.cell2indice["courtyard"]] = projected_courtyard
    return logs
```


Prenons un cas d'exemple pour clarifier le fonctionnement !

```python
>>> i1 = matIndividual(problem=problem)
>>> i1.evaluate()
>>> i1.fitness
8
>>> i1.state
array([[0., 0., 0., 0.],
       [0., 0., 1., 0.],
       [0., 0., 0., 2.],
       [5., 0., 0., 0.],
       [0., 8., 5., 4.]])
```

Voici notre premier parent généré.

Créons en un deuxième: 

```python
>>> i2 = matIndividual(problem=problem)
>>> i2.evaluate()
>>> i2.fitness
9
>>> i2.state
array([[0., 0., 1., 0.],
       [0., 0., 4., 0.],
       [0., 0., 0., 2.],
       [2., 0., 0., 0.],
       [3., 8., 1., 4.]])
```

Et mainteant l'individu enfant `i3`, issu du crossover
entre l'individu `i1` et `i2` :

```python
>>> i3 = deepcopy(i2)
>>> i3.crossover(mixinInd=i1, rate_prop=1)
>>> i3.state
array([[0., 0., 1., 0.],
       [0., 0., 4., 0.],
       [0., 0., 0., 2.],
       [5., 0., 0., 0.],
       [0., 8., 1., 4.]])

>>> i3.fitness
12
```

Incroyable ! Notre individu est plus performant que 
ses 2 parents ! 

Étudions de près ce qu'il s'est passé. Initialement, 
les gènes sont pré-remplis avec les cellules 
de l'individu `i2`.

Lors du processus, la cellule 4 est échangée avec celle de 
l'individu `i1`. 

Voici le log associé :
```
Crossover C4 - other
New [5. 0. 0. 0.] - Old [2. 0. 0. 0.] - Diff [-3.  0.  0.  0.] - CW [0. 8. 1. 4.]
```

Les 3 individus manquant étaient récupérables depuis la cour de promenade. 
C'est un gain de fitness de `3` ! 

## Et ainsi va l'évolution.. 

Maintenant que nous avons une manière de générer de nouveau individus et
enrichir notre population de base, il faut choisir une méthode pour 
sélectionner les meilleurs d'entre eux sans tomber dans un local-optimal. 

Il faut faire la balance entre l'exploration des solutions possibles et la rapidité
de convergence vers une bonne solution.

### Sélectionner des individus

#### Sélection par tournoi

Nous allons nous pourrions implémenter la sélection par tournoi, qui sélectionne
au hasard un nombre d'individus, et conserve le meilleur d'entre eux. 

Cela élimine une partie des individus qui ne sont pas les plus performants, 
mais permet, dans le cas où les quelques individus assez peu performants
sont sélectionnés, cela permet de conserver des solutions exploratoires.

Ajuster le nombre d'individus par groupe permet de jouer avec la pression de sélection. 
Plus les groupes sont petits et moins les individus les plus performants pourront faire
valoir leur avantage. Plus les groupes seront grands et moins le hasard rentrera en jeu et 
les individus sélectionnés seront les meilleurs.

#### Sélection par roulette

Nous allons implémenter une solution plus simple, qui sélectionne de manière pondérée 
les individus. Il faut imaginer une grande roue, sur laquelle le périmètre a été subdivisié 
en longueurs proportionnelles à la valeur de la fonction objectif de chaque individu.

À chaque fois que l'on veut choisir un individu, on fait virtuellement tourner 
cette roue et on choisit l'individu sur laquelle s'arrêterait la roue. 

L'implémentation (un peu moins fun qu'une roue de la fortune, je vous l'accorde)
de cette sélection est la suivante,


```python
while len(parents) < 10:
    max = sum([i.fitness for i in self.individuals])
    selection_probs = [i.fitness/max for i in self.individuals]
    parents.append(self.individuals[rand.choice(len(self.individuals), p=selection_probs)])
```

Maintenant que notre processus de sélection est fonctionnel, implémentons 
l'évolution des individus. 

- On ajoute le 3 meilleur individus à la liste des parents
- On sélectionne d'autres parents jusqu'à obtenir 10 individus
- Pour chaque parent, on crée 1 exacte copie et 4 individus 
mutés
- Et on remplace la population par la nouvelle
- On l'évalue et la trie par performance


```python
def enhance(self):
    """
    Enhance the population by making an iteration of selection, mutation, feature crossing.
    """
    parents = []

    # add the 3 best
    for ind in self.individuals[:1]:
        parents.append(ind)
    
    # roulette selection
    while len(parents) < 10:
        max = sum([i.fitness for i in self.individuals])
        selection_probs = [i.fitness/max for i in self.individuals]
        parents.append(self.individuals[rand.choice(len(self.individuals), p=selection_probs)])
    
    # Create new childs individuals from parents
    newIndividuals = []
    # Go through top 10 individuals - mutate
    for individual in parents:
        # Create 1 exact copy of each top 10 individuals
        newIndividuals.append(deepcopy(individual))
        # Create 4 mutated individuals
        for _ in range(4):
            newIndividual = deepcopy(individual)
            newIndividual.mutate(
                rate_amount=self.rate_amount,
                rate_prop=self.rate_prop
            )
            newIndividuals.append(newIndividual)
    # create 10 pairs of individuals - crossover
    pairs = [(random.choice(parents), random.choice(parents)) for _ in range(10)]
    for pair in pairs:
        parent1, parent2 = pair
        newIndividual_parent1 = deepcopy(parent1)
        newIndividual_parent2 = deepcopy(parent2)

        newIndividual_parent1.crossover(
            mixinInd=newIndividual_parent2,
            rate_prop=self.rate_prop
        )
        newIndividuals.append(newIndividual_parent1)
    
    # Replace the old population with the new population of offsprings
    self.individuals = newIndividuals
    self.evaluate()
    self.sort()
    # Store the new best individual
    self.best.append(self.individuals[0])
```

Lançons un calcul sur plusieurs générations avec 30 individus au départ, 
avec comme condition d'arrêt soit l'arrivée sur 500 générations, soit 
la fonction objectif étant égale à la capacité des cellules (signifiant 
qu'aucune optimisation supplémentaire sera trouvée, le maximum global ou un des
maximum s'il n'est pas unique, est atteint.)


Voici l'implémentation :

```python
cell_capacity = 0
for cell in problem["capacity"].keys():
    
    if cell != "courtyard":
        cell_capacity += problem["capacity"][cell]

size=30
jail_fillings = matPopulation(size=size, problem=problem)
jail_fillings.evaluate()
jail_fillings.sort()

for i in range(500):
    jail_fillings.enhance()
    print( f"Generation {i} - {jail_fillings.best[-1].fitness} - Inc. {jail_fillings.best[-1].fitness - jail_fillings.best[-2].fitness}")
    if jail_fillings.best[-1].fitness == cell_capacity:
        break
```

Voici les logs de cette itération : 

```txt
Generation 0 - 14.0 - Inc. 12.0
Generation 1 - 15.0 - Inc. 1.0
Generation 2 - 16.0 - Inc. 1.0
Generation 3 - 16.0 - Inc. 0.0
Generation 4 - 17.0 - Inc. 1.0
```

Nous avons donc trouvé la manière la plus optimale de remplir les cellules 
et brouillé au mieux les communications avec cette disposition : 

```python
>>> jail_fillings.best[-1].fitness
17
>>> jail_fillings.best[-1].state
array([[3., 0., 0., 0.],
       [0., 0., 4., 0.],
       [0., 4., 0., 0.],
       [0., 0., 0., 6.],
       [2., 4., 2., 0.]])
```

Pour cela vous déterminez qu'il faut placer : 
- 3 individus de l'escouade 1 en cellule 1
- 4 individus de l'escouade 3 en cellule 2
- 4 individus de l'escouade 2 en cellule 3
- 6 individus de l'escouade 4 en cellule 4

Et malheureusement, ce sont 8 individus qu'il va falloir placer 
dans la cour de promenade et cette information sera perdue à tout jamais. 
Mais vous avez fait du mieux possible.

"Bravo Matthew. Big Brother est satisfait de votre travail. Continuez
ainsi."

Secrètement, derrière ce masque de fausse fierté vous soufflez de soulagement.

Votre couverture est toujours sauve, bravo !

![bigbrotherispleased](story_illustrations/bigbrotherispleased.jpg#center)

### Pour aller plus loin

Si vous souhaitez lancer le code de votre côté, il est disponible 
sur mon Repo Github.

Envie de jouer avec un dashboard ? Une application hébergée sur Streamlit 
est disponible ici ! Jetez un oeil au repos [Github](https://github.com/Emilien-Foissotte/ml-genetics-algorithm-app) 
des sources pour l'utiliser en Live.

Vous pouvez : 

#### Générer un problème

{{< video "demos/pb_generation.mp4" "my-5" "1" >}}


#### Générer une population d'individus


{{< video "demos/generation.mp4" "my-5"  "2" >}}


#### Étudier un cas de mutation


{{< video "demos/mutation.mp4" "my-5" "3" >}}


#### Étudier un cas de crossover

{{< video "demos/featurecrossing.mp4" "my-5" "4" >}}

#### Générer une population pour répondre au problème

et servir Big Brother ! 😎

{{< video "demos/evolution.mp4" "my-5" >}}

## Conclusion

Les algorithmes génétiques sont très puissants. Ce que nous n'avons pas dit, c'est que nous pouvons 
désormais changer très rapidement le contexte de la solution à trouver (mettre des bonus sur 
des cellules spécifiques, rendre les solutions qui n'utilisent qu'une partie des cellules plus intéressantes.)


En encodant une manière de prendre cela en compte dans la fonction objectif, et bien alors vous serez 
capable de répondre encore très efficacement au problème. 

En effet, cela ne sera peut-être pas la meilleure solution, mais la solution trouvée le sera
en un temps raisonnable et sera une bonne solution (au sens d'un optimum local). 

Les algorithmes génétiques sont sensibles à la manière dont vous choisissez les paramètres
d'exécution (taux de mutation, population de départ, proportions d'individus mutés et de crossover), 
explorez les différentes possibilités pour essayer. 


[^1]: Cet excellent article de [blog](https://maxhalford.github.io/blog/genetic-algorithms-introduction/) de Max Halford
présente à merveille les algorithmes génétiques, de manière assez simple, mais sans feature crossing. 

[^2]: Ce [podcast](https://www.radiofrance.fr/franceculture/podcasts/avec-philosophie/qu-a-vraiment-dit-darwin-7854050)
explore la manière de lire la compétition entre les individus de manière générale, et
surtout d'éviter de tomber dans les écueils de la lecture du darwinisme social ou de la lecture trop simpliste par
le biais de la performance individuelle uniquement par exemple dans les contextes sociaux. 
