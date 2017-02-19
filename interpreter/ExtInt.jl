module ExtInt

push!(LOAD_PATH, ".")

using Error
using Lexer
import Base.==
export parse, calc, interp, exec
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
  :% => mod,
  :mod => mod
)
uDict = Dict(
  :- => -,
  :collatz => collatz
)
#
# ===================================================
#
abstract OWL

type IdNode <: OWL
  name::Symbol
end
==(x::IdNode, y::IdNode) = x.name == y.name

type NumNode <: OWL
    n::Real
end
==(x::NumNode, y::NumNode) = x.n == y.n

type UnOpNode <: OWL
	op::Function
	val::OWL
end
==(x::UnOpNode, y::UnOpNode) = x.op == y.op && x.val == y.val

type BinOpNode <: OWL
  op::Function
  lhs::OWL
  rhs::OWL
end
==(x::BinOpNode, y::BinOpNode) = x.op == y.op && x.lhs == y.lhs && x.rhs == y.rhs

type If0Node <: OWL
  condition::OWL
  zero_branch::OWL
  nonzero_branch::OWL
end
==(x::If0Node, y::If0Node) = x.condition == y.condition && x.zero_branch == y.zero_branch && x.nonzero_branch == y.nonzero_branch

type WithNode <: OWL
  bindings::Dict{Symbol,OWL}
  body::OWL
end
==(x::WithNode, y::WithNode) = x.body == y.body && x.bindings == y.bindings

type FunDefNode <: OWL
  param_names::Array{Symbol}
  body::OWL
end
==(x::FunDefNode, y::FunDefNode) = x.param_names == y.param_names && x.body == y.body

type FunAppNode <: OWL
  fun_expr::FunDefNode
  args::Array{OWL}
end
==(x::FunAppNode, y::FunAppNode) = x.fun_expr == y.fun_expr && x.args == y.args
#
# ========================Environments==========================
#
abstract Environment

type mtEnv <: Environment
end
==(x::mtEnv, y::mtEnv) = true

type CEnvironment <: Environment
  name::Symbol
  value::Real
  parent::Environment
end
==(x::CEnvironment, y::CEnvironment) = x.name == y.name && x.value == y.value && x.parent == y.parent
#
# ========================Return Values===========================
#
abstract RetVal

type NumVal <: RetVal
  n::Real
end
==(x::NumVal, y::NumVal) = x.n == y.n
==(x::NumVal, y::Real) = x.n == y
==(x::Real, y::NumVal) = x == y.n

type ClosureVal <: RetVal
  params::Array{Symbol}
  body::OWL
  env::Environment  # this is the environment at definition time!
end
==(x::ClosureVal, y::ClosureVal) = x.param == y.param && x.body == y.body && x.env == y.env
#
# =======================Parseing============================
#
function parse( expr::Any )
  #println(expr)
  #println(typeof(expr))
  throw(LispError("Tried to parse variable of type ::Any"))
end

function parse( expr::Real )
  return NumNode( expr )
end

function parse( expr::Symbol )
  return IdNode( expr )
end

function parse( expr::Array{Any} )
  if length(expr) == 0
    throw(LispError("Called parse with empty array"))

  elseif haskey( uDict, expr[1]) && length( expr ) == 2
    op = uDict[expr[1]]
    val = parse( expr[2] )
    return UnOpNode( op, val )


  elseif haskey( bDict, expr[1] )
    if length( expr ) != 3
      throw(LispError("Improper number of arguments"))
    end
    op = bDict[expr[1]]
    lhs = parse( expr[2] )
    rhs = parse( expr[3] )
    return BinOpNode( op, lhs, rhs )


  elseif expr[1] == :if0
    if length( expr ) != 4
      throw(LispError("Improper number of arguments"))
    end
    condition = parse( expr[2] )
    zero_branch = parse( expr[3] )
    nonzero_branch = parse( expr[4] )
    return If0Node( condition, zero_branch, nonzero_branch )


  elseif expr[1] == :with
    if length( expr ) != 3
      throw(LispError("Improper number of arguments"))
    end
    bindings = parseWith( expr[2])
    body = parse( expr[3] )
    return WithNode(bindings, body )


  elseif expr[1] == :lambda
    if length( expr ) != 3
      throw(LispError("Improper number of arguments"))
    end
    param_names = parseLambda( expr[2] )
    body = parse( expr[3] )
    return FunDefNode( param_names, body )


  elseif typeof( expr[1] ) == Real
    return NumNode( expr[1])


  elseif typeof( expr[1] ) == Array{Any,1}
    lambda = parse( expr[1] )
    if typeof( lambda ) != FunDefNode
      throw(LispError("Failed lambda verification"))
    elseif length( lambda.param_names ) == 0 && length( expr ) != 1
      throw(LispError("Failed lambda verification (params length not equal to values passed)"))
    elseif length( lambda.param_names ) > 0 && length( expr ) < 2
      throw(LispError("Failed lambda verification (params length not equal to values passed)"))
    end
    params = Array(OWL,0)
    if length( lambda.param_names ) != 0
      if length( lambda.param_names ) != length( expr ) - 1
        throw(LispError("Failed lambda verification (params length not equal to values passed)"))
      end
      for i in 1:length( lambda.param_names )
        push!( params, parse( expr[1 + i]) )
      end
    end
    return FunAppNode( lambda, params )


  elseif typeof( expr[1] ) == Symbol
    return IdNode( expr[1] )


  elseif typeof( expr[1] ) == Int64
    return NumNode( expr[1] )

  else
    throw(LispError("Unrecognized Type"))
  end
end

function parseWith( binds::Array{Any} )
  bindings = Dict{Symbol,OWL}()
  for item in binds
    if typeof(item) != Array{Any,1}
      throw(LispError("Incorrect With Statement (Not Array of (id, owl))"))
    elseif length(item) != 2
      throw(LispError("Incorrect With Statement (Bad number of values)"))
    elseif typeof( item[1] ) != Symbol
      throw(LispError("Incorrect With Statement (Not a symbol)"))
    elseif haskey( bindings, item[1] )
      throw(LispError("Incorrect With Statement (Reused Symbol)"))
    end
    bindings[item[1]] = parse( item[2] )
  end
  return bindings
end
function parseLambda( ids::Array{Any} )
  cleaned = Array{Any}(0)
  for id in ids
    checkReserved( id )
    if length( find( a -> a == id, cleaned )) != 0
      throw(LispError("duplicate Ids in lambda"))
    end
    push!( cleaned, id )
  end
  return ids
end

function checkReserved( id::Any )
  if typeof( id ) != Symbol
    throw(LispError("Variables must be symbols"))
  end
  if haskey( uDict, id )
    throw(LispError("Symbol is reserved"))
  elseif haskey( bDict, id )
    throw(LispError("Symbol is reserved"))
  elseif id == :if0
    throw(LispError("Symbol is reserved"))
  elseif id == :with
    throw(LispError("Symbol is reserved"))
  elseif id == :lambda
    throw(LispError("Symbol is reserved"))
  end
end
#
# ========================Calc===========================
#
function calc( owl::IdNode, env::Environment)
  if typeof(env) == mtEnv
    throw(LispError("Underfined variable"))
  end
  if env.name == owl.name
    return env.value
  else
    return calc( owl, env.parent )
  end
end

function calc( owl::NumNode, env::Environment)
  return owl.n
end

function calc( owl::UnOpNode, env::Environment)
  return owl.op( calc( owl.val , env ) )
end

function calc( owl::BinOpNode, env::Environment )
  lhs = calc( owl.lhs, env )
  rhs = calc( owl.rhs, env )
  if owl.op == bDict[:/] && rhs == 0
    throw(LispError("Can not Divide by zero"))
  end
  if owl.op == bDict[:%] && rhs == 0
    throw(LispError("Can not Mod by zero"))
  end
  return owl.op( lhs, rhs )
end

function calc( owl::If0Node, env::Environment )
  if calc( owl.condition , env) == 0
    return calc( owl.zero_branch, env )
  else
    return calc( owl.nonzero_branch, env )
  end
end

function calc( owl::WithNode, env::Environment )
  for (symbol, owlet) in owl.bindings
    env = CEnvironment( symbol, calc( owlet, env ), env )
  end
  return calc( owl.body, env )
end

function calc( owl::FunDefNode, env::Environment )
  return ClosureVal( owl.param_names, owl.body, env)
end
function calc( owl::FunAppNode, env::Environment )
  closure = calc(owl.fun_expr, env)

  for i in 1:length( owl.args )
    env = CEnvironment( closure.params[i], calc( owl.args[i], env ), env )
  end
  return calc( closure.body, env )
end
#
# ========================Interp===========================
#

function interp( cs::AbstractString )
  lxd = Lexer.lex( cs )
  ast = parse( lxd )
end
function exec( cs::AbstractString )
  lxd = Lexer.lex( cs )
  ast = parse( lxd )
  return calc( ast, mtEnv() )
end
function calc( owl::OWL )
  return calc( owl, mtEnv() )
end
end # module
