# Kronos.vim [![Build Status](https://travis-ci.org/soywod/kronos.vim.svg?branch=master)](https://travis-ci.org/soywod/kronos.vim)

A simple task and time manager for vim.

<p align="center">
<img width="1068" src="https://user-images.githubusercontent.com/10437171/41814954-1a80cba8-775d-11e8-9b9e-10d4c604aab3.png"></img>
</p>

## Table of contents

  * [Introduction](#introduction)
  * [Usage](#usage)
    * [Add](#add)
    * [Update](#update)
    * [Worktime](#worktime)
    * [Context](#context)
  * [Mappings](#mappings)
    * [List](#klist)
    * [Info](#info)
  * [Configuration](#configuration)
    * [Context](#context-1)
    * [Hide done tasks](#hide-done-tasks)
    * [Database](#database)
    * [Gist sync](#gist-sync)
  * [License](#license)
  * [Bugs](#bugs)
  * [Contributing](#contributing)
  * [Changelog](#changelog)
  * [Credits](#credits)

## Introduction

Kronos is a simple task and time manager for vim, inspired by [Taskwarrior](https://taskwarrior.org) and [Timewarrior](https://taskwarrior.org/docs/timewarrior).

[Taskwarrior](https://taskwarrior.org) and [Timewarrior](https://taskwarrior.org/docs/timewarrior) are very good and complete tools, but complex and not so easy to understand. [Kronos](https://github.com/soywod/kronos.vim) aims to unify both tools in one, and to be more simple (focusing on what it's really needed).

## Usage

Kronos comes with a unique command and its alias:

```vim
:Kronos <command> <args>
:K      <command> <args>
```

Here the list of all available commands with their alias:

```vim
:Kronos                        " Start the GUI
:Kronos l(ist)                 " List all tasks
:Kronos i(nfo)     <id>        " Show task informations
:Kronos del(ete)   <id>        " Delete a task
:Kronos a(dd)      <args>      " Add a new task
:Kronos u(pdate)   <id> <args> " Update a task
:Kronos sta(rt)    <id>        " Start a task
:Kronos sto(p)     <id>        " Stop a task
:Kronos t(oggle)   <id>        " Start or stop a task
:Kronos d(one)     <id>        " Mark as done a task
:Kronos w(orktime) <tags>      " Show the total worktime for a task
:Kronos c(ontext)  <tags>      " Define a context by tags
```

### Add

To add a new task:

```vim
:Kronos add <desc> <tags> <due>
```

A **tag** must start by `+` and should not contain any space. Eg:

```vim
:K a +tag +tag-2 +tag_3
```

A **due** must start by `:` and should contain numbers only.  The full format of a valid due is `:DDMMYY:HHMM` but almost everything can be omitted. Here some example to understand better the concept:

  - *\<day\>   means the current day (day when the command is executed)*
  - *\<month\> means the current month*
  - *\<year\>  means the current year*

Full due:

```vim
:K a :100518:1200 " 10th of May 2018, 12h00
```

If minutes omitted, set to `00`:

```vim
:K a :100518:12   " 10th of May 2018, 12h00
```
If hours omitted, set to `00`:

```vim
:K a :100518      " 10th of May 2018, 00h00
```

If years omitted, try first the current year. If the final date is exceeded, try with the next year:

```vim
:K a :1005        " 10th of May <year> or <year>+1, 00h00
```

If months omitted, try first the current month. If the final date is exceeded, try with the next month:

```vim
:K a :10          " 10th of <month> or <month>+1 <year>, 00h00
```

If days omitted, try first the current day. If the final date is exceeded try with the next day:

```vim
:K a :            " <day> or <day>+1 of <month> <year>, 00h00
:K a ::8          " <day> or <day>+1 of <month> <year>, 08h00
```

All together:

```vim
" Command executed on 1st of March, 2018 at 21h21
:K a my awesome task +firstTask :3:18 +awesome
```

will result in:

```json
{
  "desc": "my awesome task",
  "tags": ["firstTask", "awesome"],
  "due": "3rd of March 2018, 18h00"
}
```

The order is not important, tags can be everywhere, and due as well. The desc is the remaining of text present after removing tags and due. Both examples end up with the same result:

```vim
:K a my awesome task +firstTask :3:18 +awesome
:K a my +awesame awesome :3:18 +firstTask task
```

### Update

To update a task:

```vim
:Kronos update <id> <desc> <tags> <due>
```

Same usage as [kronos-add](#add), except for **tags**. You can remove an existing tag by prefixing it with a `-`.

For eg., to remove **oldtag** and add **newtag** to task **42**:

```vim
:K u 42 -oldtag +newtag
```

### Worktime

To print the total worktime for a tag:

```vim
:Kronos worktime <tags>
```

Eg., to print the total worktime for tags **tag1** and **tag2**:

```vim
:K w tag1 tag2
```

### Context

To define a context by tags:

```vim
:Kronos context <tags>
```
Eg., to define a context for tag **project1** :

```vim
:K c project1
```

Only tasks with tag **project1** will be displayed in the [list](#list).

If a new task is added with a context set, it will automatically get the tag
**project1** .

To clear the context, just enter an empty one.

## Mappings

To start the GUI mode:

```vim
:Kronos " or simply :K
```

There is 2 different types of buffer (filetype): **klist** and **kinfo** (for tasks list and task info). When you start the GUI mode, you arrive on the **klist** buffer.

### klist

| Action | Mapping | Info |
| --- | :---: | --- |
| Add | `<a>` | Args will be prompted (see [kronos-add](#add)) |
| Show info | `<i>` | Open the **kinfo** buffer (see [kronos-kinfo](#kinfo)) |
| Update | `<u>` | Args will be prompted (see [kronos-update](#update)) |
| Delete | `<Backspace>`, `<Del>` | Confirmation will be prompted |
| Start | `<s>` | Start the task under cursor |
| Stop | `<S>` | Stop the task under cursor |
| Toggle | `<Enter>`, `<t>` |  Start or stop the task under cursor |
| Done | `<D>` | Mark task under cursor as done |
| Undone | `<U>` | Mark task under cursor as undone |
| Context | `<C>` | Define a context by tags |
| Refresh | `<r>` | Refresh all the GUI |
| Toggle hide done | `<H>` | Show or hide done tasks |
| Quit | `<q>`, `<Esc>` | Quit the GUI mode |

### kinfo

| Action | Mapping | Info |
| --- | :---: | --- |
| Quit | `<q>`, `<i>`, `<Escape>` | Quit the GUI info mode |

## Configuration

### Context

Define a context by default:

```vim
g:kronos_context = <string[]>
```

Default: `[]`

Hide done tasks by default:

```vim
g:kronos_hide_done = <boolean>
```

Default: `1`

### Database

Path to the database file:

```vim
g:kronos_database = <path>
```

Default: `<KRONOS_ROOT_DIR>/kronos.db`

### Gist sync

Enable [Gist](https://gist.github.com/) sync feature:

```vim
g:kronos_gist_sync = <boolean>
```

This option will synchronize your local [database](#database) with a secret Gist, so it can be used by other clients, or just act as a backup.

The first time you activate this option, you will need to restart Vim, and a **GitHub token** will be prompted. To get one, [go to this page](https://github.com/settings/tokens), click on **Generate new token**, and check gist scope:

```
Token description: kronos
Select scopes
  [X] gist         Create gists
```

This feature requires `Vim 8+`, with `+job` option. A port to `Neovim` is not planed yet, feel free to contribute. 

Default: `0`

## Contributing

 Git commit messages follow the [Angular Convention](https://gist.github.com/stephenparish/9941e89d80e2bc58a153), but contain only a subject.

  > Use imperative, present tense: “change” not “changed” nor “changes”<br>Don't capitalize first letter<br>No dot (.) at the end

Vim code should be as clean as possible, variables use the lowercase abbreviation convention, functions use camel case and constants the uppercase snake case. A line should never contain more than `80` characters.

Tests should be added for each new functionality. Be sure to run tests before proposing a pull request (via the script `run-tests.sh`)

## Changelog

  - **Jul. 05**, *2018* - Add context by tags
  - **Jun. 26**, *2018* - Implement Gist sync feature
  - **Jun. 25**, *2018* - Add ability to mark tasks as undone
  - **Jun. 24**, *2018* - Add option to show or hide done tasks
  - **Jun. 23**, *2018* - Init changelog

## Credits

  - [Taskwarrior](https://taskwarrior.org), a task manager
  - [Timewarrior](https://taskwarrior.org/docs/timewarrior), a time manager
  - [vim-taskwarrior](https://github.com/blindFS/vim-taskwarrior), a very good Taskwarrior wrapper for vim

