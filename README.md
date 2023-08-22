# Class support scripts

Simple unix scripts to support pulling data from multiple student repositories

# Workflow

```
mkdir studentrepos
cd studentrepos
cat > AllRepos.txt
### insert the git@github/user/repo lines here
^D
```

Then one time:

```
sds_clone.sh ## make sure this is in your path
```

after which every time:

```
sds_pull.sh
```

