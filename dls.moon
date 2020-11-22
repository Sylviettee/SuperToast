require 'dsl'

-- Enter the dsl

command {
    name: 'hi'
    example: 'cool'
    execute: ->
        rich = embed {
            title: 'hi'
        }

        msg\reply rich
}

event 'messageCreate', ->
    p ctx

endDsl!

-- Out of the dsl

p dslOut
-- Contains all constructed commands within the dsl and the states required