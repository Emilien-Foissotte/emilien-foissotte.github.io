---
title: "Optimization, 1984 and Genetics Algorithms"
description: ""
cover:
    image: "coveren.png"
    alt: "DNA Genetic Engineering Big Brother Stable Diffusion"
    relative: true
date: 2023-10-07T09:01:23+02:00
publishDate: 2024-01-16T07:00:00+01:00
draft: false
tags: [Machine Learning, Python]
ShowToc: true
TocOpen: false
---

# TL;DR

This post will leverage and deep dive in the behavior of genetic
algorithm, in order to solve an hypothetical fun problem, using
solely Python. We will review high level concepts, and apply them
to solve an optimization problem. This hypothetical problem takes shape in the narrative
of George Orwell and his dystopian novel 1984

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

### Background Story

I am a shitty writer in French, so I let you imagine in English.. 

Have a look for the French version of this article if you are interested
in the [full](/fr/posts/2023/10/genetic-algorithm/#par-un-froid-matin-dhiver)
background story that sets up the sitation.

![walking](story_illustrations/coldmorning.png#center)

_In a distopic regime.._

![building](story_illustrations/ministry.jpg#center)

_A double agent working in a Ministry that tracks
rebels_

![announcement](story_illustrations/announcement.png#center)

_A big arrest have been done by autoritarian regime_


![backroom](story_illustrations/backroom.jpg#center)

_The head of the department ask to privately have a discussion with you_

![order](story_illustrations/order.png#center)


_The tasks is handed out to you to handle enprisonment and interrogations_

![thinking](story_illustrations/thinking.png#center)

_The task is very complex and has a lot of situationnal constraints_

![cell](story_illustrations/crowded_cell.png#center)

_Your duty is to retrieve as much information as possible
from the prisoners_

## Sum up of the situation

An arrest of 30 men was carried out yesterday

- These 30 men are organized into squads, smaller sub-units of different sizes.
of different sizes: `Squad_0`, `Squad_1`.

- Each squad speaks a cipher language, and understands the cipher language
of the others. It cannot, however, speak it.

- You have at your disposal a list of Cells, `Cell_0`,
`Cell_1`, `Cell_2` ...

- Each cell can scramble one of a pre-determined number of different
different for each cell.

- To carry out interrogations, each cell must contain members of only one
members of a single squad to jam all communications.

- Each cell can contain a pre-defined number of prisoners.

- If a prisoner exchanges encrypted information, the interrogation is corrupted
is corrupted and all information is lost.

- If there's not enough space in the cells, you can use the courtyard
a non-encrypted area. Any man placed there will be able to
exchange with the others, but his information will be lost.

Objective: You must maximize the information recovered, in the name of
Big Brother.

## Convert the problem into a matrix

For ease of handling, we can represent our problem as a matrix.

To store information, we'll use a matrix in which each row represents a cell
row represents a cell and each column a squad.

The last row will be a little special, as it will contain the promenade yard.
yard.

To illustrate, let's take an example:

We have arrested 4 squads. Here's the list from the arrest bulletin
with the number of members per squad:

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

This party member has sent you this list :

|  Cell  | Jam Cells  | Capacity   |
|-----------|------------|------------|
| Cell 1 |  1 / 3 	| 3      	|
| Cell 2 |  3 / 4 	| 4      	|
| Cell 3 |  2 / 4 	| 4      	|
| Cell 4 |  1 / 4 	| 6      	|

A possible solution would be the following, but
unfortunately we would loose information from 11 mens,
as they are in the courtyard and unwatchable..

|  Cell  | Squad 1 | Squad 2 | Squad 3 | Squad 4 |
|-----------|------------|------------|------------|------------|
| Cell 1 | 0      	| 0      	| 3      	| 0      	|
| Cell 2 | 0      	| 0      	| 0      	| 4      	|
| Cell 3 | 0      	| 0      	| 0      	| 2      	|
| Cell 4 | 5      	| 0      	| 0      	| 0      	|
| Courtyard  	| 0      	| 8      	| 3      	| 0      	|


A better solution would be this one, as only 8 mens
would be unwatched :

|  Cell  | Squad 1 | Squad 2 | Squad 3 | Squad 4 |
|-----------|------------|------------|------------|------------|
| Cell 1 | 3      	| 0      	| 0      	| 0      	|
| Cell 2 | 0      	| 0      	| 4      	| 0      	|
| Cell 3 | 0      	| 4      	| 0      	| 0      	|
| Cell 4 | 0      	| 0      	| 0      	| 6      	|
| Courtyard  	| 2      	| 4      	| 2      	| 0      	|

But is it the best solution? Clearly, this one
better than the previous one, but is there any
possible solution for which more information
would be retrieved from prisoners ?


It's exactly this search for local optima that
a genetic algorithm will perform!

## Let's move on Genetic Algorithms

### Defining Fitness Function

Genetic algorithms are a way of solving optimization problems
optimization problems, which are often too complex to be solved
an exact solution in a reasonable time. One example is the
NP-difficult problem, for example.

Here, in the context of this problem, optimization is based on
maximizing the number of prisoners in a cell, and therefore by equivalent
minimizing the number of renegades in the exercise yard.

The objective function is therefore the sum of the coefficients of the line
associated with the yard. The aim is to minimize this quantity.

The power of these algorithms lies in the speed of evaluation of the
the objective function, in the sense that it's something that's going to be
performed a large number of times.

### Describe the whole evolutionnary process

The various stages of operation are as follows. We'll draw a parallel
parallel with object-oriented code to illustrate the different
methods.

- First, a set of individuals is randomly generated. Each
individual is described in full by its gene set,
the biological equivalent of DNA. Each gene encodes
a particular functionality, in this case we can define each gene `X_ij` as
being the number of prisoners in squad `j` in cell `i`. Note
that the matrix representation of the problem is thus equivalent to representing
DNA.

- Next, we select each individual and evaluate its performance
using the objective function. The population is then sorted according to
to simulate "natural selection".

- A subset of the best individuals is selected. There are various
ways of selecting individuals, such as the roulette selection system
roulette selection system, where the best individuals have a greater
more likely to be selected.

- Individuals are crossed by altering their DNA, either within the same
within the same individual, or by crossing the DNA of 2 high-performing individuals.

- This new pool of individuals is then used and evaluated to
a new iteration of evolution.

- The process is repeated until a stop condition is reached.
stagnation of candidate performance, or a given number of generations
 (i.e. we stop at the 500th generation of individuals) or
or we can try to set a quantitative criterion on the objective function,
as soon as an individual reaches this performance, we stop (which may never happen).


### Encoding a way to alter DNA

Biology classically refers to two well-known types of DNA modifications.
Theses phenomenon inspired the way modifying DNA of individuals
can be applied in Genetics Algorithms.

- **Mutation**: This is a random process in a single individual that modifies a portion of a gene
and alters its function, which occurs during replication of cells.
This process can result in a change in the individual's behavior, 
which may or may not confer an evolutionary advantage.


![mutation](http://www.lewrockwell.com/assets/2014/07/12.png#center)


- **Feature Crossing **: This process classically mixes the genes
of 2 parent individuals, A and B, to form a new individual, C.
Individual C can then benefit from the evolutionary
advantages of both parent A and parent B, and this can lead to unexpected
effects of gene crossover.

![crossover](https://genetics.thetech.org/sites/default/files/CrossOver.gif#center)


## What about algorithms?

There's nothing better than a computer to generate a large number of random elements
and perform multiple mathematical calculations to evaluate the objective function.

Let's encode all this.

We're going to use Python objects to generate our elements.

Let's represent the problem as a dictionary of constraints : 
- **Ci**: Represents our cells (Cell_i), only 'Courtyard' is set aside
set aside as the courtyard.
- **Si**: Represents our squads (Squad_i).
- **compatibility**: This key cross-references the scrambling compatibility
between cells and the coded language of each squad.
- capacity**: This key links the maximum quantity of prisoners
that each squad can store.
- **arrest**: This key contains the number of rebels arrested
per squad
- **squads**: This key contains the list of squads.
- **cells**: This key contains the list of cells.

This is the representation of our previous problem:
```
problem = {
    "compatibility": {
        "C0": ["S0", "S2"],
        "C1": ["S2", "S3"],
        "C2": ["S1", "S3"],
        "C3": ["S0", "S3"],
        "courtyard": ["S0", "S1", "S2"],
    },
    "capacity": {"C0": 3, "C1": 4, "C2": 4, "C3": 6, "courtyard": 1000},
    "arrest": {"S0": 5, "S1": 8, "S2": 6, "S3": 6},
    "squads": ["S0", "S1", "S2", "S3"],
    "cells": ["C0", "C1", "C2", "C3", "courtyard"],
}
```

__NB: 1000 for courtyard is simply used as an arbitrarily high value.__

### Generate individuals

Now the main step is to produce a generation of individuals 
who could meet the constraints of the problem.

To begin with, let's create an object that will represent this individual.

The idea of this method is to randomly distribute the different
members of each squad into the cells.

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

Let's create an individual, at random, from the
object above and our problem.

Here's an example of a randomly generated individual:

```python
>>> i1 = matIndividual(problem=problem)
>>> i1.state
array([[0., 0., 1., 0.],
   	[0., 0., 0., 4.],
   	[0., 4., 0., 0.],
   	[2., 0., 0., 0.],
   	[3., 4., 5., 2.]])
```

```python
def evaluate(self):
	# The objective function is the amount of prisoners in cells
	self.fitness = 0
	sum = self.state[self.cell2indice["courtyard"]].sum()

   self.fitness = self.arrested - sum
```

Let's evaluate the previously generated individual:

```python
>>> i1.evaluate()
>>> i1.fitness
11
```

### Generate an entire population

To aggregate a population of individuals, nothing could be simpler.
We'll create a class with a new Object.


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

Here's the generation of 100 individuals and the display of the individual having the 
highest fitness of them.

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

### Creating mutations

Creating mutations is simple

Simply move prisoners at random from the
the yard (which is supposed to have an unlimited capacity of prisoners)
or to the courtyard.

To maximize exploration of possible individuals, we'll also
allow mutations to reset the choice of a cell
by moving all prisoners to the courtyard. To limit the penalty
the penalty of this choice, we will then, if possible, repatriate
to the cell, as far as possible.

Here's a flowchart of the possibilities

{{<mermaid>}}

flowchart TD
	S0[Original </br> Individual] -->|For each cell </br> influenced by rates| C{Mutation type </br> applied }
	C --> D[Move prisoners from </br> cell to courtyard]
	C --> E[Move prisoners from </br> courtyard to cell]
	C --> F[Move all prisoners from </br> cell to courtyard, </br> and move in other squad to Cell]

{{</mermaid>}}

Each mutation condition is evaluated to ensure that the constraints are respected.

Here's the generation snippet of the new mutated individual :

```python
def mutate(self, rate_amount, rate_prop):
    """
    Create a mutated individual from this base individual.

    Args:
        rate_amount: Apply a percentage of amount of value to increase the amount of change in cells population
        rate_prop: Apply a percentage of coverage of cell that might be mutated

    Returns:
       A mutated individual

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

Let's study a mutated individual.

We'll use a **quantitative mutation rate** of 50%, i.e. we'll be able to
move up to 50% of the prisoners in a cell to place them elsewhere
(or half the squad present in the yard in the case of the 
courtyard situation).

We'll use an **amount mutation rate** of 100%,
meaning that all cells can be re-distributed
randomly.

Let's put this into practice!

Initially,
we generate an individual

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

With this individual, 9 prisoners are in cells only, not terrible...

Let's make a mutation


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

The new individual generated is a little more efficient, 
not bad! 

_NB: We seem to be able to make the situation worse by 
transferring prisoners from the cell to the courtyard 
but this is to allow transfers between cells, so sometimes 
it's better to lose a little performance to avoid getting 
in a local optimum._

### Feature Crossing between individuals

The idea now is to mix one individual with another, in order to
allow the genes of 2 high-performing individuals to be blended
to create a child with the attributes of both parents.

The idea behind this snippet is to randomly select for each prison cell
whether to retrieve it from parent individual 1 or parent individual 2. 

The yard will act as a compensating element if there are prisoners who cannot
fit into the cell (excess or shortage prisoners), 
then we'll add them or take them from the yard, if possible.

If it's not possible, then we don't make the cross. 

Here's the Feature Crossing flowchart 

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

Let's take an example to clarify how it works!


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

This is our first generated parent.

Let's create a second one:

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

And now the child individual `i3`, resulting from the crossover
between individual `i1` and `i2` :

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
Incredible! Our individual performs better than 
his 2 parents! 

Let's take a closer look at what happened. Initially, 
the genes are pre-filled with the cells 
of individual `i2`.

During the process, cell 4 is exchanged with that of 
individual `i1`. 

Here's the associated log:
```
Crossover C4 - other
New [5. 0. 0. 0.] - Old [2. 0. 0. 0.] - Diff [-3.  0.  0.  0.] - CW [0. 8. 1. 4.]
```

The 3 missing individuals were retrievable from the promenade yard. 
That's a fitness gain of `3`! 

## And so keeps going evolution, change is the only constant

Now that we have a way of generating new individuals and 
enrich our basic population, we need to choose a method 
to select the best of them without falling into local-optimality. 

We need to strike a balance between exploring possible solutions and the speed
of convergence towards a good solution.

### Selecting individuals

#### Tournament selection

We're going to implement tournament selection, which randomly selects
a number of individuals at random, and retains the best of them. 

This eliminates some of the individuals who are not the best performers, 
but, in the case where the few low-performing individuals 
are selected, this allows exploratory solutions to be retained.

Adjusting the number of individuals per group allows you to play with selection pressure. 

The smaller the groups, the less the best-performing individuals will be able to assert their advantage.
The larger the groups, the less chance will come into play, and the individuals selected will be the best
performing, on the whole group.

#### Selection by roulette wheel

We're going to implement a simpler solution, which selects individuals on a weighted basis.
Imagine a large wheel, on which the perimeter has been subdivided into lengths proportional
to the value of each individual's objective function.

Each time we want to select an individual, we virtually spin this wheel and
choose the individual on which the wheel would stop. 

The implementation (a little less fun than a wheel of fortune, I grant you)
of this selection is as follows

```python
while len(parents) < 10:
    max = sum([i.fitness for i in self.individuals])
    selection_probs = [i.fitness/max for i in self.individuals]
    parents.append(self.individuals[rand.choice(len(self.individuals), p=selection_probs)])
```

Now that our selection process is up and running, let's implement  the evolution of individuals. 

- Add the 3 best individuals to the list of parents
- We select other parents until we obtain 10 individuals
- For each parent, we create 1 exact copy and 4 
mutated individuals
- And replace the population with the new one
- Evaluate and sort by performance

```python
def enhance(self):
    """
    Enhance the population by making an iteration of selection, mutation, feature crossing.
    """
    parents = []

    # add the 3 best
    for ind in self.individuals[:3]:
        parents.append(ind)

    # roulette selection
    while len(parents) < 10:
        max = sum([i.fitness for i in self.individuals])
        selection_probs = [i.fitness / max for i in self.individuals]
        parents.append(
            self.individuals[rand.choice(len(self.individuals), p=selection_probs)]
        )

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
                rate_amount=self.rate_amount, rate_prop=self.rate_prop
            )
            newIndividuals.append(newIndividual)
    # create 10 pairs of individuals - crossover
    pairs = [(random.choice(parents), random.choice(parents)) for _ in range(10)]
    for pair in pairs:
        parent1, parent2 = pair
        newIndividual_parent1 = deepcopy(parent1)
        newIndividual_parent2 = deepcopy(parent2)

        newIndividual_parent1.crossover(
            mixinInd=newIndividual_parent2, rate_prop=self.rate_prop
        )
        newIndividuals.append(newIndividual_parent1)

    # Replace the old population with the new population of offsprings
    self.individuals = newIndividuals
    self.evaluate()
    self.sort()
    # Store the new best individual
    self.best.append(self.individuals[0])
```

Let's run a calculation over several generations, starting with 30 individuals,
with a stopping condition of either 500 generations, or  the objective function
being equal to the cell capacity (meaning that no further no further optimization
will be found, the global maximum or one of the maximum,
if not unique, is reached).


Here's the implementation:

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

Here are the logs of this operation :

```txt
Generation 0 - 14.0 - Inc. 12.0
Generation 1 - 15.0 - Inc. 1.0
Generation 2 - 16.0 - Inc. 1.0
Generation 3 - 16.0 - Inc. 0.0
Generation 4 - 17.0 - Inc. 1.0
```

So we found the most optimal way of filling the cells 
and scrambled communications as much as possible with this layout: 

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

To do this, you determine that you need to place : 
- 3 individuals from squad 1 in cell 1
- 4 individuals from squad 3 in cell 2
- 4 individuals from squad 2 in cell 3
- 6 individuals from squad 4 in cell 4

And unfortunately, 8 individuals will have to be placed in the courtyard
and this information will be lost forever. 
But you did the best you could.

"Well done Matthew. Big Brother is pleased with your work. Keep up
the good work."

Secretly, behind that mask of false pride you breathe a sigh of relief.

Your cover is still safe, bravo!

![bigbrotherispleased](story_illustrations/bigbrotherispleased.jpg#center)

### To find out more and have fun with dashboard

If you'd like to launch the snippets on your own, it's available 
on my [Github repo](https://github.com/Emilien-Foissotte/ml-genetics-algorithm-app) 

Want to play with a dashboard? An application hosted on Streamlit is available
[here](https://github.com/Emilien-Foissotte/ml-genetics-algorithm-app),
have a look at README file for the public URL!

You can :

#### Generate your own problem

{{< video "demos/pb_generation.mp4" "my-5" "1" >}}


#### Generate your own generation of individuals


{{< video "demos/generation.mp4" "my-5"  "2" >}}


#### Have a look in depth of a mutation


{{< video "demos/mutation.mp4" "my-5" "3" >}}


#### Have a closer glance at feature crossing

{{< video "demos/featurecrossing.mp4" "my-5" "4" >}}

#### Produce a solution throught an evolutionary process

and serve Big Brother ! 😎

{{< video "demos/evolution.mp4" "my-5" >}}

## Conclusion

Genetic algorithms are very powerful. What we haven't mentioned is that we can
now quickly change the context of the solution to be found (putting bonuses
on specific cells, making specific cells, make solutions that use only part
of the cells more interesting).


By encoding a way of taking this into account in the objective function, well
then you'll be still be able to respond very effectively to the problem. 

Indeed, it may not be the best solution, but the solution found will be the
best one in a reasonable time and will be a good solution (in the sense of a local optimum). 

Genetic algorithms are sensitive to the way you choose the execution parameters
(mutation rate, starting population, proportions of mutated and crossover individuals).

Explore the different possibilities and give them a try !

[^1]: This excellent [blog post](https://maxhalford.github.io/blog/genetic-algorithms-introduction/) 
by Max Halford gives a wonderful introduction to genetic algorithms,
quite straightforward, very clear but without feature crossing. 

[^2]: This [podcast](https://www.radiofrance.fr/franceculture/podcasts/avec-philosophie/qu-a-vraiment-dit-darwin-7854050)
explores how to read the competition between individuals
in general, and and, above all, to avoid falling into the pitfalls of reading social Darwinism
or the over-simplistic reading through individual performance in social contexts, for example.  

