---
title: "Start blogging"
date: 2023-03-18T20:07:14+01:00
draft: false
tags: [MetaBlog]
ShowToc: true
TocOpen: false
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

You can see all details about the various step under this file

```yaml {linenos=true}
# Sample workflow for building and deploying a Hugo site to GitHub Pages
name: Deploy Hugo site to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches:
      - main

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: true

# Default to bash
defaults:
  run:
    shell: bash

jobs:
  # Build job
  build:
    runs-on: ubuntu-latest
    env:
      HUGO_VERSION: 0.111.2
    steps:
      - name: Install Hugo CLI
        run: |
          wget -O ${{ runner.temp }}/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb \
          && sudo dpkg -i ${{ runner.temp }}/hugo.deb
      - name: Install Dart Sass Embedded
        run: sudo snap install dart-sass-embedded
      - name: Checkout
        uses: actions/checkout@v3
        with:
          submodules: recursive
          fetch-depth: 0
      - name: Setup Pages
        id: pages
        uses: actions/configure-pages@v3
      - name: Install Node.js dependencies
        run: "[[ -f package-lock.json || -f npm-shrinkwrap.json ]] && npm ci || true"
      - name: Build with Hugo
        env:
          # For maximum backward compatibility with Hugo modules
          HUGO_ENVIRONMENT: production
          HUGO_ENV: production
        run: |
          hugo \
            --gc \
            --minify \
            --baseURL "${{ steps.pages.outputs.base_url }}/"
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: ./public

  # Deployment job
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```

Basically Github
1. Build the static sites using job at line 31, generating pages for each article.
2. Deploy it using GitHub Pages environment, using job definition at line 68.
