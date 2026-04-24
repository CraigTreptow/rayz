from __future__ import annotations

import numpy as np

from rayz.constants import EPSILON
from rayz.tuple import Tuple


class Matrix:
    """An NxN matrix backed by a NumPy array."""

    def __init__(self, rows: list[list[float]] | np.ndarray) -> None:
        if isinstance(rows, np.ndarray):
            self._data = rows.astype(float)
        else:
            self._data = np.array(rows, dtype=float)

    # ------------------------------------------------------------------
    # Element access
    # ------------------------------------------------------------------

    def __getitem__(self, key: tuple[int, int]) -> float:
        return float(self._data[key])

    # ------------------------------------------------------------------
    # Equality
    # ------------------------------------------------------------------

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Matrix):
            return NotImplemented
        if self._data.shape != other._data.shape:
            return False
        return bool(np.all(np.abs(self._data - other._data) < EPSILON))

    __hash__ = None  # type: ignore[assignment]

    def __repr__(self) -> str:
        return f"Matrix({self._data.tolist()})"

    # ------------------------------------------------------------------
    # Multiplication
    # ------------------------------------------------------------------

    def __mul__(self, other: Matrix | Tuple) -> Matrix | Tuple:
        if isinstance(other, Matrix):
            return Matrix(self._data @ other._data)
        if isinstance(other, Tuple):
            vec = np.array([other.x, other.y, other.z, other.w])
            result = self._data @ vec
            return Tuple(result[0], result[1], result[2], result[3])
        return NotImplemented

    # ------------------------------------------------------------------
    # Transpose
    # ------------------------------------------------------------------

    def transpose(self) -> Matrix:
        return Matrix(self._data.T.copy())

    # ------------------------------------------------------------------
    # Determinant
    # ------------------------------------------------------------------

    def determinant(self) -> float:
        n = self._data.shape[0]
        if n == 2:
            return float(self._data[0, 0] * self._data[1, 1] - self._data[0, 1] * self._data[1, 0])
        total = 0.0
        for col in range(n):
            total += self._data[0, col] * self.cofactor(0, col)
        return total

    # ------------------------------------------------------------------
    # Submatrix, minor, cofactor
    # ------------------------------------------------------------------

    def submatrix(self, row: int, col: int) -> Matrix:
        """Return this matrix with the given row and column removed."""
        data = np.delete(np.delete(self._data, row, axis=0), col, axis=1)
        return Matrix(data)

    def minor(self, row: int, col: int) -> float:
        """Determinant of the submatrix at (row, col)."""
        return self.submatrix(row, col).determinant()

    def cofactor(self, row: int, col: int) -> float:
        """Signed minor — negated when (row + col) is odd."""
        m = self.minor(row, col)
        return -m if (row + col) % 2 == 1 else m

    # ------------------------------------------------------------------
    # Invertibility and inverse
    # ------------------------------------------------------------------

    def is_invertible(self) -> bool:
        return abs(self.determinant()) > EPSILON

    def inverse(self) -> Matrix:
        if not self.is_invertible():
            raise ValueError("Matrix is not invertible")
        return Matrix(np.linalg.inv(self._data))

    # ------------------------------------------------------------------
    # Factory
    # ------------------------------------------------------------------

    @classmethod
    def identity(cls, size: int = 4) -> Matrix:
        return cls(np.eye(size))
