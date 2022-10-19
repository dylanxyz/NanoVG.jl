asset(path::String) = normpath(joinpath(@__DIR__, "assets", path))

macro asset(path)
    Expr(:call, :asset, esc(path))
end

macro asset_str(path)
    Expr(:call, :asset, esc(path))
end

const THEN = Ref(time())
const TIME = Ref(0.0)

Base.@kwdef mutable struct TimeInfo
    then::Float64 = time()
    now::Float64 = 0.0
    elapsed::Float64 = 0.0
    frametime::Float64 = 0.0
    framerate::Float64 = 0.0
end

function update!(info::TimeInfo)
    info.now = time()
    info.frametime = info.now - info.then
    info.elapsed += info.frametime
    info.framerate = 1 / info.frametime
    info.then = info.now
end
