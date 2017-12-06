include("./dep/Error.jl")
include("./dep/HPLexer.jl")
include("./test/test.jl")
 
module CITypes # based on the CI5 interpreter
 
using Error
using Lexer
import Base.==
export parse, type_of_expr, NumType, BoolType, FunType, NListType
 
# ===================================================
 
abstract AE
abstract TypeVal
abstract TypeEnvironment
 
# ===================================================
 
# AST nodes for expressions
 
type Num <: AE
  n::Real
end
 
type Boolean <: AE
  v::Bool
end
 
type Plus <: AE
  lhs::AE
  rhs::AE
end
 
type Minus <: AE
  lhs::AE
  rhs::AE
end
 
type IsZero <: AE
  arg::AE
end
 
type IfB <: AE
  condition::AE
  true_branch::AE
  false_branch::AE
end
 
type With <: AE
  name::Symbol
  binding_expr::AE
  body::AE
end
 
type Id <: AE
  name::Symbol
end
 
type FunDef <: AE
  formal_parameter::Symbol
  formal_type::TypeVal
  fun_body::AE
end
 
type FunApp <: AE
  fun_expr::AE
  arg_expr::AE
end
 
type NEmpty <: AE
end
 
type NIsEmpty <: AE
  list::AE
end
 
type NCons <: AE
  f::AE
  r::AE
end
 
type NFirst <: AE
  list::AE
end
 
type NRest <: AE
  list::AE
end
 
# ===================================================
 
# AST nodes for types (used for type information as well)
 
type NumType <: TypeVal
end
 
type BoolType <: TypeVal
end
 
type FunType <: TypeVal
  arg_type::TypeVal
  result_type::TypeVal
end
==(a::FunType, b::FunType) = a.arg_type == b.arg_type && a.result_type == b.result_type
 
type NListType <: TypeVal
end
 
# ===================================================
 
# Type Environments
 
type mtTypeEnvironment <: TypeEnvironment
end
 
type CTypeEnvironment <: TypeEnvironment
  name::Symbol
  value::TypeVal
  parent::TypeEnvironment
end
 
# ===================================================
 
# Parser for expressions
# functional for valid input, doesn't fully reject bad input)
 
function parse(expr::Real)
  return Num(expr)
end
 
function parse(expr::Bool)
  return Boolean(expr)
end
 
function parse(expr::Symbol)
  if expr == :nempty
    return NEmpty()
  else
    return Id(expr)
  end
end
 
function parse(expr::Array{Any})
 
  op_symbol = expr[1]
 
  if op_symbol == :+
    lhs = parse(expr[2])
    rhs = parse(expr[3])
    return Plus(lhs, rhs)
 
  elseif op_symbol == :-
    lhs = parse(expr[2])
    rhs = parse(expr[3])
    return Minus(lhs, rhs)
 
  elseif op_symbol == :iszero
    arg = parse(expr[2])
    return IsZero(arg)
 
  elseif op_symbol == :ifb
    condition = parse(expr[2])
    true_branch = parse(expr[3])
    false_branch = parse(expr[4])
    return IfB(condition, true_branch, false_branch)
 
  elseif op_symbol == :with    # (with x (+ 5 1) (+ x x))
    sym = expr[2]
    binding_expr = parse(expr[3])
    body = parse(expr[4])
    return With(sym, binding_expr, body)
 
  elseif op_symbol == :lambda
    formal = expr[2]
    formal_type = parse_type(expr[4])
    body = parse(expr[5])
    return FunDef(formal, formal_type, body)
 
  elseif op_symbol == :ncons
    f = parse(expr[2])
    r = parse(expr[3])
    return NCons(f, r)
 
  elseif op_symbol == :nisempty
    list = parse(expr[2])
    return NIsEmpty(list)
 
  elseif op_symbol == :nfirst
    list = parse(expr[2])
    return NFirst(list)
 
  elseif op_symbol == :nrest
    list = parse(expr[2])
    return NRest(list)
 
  else
    return FunApp(parse(expr[1]), parse(expr[2]))
 
  end
end
 
function parse(expr::Any)
  throw(LispError("Invalid expression $expr"))
end
 
# ===================================================
 
# Parser for type expressions
 
function parse_type(t::Symbol)
  if (t == :number)
    return NumType()
  elseif (t == :boolean)
    return BoolType()
  elseif (t == :nlist)
    return NListType()
  end
end
 
function parse_type(t :: Array{Any})
  return FunType(parse_type(t[1]),
                  parse_type(t[3]))
end
 
function parse_type(expr::Any)
  throw(LispError("Invalid type $expr"))
end
 
# ===================================================
 
# Type checking functions (modeled after the earlier calc)
 
function type_of_expr(ast::AE)
  return type_of_expr(ast, mtTypeEnvironment())
end
 
function type_of_expr(ae::Num, env::TypeEnvironment)
  return NumType()
end
 
function type_of_expr(ae::Boolean, env::TypeEnvironment)
  return BoolType()
end
 
function type_of_expr(ae::Plus, env::TypeEnvironment)
  lhs = type_of_expr(ae.lhs, env)
  rhs = type_of_expr(ae.rhs, env)
  return type_of_math_expr(lhs, rhs)
end
 
function type_of_expr(ae::Minus, env::TypeEnvironment)
  lhs = type_of_expr(ae.lhs, env)
  rhs = type_of_expr(ae.rhs, env)
  return type_of_math_expr(lhs, rhs)
end

function type_of_expr(ae::IsZero, env::TypeEnvironment)
  param = type_of_expr(ae.arg, env)
  if param == NumType()
    return BoolType()
  end
  throw(LispError("IsZero takes a NumType"))
end

function type_of_expr(ae::NEmpty, env::TypeEnvironment)
  return NListType()
end

function type_of_expr(ae::NRest, env::TypeEnvironment)
  return NListType()
end

function type_of_expr(ae::Id, env::TypeEnvironment)
  if env == mtTypeEnvironment()
    val = ae.name
    throw(LispError("Symbol $val not found"))
  elseif env.name != ae.name
    return type_of_expr(ae, env.parent)
  else
    return env.value
  end
end

function type_of_expr(ae::NIsEmpty, env::TypeEnvironment)
  if type_of_expr(ae.list, env) != NListType()
    throw(LispError("nisempty takes a listType"))
  end
  return BoolType()
end

function type_of_expr(ae::NFirst, env::TypeEnvironment)
  if type_of_expr(ae.list, env) != NListType()
    throw(LispError("Bad argument for nfirst"))
  end
  return NumType()
end

function type_of_expr(ae::NCons, env::TypeEnvironment)
  if type_of_expr(ae.f) != NumType()
    throw(LispError("Ncons takes a Numtype"))
  elseif type_of_expr(ae.r) != NListType()
    throw(LispError("Ncons takes a list"))
  end
  return NListType()
end

function type_of_expr(ae::IfB, env::TypeEnvironment)
  if type_of_expr(ae.condition, env) != BoolType()
    throw(LispError("IfB takes a boolType"))
  end

  tbType = type_of_expr(ae.true_branch, env)
  fbType = type_of_expr(ae.false_branch, env)
  if !same_type(tbType, fbType)
    throw(LispError("dissagreeing types contained in branches of IfB"))
  end
  return tbType
end

function type_of_expr(ae::FunDef, env::TypeEnvironment)
  newEnv = CTypeEnvironment(ae.formal_parameter, ae.formal_type, env)
  bodyType = type_of_expr(ae.fun_body, newEnv)
  return FunType(ae.formal_type, bodyType)
end

function type_of_expr(ae::FunApp, env::TypeEnvironment)
  func_type = type_of_expr(ae.fun_expr)
  arg_type = type_of_expr(ae.arg_expr)

  if arg_type != func_type.arg_type
    throw(LispError("FunApp requries matching argument and param types"))
  end

  return func_type.result_type
end
function type_of_expr(ae::With, env::TypeEnvironment)
  arg_type = type_of_expr(ae.binding_expr)

  newEnv = CTypeEnvironment(ae.name, arg_type, env)

  bodyType = type_of_expr(ae.body, newEnv)

  return bodyType
end
 
# ===================================================
 
# Helper function for comparing two type values recursively if necessary
 
same_type(t1::FunType, t2::FunType) =
    (same_type(t1.arg_type, t2.arg_type)
  && same_type(t1.result_type, t2.result_type))
 
same_type{ T <: TypeVal }(t1::T, t2::T) = true
 
same_type(t1::TypeVal, t2::TypeVal) = false
 
# ===================================================
 
# Type judgments (could be folded into type checking functions)
 
function type_of_math_expr(left::NumType, right::NumType)
  return NumType()
end
 
function type_of_math_expr(left::Any, right::Any)
  throw(LispError("Operands for + or - must be numbers"))
end
 
# the rest of your type-judgement functions (if you choose to separate them) go here...
 
# ===================================================
 
# convenience function to make everything easier
function type_of_expr(expr::AbstractString)
  return type_of_expr(parse(Lexer.lex(expr)))
end
 
# ===================================================
 
end # module