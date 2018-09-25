module VisdomLog
export Visdom, report
using PyCall
using PyPlot: Figure

struct Visdom
  vis::PyObject
  d::Dict{Symbol, Pair{PyObject,Any}}
end

"Start a new visdom environment"
function Visdom(env::String)
  visdom = pyimport(:visdom)
  vd = visdom[:Visdom](env=env)
  Visdom(vd, Dict{Symbol, Pair{PyObject,Any}}())
end
    
"Add a value to a log of results"
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

"Display a histogram of current results"
function report(l, k::Symbol, vals::Array{Float64})
  if !haskey(l.d, k)
    win = l.vis[:histogram](X=vals[:], opts=Dict(:title=>String(k)))
    l.d[k] = win=>nothing;
  else
    (win, _) = l.d[k]
    l.vis[:histogram](win=win, X=vals[:], opts=Dict(:ytype=>"log", :title=>String(k)));
  end
end

"Plot a comparison of current results"
function report(l, k::Symbol, xs::Vector, ys::Matrix{Float64}, legend::Vector)
  if !haskey(l.d, k)
    win = l.vis[:line](X=xs, Y=ys, opts=Dict(:legend=>legend, :title=>String(k)))
    l.d[k] = win=>nothing;
  else
    (win, _) = l.d[k]
    l.vis[:line](win=win, X=xs, Y=ys, update="replace",
      opts=Dict(:legend=>legend, :title=>String(k)));
  end
end

"Plot a matplotlib figure"
function report(l, k::Symbol, fig::Figure)
  if !haskey(l.d, k)
    win = l.vis[:matplot](plot=fig, opts=Dict(:title=>String(k)))
    l.d[k] = win=>nothing;
  else
    (win, _) = l.d[k]
    l.vis[:matplot](win=win, plot=fig, opts=Dict(:title=>String(k)));
  end
end

end
