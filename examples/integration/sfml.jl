using CSFML
using CSFML.LibCSFML

using NanoVG
using Printf

include("../utils.jl")
include("../demo.jl")
include("../perf.jl")

const settings = Demo.settings

function main()
    mode = sfVideoMode(settings.width, settings.height, 32)

    winSettings = Ref(sfContextSettings(
        24, #= depthBits =#
        8, #= stencilBits =#
        4, #= antialiasingLevel =#
        3, #= majorVersion =#
        2, #= minorVersion =#
        0, #= attributeFlags =#
        0, #= sRgbCapable =#
    ))

    window = sfWindow_create(mode, settings.title, sfResize | sfClose, winSettings)
    @assert window != C_NULL "Could not create a SFML window 😥"

    sfWindow_setActive(window, true)
    sfWindow_setVerticalSyncEnabled(window, settings.vsync)

    # create a NanoVG context
    NanoVG.create(NanoVG.GL3)
    Demo.setup()

    event = Ref{sfEvent}()
    time = TimeInfo()
    running = true

    fpsGraph = PerfGraph(GRAPH_RENDER_FPS, "Frame Time")
    cpuGraph = PerfGraph(GRAPH_RENDER_MS,  "CPU Time")

    while running
        # process events
        while Bool(sfWindow_pollEvent(window, event))
            # close window : exit
            if event.x.type == sfEvtClosed
                running = false
                sfWindow_close(window)
            end
        end
        # mouse position
        mouse = let pos = sfMouse_getPosition(window)
            pos.x, pos.y
        end
        # update time
        update!(time)
        # get the window size
        size = sfWindow_getSize(window)
        # create a new frame
        NanoVG.frame(size.x, size.y, 1.0f0)
        # Draw stuff
        Demo.draw(size.x, size.y, time.elapsed, mouse)

        render(fpsGraph, 5, 5)
        render(cpuGraph, 5 + 200 + 5, 5)

        cpuTime = 1e-9 * time_ns() - time.now
        update!(fpsGraph, time.frametime)
        update!(cpuGraph, cpuTime)

        # render the frame
        NanoVG.render()
        # update the window
        sfWindow_display(window)
    end

    Demo.dispose()
    NanoVG.dispose()
    sfWindow_destroy(window)
end

main()
