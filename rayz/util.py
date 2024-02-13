class ColumnIndexTooLarge(Exception):
    pass
class RowIndexTooLarge(Exception):
    pass

def equal(a: float, b: float) -> int:
    EPSILON = 0.00001
    return abs(a - b) < EPSILON
