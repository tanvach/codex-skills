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

When new skills are added to this repo, run `./install.sh` again to link them.
