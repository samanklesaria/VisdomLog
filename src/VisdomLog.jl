__precompile__(false) 
module VisdomLog
export Visdom, report, matplot
using PyCall
@pyimport visdom
@pyimport numpy as np

struct Visdom
  vis::PyObject
  d::Dict{Symbol, Pair{PyObject,Any}}
end

function Visdom(env::String)
  vd = visdom.Visdom(env=env)
  Visdom(vd, Dict{Symbol, Pair{PyObject,Any}}())
end
    
function report(l, k::Symbol, y::Float64)
  if !haskey(l.d, k)
    win = l.vis[:line](X=[1], Y=[y], opts=Dict(:title=>String(k)))
    l.d[k] = (win => 2);
  else
    (win, x) = l.d[k]
    l.vis[:line](win=win, X=[x], Y=[y], update="append", opts=Dict(:ytype=>"log"))
    l.d[k] = (win => x + 1);
  end
end

function report(l, k::Symbol, vals::Array{Float64})
  if !haskey(l.d, k)
    win = l.vis[:histogram](X=vals[:], opts=Dict(:title=>String(k)))
    l.d[k] = win=>nothing;
  else
    (win, _) = l.d[k]
    l.vis[:histogram](win=win, X=vals[:], opts=Dict(:ytype=>"log", :title=>String(k)));
  end
end

function matplot(l, k::Symbol, fig)
  if !haskey(l.d, k)
    win = l.vis[:matplot](plot=fig, opts=Dict(:title=>String(k)))
    l.d[k] = win=>nothing;
  else
    (win, _) = l.d[k]
    l.vis[:matplot](win=win, plot=fig, opts=Dict(:title=>String(k)));
  end
end

end
