#!/usr/bin/env python
# -*-mode: Python; coding: utf-8;-*-
# SPDX-License-Identifier: BlueOak-1.0.0
# Description:

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

    @pytest.mark.parametrize("a, b, expected", [
        (5, 3, 2),
        (0, 1, -1),
        (100, 50, 50),
        (-1, -1, 0)
    ])
    def test_subtract(self, a, b, expected):
        assert subtract(a, b) == expected

    @pytest.mark.parametrize("a, b, expected", [
        (2, 3, 6),
        (-1, 1, -1),
        (0, 5, 0),
        (100, 2, 200)
    ])
    def test_multiply(self, a, b, expected):
        assert multiply(a, b) == expected

    @pytest.mark.parametrize("a, b, expected", [
        (6, 3, 2),
        (-10, 2, -5),
        (100, 4, 25),
        (5, 2, 2.5)
    ])
    def test_divide(self, a, b, expected):
        assert divide(a, b) == expected

    def test_divide_by_zero(self):
        with pytest.raises(ValueError):
            divide(1, 0)
