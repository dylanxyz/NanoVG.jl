using NanoVG
using CSFML
using CSFML.LibCSFML

const clock = sfClock_create()

function draw(window)
    background(rgb(8))

    time = sfClock_getElapsedTime(clock)
    elapsed = sfTime_asSeconds(time)
    mouse = sfMouse_getPosition(window)
    hue = 360 * (cos(π/12 * elapsed) + 1)

    fillcolor(hsl(hue, 0.75, 0.65))
    circle(mouse.x, mouse.y, 64.0, :fill)
end

function main()
    mode = sfVideoMode(800, 600, 32)

    winSettings = Ref(sfContextSettings(
        24, #= depthBits =#
        8, #= stencilBits =#
        4, #= antialiasingLevel =#
        3, #= majorVersion =#
        2, #= minorVersion =#
        0, #= attributeFlags =#
        0, #= sRgbCapable =#
    ))

    window = sfWindow_create(mode, "NanoVG && SFML", sfResize | sfClose, winSettings)
    @assert window != C_NULL "Could not create a SFML window 😥"

    sfWindow_setActive(window, true)

    # create a NanoVG context
    NanoVG.create(NanoVG.GL3)

    event = Ref{sfEvent}()
    running = true

    while running
        # process events
        while Bool(sfWindow_pollEvent(window, event))
            # close window : exit
            if event.x.type == sfEvtClosed
                running = false
                sfWindow_close(window)
            end
        end

        # get the window size
        size = sfWindow_getSize(window)
        # create a new frame
        NanoVG.frame(size.x, size.y, 1.0f0)
        # drawing functions should be called here
        draw(window)
        # render the frame
        NanoVG.render()
        # update the window
        sfWindow_display(window)
    end

    NanoVG.dispose()
    sfWindow_destroy(window)
end

main()
