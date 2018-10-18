# Kronos.vim [![Build Status](https://travis-ci.org/kronos-io/kronos.vim.svg?branch=master)](https://travis-ci.org/kronos-io/kronos.vim)

A vim client for [Kronos protocol](https://github.com/kronos-io/kronos).

<p align="center">
  <img width="1068" src="https://user-images.githubusercontent.com/10437171/41814954-1a80cba8-775d-11e8-9b9e-10d4c604aab3.png"></img>
</p>

## Table of contents

  * [Introduction](#introduction)
  * [Usage](#usage)
    * [CLI](#cli)
    * [GUI](#gui)
  * [Config](#config)
    * [Database](#database)
    * [Hide done tasks](#hide-done-tasks)
    * [Context](#context)
    * [Sync](#sync)
    * [Sync host](#sync-host)
  * [Contributing](#contributing)
  * [Changelog](#changelog)
  * [Credits](#credits)

## Introduction

See [Kronos protocol](https://github.com/kronos-io/kronos#kronos-protocol).

## Usage
### CLI

Kronos comes with a unique command and its alias:

```vim
:Kronos <command> <args>
:K      <command> <args>
```

For examples, to create a new task with description 'my task', tag 'home' at
10:00 a.m. today or tomorrow, you can write one of the following command (same
result):

```vim
:Kronos add my task +home ::10
:Kronos ad +home ::10 my task
:K add my task ::10 +home
:K a my ::10 task +home
```

See [Kronos protocol](https://github.com/kronos-io/kronos#cli).

### GUI

You can start the GUI mode using the full command or its alias:

```vim
:Kronos
:K
```

See [Kronos protocol](https://github.com/kronos-io/kronos#gui).

## Config
### Database

Path to the database file:

```vim
g:kronos_database = <path>
```

Default: `<KRONOS_ROOT_DIR>/.database`

### Hide done tasks

Hide done tasks by default:

```vim
g:kronos_hide_done = <boolean>
```

Default: `1`

See [Kronos protocol](https://github.com/kronos-io/kronos#hide-done).

### Context

Define a context by default:

```vim
g:kronos_context = <string[]>
```

Default: `[]`

### Sync

Enable sync feature:

```vim
g:kronos_sync = <boolean>
```

Default: `0`

See [Kronos protocol](https://github.com/kronos-io/kronos#enable-sync).

### Sync host

Set sync host:

```vim
g:kronos_sync_host = <string>
```

Default: `localhost:5000`

See [Kronos protocol](https://github.com/kronos-io/kronos#host).

## Contributing

See [Kronos protocol](https://github.com/kronos-io/kronos#contributing).

## Changelog

  - `Oct. 18, 2018` - Refactor code to match the [Kronos protocol](https://github.com/kronos-io/kronos)
  - `Jul. 05, 2018` - Add context by tags
  - `Jun. 26, 2018` - Implement Gist sync feature
  - `Jun. 25, 2018` - Add ability to mark tasks as undone
  - `Jun. 24, 2018` - Add option to show or hide done tasks
  - `Jun. 23, 2018` - Init changelog

## Credits

  - [Taskwarrior](https://taskwarrior.org), a task manager
  - [Timewarrior](https://taskwarrior.org/docs/timewarrior), a time manager
  - [vim-taskwarrior](https://github.com/blindFS/vim-taskwarrior), a very good Taskwarrior wrapper for vim
