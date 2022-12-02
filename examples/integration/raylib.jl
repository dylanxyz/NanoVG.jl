using Raylib
using NanoVG
using Printf

include("../utils.jl")
include("../demo.jl")
include("../perf.jl")

const settings = Demo.settings

const config = let flags = 0
    flags |= settings.vsync ? Raylib.FLAG_VSYNC_HINT : 0
    flags |= Raylib.FLAG_WINDOW_RESIZABLE
    flags |= Raylib.FLAG_MSAA_4X_HINT
end

function main()
    Raylib.SetConfigFlags(config)
    Raylib.InitWindow(settings.width, settings.height, settings.title)
    # create a NanoVG context
    NanoVG.create(NanoVG.GL3)

    Demo.setup()

    fpsGraph = PerfGraph(GRAPH_RENDER_FPS, "Frame Time")
    cpuGraph = PerfGraph(GRAPH_RENDER_MS,  "CPU Time")
    time = TimeInfo()

    while !Raylib.WindowShouldClose()
        update!(time)

        Raylib.BeginDrawing()
        dpi = Raylib.GetWindowScaleDPI()
        mouse = Raylib.GetMousePosition()
        width = Raylib.GetScreenWidth()
        height = Raylib.GetScreenHeight()
        # create a new frame
        NanoVG.frame(width, height, dpi.x)
        # draw stuff
        Demo.draw(width, height, time.elapsed, mouse)

        render(fpsGraph, 5, 5)
        render(cpuGraph, 5 + 200 + 5, 5)

        cpuTime = 1e-9 * time_ns() - time.now
        update!(fpsGraph, time.frametime)
        update!(cpuGraph, cpuTime)

        # render the frame
        NanoVG.render()
        Raylib.EndDrawing()
    end

    Demo.dispose()
    # Deletes the NanoVG context
    NanoVG.dispose()
    Raylib.CloseWindow()
end

main()
