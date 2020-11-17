=========
Examples
=========

Some quick examples to get you started on a bot

Ping command
-------------

Here is the basic ping command.

.. literalinclude:: ../examples/ping.lua
    :language: lua
    :emphasize-lines: 1
    :linenos:

In line 1 we see a type definition, it is recommended to have this.

Embeds
-------

Embeds are quite simple to make with SuperToast

.. literalinclude:: ../examples/embeds.lua
    :language: lua
    :emphasize-lines: 12-16
    :linenos:
    :name: embeds.lua

We see that we use ``embed:send(msg.channel)`` but we could also use ``msg:reply(embed:toJSON())``