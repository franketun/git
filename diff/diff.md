# git diff

using [git delta](https://github.com/dandavison/delta "github repo for git repo") as the git diff handler for all `git diff` commands

Recommendation

- If you do not already have `git-delta` configured, consider installing and enabling it — it significantly improves diff readability. See the repository's `./git-delta` documentation for build and install instructions, and set `core.pager` to the `delta` executable or add a symlink to a `PATH` location after you install it.

Quick cheat-sheet for showing diffs from past commits, integrating `delta` as a pager, and handy aliases.

**Commands & examples**

- **Show a single commit (message + patch):** `git show <commit>`
  - Example: `git show 3a7f2b1`
- **Show only the patch introduced by a commit:** `git diff <commit>^!`
  - Example: `git diff 3a7f2b1^!`
- **Compare two commits (range):** `git diff <commit1> <commit2>` or `git diff <commit1>..<commit2>`
  - Example: `git diff HEAD~3 HEAD`
- **Diff between working tree and a commit:** `git diff <commit>`
  - Example: `git diff origin/main`
- **Show staged changes (what will be committed):** `git diff --staged` (aka `--cached`)
- **Show patches in history:** `git log -p` (limit with `-n`, e.g. `git log -p -n 3`)
- **List changed files only:** `git diff --name-only <a> <b>` or `git show --name-only <commit>`
- **List changed files with status (A/M/D):** `git diff --name-status <a> <b>` or `git show --name-status <commit>`
- **Show file contents at a commit:** `git show <commit>:path/to/file`
- **Merge commits:** `git show -m <merge-commit>` shows diffs against each parent; use `-c`/`--cc` for combined diffs.

Range & ref shorthand cheats:

- `HEAD~n` — nth ancestor (e.g. `HEAD~1` is last commit).
- `<a>..<b>` — diff a → b.
- `<a>...<b>` — diff b vs merge-base(a,b) (useful for branch vs base comparisons).

Useful `git diff` options

- `--name-only` — show file list.
- `--name-status` — show file list with A/M/D.
- `--stat` — compact summary of file changes.
- `-U<n>` — set context lines (e.g. `-U0`).
- `-M` — detect renames.
- `--color-moved` — show moved blocks (works well with `delta`).

Using `delta` as your pager

- One-shot: `git -c core.pager=delta show <commit>`
- With options temporarily: `git -c core.pager='delta --side-by-side --line-numbers' show <commit>`
- Environment override: `GIT_PAGER="delta --side-by-side" git show <commit>`
- Useful `delta` flags:
  - `--side-by-side` — two-column view.
  - `--line-numbers` — show source line numbers.
  - `--width <cols>` — set width for side-by-side.
  - `--syntax-theme <name>` / `--dark` — adjust coloring.
  - `--file-style <style>` — change file header formatting.
  - `--navigate` — ease jumping between hunks.

Set `delta` globally as the pager (recommended):

```bash
git config --global core.pager delta
```

Optional recommended delta config examples:

```bash
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.side-by-side true
git config --global delta.line-numbers true
```

Aliases & shortcuts (add to `~/.gitconfig` or run with `git config --global`)

- `s` : show with name-status
  - `git config --global alias.s 'show --name-status'`
- `d` : list changed files
  - `git config --global alias.d 'diff --name-only'`
- `p` : log with patches (accepts a number after the alias)
  - `git config --global alias.p 'log -p -n'`
- `last` : last commit patch
  - `git config --global alias.last 'log -p -1'`
- `cdiff` : run diff with delta (one-shot alias wrapper)
  - `git config --global alias.cdiff '!git -c core.pager=delta diff'`

Practical copy-paste examples

- Show patch for commit `abc123`:
  - `git show abc123`
- Show that commit with delta side-by-side and line numbers:
  - `git -c core.pager='delta --side-by-side --line-numbers' show abc123`
- Show files changed between `main` and `feature`:
  - `git diff --name-only main..feature`
- Show staged changes in delta side-by-side:
  - `git -c core.pager='delta --side-by-side' --no-pager diff --staged`

Notes

- Use `..` vs `...` intentionally: `..` compares two endpoints, `...` compares against their merge-base.
- `git show` is convenient for single commit exploration; `git diff` is better for arbitrary pairs/ranges.

If you'd like, I can apply the `delta` config and aliases to your global `git` config now, or add more project-specific presets.

**Understanding `merge-base` (with clear examples)**

Plainly: the `merge-base` of two refs is the last commit they both share — the snapshot where their histories split. It's the concrete commit Git uses as the starting point when asking "what changed on this branch since we diverged?".

Why that matters for `git diff`:

- `A..B` (two-dots) compares the trees at `A` and `B` (tip-to-tip): `git diff A B`.
- `A...B` (three-dots) for `git diff` compares the merge-base to the right-hand ref: it is equivalent to `git diff $(git merge-base A B) B`.

ASCII diagrams

Case 1 — feature branched, main moved after branch point

```
A --- B --- C   (main)
	  \
	   D --- E   (feature)
```

- `merge-base(main,feature)` = `B`.
- `git diff main..feature` compares `C` (main tip) to `E` (feature tip).
- `git diff main...feature` compares `B` (merge-base) to `E` (feature tip) — i.e., what `feature` introduced since the split.

Case 2 — main didn't move after branching (feature is purely ahead)

```
A --- B   (main)
	\
	 D --- E   (feature)
```

- `merge-base = B` (also `main` tip), so `main..feature` and `main...feature` act the same here (both compare B→E).

Case 3 — both advanced independently

```
A --- B --- C --- F   (main)
	\
	 D --- E        (feature)
```

- `merge-base = B`.
- `main..feature` compares `F` vs `E` (tips).
- `main...feature` compares `B` vs `E` (what `feature` added since split), which will not include changes unique to `main` after `B`.

Reproducible example you can run locally (copy-paste)

```bash
# create demo repo
rm -rf demo-mergebase && mkdir demo-mergebase && cd demo-mergebase
git init

# A: base
echo "line1" > file.txt
git add file.txt
git commit -m "A: base"

# B: branch point (empty commit to mark the split)
git commit --allow-empty -m "B: branch point"

# create feature and commit D/E
git checkout -b feature
echo "feature-line1" >> file.txt
git commit -am "D: append feature-line1"
echo "feature-file" > feat.txt
git add feat.txt
git commit -m "E: add feat.txt"

# go back to main and commit C
git checkout main
echo "main-mod" > file.txt
git commit -am "C: change file on main"
```

Now inspect the relationships and diffs:

```bash
# view graph
git log --graph --oneline --decorate --all

# concrete merge-base SHA
git merge-base main feature

# two-dot (tip-to-tip): C vs E
git diff main..feature --name-only
git diff main..feature

# three-dot (merge-base → feature): B vs E
git diff main...feature --name-only
git diff main...feature
```

What you'll see

- `git merge-base main feature` prints the SHA of `B` (the shared commit).
- `git diff main..feature` shows the net difference between the two tips (C vs E).
- `git diff main...feature` shows only what `feature` introduced since `B` (merge-base → E).

Extra commands to explore divergence

- `git log --oneline main..feature` — commits reachable from `feature` but not from `main`.
- `git log --oneline main...feature` — commits reachable from either side but not from both (symmetric difference).
- `git log --left-right --oneline main...feature` — label commits by which side they come from.

Short mental model

- `..` (two-dots): compare endpoints — what differs between snapshot A and snapshot B?
- `...` (three-dots for `git diff`): start from where they last agreed (merge-base) and show what the right-hand ref added since then.

Note: remember that `A...B` for `git log` has a different meaning (symmetric commit selection). Above focuses on `git diff` semantics.
