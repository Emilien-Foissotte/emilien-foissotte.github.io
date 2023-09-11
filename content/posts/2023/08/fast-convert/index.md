---
title: "Lightening fast, Parquet to CSV"
description: ""
date: 2023-08-26T09:50:14+02:00
publishDate: 2023-08-26T09:50:14+02:00
draft: false
tags: [DataEng, Craftmanship, DuckDB, Data]
ShowToc: true
TocOpen: false
---

# TL;DR

This post will expose you how to convert in a very convenient and fast way 🚀 some `Apache Parquet`
files to `CSV`, and vice-versa, using either DuckDB 🦆 or Pandas 🐍 for a baseline comparison

As a quick bonus, we will embedded this tool in a small convient CLI script, easily triggered from your favorite 
shell 👨‍💻

Let's go !

## Intro

Recently, I've been working a little bit more on Data Engineering tasks (setup a Datalake, convert data,
design pipelines, make cleanup of some data). 📊

From time to time, I had to convert .csv data, which is perfect to rapidly catch any important info or check that decryption
is effective and so on.. 👀

But CSV files are very memory consuming, and in order to save some costs on AWS S3 Storage, it is way
better to handle some files using `Apache Parquet` format ⚡

And eventually, I've been finding myself doing again the same commands, in order to convert Parquet to CSV
and vice-versa. I tried to find a CLI tool which is plebiscited by Data Engineering community, but infortunalely
I couldn't encounter one !

And low efficient commands were going one again..

![cat](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExbWVxbHpwc2FzNHh2anFtcDRoaXdianJhOGl5bDFwYXJsdW5pNHVzbyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/JIX9t2j0ZTN9S/giphy.gif#center)

So sad that with parquet you can't vizualize your data , the following
command won't help you dealing with your data pieces.. 😥

```sh
❯ head file.parquet
B%R1x,<I/

!
b
B5
 u
:!-
<M=
P(-    bG
```

As always in optimization problems, there is no free lunch, you cannot get the convience of
being able to vizualize your data in a glimpse, and get a storage space super-efficient format. 🤑

But, after a while I remembered a post from a DuckDB advocate, showing how DuckDB could handle
this kind of operations, let's try to do it on our machine ! 🚀

## Comparing Pandas and DuckDB

Few month ago, I've encountered a Linkedin [post](https://www.linkedin.com/posts/motherduck_csv-to-parquet-using-duckdb-cli-activity-7043982478671306752-z2EK?utm_source=share&utm_medium=member_desktop) from a DuckDB advocate about crafting a one line script to
efficiently convert a CSV file into a parquet file.

I decided to give it a try and compare it from classical tool to do so (like pandas).

## Setup a baseline for a conversion tool

Let's first download a medium size dataset, for instance the [MovieLens 25M datasets](https://grouplens.org/datasets/movielens/)

Stay tuned, we will be using it in a future post !

```sh
❯ head -n 3 ratings.csv
userId,movieId,rating,timestamp
1,296,5.0,1147880044
1,306,3.5,1147868817
```

Let see with pandas and pyarrow installed, how does the baseline tool behave with this operations.
Just for the record and the sake of reproducibility is the snapshot of my `pip freeze` of my whole venv

```sh
❯ pip freeze
numpy==1.25.2
pandas==2.1.0
pyarrow==13.0.0
python-dateutil==2.8.2
pytz==2023.3.post1
six==1.16.0
tzdata==2023.3
```

And the performances are the following :

```sh
❯ /usr/bin/time -l -h -p python -c "import pandas; df=pandas.read_csv('ratings.csv'); df.to_parquet('ratings.parquet')"
real 14,43
user 9,40
sys 2,80
          1774600192  maximum resident set size
                   0  average shared memory size
                   0  average unshared data size
                   0  average unshared stack size
             1037341  page reclaims
                5284  page faults
                   0  swaps
                   0  block input operations
                   0  block output operations
                   0  messages sent
                   0  messages received
                   0  signals received
                 864  voluntary context switches
               25149  involuntary context switches
         77809521962  instructions retired
         42836239895  cycles elapsed
          2854670336  peak memory footprint
```

Now let's use DuckDB 🦆

To [install](https://duckdb.org/docs/installation/) it, very simple :

For macOS

```sh
brew install duckdb
```

and for Linux (be sure to get the right arch)

```sh
curl -SL https://github.com/duckdb/duckdb/releases/download/v0.8.1/duckdb_cli-linux-amd64.zip -o /tmp/duckdb.zip
unzip /tmp/duckdb.zip
mv /tmp/duckdb/* /usr/local/bin/
chmod +x /usr/local/bin/duckdb
```

Let's convert that `.csv` file 🚀 :

```sh
❯ /usr/bin/time -l -h -p duckdb -c "COPY (select * from read_csv_auto('ratings.csv')) TO 'ratings.parquet' (FORMAT PARQUET)"
100% ▕████████████████████████████████████████████████████████████▏
real 9,12
user 24,58
sys 2,36
           603959296  maximum resident set size
                   0  average shared memory size
                   0  average unshared data size
                   0  average unshared stack size
              551447  page reclaims
                1741  page faults
                   0  swaps
                   0  block input operations
                   0  block output operations
                   0  messages sent
                   0  messages received
                   0  signals received
                 761  voluntary context switches
               34911  involuntary context switches
        135618259891  instructions retired
         96669139421  cycles elapsed
           645996544  peak memory footprint
```

Let's compare the data between those runs !

![data](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExNXNlbDl1dnZnMzVyMHN5MTF5cHQ3MnN1ZXowNXc4NmEzYW9kbnhxZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/LaVp0AyqR5bGsC5Cbm/giphy.gif#center)

First impression : Love that progress bar, it is always annoying to wait for operations and never be sure when it is going to end.

However it seems that the file is a little less compressed than pandas one (might be some tweaks to do to compress it
with duckdb) :

```sh
❯ du -h ratings*.parquet
225M    ratings_duckdb.parquet
168M    ratings_pandas.parquet
```

However, when looking at the peak memory item, we can see that DuckDB process it on chunks, while
Pandas loads all the object in memory. On low memory system or with big objects, it can be limitating.

The overall peak is `4.4` times less important with DuckDB. Excellent !

![duck](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExcWUzOGJ0OGpjanJuajg2MTkyemRxY3FqdWV1emRrdmE3cmN5bHNrZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/x4bgmvMlRSYRVcTm29/giphy.gif#center)

## Developing a small CLI tool - the fancy way

Simply tweak your `.zshrc` or `.bashrc` with theses incredible functions :

```sh
function csv_to_parquet() {
    file_path="$1"
    duckdb -c "COPY (SELECT * FROM read_csv_auto('$file_path')) TO '${file_path%.*}.parquet' (FORMAT PARQUET);"
}

function parquet_to_csv() {
    file_path="$1"
    duckdb -c "COPY (SELECT * FROM '$file_path') TO '${file_path%.*}.csv' (HEADER, FORMAT 'csv');"
}
```

And transform your files in a one-liner command :

```sh
parquet_to_csv file.parquet
```

and boom, you get a `file.csv` 💥

And do the reverse operation very simply :

```sh
csv_to_parquet file.csv
```

And here is your `file.parquet`, so fast and efficient ! 🏎️

## Conclusion

We just covered a very handy feature with DuckDB, but with this small example, we have
been able to turn this versatile tool in a very handy CLI software, which will save you
so much time in your daily Data Engineering life !

Do not hesitate to add some of your smarts one-liners commands and function
you have in your `.bashrc` and `.zshrc`

Lots of ❤️ to the DuckDB team for the incredible work !

### Links and references

- [Linkedin Post](https://www.linkedin.com/posts/motherduck_csv-to-parquet-using-duckdb-cli-activity-7043982478671306752-z2EK?utm_source=share&utm_medium=member_desktop)
- [Repost from Mehdi Ouazza, great Data Eng advocate to follow !](https://www.linkedin.com/posts/mehd-io_csv-to-parquet-using-duckdb-cli-activity-7043984992632229888-7GJr?utm_source=share&utm_medium=member_desktop)
- [DuckDB documentation](https://duckdb.org/docs/installation/)
- [Discover DuckDB PDF](https://duckdb.org/pdf/SIGMOD2019-demo-duckdb.pdf)
