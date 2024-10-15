@staticmethod
def add(a, b):
    """Return the sum of a and b."""
    return a + b

@staticmethod
def subtract(a, b):
    """Return the difference between a and b."""
    return a - b

@staticmethod
def multiply(a, b):
    """Return the product of a and b."""
    return a * b

@staticmethod
def divide(a, b):
    """Return the quotient of a and b.

    Raise ValueError if b is zero.
    """
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
