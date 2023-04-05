module VisdomLog
export Visdom, report, scatter, save
using PyCall

struct Visdom
  vis::PyObject
end

"Start a new visdom environment"
function Visdom(env::String)
  visdom = pyimport(:visdom)
  vd = visdom[:Visdom](env=env)
  Visdom(vd)
end

pathstr(a::String) = a
pathstr(a::Symbol) = String(a)
pathstr(a::Tuple) = join(pathstr.(a), ".")

"Save state to disk"
function save(vd::Visdom, envs)
  vd.vis[:save](envs)
end

"Add a value to a log of results"
function report(l, k, x::Number, y::Number; log=true, scatter=false)
  ytype = log ? "log" : "linear"
  kstr = pathstr(k)
  f = scatter ? l.vis[:scatter] : l.vis[:line]
  f(win=kstr, X=[x], Y=[y], update="append",
      opts=Dict(:ytype=>ytype, :title=>kstr))
end
              
"Display a histogram of current results"
function report(l, k, vals::AbstractArray{<: Number})
  kstr = pathstr(k)
  l.vis[:histogram](win=kstr, X=vals[:], opts=Dict(:ytype=>"log", :title=>kstr));
end

function scatter(l::Visdom, k, xs)
  kstr = pathstr(k)
  l.vis[:scatter](win=kstr, X=xs, opts=Dict(:title=>kstr));
end

"Plot a comparison of current results"
function report(l, k, (xs, ys, legend)::Tuple{AbstractVector,AbstractMatrix{<: Number},AbstractVector})
  kstr = pathstr(k)
  l.vis[:line](win=kstr, X=xs, Y=ys, opts=Dict(:legend=>legend, :title=>kstr))
end

"Plot a comparison of current results"
function report(l, k, (xs, ys)::Tuple{AbstractArray,AbstractArray{<: Number}})
  kstr = pathstr(k)
  l.vis[:line](win=kstr, X=xs, Y=ys, opts=Dict(:title=>kstr))
end

end
