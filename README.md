<div align="center">
  <br>
  <h1>Emilien's blog 🌐✍️</h1>
  <strong>A space for my blog and personal projects.</strong>
</div>
<br>
<p align="center">
  <a href="https://github.com/Emilien-Foissotte/emilien-foissotte.github.io">
    <img src="https://img.shields.io/github/commit-activity/w/Emilien-Foissotte/emilien-foissotte.github.io" alt="GitHub commit activity">
  </a>
  <!-- add python version badge -->
  <a href="https://github.com/Emilien-Foissotte/emilien-foissotte.github.io/blob/main/.github/workflows/hugo.yaml">
    <img src="https://img.shields.io/badge/hugo-0.140.2-red?logo=hugo" alt="Hugo version">
  </a>
  <!-- add build status -->
  <a href="https://github.com/emilien-foissotte/emilien-foissotte.github.io/actions/workflows/hugo.yaml">
    <img src="https://github.com/emilien-foissotte/emilien-foissotte.github.io/actions/workflows/hugo.yaml/badge.svg" alt="Deploy job">
  </a>
  <a href="https://emilien-foissotte.github.io/">
    <img src="https://img.shields.io/badge/website-online-green?logo=github" alt="Github Pages online">
  </a>
</p>

Welcome to my personal website repository, where I share my thoughts, projects, and achievements.

## Table of Contents

1. [About](#about)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Contributing](#contributing)
5. [License](#license)

## About

This site is made with ❤️ (and few ☕) by Emilien Foissotte using [Hugo](https://gohugo.io/)

This repository contains the source code for my personal website. It showcases my blog posts, projects, and other personal content.

## Setup

To set up the project locally, follow these steps:

1. [Install](https://gohugo.io/getting-started/quick-start/) hugo

#### Ubuntu

```sh
sudo snap install hugo
```

#### Mac

```sh
brew install hugo
```

2. Clone this repo

```sh
git clone git@github.com:Emilien-Foissotte/emilien-foissotte.github.io.git
```

3. Init the submodules for customizations using my fork of [Papermod theme](https://github.com/adityatelange/hugo-PaperMod)

```sh
git submodule update --init --recursive
```

4. Update them with their latest changes

```sh
git submodule update --recursive --remote
```

5. Config your git repo

```sh
git config --local user.name "Emilien-Foissotte"
git config --local user.email "emilienfoissotte44@gmail.com"
```

### Deploy locally

Then review your content `hugo server -D` to render draft.

### Edit your content

Add some markdowns under content, review if it gets a nice rendering `hugo server -D`
to render also drafts.

### Publish

If that sounds right, push to the `main` branch, Github Action will cary on the job to
deploy it.

### Repeat, and share if you liked :)

## Usage

You can view the website by navigating to [https://emilien-foissotte.github.io](https://emilien-foissotte.github.io) in your web browser.

## Contributing

Even though this project is personal, any suggestions or pull requests are happily welcomed.

## License

<div align="center" style="font-size:12px; color:lightgrey;">
    <a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/">
        <img alt="Creative Commons License" style="border-width:0"
            src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" />
    </a><br><br>
    This work is licensed under a <b>Creative Commons
    Attribution-NonCommercial-ShareAlike 4.0 International License</b>.<br>
    You can modify and build upon this work non-commercially. All derivatives should be
    credited to Émilien Foissotte and
    be licensed under the same terms.
</div>

<br>

<p align="center">
  <img alt="Lemur, EF's mascot" width="250px" src="https://emilienfoissotte.fr/public/sharefolder/lemur.jpg">
  <br>
  <strong>Happy Coding</strong> ❤️
</p>

[⬆ Back to Top](#table-of-contents)
