class ColumnIndexTooLarge(Exception):
    pass
class RowIndexTooLarge(Exception):
    pass

def equal(a: float, b: float) -> bool:
    EPSILON = 0.00001
    return abs(a - b) < EPSILON
