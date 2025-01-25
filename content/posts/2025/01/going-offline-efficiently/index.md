---
title: "Going Offline Efficiently"
date: 2025-01-11T09:04:03+01:00
publishDate: 2025-01-11T09:04:03+01:00
cover:
  image: "cover.jpg"
  relative: true
  alt: "Coding in the countryside"
draft: true
tags: ["DataEng", "LLM", "Duckdb", "Python"]
ShowToc: false
TocOpen: false
---

# TL;DR

This post will show some tips on how to work efficiently as a Data Engineer 🚀, either navigating throught documentation
or using a local LLM to ease your development experience (having a Mac chip will be mandatory for this one). 👨‍💻

Let's go !

## Intro

Nowadays, working in limited internet connection can occur and there is a huge gap compared to our workstation setup 🦾

In those situations, connection speed might be very slow, with a very broken bandwith. This makes it very difficult to work in those environments, but with a few
preparation you might be as effective than before ! 💥

![sloth](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExbzN1eTJlY2Y5cndiaGdydDdhZW9iZjE3bzhpZ3VtczZwODhyY3p5NyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/3oz8xOu5Gw81qULRh6/giphy.gif#center)

Get ready to boost your productivity, on a train, on a bus or enjoying a family trip in the countryside ! 🚜

## Keep a browsable documentation, everywhere

Never received a RTFM raising an Issue ? Make yourself a gift, read the documentation when approaching a
new concept or feature of a package ! 📖

### Unix troubles

A very good tool to use when working on UNIX computers is `man`, a simple documentation tool that gives you
every details of software installed.

However, it can be hard to navigate the entire documentation. And it's quite difficult to get the exact purpose
you are looking for.

To solve this, a community tool have emerged : `tldr`.

In a few lines of text documentation you will find out the main usage of the software and its syntax.

For instance, for `xargs` command :

![xargs_tldr](tldr_xargs.png#center)

Pretty neat, isn't it ? 🔥

To install it, have a look at the [repository](https://github.com/tldr-pages/tldr).

### Browsing Python documentation

As Python is becoming the 1st programming language, you will surely encounter issues while working on it.
You are struggling using a built-in Python object ? 🐍

A deep exploration using Pythonic Wizard tricks like `yourobject.__dict__` asn't provided you any useful information ?

Fire up the buit-in documentation server associated to your Python version with :

```sh
pydoc -p 0
```

and type `b` to open automatically a browser page. 🌐

All the installed package will have their documentation provided here, with docstrings and examples.

For instance, here is the docstring of `pyspark` with the `agg` function :

![pyspark_agg](pyspark_agg.png#center)

## Browsing offline Duckdb documentation

Sometimes, with the right preparation a Data Engineer can safely work on a `dbt` projects
using `unit-tests` or `data-tests` using mock sources. 📊

For instance, I've been working recently with [lea](https://github.com/carbonfact/lea), a lightweight alternative to
`dbt` which is plug and play with `duckdb`.

My staging models where used to retrieve some local data which was not too large to oversize my hard-drive.

I declare views as follow :

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

The `seeds/inventory.sql` model contains :

```sql
CALL load_aws_credentials('my-profile');
DROP TABLE IF EXISTS inventory;
COPY (
  SELECT * FROM 's3://mylarge-bucket/inventory.parquet'
) TO 'seeds/raw_inventory.parquet' (FORMAT PARQUET);
```

When I'm still online, I make a :

```sh
duckdb < seeds/inventory.sql
```

It generates a dump of _raw_inventory.parquet_ file ⚙️

And later on I can declare `staging` model, which contains :

```py
from __future__ import annotations

import pathlib

import pandas as pd

here = pathlib.Path(__file__).parent
inventory = pd.read_parquet(here.parent.parent / "seeds" / "raw_inventory.parquet")
```

You need to review duckdb docs on an edge case for a function ?

Before your offline trip, download the latest <cite> documentation [^1] </cite>
as a zip file at [https://duckdb.org/duckdb-docs.zip](https://duckdb.org/duckdb-docs.zip).

[^1]: Duckdb team provide several ways to browse offline the documentation, head to [offline doc page](https://duckdb.org/docs/guides/offline-copy.html) for more.

Download it, unzip it :

```sh
mkdir ~/duckdb-offline && mv ~/Downloads/duckdb-docs.zip ~/duckdb-offline
cd duckdb-offline && unzip duckdb-docs.zip
```

Once it's unzipped, load the python built-in webserver, it will be available everywhere
offline, even with the search bar, very neat ! 🦆

```sh
python -m http.server
```

![duckdb-docs](duckdb_docs.png#center)

## Facing a hard issue on this one ? Ask for local LLM help !

Using managed services like Github Copilot is super handy, but it might be
costly (~100$/yr) and not suitable when developing in limited bandwith
environments. 🐌

To overcome theses challenges, if your are a happy owner of Apple M2 or M3 chip,
you will have enough computing power to run a local LLM, within 1 to 3B weights.

Hopefully, the ARM architecture of the chip will save us also from completely wipe the
battery out of power. 🔋

To do so, before your first offline session, head to [tabby documentation](https://tabby.tabbyml.com/docs/quick-start/installation/apple/),
a framework that makes available local LLM to LSP servers.

Install tabby and launch it with :

```sh
tabby serve --port 8889 --device metal --model StarCoder-1B --chat-model Qwen2-1.5B-Instruct
```

Use the plugin on the <cite> IDE [^2] </cite> of your choice, for instance `vim-tabby` on neovim,
with a few setup to do not conflict with Copilot setup :

[^2]: Tabby team developped also plugins for Visual Studio Code, IntelliJ. Have a look at [documentation](https://tabby.tabbyml.com/docs/extensions/troubleshooting/).

Lazy.nvim configuration :

```lua
return {
	"TabbyML/vim-tabby",
	lazy = false,
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	init = function()
		vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
		vim.g.tabby_inline_completion_trigger = "manual"
		vim.g.tabby_inline_completion_keybinding_accept = "<leader>%"
	end,
}
```

and use leader + % to accept the tabby autocomplete from LLM.

If your are more familiar with a chat interface, head to [http://0.0.0.0:8889/](http://0.0.0.0:8889/) to
use the chat web app ! 💬

Here is a result defining fibonacci function :

![tabby_suggestions](tabby.png#center)

Not so bad !

## Conclusion

Going offline is still an occasion of executing deepwork, even if the network connection is not so great.
It doesn't mean that you have to fail on each issue and try to debug it without documentation.

It's a great way of standing on <cite> _the shoulders of giants_ [^3]</cite>, tons of developer tried to provide the most
efficient documentation, RTFM. And nowadays, having a copilot is a great you to have straight to the point
code suggestions, do not underestimate it.

[^3]: Knowledge is cumulative, [wikipedia]( https://en.wikipedia.org/wiki/Standing_on_the_shoulders_of_giants %C3%A9ants) pour
