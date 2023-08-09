export Dual

""" Structure representing a Dual DualNumber """
struct Dual
    x::Real
    dx::Real

    """ Default constructor """
    function Dual(x::Real, dx::Real=0)::Dual
        new(x, dx)
    end

    """ If passed a Dual, just return it
    
    This will be handy later """
    function Dual(x::Dual)::Dual
        return x
    end

    # Consider using this instead:
    # convert(::Type{Dual}, x::Dual) = return x
    # convert(::Type{Dual}, x::Number) = return Dual(x, 0)

end

## Redefine base operators
const DualNumber = Union{Dual, Number}

import Base: ==, !=, +, -, *, /, \

==(self::Dual, other::Dual) = return (self.x == other.x) && (self.dx == other.dx)
!=(self::Dual, other::Dual) = return !(self == other)
+(z::Dual) = return z
-(z::Dual) = return Dual(-z.x, -z.dx)

function +(self::DualNumber, other::DualNumber)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return Dual(self.x + other.x, self.dx + other.dx)
end

function -(self::DualNumber, other::DualNumber)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    return self + (-other)
end

function *(self::DualNumber, other::DualNumber)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x * other.x
    dy = self.dx * other.x + self.x * other.dx
    return Dual(y, dy)
end

function /(self::DualNumber, other::DualNumber)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x / other.x
    dy = (self.dx * other.x - self.x * other.dx) / (other.x)^2
    return Dual(y, dy)
end

function \(self::DualNumber, other::DualNumber)::Dual
    return other / self
end

function Base.:^(self::Dual, other::Real)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x^other.x
    dy = other.x * self.x^(other.x - 1) * self.dx
    return Dual(y, dy)
end

import Base: sin, cos

function _factory(f, df)
    return z -> Dual(f(z.x), df(z.x) * z.dx)
end

function sin(z::DualNumber)
    z = Dual(z)
    return _factory(sin, cos)(z)
end

function cos(z::DualNumber)
    z = Dual(z)
    return _factory(cos, z -> -sin(z))(z)
end