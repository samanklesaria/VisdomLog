module VisdomLog
export Visdom, report, inform
using PyCall
@pyimport visdom
@pyimport numpy as np

struct Visdom
  vis::PyObject
  d::Dict{Symbol,Union{Nothing, Pair{PyObject,Any}}}
end

function Visdom(env::String, ks::Array{Symbol})
  vd = visdom.Visdom(env=env)
  Visdom(vd, Dict(k=>nothing for k in ks))
end
    
function report(l, k::Symbol, y)
  if l.d[k] == nothing
    win = l.vis[:line](X=[1], Y=[y], opts=Dict(:title=>String(k)))
    l.d[k] = (win => 2)
  else
    (win, x) = l.d[k]
    l.vis[:line](win=win, X=[x], Y=[y], update="append", opts=Dict("ytype"=>"log"))
    l.d[k] = (win => x + 1)
  end
end

function inform(l, k::Symbol, vals)
  if l.d[k] == nothing
    win = l.vis[:histogram](X=vals[:], opts=Dict(:title=>String(k)))
    l.d[k] = win
  else
    (win, x) = l.d[k]
    l.vis[:histogram](win=win, X=vals[:], opts=Dict("ytype"=>"log"))
  end
end
end

