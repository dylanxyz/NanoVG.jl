using NanoVG
using Test
using GLFW
using Colors
using Printf
using ModernGL

include(joinpath(@__DIR__, "../examples/utils.jl"))
include(joinpath(@__DIR__, "../examples/demo.jl"))
include(joinpath(@__DIR__, "../examples/perf.jl"))

const settings = Demo.settings

@testset "NanoVG.jl" begin
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)
    GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, true)
    GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)

    window = GLFW.CreateWindow(settings.width, settings.height, settings.title)
    @assert window != C_NULL "Could not create a GLFW window 😥"

    GLFW.MakeContextCurrent(window)
    GLFW.SwapInterval(settings.vsync)

    NanoVG.create(NanoVG.GL3, antialiasing=true)
    Demo.setup()

    time = TimeInfo()
    fpsGraph = PerfGraph(GRAPH_RENDER_FPS, "Frame Time")
    cpuGraph = PerfGraph(GRAPH_RENDER_MS,  "CPU Time")

    update!(time)
    width, height = GLFW.GetFramebufferSize(window)
    winWidth, winHeight = GLFW.GetWindowSize(window)
    dpr = width / winWidth

    mouse = GLFW.GetCursorPos(window)
    glViewport(0, 0, width, height)
    NanoVG.frame(winWidth, winHeight, dpr)
    Demo.draw(width, height, time.elapsed, mouse)

    render(fpsGraph, 5, 5)
    render(cpuGraph, 5 + 200 + 5, 5)

    cpuTime = 1e-9 * time_ns() - time.now
    update!(fpsGraph, time.frametime)
    update!(cpuGraph, cpuTime)

    NanoVG.render()

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    Demo.dispose()
    NanoVG.dispose()
    GLFW.DestroyWindow(window)
end
