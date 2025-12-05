# hig-cli

A lightweight Swift command-line tool that ships with the DocuChat Human Interface Guidelines dataset. It loads the bundled
`hig_combined.json` file through `HIGPackage` and lets you inspect categories or search for topics directly from the terminal.

## Building and running

```bash
swift build --product hig-cli
swift run hig-cli --help
```

## Commands

- `--list` (`-l`): print all guideline categories in alphabetical order.
- `--search <query>` (`-s`): search topics by title, abstract, or section text.
- `--help` (`-h`): show the built-in usage message.

Examples:

```bash
# List the available Human Interface Guideline categories
swift run hig-cli --list

# Find topics that mention alerts
swift run hig-cli --search alert
```
