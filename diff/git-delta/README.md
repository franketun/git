<!-- @format -->

git-diff-ln.py

Usage

Pipe git diff into the script to annotate each changed line with old/new file line numbers:

```bash
git diff --no-color | ./scripts/git-diff-ln.py
```

Notes

- The script expects unified diff format (the default from `git diff`).
- It's a lightweight helper for local usage; for more advanced features consider tools like
  `diff-so-fancy` or `delta`.

## Prefer `delta` for everyday use

Instead of piping diffs through custom scripts, I recommend using `delta`
(https://github.com/dandavison/delta). `delta` is a fast Rust-based pager for git diffs with syntax
highlighting, side-by-side view, and many configuration options.

Install (macOS - Homebrew):

```bash
brew install git-delta
```

Make `git diff` use delta by default (global):

```bash
git config --global core.pager "delta"
# or only for diffs:
git config --global pager.diff delta
```

Bypass delta when you need the raw diff (or your helper script):

```bash
# show raw git diff without delta pager
git --no-pager diff

# or temporarily run without pager
GIT_PAGER= cat | less
```

Recommended minimal delta config (add to `~/.gitconfig` or via `git config --global`):

```ini
[delta]
	syntax-theme = Monokai Extended
	side-by-side = false
	line-numbers = true
	navigate = true

[core]
	pager = delta
```

If you still want the small `git-diff-ln.py` helper available, keep it in `scripts/` and call it
explicitly:

```bash
git diff --no-color | ./scripts/git-diff-ln.py
```

## Summary

`delta` is the recommended tool for fast, feature-rich diffs. Use `git config` to set it as your
pager so `git diff` uses it by default.

## Installer helper

There's a small helper script `scripts/install-delta.sh` that attempts to install delta
(Homebrew/cargo/apt) and configure git to use it. It is idempotent and safe to use from dotfiles.
Example:

```bash
./scripts/install-delta.sh -y
```

Run `./scripts/install-delta.sh --help` for options.
