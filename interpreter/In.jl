include("./dep/Error.jl")
include("./dep/HPLexer.jl")
include("./test/test.jl")

module Terp

using Error
using Lexer
using Images
using Cairo
# Exports for testing
export parse, calc, analyze
export interp, exec

# ================================================================
# ========================Abstracts===============================
# ================================================================
abstract OWL
abstract Environment
abstract RetVal

# ================================================================
# ========================Return Values===========================
# ================================================================
type NumVal <: RetVal
	val::Real
end

type ClosureVal <: RetVal
	params::Array{Symbol}
	body::OWL
	env::Environment  # this is the environment at definition time!
end

type MatrixVal <: RetVal
	val::Array{Float32,2}
end

# ================================================================
# ========================Environments============================
# ================================================================
type mtEnv <: Environment
end

type CEnvironment <: Environment
	name::Symbol
	value::RetVal
	parent::Environment
end

# ================================================================
# ==============================Nodes=============================
# ================================================================
type IdNode <: OWL
	name::Symbol
end

type NumNode <: OWL
		n::Real
end

type UnOpNode <: OWL
	op::Function
	val::OWL
end

type BinOpNode <: OWL
	op::Function
	lhs::OWL
	rhs::OWL
end

type AddNode <: OWL
	args::Array{OWL}
end

# ----------------------------------------------------------------
# ---------------------------Logic Nodes--------------------------
type If0Node <: OWL
	cond::OWL
	zero::OWL
	nonzero::OWL
end

type AndNode <: OWL
	args::Array{OWL}
end

type WithNode <: OWL
	binds::Dict{Symbol,OWL}
	body::OWL
end

type FunDefNode <: OWL
	params::Array{Symbol}
	body::OWL
end

type FunAppNode <: OWL
	func::OWL
	args::Array{OWL}
end

# ----------------------------------------------------------------
# ---------------------------Matrix Nodes-------------------------
type MatNode <: OWL
	mat::Array{Float32,2}
end

type MatOpNode <: OWL
	op::Function
	mat::OWL
end

type MatSaveNode <: OWL
	mat::OWL
	path::String
end

type MatLoadNode <: OWL
	path::String
end

type RenderTextNode <: OWL
    text::AbstractString
    xpos::OWL
    ypos::OWL
end

include("./dep/typeComp.jl")

# ================================================================
# ============================Primatives==========================
# ================================================================
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
# ----------------------------------------------------------------
# ------------------------Load & Save-----------------------------
function simple_load( img_path::AbstractString )
  im = Images.load( img_path );
  tmp = Images.separate(im);
  d = Images.data( tmp );
  d = d[:,:,1];  # just the r channel
  d = convert( Array{Float32,2}, d );
  return d    
end

function simple_save( output::Array, img_path::AbstractString )
    output[ output .> 1.0 ] = 1.0
    output[ output .< 0.0 ] = 0.0
    tmpc = convert( Array{UInt32,2}, floor(output*255.0) )
    tmp_output =  tmpc + tmpc*256 + tmpc*65536 + 0xff000000
    c2 = CairoImageSurface( transpose(tmp_output), Cairo.FORMAT_ARGB32 )
    write_to_png( c2, img_path)
    return 42
end
# ----------------------------------------------------------------
# ---------------------Matrix Operations--------------------------
function render_text( text_str::AbstractString, xpos, ypos )

  data = Matrix{UInt32}( 256, 256 );
  c = CairoImageSurface( data, Cairo.FORMAT_ARGB32 );
  cr = CairoContext( c );

  set_source_rgb( cr, 1., 1., 1. );
  rectangle( cr, 0., 0., 256., 256. );
  fill( cr );

  set_source_rgb( cr, 0, 0, 0 );
  select_font_face( cr, "Sans", Cairo.FONT_SLANT_NORMAL,
                    Cairo.FONT_WEIGHT_BOLD );
  set_font_size( cr, 90.0 );

  move_to( cr, xpos, ypos );
  show_text( cr, text_str );

  # tmp is an Array{UInt32,2}
  tmp = cr.surface.data;

  # grab just the blue channel, and convert the array to an array of floats
  tmp2 = convert( Array{Float32,2}, tmp & 0x000000ff ) / 255.0;
  tmp2 = convert( Array{Float32,2}, tmp2 );

  return tmp2
end

function emboss( img::Array )
  f = [ -2. -1. 0.
        -1.  1. 1.
         0.  1. 1. ];
  f = convert( Array{Float32,2}, f );

  es = conv2( f, img );
  es = es[1:256,1:256];
  return es    
end

function drop_shadow( img::Array )
	println("fu")
  foo = Array{Float32,2}(gaussian2d(5.0,[25,25]));
  foo = foo / maximum(foo);
  ds = conv2( foo, img );
  ds = ds[13:256+12,13:256+12];
  ds = ds / sum(foo);
  return ds
end

function inner_shadow( img::Array )
  foo = convert( Array{Float32,2}, gaussian2d(5.0,[25,25]) );
  foo = foo / maximum(foo);
  is = conv2( foo, 1.0-img );
  is = is[8:251+12,8:251+12];
  is = is / sum(foo);
  is = max( is, img );
  return is
end
# ================================================================
# ===============================Parse============================
# ================================================================
function parse(expr::Any)
	#println("parseing Any")
	println(expr)
	println(typeof(expr))
	throw(LispError("Tried to parse variable of type ::Any"))
end

function parse( expr::Real )
	return NumNode( expr )
end

function parse( expr::Int64 )
	return NumNode( expr )
end

function parse(expr::Symbol)
	return parseId(expr)
end

function parse(expr::Array{})
	#println(expr)
	if length(expr) == 0
		throw(LispError("Called parse with empty array"))
	end
	if ndims(expr) == 2
		return MatNode(expr)
	end

	key = expr[1];
	if key == :+
		if length(expr) > 2
			params = parseMany(expr[2:length(expr)])
			return AddNode(params)
		else
			throw(LispError("Improper number of arguments to \"+\""))
		end
	elseif key == :-
		if length(expr) == 2
			param1 = parse(expr[2])
			return UnOpNode(-, param1)
		elseif length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(.-, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"-\""))
		end
	elseif key == :*
		if length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(.*, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"*\""))
		end
	elseif key == :/
		if length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(./, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"/\""))
		end
	elseif key == :mod
		if length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(mod, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"mod\""))
		end
	elseif key == :collatz
		if length(expr) == 2
			param1 = parse(expr[2])
			return UnOpNode(collatz, param1)
		else
			throw(LispError("Improper number of arguments to \"collatz\""))
		end
	elseif key == :if0
		if length(expr) == 4
			param1 = parse(expr[2]) # The condition
			param2 = parse(expr[3]) # The zero branch
			param3 = parse(expr[4]) # The non-zero branch
			return If0Node(param1, param2, param3)
		else
			throw(LispError("Improper number of arguments to \"if0\""))
		end
	elseif key == :with
		if length(expr) == 3
			if !isa(expr[2], Array)
				throw(LispError("Improper type of arguments to \"with\""))
			end
			binds = parseWithBindings(expr[2])
			body = parse(expr[3])
			return WithNode(binds, body)
		else
			throw(LispError("Improper number of arguments to \"with\""))
		end
	elseif key == :lambda
		if length(expr) == 3
			if !isa(expr[2], Array)
				throw(LispError("Improper type of arguments to \"lambda\""))
			end
			params = parseLambdaParams(expr[2])
			body = parse(expr[3])
			return FunDefNode(params, body)
		else
			throw(LispError("Improper number of arguments to \"lambda\" deffinition"))
		end
	elseif key == :and
		if length(expr) > 2
			args = parseMany(expr[2:length(expr)])
			return AndNode(args)
		else
			throw(LispError("Improper number of arguments to \"and\""))
		end
	elseif key == :simple_load
		if length(expr) == 2
			path = expr[2]
			if typeof(path) != String
				throw(LispError("Must pass string to \"simple_load\" as second param"))
			end
			return MatLoadNode(path)
		else
			throw(LispError("Improper number of arguments to \"simple_load\""))
		end
	elseif key == :simple_save
		if length(expr) == 3
			path = expr[3]
			if typeof(path) != String
				throw(LispError("Must pass string to \"simple_save\" as second param"))
			end
			mat = parse(expr[2])
			return MatSaveNode(mat, path)
		else
			throw(LispError("Improper number of arguments to \"simple_save\""))
		end
	elseif key == :render_text
		if length(expr) == 4
			text = expr[2]
			if typeof(text) != String
				throw(LispError("Must pass string to \"render_text\" as first param"))
			end
			xpos = parse(expr[3])
			ypos = parse(expr[4])
			return RenderTextNode(text, xpos, ypos)
		else
			throw(LispError("Improper number of arguments to \"render_text\""))
		end
	elseif key == :emboss
		if length(expr) == 2
			mat = parse(expr[2])
			return MatOpNode(emboss, mat)
		else
			throw(LispError("Improper number of arguments to \"emboss\""))
		end
	elseif key == :drop_shadow
		if length(expr) == 2
			mat = parse(expr[2])
			return MatOpNode(drop_shadow, mat)
		else
			throw(LispError("Improper number of arguments to \"drop_shadow\""))
		end
	elseif key == :inner_shadow
		if length(expr) == 2
			mat = parse(expr[2])
			return MatOpNode(inner_shadow, mat)
		else
			throw(LispError("Improper number of arguments to \"inner_shadow\""))
		end
	elseif key == :min
		if length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(min, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"min\""))
		end
	elseif key == :max
		if length(expr) == 3
			param1 = parse(expr[2])
			param2 = parse(expr[3])
			return BinOpNode(max, param1, param2)
		else
			throw(LispError("Improper number of arguments to \"max\""))
		end
	elseif isa(key, Array)
		lambda = parse(key)
		if typeof(lambda) != FunDefNode
			throw(LispError("Failed lambda verification"))
		else
			args = parseMany(expr[2:length(expr)])
			if length(lambda.params) != length(args)
				throw(LispError("Failed lambda verification (call and signature don't match)"))
			end
			return FunAppNode(lambda, args)
		end
	elseif typeof(key) == Symbol
		lambdaId = parseId(key)
		if typeof(lambdaId) != IdNode
			throw(LispError("Failed lambda verification"))
		else
			args = parseMany(expr[2:length(expr)])
			#=if length(lambda.params) != length(args)
				throw(LispError("Failed lambda verification (call and signature don't match)"))
			end=# #Cant run this test because the function signature can't be known without some kind of eval
			return FunAppNode(lambdaId, args)
		end
	else
		#println(key)
		#println(typeof(key))
		throw(LispError("Unrecognized Type"))
	end
end

function parseWithBindings( binds::Array{} )
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
		else
			checkReserved(item[1])
			bindings[item[1]] = parse(item[2])
		end
	end
	return bindings
end
reserved = [:+, :-, :*, :/, :mod,
 	:collatz, :if0, :with, :lambda, :and,
 	:simple_load, :simple_save, :render_text,
 	:emboss, :drop_shadow, :inner_shadow,
 	:min, :max]
function checkReserved(id::Symbol)
	if length( find( a -> a == id, reserved )) != 0
		throw(LispError("Reserved Word"))
	end
end

function parseLambdaParams(ids::Array{})
	params = Array{Any}(0)
	for id in ids
		checkReserved( id )
		if length( find( a -> a == id, params )) != 0
			throw(LispError("duplicate Ids in lambda"))
		end
		push!(params, id)
	end
	return params
end

function parseId(id::Symbol)
	checkReserved(id)
	return IdNode(id)
end

function parseMany(exprs::Array{})
	owls = Array{Any}(0)
	for expr in exprs
		push!(owls, parse(expr))
	end
	return owls
end
# ================================================================
# =============================Analyze============================
# ================================================================
function analyze(owl::IdNode)
	return owl
end
function analyze(owl::NumNode)
	return owl
end
function analyze(owl::UnOpNode)
	owl.val = analyze(owl.val)
	return owl
end
function analyze(owl::BinOpNode)
	owl.lhs = analyze(owl.lhs)
	owl.rhs = analyze(owl.rhs)
	return owl
end
function analyze(owl::AddNode)
	if length(owl.args) == 2 
		arg1 = analyze(owl.args[1])
		arg2 = analyze(owl.args[2])
		return BinOpNode(.+, arg1, arg2)
	elseif length(owl.args) > 2
		addNode = AddNode(owl.args[2:length(owl.args)])
		arg2 = analyze(addNode)
		arg1 = analyze(owl.args[1])
		return BinOpNode(.+, arg1, arg2)
	end
end
function analyze(owl::If0Node)
	owl.cond = analyze(owl.cond)
	owl.zero = analyze(owl.zero)
	owl.nonzero = analyze(owl.nonzero)
	return owl
end
function analyze(owl::AndNode)
	if length(owl.args) == 1 
		cond = analyze(owl.args[1])
		return If0Node(cond,NumNode(0),NumNode(1))
	elseif length(owl.args) > 1
		andNode = AndNode(owl.args[2:length(owl.args)])
		branch = analyze(andNode)
		cond = analyze(owl.args[1])
		return If0Node(cond, NumNode(0), branch)
	end
end
function analyze(owl::WithNode)
	params = Array{Symbol}(0)
	args = Array{OWL}(0)
	body = analyze(owl.body)
	for (param, arg) in owl.binds
		push!(params, param)
		push!(args, analyze(arg))
	end
	funDefNode = FunDefNode(params, body)
	funAppNode = FunAppNode(funDefNode, args)
	return funAppNode
end
function analyze(owl::FunDefNode)
	owl.body = analyze(owl.body)
	return owl
end
function analyze(owl::FunAppNode)
	owl.func = analyze(owl.func)
	for i in 1:length(owl.args)
		owl.args[i] = analyze(owl.args[i])
	end
	return owl
end
function analyze(owl::MatOpNode)
	owl.mat = analyze(owl.mat)
	return owl
end
function analyze(owl::MatSaveNode)
	owl.mat = analyze(owl.mat)
	return owl
end
function analyze(owl::MatLoadNode)
	return owl
end
function analyze(owl::RenderTextNode)
	owl.xpos = analyze(owl.xpos)
	owl.ypos = analyze(owl.ypos)
	return owl
end
function analyze(owl::MatNode)
	return owl
end

# ================================================================
# ==============================Calc============================
# ================================================================
function calc(owl::IdNode, env::Environment)
	if typeof(env) == mtEnv
		throw(LispError("Underfined variable"))
	elseif env.name == owl.name
		return env.value
	else
		return calc(owl, env.parent)
	end
end

function calc( owl::NumNode, env::Environment)
	return wrapVal( owl.n )
end

function calc( owl::UnOpNode, env::Environment)
	val = calc( owl.val , env )
	if typeof(val) == NumVal
		return wrapVal( owl.op( val.val ) )
	elseif typeof(val) == MatrixVal
		if owl.op == -	
			return wrapVal( owl.op( val.val ) )
		else
			throw(LispError("Can not Handle type 1"))
		end
	else
		throw(LispError("Can not Handle type 2"))
	end
end

function calc( owl::BinOpNode, env::Environment )
	lhs = @spawn calc( owl.lhs, env )
	rhs = @spawn calc( owl.rhs, env )
	lhs = fetch(lhs)
	rhs = fetch(rhs)
	if typeof(lhs) != NumVal && typeof(lhs) != MatrixVal
		throw(LispError("Can not Handle type 3"))
	elseif typeof(rhs) != NumVal && typeof(rhs) != MatrixVal
		throw(LispError("Can not Handle type 4"))
	elseif owl.op == ./
		if rhs == 0
			throw(LispError("Can not Divide by zero"))
		end
	elseif owl.op == mod
		if rhs == 0
			throw(LispError("Can not Mod by zero"))
		elseif typeof(rhs) == MatrixVal || typeof(lhs) == MatrixVal
			throw(LispError("Can not Mod by Matrix"))
		end
	end
	return wrapVal(owl.op(lhs.val, rhs.val))
end

function calc(owl::If0Node, env::Environment)
	if calc(owl.cond , env) == 0
		return calc(owl.zero, env)
	else
		return calc(owl.nonzero, env)
	end
end

function calc( owl::WithNode, env::Environment )
	for (symbol, owlet) in owl.binds
		env = CEnvironment( symbol, calc( owlet, env ), env )
	end
	return calc( owl.body, env )
end

function calc(owl::FunDefNode, env::Environment)
	return ClosureVal( owl.params, owl.body, env)
end
function calc(owl::FunAppNode, env::Environment)
	closure = calc(owl.func, env)
	if length(closure.params) != length(owl.args)
		throw(LispError("Function signature mismatch"))
	end
	for i in 1:length( owl.args )
		arg = calc(owl.args[i], env)
		env = CEnvironment( closure.params[i], arg, env )
	end
	return calc( closure.body, env )
end
function calc(owl::MatNode, env::Environment)
	return wrapVal(owl.mat)
end

function calc(owl::MatOpNode, env::Environment)
	matVal = calc(owl.mat, env)
	mat = 0;
	if typeof(matVal) == MatrixVal
		#try
			mat = owl.op(matVal.val)
		#catch
		#	throw(LispError("Mat Op Evaluation borked!"))
		#end
	else
		throw(LispError("Need to pass a MatrixVal to a MatOpNode"))
	end
	if typeof(mat) == Array{Float32,2}
		return wrapVal(mat)
	else
		throw(LispError("bad return value from simple_load"))
	end
end
function calc(owl::MatSaveNode, env::Environment)
	matVal = calc(owl.mat, env)
	if typeof(matVal) == MatrixVal
		try
			simple_save(matVal.val, owl.path)
		catch
			throw(LispError("Invalid path pased to simple_save"))
		end
	else
		throw(LispError("Need to pass a MatrixVal to a MatSaveNode"))
	end
	return matVal
end
function calc(owl::MatLoadNode, env::Environment)
	mat = 0
	try
		mat = simple_load(owl.path)
	catch e 
		println(e)
		throw(LispError("Invalid path pased to simple_load"))
	end
	if typeof(mat) == Array{Float32,2}
		return wrapVal(mat)
	else
		throw(LispError("bad return value from simple_load"))
	end
end
function calc(owl::RenderTextNode, env::Environment)
	xpos = @spawn calc(owl.xpos, env)
	ypos = @spawn calc(owl.ypos, env)
	mat = 0
	xpos = fetch(xpos)
	ypos = fetch(ypos)
	if typeof(xpos) == NumVal && typeof(ypos) == NumVal
		mat = render_text(owl.text, xpos.val, ypos.val)
	else
		throw(LispError("Need to pass NumVals to a MatOpNode"))
	end
	if typeof(mat) == Array{Float32,2}
		return wrapVal(mat)
	else
		throw(LispError("bad return value from simple_load"))
	end
end

function wrapVal(val::Real)
	return NumVal(val)
end
function wrapVal(val::Array{Float32,2})
	return MatrixVal(val)
end

# ================================================================
# =============================Exports============================
# ================================================================
#=				        str   lxd   ast   rst   val
				    lex  +----->
				 interp  +----------->
				analyze  +----------------->
				   exec  +----------------------->
				   eval        +----------------->
				  assay              +----------->
				   calc                     +---->
				  parse        +----->
				analyze              +----->
=#
function lex(str::AbstractString)
	lxd = Lexer.lex(str)
	return lxd
end
function interp(str::AbstractString)
	lxd = lex(str)
	ast = parse(lxd)
	return ast
end
function analyze(str::AbstractString)
	lxd = lex(str)
	ast = parse(lxd)
	rst = analyze(ast)
	return rst
end
function exec(str::AbstractString)
	lxd = lex(str)
	ast = parse(lxd)
	rst = analyze(ast)
	val = calc(rst)
	return val
end
function eval(lxd::Array{Any,1})
	ast = parse(lxd)
	rst = analyze(ast)
	val = calc(rst)
	return val
end
function assay(ast::OWL)
	rst = analyze(ast)
	val = calc(rst)
	return val
end
function calc(rst::OWL)
	val = calc(rst, mtEnv())
	return val
end

end # module Terp



# ================================================================
# =======================Package Aliasing=========================
# ================================================================
module HPInt

using Terp: parse, calc, analyze
using Terp: NumVal, ClosureVal, MatrixVal

# Exports for Class
export parse, calc, analyze
export NumVal, ClosureVal, MatrixVal

end # module HPInt