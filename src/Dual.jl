export Dual

""" Structure representing a Dual number """
struct Dual
    x::Real
    dx::Real

    """ Default constructor """
    function Dual(x::Real, dx::Real=0)
        new(x, dx)
    end

    """ If passed a Dual, just return it
    
    This will be handy later """
    function Dual(x::Dual)
        return x
    end

end

## Redefine base operators

function Base.:+(self::Dual)
    return self
end

function Base.:+(self::Union{Real,Dual}, other::Union{Real,Dual})
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return Dual(self.x + other.x, self.dx + other.dx)
end