---
title: "Setting Up Portable Ide"
description: ""
date: 2023-05-21T17:30:36+02:00
publishDate: 2023-05-21T17:30:36+02:00
draft: true
tags: []
ShowToc: false
TocOpen: false
---

# TL;DR

This blogpost deep dive around setting up a Unix based workstation and how craft a portable and ergonomic but efficient IDE. 
We will cover 
- Crafting your terminal multiplexer tmux to mix and split windows as fast as a 10 handed guy 💻
- Move around code and software repos in a glimpse with nvim, using completions as smart as VSCode or ChatGPT ones ⌨️
- Linking the previous tool and deploy codespaces on your own workstation, and add your cherry picked plugins ⚙️

Feel free to add your own customizations or hacks in comments. 😃

Hey, you want to know how setup a comment system like this one, below the post ? Checkout my previous post [here](/posts/2023//02/bootstrapping-website/) 

Let's go ! 

## Introduction

Developping and coding software takes place as my main activity when I'm at work but also when I'm behing a computer screen. In order to interact with code, as a beginner, I've been using pre-built GUI IDE, like VSCode, Spyder, which were fine at the time. 

![GUI-IDE](spyder.png#center)

Later, seeking for customization of my workflow, I had my hands on Atom. Unfortunately, Atom has been shut down by Microsoft in order to focus on VSCode. 

Hence, this event pushed in looking for the best tool in place with the perfect trade-off betwenn ergonomy and efficiency. So, a few weeks ago, I decided to give a try to terminal based IDE (like Nano, Vim..), which makes them also perfect to develop on central server without any desktop environment. 

![nvim-IDE](neovim.png#center)

As an MLOps Engineer, when I'm focused on Data Engineering and ETL debugging stuff, It's a situation I encounter very often. 

## Crafting your own way of arranging and browsing through windows and panes

### A Terminal Multiplexer at the rescue, tmux 

The first step is to install a terminal multiplexer. 

What is a terminal multiplexer ? It's a very fancy tool which, in a simple way of explaining it, allows you to handle multiple windows, multiple sessions, using a single connection to your machine.

Let's take an example. 
You are developping a new database to store some data. You are developping the script on a server where your database is installed. Once you've edited everything, you would have to open a new connection to server to launch script ? 

No, it's not very convenient.

And, do you want to get a bonus ? It can save workspaces and sessions accross machines restart. So damn usefull in our way too mcuch multitasked lives, it's so mental load saving.

### Installing the tool

First, that's at your desire but I love terminal that are a key away from being accessible. So at the beginning I was extensively using Gnome Terminal, with a *CTRL + T* as shortcuts, but I was ending with dozens of windows open, it was a mess. 

As a fancier replacement, I use a drop down terminal, [Guake](http://guake-project.org/index.html). It is enabled whenever I press *F12*, in full screen. So cool, no more messy terminal (and as bonus, it is slightly transparent, so damn ergonomic when you want read some important man page whilst firing up some code).

![guake](guake.jpg#center)

On debian, give a go to this installation command.

```sh
sudo apt-get update && sudo apt install guake
```

Good to go ? Now install tmux, same stuff

```sh
sudo apt install tmux
```

Let's tweak a little bit tmux, fire a configuration by doing

```sh
touch ~/.tmux.conf
```

### Tmux basic workflow

Now it's time to review how tmux work. 

First by doing `tmux` you will start the tmux server. By modifying `~/.tmux.conf`, you can modify your key bindings in order to change the way you interact with it.

Let's review the basic workflow.

At start, you can create _sessions_. A _session_ is a placeholder for workspaces and allows you to separate differents windows and workspace.

How create one ? By doing `tmux new -s your_session_name`. This one will attached to your current tmux session. If you want to detach it, do a `tmux detach:` 



