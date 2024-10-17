import pytest
from calc import add, subtract, multiply, divide

class TestCalc:
    @pytest.mark.parametrize("a, b, expected", [
        (2, 3, 5),
        (-1, 1, 0),
        (0, 0, 0),
        (100, 200, 300)
    ])
    def test_add(self, a, b, expected):
        assert add(a, b) == expected
