---
title: "Setting Up Portable Ide"
description: ""
cover:
  image: "cover.png"
  relative: true
  alt: "Portable Laptop Traveler Stable Diffusion"
date: 2023-05-21T17:30:36+02:00
publishDate: 2023-05-21T17:30:36+02:00
draft: false
tags: ["IDE", "Nvim", "Software Engineering"]
ShowToc: true
TocOpen: false
---

# TL;DR

This blogpost deep dive around setting up a Unix based workstation and how craft a portable and ergonomic but efficient IDE.
We will cover

- Crafting your terminal multiplexer tmux to mix and split windows as fast as a 10 handed guy 💻
- Move around code and software repos in a glimpse with nvim, using completions as smart as VSCode ones ⌨️
- Linking the previous tool and deploy codespaces on your own workstation, and add your favorites plugins ⚙️

Feel free to add your own customizations or hacks in comments. 😃

Hey, you want to know how setup a comment system like this one, below the post ? Checkout my previous post [here](/posts/2023//02/bootstrapping-website/)

Let's go !

## Introduction

Developping and coding software takes place as my main activity when I'm at work but also when I'm behing a computer screen. In order to interact with code, as a beginner, I've been using pre-built GUI IDE, like VSCode, Spyder, which were fine at the time.

![GUI-IDE](spyder.png#center)

Later, seeking for customization of my workflow, I had my hands on Atom. Unfortunately, Atom has been shut down by Microsoft in order to focus on VSCode.

Hence, this event pushed me in looking down for the best tool in place with the perfect trade-off betwenn ergonomy and efficiency. So, a few weeks ago, I decided to give a try to terminal based IDE (like Nano, Vim..), which makes them also perfect to develop on central server without any desktop environment.

![nvim-IDE](neovim.png#center)

As an MLOps Engineer, when I'm focused on Data Engineering and ETL debugging stuff, It's a situation I encounter very often.

## Crafting your own way of arranging and browsing through windows and panes

### A Terminal Multiplexer at the rescue, tmux

The first step is to install a _terminal multiplexer_.

What is a **terminal multiplexer** ? It's a very fancy tool which, in a simple way of explaining it, allows you to handle multiple windows, multiple sessions, using a single connection to your machine.

Let's take an example.
You are developping a new database to store some data. You are developping the script on a server where your database is installed. Once you've edited everything, you would have to open a new connection to server to launch script ?

No, it's not very convenient.

And, do you want to get a bonus ? It can save workspaces and sessions accross machines restart. So damn usefull in our way too mcuch multitasked lives, it's so mental load saving.

#### Installing the tool

First, that's at your desire but I love terminal that are a key away from being accessible. So at the beginning I was extensively using Gnome Terminal, with a _CTRL + T_ as shortcuts, but I was ending with dozens of windows open, it was a mess.

As a fancier replacement, I use a drop down terminal, [Guake](http://guake-project.org/index.html). It is enabled whenever I press _F12_, in full screen. So cool, no more messy terminal (and as bonus, it is slightly transparent, so damn ergonomic when you want read some important man page whilst firing up some code).

![guake](guake.jpg#center)

On debian, give a go to this installation command.

```sh
sudo apt-get update && sudo apt install guake
```

Good to go ? Now install tmux (and xclip for copy paste commands), same stuff

```sh
sudo apt install tmux xclip
```

Let's tweak a little bit tmux, fire a configuration by doing

```sh
touch ~/.tmux.conf
```

#### Tmux basic workflow

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
