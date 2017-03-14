import Base.==
# ================================================================
# ========================Return Values===========================
# ================================================================
==(x::Terp.NumVal, y::Terp.NumVal) = x.val == y.val
==(x::Terp.NumVal, y::Terp.Real) = x.val == y
==(x::Terp.Real, y::Terp.NumVal) = x == y.val

==(x::Terp.ClosureVal, y::Terp.ClosureVal) = x.params == y.params && x.body == y.body && x.env == y.env

==(x::Terp.MatrixVal, y::Terp.MatrixVal) = x.val == y.val

# ================================================================
# ========================Environments============================
# ================================================================
==(x::Terp.mtEnv, y::Terp.mtEnv) = true

==(x::Terp.CEnvironment, y::Terp.CEnvironment) = x.name == y.name && x.value == y.value && x.parent == y.parent

# ================================================================
# ==============================Nodes=============================
# ================================================================
==(x::Terp.IdNode, y::Terp.IdNode) = x.name == y.name

==(x::Terp.NumNode, y::Terp.NumNode) = x.n == y.n

==(x::Terp.UnOpNode, y::Terp.UnOpNode) = x.op == y.op && x.val == y.val

==(x::Terp.BinOpNode, y::Terp.BinOpNode) = x.op == y.op && x.lhs == y.lhs && x.rhs == y.rhs

==(x::Terp.AddNode, y::Terp.AddNode) = arrayEquals(x.args, y.args)

# ----------------------------------------------------------------
# ---------------------------Logic Nodes--------------------------
==(x::Terp.If0Node, y::Terp.If0Node) = x.cond == y.cond && x.zero == y.zero && x.nonzero == y.nonzero

==(x::Terp.AndNode, y::Terp.AndNode) = x.args == y.args

==(x::Terp.WithNode, y::Terp.WithNode) = x.body == y.body && x.binds == y.binds

==(x::Terp.FunDefNode, y::Terp.FunDefNode) = x.params == y.params && x.body == y.body

==(x::Terp.FunAppNode, y::Terp.FunAppNode) = x.func == y.func && x.args == y.args

# ----------------------------------------------------------------
# ---------------------------Matrix Nodes-------------------------
==(x::Terp.MatNode, y::Terp.MatNode) = arrayEquals(x.mat, y.mat)

==(x::Terp.MatOpNode, y::Terp.MatOpNode) = x.op == y.op && x.mat == y.mat

==(x::Terp.MatSaveNode, y::Terp.MatSaveNode) = x.mat == y.mat && x.path == y.path

==(x::Terp.MatLoadNode, y::Terp.MatLoadNode) = x.path == y.path

==(x::Terp.RenderTextNode, y::Terp.RenderTextNode) = x.text == y.text && x.xpos == y.xpos && x.ypos == y.ypos

# ================================================================
# ==============================Errors============================
# ================================================================
==(x::Error.LispError, y::Error.LispError) = true

function arrayEquals(a::Array{Terp.OWL}, b::Array{Terp.OWL})
    if length(a) != length(b)
        return false
    end
    for i in 1:length(a)
        if !(a[i] == b[i])
            return false
        end
    end
    return true
end
function arrayEquals(a::Array{Float32}, b::Array{Float32})
    if length(a) != length(b)
        return false
    end
    for i in 1:length(a)
        if !(a[i] == b[i])
            return false
        end
    end
    return true
end