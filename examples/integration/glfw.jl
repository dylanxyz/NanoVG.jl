using GLFW
using NanoVG
using ModernGL
using Printf

include("../utils.jl")
include("../demo.jl")
include("../perf.jl")

const settings = Demo.settings

GLFW.SetErrorCallback() do error
    @error "[GLFW]" error = error
end

# Use OpenGL 3.2
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)
GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)

function main()
    window = GLFW.CreateWindow(settings.width, settings.height, settings.title)
    @assert window != C_NULL "Could not create a GLFW window 😥"

    GLFW.MakeContextCurrent(window)
    GLFW.SwapInterval(settings.vsync)

    # Create the NanoVG context with the GL3 implementation
    NanoVG.create(NanoVG.GL3, antialiasing=true)
    Demo.setup()

    fpsGraph = PerfGraph(GRAPH_RENDER_FPS, "Frame Time")
    cpuGraph = PerfGraph(GRAPH_RENDER_MS,  "CPU Time")

    time = TimeInfo()

    while !GLFW.WindowShouldClose(window)
        update!(time)
        # get window dimensions
        width, height = GLFW.GetFramebufferSize(window)
        winWidth, winHeight = GLFW.GetWindowSize(window)
        # dpr = device pixel ratio
        dpr = width / winWidth
        # get the mouse position
        mouse = GLFW.GetCursorPos(window)
        glViewport(0, 0, width, height)
        # create a new frame
        NanoVG.frame(winWidth, winHeight, dpr)
        # drawing functions should be called here
        Demo.draw(width, height, time.elapsed, mouse)

        render(fpsGraph, 5, 5)
        render(cpuGraph, 5 + 200 + 5, 5)

        cpuTime = 1e-9 * time_ns() - time.now
        update!(fpsGraph, time.frametime)
        update!(cpuGraph, cpuTime)

        # render the frame to the screen
        NanoVG.render()

        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    Demo.dispose()
    NanoVG.dispose()
    GLFW.DestroyWindow(window)
end

main()
