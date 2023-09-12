---
title: "TMUX x NVIM : Hands-on"
description: ""
cover:
  image: "cover.png"
  relative: true
  alt: "Portable Laptop Traveler Stable Diffusion"
date: 2023-05-21T17:30:36+02:00
publishDate: 2023-05-21T17:30:36+02:00
draft: false
frtags: ["IDE", "Nvim", "Software Engineering"]
ShowToc: true
TocOpen: false
---

# TRADUCTION EN COURS

# TL;DR

Ce billet de blog va couvrir différents aspects de la mise
en place d'une station de développement Unix, et comment se construire son propre
setup ultra-ergonomique et OS-transversal (pour MacOS et tout un tas de distributions Linux)

Nous verrons :

- Comment fabriquer un terminal multiplexer, tmux et comment faire danser les fenêtres de déveleppment tel un
  majestueux ballet, à la vitesse de l'éclaire 💻
- Se déplacer entrre les lignes de code et les repos d'un claquement de doigt (pressement d'une touche
  pour être précis ^^) avec nvim, tout en bénéficiant de complémentions faisant rougir ChatGPT ⌨️
- Faire fusionner les deux-outils et déployer des codespaces sur votre station, en y incluant vos plugins
  favoris ⚙️

N'hésitez pas à partager vos propres hacks de customisation en commentaires, ne
soyez pas avares de conseils 😃

Ce super système de commentaires vous intrigue ?
Allez jeter un oeil à mon précédent post pour en savoir plus [ici](/posts/2023//02/bootstrapping-website/)

C'est parti, passons aux choses sérieuses !

## Introduction

Développer des outils et des apps est l'une de mes principales activités au boulot,
mais aussi quand je suis quand je suis les mains sur un clavier.

Pour intéragir avec mes lignes de codes, quand j'étais un pur débutant, j'utilisais naturellement
des IDE "batteries-included" avec des interfaces graphiques fenêtrées comme VSCode, Spyder, que
je trouve très bien et correspondait parfaitement à l'usage que je pouvais faire des mes éditeurs.

![GUI-IDE](spyder.png#center)

Plus tard, quand j'ai cherché à maximiser et customiser mon workflow, je suis tombé sur Atom
qui permettait un degré de customisation assez indécent. Malheureusement, suite au rachat par
Microsoft et à la position naturellement indésirable de concurrent à VSCode, il a été décidé d'arrêter
le projet, pour dédier les équipes de Microsoft à 100% à VS.

Alors, ce tragique épisode pour Atom m'a poussé à chercher de nouveaux outils, et
sortir de ma zone de confort pour commencer à escalader une nouvelle courbe d'apprentissage,
dans le but d'atteindre l'équilibre idéal entre ergonomie et efficacité.

Il y a donc quelques semaines de cela, j'ai décidé de me lancer dans l'essai d'IDE
basé sur l'utilisation du terminal uniquement ( comme Nano ou Vi(m) ).

Ce choix d'IDE basés uniquement sur un terminal fait tout à fait sens également
dans mon job de tout les jours, où je passe pas mal de temps à développer sur un serveur
central sans environnement de bureau. (et j'avais déjà eu vent de VSCode en version
remote mais je n'ai pas été convaincu à 100%).

![nvim-IDE](neovim.png#center)

En tant qu'MLOps, avec une partie des tâches qui m'incombent
touchant fortemment au backend et aux aspects DevOps de la chaîne de traitement ML
quand je suis en train de bosser sur des aspects Data Engineering/ETL
c'est le genre de situation assez typique.

## Fabriquez un multiplexeur à votre image, pour joueur du bout des doigts avec les fenêtres

### Un Multiplexeur de terminal à la rescousse , tmux

La toute première des étapes est d'installer un _terminal multiplexeur_.

Mais c'est quoi un **terminal multiplexeur** ?

C'est un outil super pratique, qui permet, de manière schématique pour expliquer brièvement,
de gérer de multiples fenêtres à la fois, de multiples sessions,
tout en utilisant une simple connexion avec votre kernel.

Prenons un exemple pour clarifier un peu les choses.
Vous développez sur une nouvelle version de la base de données
qui permet de stocker une donnée quelconque.
Vous développez donc un script sur le serveur où votre base de données réside, ce script
permettant d'effectuer quelques tests.

Quand vous avez fini d'éditez votre script vous lancez une nouvelle connexion vers le serveur
pour lancer le script ? Vous bossez avec plusieurs connection en parallèle ? Et si le réseau est
instable, vous perdez votre session et le long job de test sur la DB ?

Bof hein, le setup est pas optimal, c'est rien de le dire.

Et vous voulez un super bonus ? Tmux peut sauvegarde vos
différentes sessions de travail et vous les restaurer de manière
transparente après un re-démarrage.

Extrêmement utile dans nos
vies beaucoup trop multitâches, tellement mentalement boostant par la charge que ça libère
et ça libère aussi du stress de perdre du boulot en cas de crash sauvage de son ordinateur.

J'ai enfin remords à éteindre mon ordinateur en fin de journée de boulot.

#### Installation de l'outil

En toute première étape, c'est vous qui décisez sur ce point
mais en toute subjectivité j'adore avoir un terminal à portée de touche ("hotkey").
Au début j'utilisais à outrance les terminaux Gnome, avec des _CTRL + T_ dans tous les sens,
mais je me retrouvais souvent au bout de quelques temps avec des dizaines de fenêtres
ouvertes, c'était le gros bazar.

En outil de remplacement assez intelligent, j'utilise un "drop down" terminal,
[Guake](http://guake-project.org/index.html).
Cela permet d'activer son terminal à l'instant où on presse la "hotkey"
par défaut c'est _F12_, et le terminal passe au premier plan en plein écran. Il
y a même la possibilité de le garder légèrement transparent, trop cool.

Fini les terminaux dans tous les sens !
Et tellement pratique quand on
list une page importante en fond et qu'on peut s'y référer sans avoir à perdre le
focus sur son terminal !!

![guake](guake.jpg#center)

Sur une installation Debian, lancez cette commande d'installation :

```sh
sudo apt-get update && sudo apt install guake
```

Tout est bon ? Installez tmux (et xclip pour permettre les copier-coller depuis la console), même chose:

```sh
sudo apt install tmux xclip
```

Modifions un peu tmux, créez un fichier de configuration en exécutant cette commande :

```sh
touch ~/.tmux.conf
```

#### Un exemple de workflow Tmux

Now it's time to review how tmux work.

First by doing `tmux` you will start the tmux server. By modifying `~/.tmux.conf`, you can modify your key bindings in order to change the way you interact with it.

Let's do some workaround to modify a little bit the original behavior.

The tmux prefix (_i.e. the shortcuts to fire up some tmux commands from keyboard_) is not suited for me and I find it not very ergonomic, as CTRL and B are far away to get reached by a single hand. I rather, as suggested by <cite> Josean Martinez[^1]</cite>, change it to _CTRL + a_, by adding this to `~/.tmux.conf`:

```sh
set -g prefix C-a # set the prefix
unbind C-b # remove CTRL+b keybinding
bind-key C-a send-prefix # bind CTRL + A as prefix shortcut
```

To memorize way better the way to arrange window (and splitting them), add this also :

```sh
unbind % # remove the original horizontal shortcut split
bind | split-window -h # bind with pipe to horizontal split

unbind '"' # remove the original vertical shortcut split
bind - split-window -v # bind dash to vertical split
```

We will come back latter to the choice of "|" and "-" for this shortcuts.

You can do now a `tmux source ~/.tmux.conf` to reload you configuration dynamically.

[^1]: Josean has made an excellent video on this topic, available [here](https://www.youtube.com/watch?v=U-omALWIBos)

Let's now review the basic workflow.

#### Sessions

At start, you can create _sessions_. A _session_ is a placeholder for workspaces and allows you to separate differents way of arranging workspaces and isolate them.

How create one ? By doing `tmux new -s your_session_name`. You will change to a new terminal window, an the tmux server attach this session to your tmux client. You can now do a `tmux ls` to list all sessions. You can see the named session _test_ is said to be attached.  
This one will attached to your current tmux session. If you want to detach it to let it run in background and go back to your previous terminal, do a `tmux detach`.

![tmuxls](tmuxls.png#center)

To go back to your session, in a detached state (no current session is attached), do a `tmux attach -t your_session_name`.
View all your sessions by doing a _prefix (CTRL-A) + s_ to view a listing of all your sessions and a short snapshot of each one of them.

![lssessions](lssessions.png#center)

So efficient and comprehensive, isn't it ?

#### Windows

As you can see, in each session, you can have multiples windows, a window consisting of a view. The curret windows is displayed with a small asterix on this side. You can fire up a new windows in the current session, by doing a _prefix (CTRL-a) + c_ command. You can then rename it, with a _CTRL-a + ,_. They are numbered, so you can navigate easily to the wished windows in your current session with a _CTRL-a + X_ where X is the number of the wished window.

Move around very fast between windows by going to the next one doing a _CTRL-a + n_ or the previous one with a _CTRL-a + p_.

#### Panes

Hence, now you have seen how to fire up and move between panes, let's review panes. Panes are simply subparts of your window. You can split your window in multiple panes, like in this current example, where panes are numbered, throught _CTRL-a + q_.

To split a pane in 2 vertically separated panes (as the symbol | would suggest), do a _CTRL-a + |_. To split in 2 horizontal panes, do a _CTRL-a + -_.

To rezise and move around them using vim move keys (k for ↑), (j for ↓), (h for ←) and (l for →) add this to your `~/.tmux.conf` :

```sh
bind -r j resize-pane -D 5
bind -r k resize-pane -U 5
bind -r l resize-pane -R 5
bind -r h resize-pane -L 5

bind -r m resize-pane -Z
set -g mouse on

set-window-option -g mode-keys vi
```

You can now move around panes with _CTRL-a + j_ for instance to go down, maximize or reduce a pane to full view with _CTRL-a + m_ and resize your panes by moving it with mouse or doing a _CTRL-h_ to resize in the left direction (vim movements again here).

Copy pasting in tmux can seem to be at start a little bit confusing, but it's very simple.

First add this elements to your `~/.tmux.conf`:

```sh
set-option -s set-clipboard off

bind P paste-buffer # to paste with a capital p
bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
```

To copy something (from keyboard) :

- Enter in visual mode, with _CTRL-a + [_
- Move around the elements with vi movements and drop the cursor on the beginning of the selection. Enter copy mode with _v_ key.
- Move the cursor to the end of the selection and and finish selection with _y_ key.
- Exit visual mode with _Enter_ key.
- Paste at desired location and do a _CTRL-a + P_ to paste selection in the current buffer.

To copy somtething (using mouse):

- just drag on the text you want to copy and drop.
- Hence, the selection is in the copy buffer (be sure to have xclip installed.)
- Paste it somewhere else, using _CTRL + v_ or _CTRL-Maj + v_.

#### Plugins

Tmux can resurrect and save your sessions, windows and panes throught restarts using some plugin.

First install a plugin manager, [tpm](https://github.com/tmux-plugins/tpm) by firing up this command :

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Install all plugins by adding this to your `~/.tmux.conf`:

```sh
# add tmux plugins to tpm
# tpm plugin
set -g @plugin 'tmux-plugins/tpm'

# list of tmux plugins
set -g @plugin 'christoomey/vim-tmux-navigator' # for navigating panes and vim/nvim with Ctrl-hjkl
set -g @plugin 'tmux-plugins/tmux-resurrect' # persist tmux sessions after computer restart
set -g @plugin 'tmux-plugins/tmux-continuum' # automatically saves sessions for you every 15 minutes

set -g @resurrect-capture-pane-contents 'on' # allow tmux-ressurect to capture pane contents
set -g @continuum-restore 'on' # enable tmux-continuum functionality

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
```

Your final tmux conf file should look like this :

{{< gist Emilien-Foissotte 4f22221b7fca4cec0476b0b7b8989783 >}}

## Editing code with tons of smart shortcuts and built-in LSP

### Neovim

Now our setup for terminal multiplexer is perfect (and somehow customizable), we can move on to view the way we can use [Neovim](https://neovim.io/) to edit code efficiently.

Here's is a view of the final IDE setup :
![nvimview](nvimview.png#center)

#### Installation

```sh
sudo apt-get install neovim python3-neovim
```

Now, review the whole video of Josean on the subject and adapt using files under my repo for some modifications in order to setup you Neovim and full embodied LSP.

Here is the excellent video : {{< youtube vdn_pKJUda8>}}

Follow up instructions under my own dev dot file [repo](https://github.com/Emilien-Foissotte/dot-environnement-files#readme) if you want to reproduce the same on your Debian setup with Guake.

## Conclusion

This setup allows you to gain a lot in efficiency and also in workflow tasks. Also, firing up a configuration is a git clone away and very simple to transport to other workstation.

Feel free to add any comments about the way you customize your bindings or perform tasks.
