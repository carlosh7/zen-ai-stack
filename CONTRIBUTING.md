# Contributing to zen-ai-stack

## How to Contribute

1. Fork the repository
2. Create a branch: `git checkout -b feature/my-feature`
3. Make your changes
4. Run shellcheck on all scripts: `shellcheck scripts/*.sh scripts/lib/*.sh`
5. Commit with descriptive message
6. Push and open a Pull Request

## Code Standards

- All scripts must pass shellcheck without errors
- Bash 4.0+ compatible
- No hardcoded paths — use `$HOME` and env vars
- Bilingual documentation (English + Spanish)

## Report Issues

Open a GitHub issue with:
- Description of the problem
- Steps to reproduce
- Expected vs actual behavior
- System info (OS, RAM, Docker version)
