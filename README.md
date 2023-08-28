# Class support scripts

Simple unix scripts to support pulling data from multiple student repositories

# Workflow

You need to create a directory in which all repos will be cloned;
it needs to contain a file with the magic name `AllRepos.txt`.

In a nutshell:

```
mkdir studentrepos
cd studentrepos
cat > AllRepos.txt
### insert the git@github/user/repo lines here
^D
```

Then one time to clone the repos:

```
sds_clone.sh ## make sure this is in your path
```
(this will also work if the `AllRepos.txt` has been updated.)

To update the clones:

```
sds_pull.sh
```

and such. Single user pull:

```
sds_pull.sh username
```


# Utility

`sds_url.sh reponame`: attempt to extract the URL that a repo comes from, so that you open it in a browser. Related: `sds_open_all.sh` loops this over all clones and does an `open` on each URL. Hopefully on your computer that will cause them to open in a browser.

`sds_extract.sh homeworkname`: create a directory `homeworkname` and populate it with the submissions of all students. This is tolerant of up/lo case issues but nothing else. So students need to be able to follow instructions.

`sds_open.sh username`: try to open the repo in a browser.

`sds_open_all.sh`: open all repos in a browser.
