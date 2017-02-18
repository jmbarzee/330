
module RudInt

push!(LOAD_PATH, ".")

using Error
using Lexer
export parse, calc, interp

#
# ===================================================
#

function collatz( n::Real )
  if ( n > 0 )
    return collatz_helper( n, 0 )
  else
    throw( LispError("Go away mr collatz"))
  end
end

function collatz_helper( n::Real, num_iters::Int )
  if n == 1
    return num_iters
  end
  if mod(n,2)==0
    return collatz_helper( n/2, num_iters+1 )
  else
    return collatz_helper( 3*n+1, num_iters+1 )
  end
end

#
# ===================================================
#

bDict = Dict(
  :+ => +,
  :- => -,
  :* => *,
  :/ => /,
  :% => mod
)

uDict = Dict(
  :- => -,
  :collatz => collatz
)

#
# ===================================================
#

abstract OWL

type Num <: OWL
	n::Real
end

type UnOp <: OWL
	op::Function
	val::OWL
end

type BinOp <: OWL
	op::Function
	lhs::OWL
	rhs::OWL
end

#
# ===================================================
#

function parse( expr::Any )
  throw(LispError("Tried to parse variable of type ::Any"))
end

function parse( expr::Real )
  return Num( expr )
end

function parse( expr::String )
  println(expr)
end

function parse( expr::Array{Any} )
  if length( expr ) == 3
    if haskey( bDict, expr[1] )
      f = bDict[expr[1]]
      return BinOp( f, parse(expr[2]), parse(expr[3]) )
    else
      throw(LispError("No matching binary op"))
    end
  elseif length(expr) == 2
    if haskey( uDict, expr[1] )
      f = uDict[expr[1]]
      return UnOp( f, parse(expr[2]) )
    else
      throw(LispError("No matching uinary op"))
    end
  else
    throw(LispError("No matching op"))
  end
end

#
# ===================================================
#

function interp( cs::AbstractString )
  lxd = Lexer.lex( cs )
  ast = parse( lxd )
  #return calc( ast, mtEnv() )
end

#
# ===================================================
#

function calc( owl::Num)
  return owl.n
end

function calc( owl::BinOp)
  lhs = calc(owl.lhs)
  rhs = calc(owl.rhs)
  if owl.op == bDict[:/] && rhs == 0
    throw(LispError("NO"))
  end
  if owl.op == bDict[:%] && rhs == 0
    throw(LispError("NO"))
  end
  return owl.op(lhs, rhs)
end

function calc( owl::UnOp)
  return owl.op(calc(owl.val))
end

end # module
