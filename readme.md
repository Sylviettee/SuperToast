<div align="center">
<p>
    <svg width="250" height="250" viewBox="0 0 597 588" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="299" cy="312" r="276" fill="#F9F9F9"/>
        <circle cx="298.5" cy="312.5" r="259.5" fill="#F5F5F5"/>
        <path d="M550.002 248.933C488.735 179.045 447.119 146.255 334.657 121.415C325.104 88.8916 322.429 70.3064 264.779 92.8081C209.832 123.03 201.359 143.297 185.34 179.309C80.5796 217.183 37.3419 271.035 49.8051 316.796C62.2683 362.556 110.221 325.059 98.0658 352.255C148.805 414.992 196.822 445.129 284.812 498.988C372.467 388.187 430.096 333.078 550.002 248.933Z" fill="#F0BF85"/>
        <path d="M282.529 501.14L284.812 498.988M284.812 498.988C372.467 388.187 430.096 333.078 550.002 248.933C488.735 179.045 447.119 146.255 334.657 121.415C325.104 88.8916 322.429 70.3064 264.779 92.8081C209.832 123.03 201.359 143.297 185.34 179.309C80.5796 217.183 37.3419 271.035 49.8051 316.796C62.2683 362.556 110.221 325.059 98.0658 352.255C148.805 414.992 196.822 445.129 284.812 498.988Z" stroke="#563B1B" stroke-width="10"/>
        <path d="M529.458 435.953C513.936 344.317 495.694 294.575 412.958 214.453C421.878 181.75 429.345 164.522 368.458 153.453C305.823 150.375 287.982 163.189 255.458 185.453C146.395 162.77 81.3406 185.953 67.958 231.453C54.5754 276.953 115.069 270.17 90.458 286.953C100.766 366.979 125.849 417.818 172.53 509.817C305.268 461.434 383.236 444.727 529.458 435.953Z" fill="#F0BF85"/>
        <path d="M169.458 510.453L172.53 509.817M172.53 509.817C305.268 461.434 383.236 444.727 529.458 435.953C513.936 344.317 495.694 294.575 412.958 214.453C421.878 181.75 429.345 164.522 368.458 153.453C305.823 150.375 287.982 163.189 255.458 185.453C146.395 162.77 81.3406 185.953 67.958 231.453C54.5754 276.953 115.069 270.17 90.458 286.953C100.766 366.979 125.849 417.818 172.53 509.817Z" stroke="#563B1B" stroke-width="10"/>
        <rect x="234" y="268.87" width="108.484" height="108.484" transform="rotate(-11.0916 234 268.87)" fill="#EDDC40"/>
        <rect x="251" y="282.323" width="79.6496" height="79.6496" transform="rotate(-11.0916 251 282.323)" fill="#F5E65F"/>
    </svg>
</p>
<h1>SuperToast</h1>

[Docs](https://SovietKitsune.github.io/SuperToast) |
[Comparison](./topics/comparison.md)

</div>

<div align="center">
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="Github Documentation Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Documentation?style=flat-square">
    </a>
    <a href="https://github.com/SovietKitsune/SuperToast/actions">
        <img alt="GitHub Testing Status" src="https://img.shields.io/github/workflow/status/sovietkitsune/supertoast/Testing%20and%20linting?style=flat-square">
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
