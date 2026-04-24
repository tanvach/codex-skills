# codex-skills

Personal Codex skills tracked in git and linked into `~/.codex/skills`.

## Install

Clone this repo on a machine, then run:

```bash
./install.sh
```

The installer:

- creates `~/.codex/skills` if needed
- discovers each top-level skill folder that contains `SKILL.md`
- creates symlinks into `~/.codex/skills`
- backs up conflicting existing skill folders before replacing them
- optionally prunes stale symlinks for deleted repo-managed skills with `./install.sh --prune`

When new skills are added to this repo, run `git pull` and then `./install.sh` again to link them.
If a skill was removed from the repo and you want its old symlink cleaned up, run `./install.sh --prune`.
