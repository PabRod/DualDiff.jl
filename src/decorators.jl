export autodifferentiable

"""
    autodifferentiable(f)

Just some syntactic sugar. Allows using f(x) instead of f(Dual(x, 1))
"""
function autodifferentiable(f)
    return x -> f(Dual(x, 1))
end