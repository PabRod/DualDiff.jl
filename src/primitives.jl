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
# Trigonometric
import Base: sin, cos, tan, sec, csc, cot, asin, acos, atan

sin(z::Dual) = _factory(sin, cos)(z)
cos(z::Dual) = _factory(cos, x -> -sin(x))(z)
tan(z::Dual) = sin(z) / cos(z) # We can rely on previously defined functions
csc(z::Dual) = 1 / sin(z)
sec(z::Dual) = 1 / cos(z)
cot(z::Dual) = 1 / tan(z)
asin(z::Dual) = _factory(asin, x -> 1/(1 - x^2)^0.5)(z)
acos(z::Dual) = _factory(acos, x -> -1 / (1 - x^2)^0.5)(z)
atan(z::Dual) = _factory(atan, x -> 1 / (1 + x^2))(z)

# Exponential and logarithic
import Base: exp, log, log2, log10
exp(z::Dual) = _factory(exp, exp)(z)
log(z::Dual) = _factory(log, x -> 1/x)(z)
log2(z::Dual) = log(z) / log(2)
log10(z::Dual) = log(z) / log(10)

# Other
import Base: inv, abs

inv(z::Dual) = Dual(inv(z.x), -z.dx / z.x^2)

function abs(z::Dual)
    if z.x > 0
        return z
    elseif z.x == 0
        return Dual(z.x, NaN)
    else
        return Dual(-z.x, -z.dx)
    end
end