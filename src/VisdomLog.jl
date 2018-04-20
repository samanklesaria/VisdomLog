module VisdomLog
export Visdom, report
using PyCall
@pyimport visdom
@pyimport numpy as np

struct Visdom
  vis::PyObject
  d::Dict{Symbol,Nullable{Pair{PyObject,Array{Int}}}}
end

Visdom(env::String, ks::Array{Symbol}) =
  Visdom(visdom.Visdom(env=env),
    Dict(k=>Nullable() for k in ks))
    
function report(l, k::Symbol, vals...)
  y = hcat(vals...)'
  if isnull(l.d[k])
    x = (0:(length(vals) - 1)) .+ fill(1, length(vals[1]))'
    y = hcat(vals...)'
    win = l.vis[:line](X=x, Y=y, opts=Dict(:title=>String(k)))
    l.d[k] = Nullable(win => x + length(x))
  else
    (win, x) = get(l.d[k])
    l.vis[:line](win=win, X=x, Y=y, update="append")
    l.d[k] = Nullable(win => x + size(x)[2])
  end
end

end

