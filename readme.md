<div align="center">
<img src="https://imgur.com/BMLeRmx.png" width="25%">
<h1>SuperToast</h1>

[Docs](https://SovietKitsune.github.io/SuperToast) |
[Comparison](./topics/comparison.md)

</div>

<div align="center">
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="Github Documentation Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Documentation?style=flat-square&label=docs">
    </a>
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="GitHub Testing Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Testing%20and%20linting?style=flat-square&label=tests">
    </a>
    <a href="https://github.com/XAMPPRocky/tokei">
        <img alt="Lines of Code" src="https://img.shields.io/tokei/lines/github/sovietkitsune/supertoast?style=flat-square">
    </a>
</div>

<br/>

## About

SuperToast is a Discordia command framework designed for ease of use.

## Installation

You can install SuperToast using `lit`, the package manager of luvit:

```sh
lit install SovietKitsune/SuperToast
```

## Features

* **Dotenv parsing:** SuperToast can be able to parse your `.env` files where you can store secrets. The file format is easy to understand and allows you to keep all your secrets within a secret file.
* **Typed interfaces:** SuperToast tends to tell you what you did wrong. If you try to pass a number to `Client:addCommand`, it'll tell you it expected a command instead. This can help make debugging easier.
* **Useful utility classes and modules:** SuperToast has utility modules like a `.env` parser, millisecond humanizer, string manipulation, command hot reloading and more!
* **EmmyLua types:** SuperToast uses EmmyLua in order for you to get intellisense while making your bot which, again, helps decrease the time debugging. Read more about it on the [documentation](./topics/types.md)
* **Argument parsing:** Out of the box, SuperToast has a fast argument parser which is persistent through errors and gives readable, understandable error messages. Read more about it in the [documentation](./topics/arguments.md)
* **Hot reloading:** SuperToast has a new `CommandUtil` class which provides hot reloading functionality in as little as 4 lines of code.
* **Checks and walls:** Sometimes you might need to validate permissions or check that the user meets certain requirements. This can be done with simple function calls within the `Command` class. Whenever one of these checks fails, it falls onto the errorHandler. More can be learned in the [documentation](./topics/command-checks.md)

## Types

SuperToast uses EmmyLua and also includes types for all Discordia objects.

In our example, we can view the types of the `msg` object as seen below.

![EmmyLua types](https://imgur.com/gEHl84g.png)

This allows for easier use as you don't need to look at the docs constantly.

(Note: Types on callbacks don't work on Lua by Sumneko)
