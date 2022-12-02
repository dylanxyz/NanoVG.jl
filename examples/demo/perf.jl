@enum GraphRenderStyle begin
    GRAPH_RENDER_FPS
    GRAPH_RENDER_MS
end

const GRAPH_HISTORY_COUNT = 100

mutable struct PerfGraph
    style ::GraphRenderStyle
    name  ::String
    values::Vector{Cfloat}
    head  ::Cint
    PerfGraph() = new()
end

function PerfGraph(style, name)
    fps = PerfGraph()
    fps.values = zeros(Cfloat, GRAPH_HISTORY_COUNT)
    fps.style = style
    fps.name = name
    fps.head = 0
    return fps
end

const GPU_QUERY_COUNT = 5

mutable struct GPUtimer
    supported::Bool
    curr::Cint
    ret ::Cint
    queries::Vector{Cuint}
end

GPUtimer() = GPUtimer(true, 0, 0, zeros(Cuint, GPU_QUERY_COUNT))

function start!(timer::GPUtimer)
    if !timer.supported
        return
    end

    glBeginQuery(GL_TIME_ELAPSED, timer.queries[timer.curr % GPU_QUERY_COUNT + 1])
    timer.curr += 1
end

function stop!(timer::GPUtimer)
    available = Ref(1)
    n = 0

    if !timer.supported
        return 0
    end

    glEndQuery(GL_TIME_ELAPSED)

    while (Bool(available) && timer.ret <= timer.curr)
        glGetQueryObjectiv(
            timer.queries[timer.ret % GPU_QUERY_COUNT],
            GL_QUERY_RESULT_AVAILABLE,
            available
        )
    end

    return n
end

function update!(fps::PerfGraph, frametime::Real)
    fps.head = (fps.head + 1) % GRAPH_HISTORY_COUNT
    fps.values[fps.head + 1] = frametime
end

function average(fps::PerfGraph)
    N = GRAPH_HISTORY_COUNT
    return sum(@view fps.values[1:N]) / N
end

function render(fps::PerfGraph, x::Real, y::Real)
    avg = average(fps)

    w = 200
    h = 35

    fillcolor(rgba(0, 128))
    rect(x, y, w, h, :fill)

    beginpath()
    moveto(x, y + h)

    if fps.style == GRAPH_RENDER_FPS
        for i in 0:GRAPH_HISTORY_COUNT - 1
            v = 1.0 / (0.00001 + fps.values[((fps.head + i) % GRAPH_HISTORY_COUNT) + 1])
            v = v <= 80 ? v : 80
            vx = x + (i / (GRAPH_HISTORY_COUNT - 1)) * w
            vy = y + h - ((v / 80) * h)
            lineto(vx, vy)
        end
    else
        for i in 0:GRAPH_HISTORY_COUNT - 1
            v = fps.values[((fps.head + i) % GRAPH_HISTORY_COUNT) + 1] * 1000
            v = v <= 20 ? v : 20
            vx = x + (i / (GRAPH_HISTORY_COUNT - 1)) * w
            vy = y + h - ((v / 20.0) * h)
            lineto(vx, vy)
        end
    end

    lineto(x + w, y + h)
    fillcolor(rgba(255, 192, 0, 128))
    fillpath()

    fontface("sans")

    if !isempty(fps.name)
        fontsize(12)
        textalign(:left, :top)
        fillcolor(rgba(240, 240, 240, 192))
        text(fps.name, x + 3, y + 3)
    end

    if fps.style == GRAPH_RENDER_FPS
        fontsize(15)
        textalign(:right, :top)
        fillcolor(rgba(240, 240, 240, 255))
        str = string(round(1.0 / avg, digits=2), " FPS")
        text(str, x + w - 3, y + 3)

        fontsize(13.0)
		textalign(:right, :baseline)
		fillcolor(rgba(240, 240, 240, 160))
        str = string(round(1000avg, digits=2), " ms")
		text(str, x + w - 3, y + h - 3)
    else
        fontsize(15.0)
		textalign(:right, :top)
		fillcolor(rgba(240, 240, 240, 255))
        str = string(round(1000 * avg, digits=2), " ms")
		text(str, x + w - 3, y + 3)
    end
end
