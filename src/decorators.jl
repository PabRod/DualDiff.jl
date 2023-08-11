export autodifferentiable

"""
    autodifferentiable(f)

  Seamlessly turns a given function 
    f = x -> expr(x) 
    into
    f = x -> expr(Dual(x, 1))

    How to use it:
    f = autodifferentiable(f)
"""
function autodifferentiable(f)

    function decorated(x::Number)
        return f(Dual(x, 1))
    end

    function decorated(x::Dual)
        return f(x)
    end

    return decorated
end