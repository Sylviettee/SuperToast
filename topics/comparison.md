# Comparison

Here is a small comparison to other Discordia frameworks/command handlers.

The frameworks compared are:

* [SuperToast](https://github.com/SovietKitsune/SuperToast)
* [Toast](https://github.com/NotSoClassy/Toast)
* [Commandia](https://github.com/Bilal2453/Commandia) (dev branch)

## Points

Here are some things to consider when choosing a framework for your bot.

### Metadata

Information about the package itself and not any of the functionality.

Discordia is not counted as a dependency.

| Metadata | SuperToast | Toast | Commandia |
| -------- | ---------- | ----- | --------- |
| Version | 0.7.1 | 1.3.1 | 0.0.1 |
| Discordia version | 2.8.4 | 2.8.4 | N/A (No package.lua) |
| Typings | ✓ | ✘ | ✘ |
| Dependencies* | 0 | 0 | 0 |
| Documentation | [SuperToast](https://sovietkitsune.github.io/SuperToast) | [Toast](https://github.com/NotSoClassy/Toast/wiki) | None |

### Command Parsing

Parsing is how each framework deals with parsing given input.

| Command Parsing | SuperToast | Toast | Commandia |
| --------------- | ---------- | ----- | --------- |
| Aliases | ✓ | ✓ | ✓ |
| Mention as prefix | ✘ | ✓ | ✘ |
| Multiple prefixes | ✓ | ✓ | ✓ |
| Per-guild prefix customization | ✓ | ✓ | ✓ |
| Pattern trigger | ✘ | ✘ | ✘ |
| Store original input | ✓ | ✓ | ✓ |

### Command Handling

Command handling is how each framework will handle a command once one has been identified. Things like cooldowns and other things.

| Command Handling | SuperToast | Toast | Commandia |
| ---------------- | ---------- | ----- | --------- |
| Cooldowns | ✓ | ✓ | ✘ |
| Channel restrictions | ✓ | ✓ | ✘ |
| Permission restrictions | ✓ | ✓ | ✓ |
| Command edits | ✘ | ✘ | ✘ |
| Subcommands | ✓ | ✓ | ✘ |
| Help information | ✓ | ✓ | ✘ |

### Argument Parsing

Argument parsing is the final step before starting to do what the user wants.

For matching, the parser should support more than just the id like the object name.

| Argument Parsing | SuperToast | Toast | Commandia |
| ---------------- | ---------- | ----- | --------- |
| Ordered arguments | ✓ | ✓ | ✓ |
| Unordered arguments | ✘ | ✘ | ✘ |
| Optional arguments | ✘ | ✓ | ✓ |
| Quoted arguments | ✓ | ✓ | ✓ |
| Flag arguments | ✓ | ✓ | ✓ |
| Dependant arguments | ✘ | ✓ | ✓ |
| Argument types | ✓ | ✓ | ✓ |
| Union types | ✘ | ✘ | ✘ |
| Custom types | ✓ | ✓ | ✓ |
| User and member matching | ✓ | ✘ | ✘ |
| Role matching | ✘ | ✘ | ✘ |
| Channel matching | ✘ | ✘ | ✘ |
| Pattern arguments | ✘ | ✘ | ✘ |

### Module System

A module system allows for loading modules automatically. It also defines how new modules like commands are created and loaded.

| Module System | SuperToast | Toast | Commandia |
| ------------- | ---------- | ----- | --------- |
| Tables | ✘ | N/A | ✓ |
| Functions | ✘ | N/A | ✓ |
| Classes | ✓ | N/A | ✓ |
| Recursive loading | ✓ | N/A | ✘ |
| Loading and unloading | ✓ | N/A | ✓ |
| Reloading | ✓ | N/A | ✓ |
| Directory watch | ✓ | N/A | ✓ |

### Events

Frameworks might fire events depending on whenever a command is reloaded or unloaded.

`/` indicates that it has the event in some form but not emitted.

| Events | SuperToast | Toast | Commandia |
| ------ | ---------- | ----- | --------- |
| Module event listeners | ✓ | N/A | ✓ |
| On invalid commands | ✘ | ✘ | ✘ |
| On command blocked | / | ✘ | ✘ |
| On command start | ✘ | ✓ | ✘ |
| On command end | ✘ | ✓ | ✘ |
| On command error | ✓ | ✓ | ✓ |

### Settings

All frameworks should have some sort of config to configure how things are handled like owners.

Built-in features are marked with a `✓` means they exist and are modifiable. If they are marked with `✘` it means they exist but not modifiable. `∅` indicates that the feature doesn't exist.

| Settings | SuperToast | Toast | Commandia |
| -------- | ---------- | ----- | --------- |
| Modifiable built-in commands | ✘ | ✘ | ∅ |
| Modifiable built-in command handler | ✓ | ✓ | ✘ |
| Modifiable built-in responses | ✓ | ✘ | ✘ |
| Bot owner | ✓ | ✓ | ✓ |
| Multiple owners | ✓ | ✓ | ∅ |
| Module directories | ✓ | N/A | ✓ |
