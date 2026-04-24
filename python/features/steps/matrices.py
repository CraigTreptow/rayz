import pytest
from behave import given, then, use_step_matcher

from rayz.math_parser import parse_math
from rayz.matrix import Matrix
from rayz.tuple import Tuple

use_step_matcher("re")

_V = r"([A-Za-z][A-Za-z0-9_]*)"
_I = r"(\d+)"
_A = r"([^\s,)]+)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

IDENTITY_MATRIX = Matrix.identity(4)


def _matrix_from_table(table) -> Matrix:
    # Behave treats the first table row as headings, so include it as the first data row.
    heading_row = [parse_math(h) for h in table.headings]
    data_rows = [[parse_math(cell) for cell in row.cells] for row in table.rows]
    return Matrix([heading_row] + data_rows)


def _resolve(context, name: str) -> Matrix:
    """Return the named matrix, treating 'identity_matrix' as a constant."""
    if name == "identity_matrix":
        return IDENTITY_MATRIX
    return getattr(context, name)


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------


@given(rf"the following (?:\d+x\d+ )?matrix {_V}:")
def step_given_matrix(context, var):
    setattr(context, var, _matrix_from_table(context.table))


# ---------------------------------------------------------------------------
# Derived assignments
# ---------------------------------------------------------------------------


@given(rf"{_V} ← transpose\(identity_matrix\)")
def step_given_transpose_identity(context, var):
    setattr(context, var, IDENTITY_MATRIX.transpose())


@given(rf"{_V} ← transpose\({_V}\)")
def step_given_transpose(context, result, src):
    setattr(context, result, _resolve(context, src).transpose())


@given(rf"{_V} ← inverse\({_V}\)")
def step_given_inverse(context, result, src):
    setattr(context, result, _resolve(context, src).inverse())


@given(rf"{_V} ← submatrix\({_V},\s*{_I},\s*{_I}\)")
def step_given_submatrix(context, result, src, row, col):
    setattr(context, result, _resolve(context, src).submatrix(int(row), int(col)))


@given(rf"{_V} ← {_V} \* {_V}")
def step_given_matrix_mul(context, result, a, b):
    setattr(context, result, _resolve(context, a) * _resolve(context, b))


# ---------------------------------------------------------------------------
# Element access
# ---------------------------------------------------------------------------


@then(rf"{_V}\[{_I},{_I}\] = {_A}")
def step_then_element(context, var, row, col, val):
    actual = _resolve(context, var)[int(row), int(col)]
    assert actual == pytest.approx(parse_math(val), abs=1e-5)


# ---------------------------------------------------------------------------
# Equality / inequality
# ---------------------------------------------------------------------------


@then(rf"{_V} = {_V}")
def step_then_eq(context, a, b):
    assert _resolve(context, a) == _resolve(context, b)


@then(rf"{_V} != {_V}")
def step_then_neq(context, a, b):
    assert _resolve(context, a) != _resolve(context, b)


# ---------------------------------------------------------------------------
# Matrix multiplication result as table
# ---------------------------------------------------------------------------


@then(rf"{_V} \* {_V} is the following (?:\d+x\d+ )?matrix:")
def step_then_mul_matrix(context, a, b):
    expected = _matrix_from_table(context.table)
    assert _resolve(context, a) * _resolve(context, b) == expected


@then(rf"{_V} \* identity_matrix = {_V}")
def step_then_mul_identity(context, a, b):
    assert _resolve(context, a) * IDENTITY_MATRIX == _resolve(context, b)


@then(r"identity_matrix \* ([A-Za-z][A-Za-z0-9_]*) = ([A-Za-z][A-Za-z0-9_]*)")
def step_then_identity_mul(context, a, b):
    lhs = getattr(context, a)
    if isinstance(lhs, Tuple):
        result = IDENTITY_MATRIX * lhs
        assert result == getattr(context, b)
    else:
        assert IDENTITY_MATRIX * _resolve(context, a) == _resolve(context, b)


@then(rf"{_V} \* {_V} = tuple\({_A},\s*{_A},\s*{_A},\s*{_A}\)")
def step_then_matrix_mul_tuple(context, mat, tup, x, y, z, w):
    result = _resolve(context, mat) * getattr(context, tup)
    expected = Tuple(parse_math(x), parse_math(y), parse_math(z), parse_math(w))
    assert result == expected


# ---------------------------------------------------------------------------
# Transpose result as table
# ---------------------------------------------------------------------------


@then(rf"transpose\({_V}\) is the following (?:\d+x\d+ )?matrix:")
def step_then_transpose(context, var):
    expected = _matrix_from_table(context.table)
    assert _resolve(context, var).transpose() == expected


# ---------------------------------------------------------------------------
# Determinant, submatrix, minor, cofactor
# ---------------------------------------------------------------------------


@then(rf"determinant\({_V}\) = {_A}")
def step_then_determinant(context, var, val):
    assert _resolve(context, var).determinant() == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"submatrix\({_V},\s*{_I},\s*{_I}\) is the following (?:\d+x\d+ )?matrix:")
def step_then_submatrix(context, var, row, col):
    expected = _matrix_from_table(context.table)
    assert _resolve(context, var).submatrix(int(row), int(col)) == expected


@then(rf"minor\({_V},\s*{_I},\s*{_I}\) = {_A}")
def step_then_minor(context, var, row, col, val):
    assert _resolve(context, var).minor(int(row), int(col)) == pytest.approx(parse_math(val), abs=1e-5)


@then(rf"cofactor\({_V},\s*{_I},\s*{_I}\) = {_A}")
def step_then_cofactor(context, var, row, col, val):
    assert _resolve(context, var).cofactor(int(row), int(col)) == pytest.approx(parse_math(val), abs=1e-5)


# ---------------------------------------------------------------------------
# Invertibility
# ---------------------------------------------------------------------------


@then(rf"{_V} is invertible")
def step_then_invertible(context, var):
    assert _resolve(context, var).is_invertible()


@then(rf"{_V} is not invertible")
def step_then_not_invertible(context, var):
    assert not _resolve(context, var).is_invertible()


# ---------------------------------------------------------------------------
# Inverse result as table / expression
# ---------------------------------------------------------------------------


@then(rf"inverse\({_V}\) is the following (?:\d+x\d+ )?matrix:")
def step_then_inverse_table(context, var):
    expected = _matrix_from_table(context.table)
    assert _resolve(context, var).inverse() == expected


@then(rf"{_V} is the following (?:\d+x\d+ )?matrix:")
def step_then_var_is_matrix(context, var):
    expected = _matrix_from_table(context.table)
    assert _resolve(context, var) == expected


# ---------------------------------------------------------------------------
# Multiply-then-inverse round-trip
# ---------------------------------------------------------------------------


@then(rf"{_V} \* inverse\({_V}\) = {_V}")
def step_then_mul_inverse_eq(context, c, b, a):
    result = _resolve(context, c) * _resolve(context, b).inverse()
    assert result == _resolve(context, a)
