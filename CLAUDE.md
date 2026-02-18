# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible role that installs and configures smartmontools on Ubuntu (jammy/noble). Published to Ansible Galaxy as `brianhartsock.smartmontools`.

## Commands

```sh
# Install dependencies
uv sync

# Linting (all three are run in CI)
uv run yamllint .
uv run ansible-lint
uv run flake8

# Run all linters via pre-commit
uv run pre-commit run --all-files

# Molecule testing (uses Docker driver with Ubuntu 22.04 + 24.04 containers)
uv run molecule test          # Full lifecycle: create, prepare, converge, verify, destroy
uv run molecule converge      # Apply role to containers only
uv run molecule verify        # Run testinfra tests only
uv run molecule destroy       # Tear down containers

# Update lock file
uv lock
```

## Architecture

Standard Ansible Galaxy role structure: `tasks/main.yml` installs smartmontools via apt, templates `/etc/smartd.conf`, and notifies a handler to restart `smartd` via systemd.

Configuration is driven by a single list variable `smartmontools_configuration_lines` (defined in `defaults/main.yml`). The Jinja2 template (`templates/smartd.conf.j2`) loops over this list to produce the config file.

## Conventions

- Use FQCN (Fully Qualified Collection Names) for all Ansible modules (e.g., `ansible.builtin.apt`, not `apt`)
- yamllint is run separately from ansible-lint (ansible-lint's internal yaml checks are skipped via `.ansible-lint`)
- Molecule group_vars override `smartmontools_configuration_lines` to `DEVICESCAN test` for deterministic test assertions
- Pre-commit hooks use `language: system` with `uv run` prefixes — tools are resolved from the uv-managed venv
- CI checks out the repo as `brianhartsock.smartmontools` to match the role name used in `converge.yml`

## Development Workflow

Follow this workflow for all code changes.

```
Code → Document → Verify → Code Review
  ^                              |
  └──── fix issues ──────────────┘
```

### 1. Code

Make the implementation changes. Use FQCNs, name all tasks, and follow the patterns in existing task files.

### 2. Document

Update README.md and CLAUDE.md to reflect any changes to variables, platforms, commands, or architecture. If the ansible plugin is installed, use the `documentator` agent.

### 3. Verify

Run linters (yamllint, ansible-lint, flake8), pre-commit hooks, and molecule tests. All checks must pass before proceeding. If the ansible plugin is installed, use the `verifier` agent.

### 4. Code Review

Review the changes for Ansible best practices, idempotency, security, cross-platform correctness, and test coverage. If the ansible plugin is installed, use the `code-reviewer` agent.

### 5. Iterate

If verification or code review flags issues, fix them and repeat from step 2. Continue until all checks pass and the review is clean.
