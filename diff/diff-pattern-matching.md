# git diff pattern matching guide

```
#match files with Page.vue suffixes
gd \*Page.vue #option 1

gd -- '*Page.vue' #option 2

noglob gd *Page.vue #option 3

gdw() { git diff -- "*$1*" | detla } # option 4 - assuming git-delta is used for showing diffs (delta is bin for git-delta)

```

Zsh expands the wildcards (asterisks) before anything reaches git diff, therefore (option 1) escaping with \ prevents zsh expansion,
(option 2) -- treats everything after as arguments, (option 3) `noglob` temporarily disables glob expansion or we can define a function
that wraps the operation so that we can pattern match more easily

## recommendations:

```
# Disable globbing for git diff

alias gd='noglob git diff'

# Or create a fuzzy diff function

gdf() { git diff -- "_$1_" | delta }

```
