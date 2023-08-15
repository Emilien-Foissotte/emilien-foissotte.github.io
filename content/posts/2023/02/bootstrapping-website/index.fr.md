---
title: "Et le blog fut"
date: 2023-03-18T20:07:14+01:00
draft: false
frtags: [MetaBlog, Github]
ShowToc: true
TocOpen: false
---

# TRADUCTION EN COURS

# TL;DR

Cet article va balayer tous les aspects de la gestion d'un blog/portfolio comme
celui que vous êtes en train de lire 
- Depuis la manière d'écrire et de poster des articles avec de simples Markdown 🔤
- En passant par le déploiement sur Github Pages 🚀, avec le système libre et intégré de
de commentaires Giscus sous chaque article 🗣️
- Et enfin le monitoring de l'engagement des posts et campagnes de publication, avec un outil libre
également, Goatcounter 📶

Plus de détails dans les prochains paragraphes !

## Introduction

Je commence ce blog/portfolio afin de partager mon travail sur Internet, et pour publier 
du contenu à propos des découvertes marrantes que j'ai pu effectuer en explorant des sujets
divers et variés qui pourraient intéresser d'autres personnes.

C'est donc grosso modo un memo hébergé sur le web, mais j'espère qu'il pourra
aider de nombreux autres tech-hobbyist explorant diverses choses !

Cela me semblait un bon début d'essayer d'expliquer un peu les ficelles techniques 
qui permettent à ce tout nouveau site web d'exister sur la toile. 

Cela fera un bon point de départ à notre exploration technique, de regarder 
un peu sous le capot comment se génère, se déploie et se surveille ce site web.

Le dilemne entre l' 🥚 et la 🐔 reste entier, mais au moins nous allons
voir un peu comment les choses se passent ! 😃

Maintenant que tout a été dit, passons aux choses sérieuses..

## Lancer ce genre de site web - Un guide pour les "Nuls"

Ce site web statique est déployé sur la toile grâce au superbe outil [Github Pages](https://pages.github.com/)
et derrière c'est le framework [Hugo](https://gohugo.io/) qui s'occupe de tout.

### Installer Hugo

La mise en place d'hugo est sumple, il suffit de l'installer en suivant 
les procédures décrites sur le site plus haut, en sélectionnant la bonne option selon 
votre OS.

Dans mon cas, ce sera la section relative à Ubuntu :

```sh
sudo snap install hugo
```

Passons à la création du template de notre site web 🚀, en lançant sa génération avec : 

```sh
hugo new site <name of site> -f yml
```

Forkez votre thème Hugo favori 🌟, et ajoutez-le comme sous-module git, sous votre dossier `theme`

```sh
git submodule add --depth=1 https://github.com/<yourGHuser>/hugo-PaperMod.git themes/PaperMod
git submodule update --init --recursive
```

Plus tard, vous pourrez mettre à jour votre layout et customiser votre thème 
grâce à votre propre repo de fork, en ajoutant les modifications dans ce module. 

Pour terminer, ajouter à votre fichier `config.yml`:


```yaml
theme: "PaperMod"
```

Customiser votre blogfolio selon votre envie :
- Ajoutez une barre de recherche et d'archiv de vos posts 
- Rédigez une page de présentation 
- Modifiez `assets/css/extended/themes-vars-override.css` pour modifier la palette colorimétrique 
et l'UX/UI selon vos goûts. 
- Modifiez les options de `config.yml` pour activer/désactiver les fonctionnalités relatives
à votre thème.

**Vous souhaiteriez que l'on puisse commenter sous vos posts ?**
1. Créez une catégorie "Discussions" sous votre repository Github repository, dans l'onglet 
discussions. (Utiliser les "Announcements" est une good practice, comme 
l'explique à merveille <cite>Chris Wilson[^1]</cite>)
[^1]: Cette catégorie "Announcements" permet aux Maintainers et au bot Giscus de créer des Discussions,
ce qui est préférable. Plus de détails dans ce [post](https://cdwilson.dev/articles/using-giscus-for-comments-in-hugo/)
2.  Jetez un oeil à [Giscus](https://giscus.app/), répondez aux questions relatives à la configuration 
et copiez le script généré sous `layouts/partials/comments.html`. N'oubliez pas de réglez `comments: true`
sous le fichier `config.yml`
3. Félicitations, vous avez désormais un superbe système de commentaires 
![comments](comments_giscus.png#center)



**Vous aimeriez visualiser le traffic généré par votre site web ?**
1. Inscrivez-vous sur [Goatcounter.com](https://www.goatcounter.com/),
et copiez le snippet généré sous le fichier `layouts/extend_footer.html`

```html
<script data-goatcounter="https://<yoursitename>.goatcounter.com/count"
        async src="//gc.zgo.at/count.js"></script>
```
2. Ouvrez un navigateur à l'adresse de votre dashboard à
[https://yoursitename.goatcounter.com](https://www.goatcounter.com/) et observez le traffic généré
par votre propre navigation. Si vous ne voyez rien, pensez à désactiver votre Ad-blocker.
3. Vous pouvez mainteant voir le nimbre de vues de chacunes de vos pages et de vos posts !
![dashboard](goatcounter_dashboard.png#center)



### Publiez du contenu

Je vais, dans un souci d'organisation, gérer un post par dossier, 
en séparant les dossiers par années et par mois, comme vous pouvez le constater sous 
la page d'archive.
![content](content_folder.png)

Pour générer rapidement un nouveau squelette de post, nous allons générer un script
sous le dossier `script`. Cette pratique est inspirée de <cite> Nicholas Gilbert[^2]</cite>

[^2]: Ce script est dérivé de celui effectué par Nicholas Gilbert et détaillé dans cet 
excellent [article](https://gilbertdev.net/posts/2023/02/enter-automation/).

```bash
#!/bin/bash
printf -v year '%(%Y)T' -1
printf -v month '%(%m)T' -1

hugo new --kind post posts/$year/$month/$1/index.md
```

Donc, pour revenir à la base, la prochaine fois que vous lirez 
du contenu sur ce site web, rappelez vous que ce ne sont 
que de simples fichiers Markdown contenant des notes et guides de mise en page
puis tout simplement versés sur mon repository personnel, sur [Github](https://github.com/Emilien-Foissotte/emilien-foissotte.github.io).

Nous pouvons donc débuter l'écriture d'un nouvel article avec ce script : 

```sh
./scripts/make-post.sh new-fancy-idea
```

### Le déploiement de votre nouveau site

Pour chaque commit sur la branche `main`, Github Action
déclenche un pipeline pour construire et déployer les pages statiques 
du site web Hugo.

Vous pouvez étudier en détails les différentes étapes 
dans le fichier au format YAML `.github/workflows/hugo.yaml`

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

De manière simplifiée, Github se charge de :

1. Générer les pages statiques avec le job ligne 31, en créant les pages de chaque article.
2. Déployer le tout en utilisant l'environnement GitHub Pages , avec le job ligne 68.

## Conclusion

Hugo est un framework très facile d'utilisation, dont l'ergonomie n'a rien à envier 
à d'autres framework. Il a le luxe d'être intégré à merveille dans l'écosystème 
Github et les différents outils qui le composent.
Désormais, publier des notes de blog revient, de votre point de vue, à ne générer que 
quelques notes Markdown, ce qui rend la chose enfantine en terme d'utilisation !

Si vous souhaitez enregistrer votre blog dans un aggrégateur Open Source, qui n'est pas un 
hébergeur privé comme Medium ou Substack jetez un oeil à [diff.blog](https://diff.blog/)  

De chaleureux remerciements à tous les 
autres bloggeurs qui publient à propos de leurs projets, 
cela rend la vie tellement plus simple, tout en réussissant à ne pas faire l'impasse sur 
les aspects "logiciel" libre et le respect de la vie privée des outils développés. 

Toujours plaisant de vous des blogs Open Source et dénués de toute publicité sur la toile ! 😊
