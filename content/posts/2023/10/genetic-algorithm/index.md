---
title: "Genetic Algorithm"
description: ""
date: 2023-10-07T09:01:23+02:00
publishDate: 2023-10-07T09:01:23+02:00
draft: true
tags: [Machine Learning, Python]
ShowToc: true
TocOpen: false
---

# TL;DR

This post will leverage and deep dive in the behavior of genetic
algorithm, in order to solve an hypothetical fun problem, using
solely Python. We will review high level concepts, and apply them
to our problem.

Later you will be able to apply Genetic Algorithms to your
own optimization problems.

Let's go !

## Intro

A few years ago, I encountered an excellent blog post about
a kind of algorithm, which were said to be adaptive and powerful
in a lot of problems were the context can change rapidly. 📊

Author was explaining that it was using some theorical background
of species and evolution from Darwinism, and as I love also this
topics, it seemed a perfect match for a deep dive ! 👀

I recently read again the excellent book _Nineteen Eighty-Four_
from George Orwell, a gift from my colleagues for my departure in
my last job.

An idea of situation to apply some Genetic Algorithm made up
is way in my mind. As you would expect, it will not be a pleasant
story, but it will be perfect for the demonstration.

Let say that you are an employee of the Thought Police, the
organization of _IngSoc_, the totalitarian regime in place.
Your job is to track opponents from Resistance movement.

An order is coming from your boss, you have to execute it
very very quickly. The stakes are very high, Big Brother is
expecting a tremendous victory.

At the end of the letter, you boss is explaining you using "double
thinking" what happened last night.

Members from Ministry of Love have managed to track and find
opponents from a huge resistance unit. As an example, they killed
the unit leader, but this unit was divided in 30 squads of
resisting citizens.

Each squad is a group of men and women, which
speak a ciphered language.  
They also understand other ciphered langage, but cannot speak it.

However, if they ear informations from other groups, they will
modify their own testimony to mask informations.

At the Ministry of Truth, you have cells that can jam a spefic
ciphering language, but you cannot jam several language in the same
time.

Unfortunately, jammers in each cell are predefined for specific
language, you cannot modify it.

Additionnally

You job is to put theses groups in a jail in order to make them tell
the truth, and to maximize the amount of valuable information
you can retrieve. After that, you will be able to make them love
Big Brother again.

For all resisting men which cannot be put into jail, you will have
to put them in a courtyard, but Unfortunately you will loose
all information they might have given

## Sum up of the situation

- A list of cells, Cell_A, Cell_B, Cell_C
- Each cell can jam 1 language, from a predefined set of
  language for each cell
- Each cell must contain members from a single squad.
- In case some resisting men cannot fit into a cellroom, they will
  go an unwatched and unjammed courtyard. All information from
  them will be corrupted and lossed.
- Each cell have a specific capacity

## Convert the problem into a matrix

Let's represent our problem using a matrix.
Each line of the matric represents a cell and each column
represent a squad.

Last line represents the courtyard.

Let's take an example :

We arrested 4 Squads, 5 members from squad 1, 8 dangerous mens
in Squad 8, 6 warriors against "Double Think" in Squad 3 and
6 members from Squad 4 making treason against Big Brother.

Here is a formal list :

```md
- Squad 1 : 5
- Squad 2 : 8
- Squad 3 : 6
- Squad 4 : 6
```

An member of Ministry of Truth is giving you information about
each cell. Each jammer has a communication mode and a number of
maximum person that can be jammed.
This parti member has sent you this list :

```md
- Jam Mode
  Cell 1: Squad 1 / Squad 3 : 3 prisonners max.
  Cell 2: Squad 3 / Squad 4 : 4 prisonners max.
  Cell 3: Squad 2 / Squad 4 : 4 prisonners max.
  Cell 4: Squad 1 / Squad 4 : 6 prisonners max.
```

A possible solution would be the following, but
unfortunately we would loose information from 11 mens,
as they are in the courtyard and unwatchable..

```sh
            Squad 1    Squad 2     Squad 3  Squad 4
Cell 1         0          0          3        0
Cell 2         0          0          0        4
Cell 3         0          0          0        2
Cell 4         5          0          0        0
Courtyard      0          8          3        0
```

A better solution would be this one, as only 8 mens
would be unwatched :

```sh
            Squad 1    Squad 2     Squad 3  Squad 4
Cell 1         3          0          0        0
Cell 2         0          0          4        0
Cell 3         0          4          0        0
Cell 4         0          0          0        6
Courtyard      2          4          2        0
```

## Introducing Genetic Algorithm

### Defining Fitness Function

Genetic algorithm are a way to solve this kind of optimization
problem, (here the target is to minimize amount of men in the
courtyard).

The target is evaluated using a fitness function (here our
fitness function count the number of element in the courtyard).

### Describe the whole evolutionnary process

The way of functinning is the following one :

- Create a population of individual. Each individual is
  described by a number of prisoner from each squad in each cell.
  DNA of the individual is each number of the matrix shown above
  and could be interpreted as it's genes.

- Population is evaluated and sort, from best fitness to the
  lowest one.

- A subset of best individuals is selected and individuals are
  mixed up, with various technics, in order to alter their genes.

- After an evolution round, individuals are evaluated again,
  and only the best one are selected for the next evolution round.

### Encoding a way to alter DNA

In Genetics Algorithms, there is traditionnally 2 ways of
mixing up DNA.

- **Mutations** : From a single best individuals, we can derive
  new individuals by tweak values from specific genes. By doing so,
  we might expect that in some cases we found a better individual.

Let's take an example on how to do so. We could for instance try
to take each cell, and move randomely some prisoners either

- **Feature Crossing**:
