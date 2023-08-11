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

end

## Auxiliary data type
const DualNumber = Union{Dual, Number}

## Redefine base operators

## Comparers
import Base: ==, !=, >, >=, <, <=

==(self::Dual, other::Dual) = (self.x == other.x) && (self.dx == other.dx)
!=(self::Dual, other::Dual) = !(self == other)
>(self::Dual, other::Dual) = self.x > other.x
>=(self::Dual, other::Dual) = self.x >= other.x
<(self::Dual, other::Dual) = self.x < other.x
<=(self::Dual, other::Dual) = self.x <= other.x

## Algebraic operators
import Base: +, -, *, /, \, ^

+(z::Dual) = z
-(z::Dual) = Dual(-z.x, -z.dx)

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

function ^(self::Dual, other::Real)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x^other.x
    dy = other.x * self.x^(other.x - 1) * self.dx
    return Dual(y, dy)
end

function ^(self::Real, other::Dual)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x^other.x
    dy = self.x^other.x * log(self.x) * other.dx
    return Dual(y, dy)
end

function ^(self::Dual, other::Dual)::Dual
    self, other = Dual(self), Dual(other) # Coerce into Dual
    y = self.x^other.x
    dy = self.x^other.x * log(self.x) * other.dx + other.x * self.x^(other.x - 1) * self.dx
    return Dual(y, dy)
end

# Derivatives table
import Base: sin, cos, tan, exp

function _factory(f::Function, df::Function)::Function
    return z -> Dual(f(z.x), df(z.x) * z.dx)
end

sin(z::Dual) = _factory(sin, cos)(z)
cos(z::Dual) = _factory(cos, x -> -sin(x))(z)
tan(z::Dual) = sin(z) / cos(z)
exp(z::Dual) = _factory(exp, exp)(z)