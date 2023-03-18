---
title: "Starting blogging"
date: 2023-03-18T20:07:14+01:00
draft: false
---

## Introduction

Hi, I will try to kick off some content on this blog, in order to hold details about
some fun stuff I actually enjoyed making, or that might help other doing so.

To start with some technical details here, I think that explaining how this website is
generated is a good start.


## Making this kind of website

This website is made public using the fancy tool of [Github Pages](https://pages.github.com/)
and the behind the scenes are curated by [Hugo](https://gohugo.io/).

So basically, next time you see a new blog post, it's just a markdown containing notes
samples, which is commited on my personnal repo on Github. Each time a commit reach `main`
branch, Github Action trigger some pipelines to build and deploy it.

You can see all details about the various step under this [file](https://github.com/Emilien-Foissotte/emilien-foissotte.github.io/blob/main/.github/workflows/hugo.yml)
