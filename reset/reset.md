# git reset guide

git reset is a powerful command that manipulates the three main trees in Git: working directory, staging area (index), and commit history.
The Three Trees

    HEAD: Last commit snapshot

    Index: Staging area

    Working Directory: Sandbox where you make changes

Common Reset Modes

1. git reset --soft <commit>

   Moves HEAD to specified commit

   Keeps staging area and working directory changes

   Use case: Undo commits but keep changes staged

2. git reset --mixed <commit> (DEFAULT)

   Moves HEAD to specified commit

   Resets staging area to match commit

   Keeps working directory changes

   Use case: Unstage changes while keeping modifications

3. git reset --hard <commit>

   Moves HEAD to specified commit

   Resets staging area and working directory

   Use case: Completely discard all changes (⚠️ Dangerous!)

Practical Examples
Undoing git add -N (Intent-to-Add)
bash

# Add intent-to-add for untracked files

git add -N filename.txt

# Reset specific file

git reset filename.txt

# Reset all intent-to-add files

git reset

Resetting Specific Files
bash

# Unstage single file (keeps working directory changes)

git reset filename.txt

# Unstage all files (keeps working directory changes)

git reset

Resetting Commits
bash

# Move HEAD back 1 commit, keep changes staged

git reset --soft HEAD~1

# Move HEAD back 1 commit, unstage changes (default)

git reset --mixed HEAD~1

# Move HEAD back 1 commit, discard all changes

git reset --hard HEAD~1

Working with Mixed Tracked/Untracked Files
Scenario Setup
bash

# Modified tracked file

echo "changes" > tracked-file.txt

# New untracked file

echo "new content" > untracked-file.txt

# Add intent-to-add for untracked file

git add -N untracked-file.txt

Reset Behavior
bash

# Before reset:

git status

# Changes to be committed: (intent-to-add untracked-file.txt)

# Changes not staged: (modified tracked-file.txt)

# After git reset:

git status

# Changes not staged: (modified tracked-file.txt)

# Untracked files: (untracked-file.txt) - back to untracked!

Safety Notes
Safe Operations

    git reset (without --hard) never loses work

    Untracked files are always preserved

    Modifications remain in working directory

⚠️ Dangerous Operations

    git reset --hard discards all uncommitted changes

    Can lose work if used carelessly

    Always check git status before using --hard

Useful Aliases

Add to your .gitconfig:
ini

[alias]
unstage = reset HEAD --
undo-commit = reset --soft HEAD~1
discard-changes = reset --hard HEAD

Quick Reference
Command Effect Safety
git reset Unstage everything Safe
git reset file Unstage single file Safe
git reset --soft HEAD~1 Undo commit, keep changes staged Safe
git reset --mixed HEAD~1 Undo commit, unstage changes Safe
git reset --hard HEAD~1 Undo commit, discard changes ⚠️ Dangerous
Best Practices

    Always check git status before resetting

    Use --soft or --mixed when unsure

    Use --hard only when you want to completely discard changes

    Remember: git reset doesn't affect untracked files

    git add -N can be undone with simple git reset

Recovery

If you accidentally reset too far:
bash

# View recent actions

git reflog

# Reset to previous state using reflog hash

git reset --hard HEAD@{1}
