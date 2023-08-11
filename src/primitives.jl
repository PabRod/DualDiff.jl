# Auxiliary function
"""
_factory(f::Function, df::Function)::Function

f: a function of x
df: its exact derivative, computed manually

This auxiliary method helps generating a derivatives table,

Many of the functions below have the structure:
    
    function operator(z::Dual)
        y = foo(z.x)
        dy = dfoo(z.x) * z.dx # Chain rule
        return Dual(y, dy)
    end

    This factory method simplifies the input to:

    function operator(z: Dual) 
        aux = _factory(<fun>, <derivative>)
        return aux(z)
    end

    or the shorthand:

    operator(z::Dual) = _factory(<fun>, <derivative>)(z)

    Additionally, reduces the chances of introducing bugs (typically
    from forgetting to add the chain rule)
"""
function _factory(f::Function, df::Function)::Function
    return z -> Dual(f(z.x), df(z.x) * z.dx)
end


# Derivatives table
import Base: sin, cos, tan, exp

sin(z::Dual) = _factory(sin, cos)(z)
cos(z::Dual) = _factory(cos, x -> -sin(x))(z)
tan(z::Dual) = sin(z) / cos(z) # We can rely on previously defined functions
exp(z::Dual) = _factory(exp, exp)(z)
