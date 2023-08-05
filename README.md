# Personal website

This site is made with ❤️ (and few ☕) by Emilien Foissotte using [Hugo](https://gohugo.io/)

Have a nice glance, happy to see you here !

## How to

### First time ? 

[Install hugo](https://gohugo.io/getting-started/quick-start/)

#### Ubuntu

```sh
sudo snap install hugo
```

#### Mac

```sh
brew install hugo
```

Clone this repo

```sh
git clone git@github.com:Emilien-Foissotte/emilien-foissotte.github.io.git
```

Init the submodules (for themes customizations)

```sh
git submodule update --init --recursive
```

Update them with their latest changes

```sh
git submodule update --recursive --remote
```

Config your git repo

```sh
git config --local user.name "Emilien-Foissotte"
git config --local user.email "emilienfoissotte44@gmail.com"
```

### Ensure everything is alright

Then review your content `hugo server`

### Edit your content 

Add some markdowns under content, review if it gets a nice rendering `hugo server -D`
to render also drafts.

### Publish 

If that sounds right, push to the `main` branch, Github Action will cary on the job to
deploy it.

### Repeat, and share if you liked :) 
