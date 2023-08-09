export Dual

""" Structure representing a Dual DualNumber """
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
const DualNumber = Union{Dual, Number}

import Base: +, -, *, /, \

+(z::Dual) = return z
-(z::Dual) = return Dual(-z.x, -z.dx)

function +(self::DualNumber, other::DualNumber)
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return Dual(self.x + other.x, self.dx + other.dx)
end

function -(self::DualNumber, other::DualNumber)
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return self + (-other)
end

function *(self::DualNumber, other::DualNumber)
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x * other.x
    dy = self.dx * other.x + self.x * other.dx
    return Dual(y, dy)
end

function /(self::DualNumber, other::DualNumber)
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x / other.x
    dy = (self.dx * other.x - self.x * other.dx) / (other.x)^2
    return Dual(y, dy)
end

function \(self::DualNumber, other::DualNumber)
    return other / self
end

function Base.:^(self::Dual, other::Real)
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x^other.x
    dy = other.x * self.x^(other.x - 1) * self.dx
    return Dual(y, dy)
end
