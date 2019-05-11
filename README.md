# Kronos.vim [![Build Status](https://travis-ci.org/soywod/kronos.vim.svg?branch=master)](https://travis-ci.org/soywod/kronos.vim)
A simple task and time manager.

<p align="center">
  <img src="https://user-images.githubusercontent.com/10437171/50441115-77205f80-08f9-11e9-97d4-b7b64741d8f2.png"></img>
</p>

## Table of contents

  * [Usage](#usage)
    * [Create](#create)
    * [Read](#read)
    * [Update](#update)
    * [Start/stop](#startstop)
    * [Done](#done)
    * [Hide done tasks](#hide-done-tasks)
    * [Context](#context)
    * [Worktime](#worktime)
    * [Delete](#delete)
  * [Mappings](#mappings)
  * [Contributing](#contributing)
  * [Changelog](#changelog)
  * [Credits](#credits)

## Usage

```vim
:Kronos
```

Then you can create, read, update, delete tasks using Vim mapping. The table
will automatically readjust when you save the buffer (`:w`).

### Create

To create a task, you can:

- Write or copy a full table line: `|id|desc|tags|active|due|`
- Write a Kronos create format: `<desc> <+tag> <:due>`

![Create
task](https://user-images.githubusercontent.com/10437171/50438709-61a63800-08ef-11e9-8f49-aa02b6da7f3b.gif)

A tag should start by a `+`, and a due by a `:`.

A due should start by a `:`, and should follow this pattern: `:DDMMYY:HHMM`.
Not all digits are required. Actually, Kronos tries to find the closest date
matching your due pattern. Here some use cases:

*Note: the date format is DD/MM/YYYY HH:MM*

| Current date | Given pattern | Output |
| --- | --- | --- |
| 03/03/2019 21:42 | `:4` | 04/03/2019 00:00 |
| 03/03/2019 21:42 | `:2` | 02/04/2019 00:00 |
| 03/03/2019 21:42 | `:0304` or `:034` | 03/04/2019 00:00 |
| 03/03/2019 21:42 | `:3004` or `304` | 30/04/2019 00:00 |
| 03/03/2019 21:42 | `:0202` | 02/02/2020 00:00 |
| 03/03/2019 21:42 | `:020221` | 02/02/2021 00:00 |
| 03/03/2019 21:42 | `::22` | 03/03/2019 22:00 |
| 03/03/2019 21:42 | `::19` | 04/03/2019 19:00 |
| 03/03/2019 21:42 | `:4:2150` | 04/03/2019 21:50 |

### Read

To show focused task details, press `<K>`:

![Read
task](https://user-images.githubusercontent.com/10437171/50438871-2f490a80-08f0-11e9-9ef9-a016a898947d.gif)

### Update

To update a task, just edit the cell and save:

![Update
task](https://user-images.githubusercontent.com/10437171/50439213-7e436f80-08f1-11e9-8180-965d52ab7d52.gif)

For the `due` field, you need to use the date [Kronos create
format](https://github.com/soywod/kronos.vim#create) (eg: `:18`, `:20:1230`...).

### Start/stop

To start/stop a task, press `<Enter>`:

![Start/stop
task](https://user-images.githubusercontent.com/10437171/50439087-fcebdd00-08f0-11e9-8853-54639eaa2146.gif)

### Done

To mark a task as done, delete the line:

![Done
task](https://user-images.githubusercontent.com/10437171/50439278-c367a180-08f1-11e9-9729-86554b116479.gif)

### Hide done tasks

To show/hide done tasks, press `<gh>` (for `go hide`):

![Hide done
tasks](https://user-images.githubusercontent.com/10437171/50440820-278d6400-08f8-11e9-890c-b68d83f0f0fc.gif)

### Context

The context filters tasks by a list of tags. Once setup:

- You will see only tasks containing at least one tag of your context
- When you [create](#create) a task, all tags in your context will be assigned
  to it

To setup a context, press `gc` (for `go to context`), and type all tags you
want in your context (separated by spaces). Typing an empty context removes it:

![Set
context](https://user-images.githubusercontent.com/10437171/50439628-09713500-08f3-11e9-88e0-a5ed72c9134e.gif)

### Worktime

The worktime allows you to check how much time you spent on one or many tags,
grouped by day. Press `gw` (for `go to worktime`), and type the tags you want
to calculate the total worktime:

![Worktime](https://user-images.githubusercontent.com/10437171/50560067-2182f300-0cfd-11e9-95bc-6b3ce1f23535.gif)

### Delete

To delete a task, delete the line when [done tasks are
shown](#hide-done-tasks):

![Delete
task](https://user-images.githubusercontent.com/10437171/50439349-0295f280-08f2-11e9-8c26-e9f67698c59c.gif)

## Mappings

| Function | Mapping |
| --- | --- |
| Jump to the next cell | `<Tab>`, `<C-n>` |
| Jump to the prev cell | `<S-Tab>`, `<C-p>` |
| Change in cell | `cic` |
| Visual in cell | `vic` |
| Delete in cell | `dic` |
| [Show task infos](#read) | `K` |
| [Hide/show done tasks](#hide-done-tasks) | `gh` |
| [Set context](#context) | `gc` |
| [Show worktime](#worktime) | `gw` |

## Contributing

Git commit messages follow the [Angular
Convention](https://gist.github.com/stephenparish/9941e89d80e2bc58a153), but
contain only a subject.

  > Use imperative, present tense: “change” not “changed” nor
  > “changes”<br>Don't capitalize first letter<br>No dot (.) at the end

Code should be as clean as possible, variables and functions use the snake case
convention. A line should never contain more than `80` characters.

Tests should be added for each new functionality. Be sure to run tests before
proposing a pull request.

## Changelog

- **May. 11, 2019** - Remove sync support due to too many complications
- **Dec. 31, 2018** - Worktime is now calculated also per day
- **Dec. 26, 2018** - Refactor interface
  ([Vimwiki](https://github.com/vimwiki/vimwiki) like)
- **Oct. 18, 2018** - ~Refactor code to match the [Kronos
  protocol](https://github.com/soywod/kronos)~
- **Jul. 05, 2018** - Add context by tags
- **Jun. 26, 2018** - ~Implement Gist sync feature~
- **Jun. 25, 2018** - Add ability to mark tasks as undone
- **Jun. 24, 2018** - Add option to show or hide done tasks
- **Jun. 23, 2018** - Init changelog

## Credits

- [Taskwarrior](https://taskwarrior.org), a task manager
- [Timewarrior](https://taskwarrior.org/docs/timewarrior), a time manager
- [vim-taskwarrior](https://github.com/blindFS/vim-taskwarrior), a
  Taskwarrior wrapper for vim
- [Vimwiki](https://github.com/vimwiki/vimwiki)
