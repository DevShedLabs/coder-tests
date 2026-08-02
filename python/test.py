# =============================================================================
# Python Language Test Suite — Editor Feature Testing
# Exercises: syntax highlighting, bracket matching, code folding,
#            indentation, auto-completion, diagnostics, and more.
# =============================================================================

from __future__ import annotations

import asyncio
import dataclasses
import enum
import math
import os
import sys
import typing
from abc import ABC, abstractmethod
from collections.abc import Callable, Generator, Iterable, Iterator
from dataclasses import dataclass, field
from typing import Any, ClassVar, Final, Generic, Optional, TypeVar, Union

# ---------------------------------------------------------------------------
# 1. Constants, variables, and type hints
# ---------------------------------------------------------------------------

NAME: Final[str] = "PyTest"
VERSION: Final[int] = 1
PI: Final[float] = 3.141592653589793
DEBUG: Final[bool] = True

counter: int = 0
message: str | None = None  # union type syntax (3.10+)

# ---------------------------------------------------------------------------
# 2. Functions — positional, keyword, default args, *args, **kwargs, decorators
# ---------------------------------------------------------------------------


def add(a: int, b: int) -> int:
    """Add two integers."""
    return a + b


def factorial(n: int) -> int:
    """Recursive factorial."""
    if n <= 1:
        return 1
    return n * factorial(n - 1)


def greet(name: str = "World") -> str:
    return f"Hello, {name}!"


def variadic(*args: int, **kwargs: str) -> None:
    _ = args
    _ = kwargs


# ---------------------------------------------------------------------------
# 3. Decorators — @staticmethod, @classmethod, @property, custom
# ---------------------------------------------------------------------------


def timer(func: Callable) -> Callable:
    """Simple decorator that prints elapsed time."""

    def wrapper(*args, **kwargs):
        import time

        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result

    return wrapper


@timer
def slow_function() -> None:
    _ = sum(range(10**6))


# ---------------------------------------------------------------------------
# 4. Control flow — if/elif/else, for, while, match/case (3.10+)
# ---------------------------------------------------------------------------


def classify_number(x: int) -> str:
    if x > 0:
        return "positive"
    elif x < 0:
        return "negative"
    else:
        return "zero"


def sum_array(arr: list[int]) -> int:
    total = 0
    for val in arr:
        total += val
    return total


def countdown(limit: int) -> None:
    i = limit
    while i > 0:
        i -= 1


def describe_color(rgb: int) -> str:
    match rgb:
        case 0xFF0000:
            return "red"
        case 0x00FF00:
            return "green"
        case 0x0000FF:
            return "blue"
        case 0x000000:
            return "black"
        case 0xFFFFFF:
            return "white"
        case _:
            return "unknown"


# ---------------------------------------------------------------------------
# 5. Classes, inheritance, abstract base classes, magic methods
# ---------------------------------------------------------------------------


class Vec2:
    """A 2D vector."""

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y

    def __repr__(self) -> str:
        return f"Vec2({self.x}, {self.y})"

    def __add__(self, other: Vec2) -> Vec2:
        return Vec2(self.x + other.x, self.y + other.y)

    def length(self) -> float:
        return math.sqrt(self.x**2 + self.y**2)


class Shape(ABC):
    """Abstract base class."""

    @abstractmethod
    def area(self) -> float: ...

    @abstractmethod
    def perimeter(self) -> float: ...


class Circle(Shape):
    def __init__(self, radius: float) -> None:
        self.radius = radius

    def area(self) -> float:
        return math.pi * self.radius**2

    def perimeter(self) -> float:
        return 2 * math.pi * self.radius


class Rectangle(Shape):
    def __init__(self, width: float, height: float) -> None:
        self.width = width
        self.height = height

    def area(self) -> float:
        return self.width * self.height

    def perimeter(self) -> float:
        return 2 * (self.width + self.height)


# ---------------------------------------------------------------------------
# 6. Enums (IntEnum, StrEnum, auto)
# ---------------------------------------------------------------------------


class Direction(enum.IntEnum):
    NORTH = 1
    SOUTH = 2
    EAST = 3
    WEST = 4

    def opposite(self) -> Direction:
        match self:
            case Direction.NORTH:
                return Direction.SOUTH
            case Direction.SOUTH:
                return Direction.NORTH
            case Direction.EAST:
                return Direction.WEST
            case Direction.WEST:
                return Direction.EAST


# ---------------------------------------------------------------------------
# 7. Dataclasses and typing
# ---------------------------------------------------------------------------


@dataclass
class Config:
    host: str = "localhost"
    port: int = 8080
    tls: bool = False
    tags: list[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# 8. Generators, iterators, context managers, async
# ---------------------------------------------------------------------------


def fibonacci(limit: int) -> Generator[int, None, None]:
    a, b = 0, 1
    while a < limit:
        yield a
        a, b = b, a + b


class ManagedFile:
    """Context manager."""

    def __init__(self, path: str) -> None:
        self.path = path

    def __enter__(self) -> ManagedFile:
        self.file = open(self.path, "w")
        return self

    def __exit__(self, *args) -> None:
        self.file.close()

    def write(self, text: str) -> None:
        self.file.write(text)


async def fetch_data(url: str) -> dict[str, Any]:
    """Async function (placeholder)."""
    await asyncio.sleep(0.1)
    return {"url": url, "status": 200}


async def async_main() -> None:
    results = await asyncio.gather(
        fetch_data("/a"),
        fetch_data("/b"),
        fetch_data("/c"),
    )
    print(results)


# ---------------------------------------------------------------------------
# 9. Type aliases, Generics (Generic[T]), TypeVar
# ---------------------------------------------------------------------------

T = TypeVar("T")
K = TypeVar("K")
V = TypeVar("V")

JSON = dict[str, Any]


class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

    @property
    def is_empty(self) -> bool:
        return len(self._items) == 0


# ---------------------------------------------------------------------------
# 10. Lambda, map, filter, list/dict/set comprehensions
# ---------------------------------------------------------------------------

square = lambda x: x * x

def comprehension_demo() -> None:
    squares = [x**2 for x in range(10)]
    evens = [x for x in range(20) if x % 2 == 0]
    squares_map = {x: x**2 for x in range(5)}
    unique = {x % 3 for x in range(10)}
    _ = squares
    _ = evens
    _ = squares_map
    _ = unique


# ---------------------------------------------------------------------------
# 11. Error handling — try/except/else/finally, raise, custom exceptions
# ---------------------------------------------------------------------------


class AppError(Exception):
    """Base application error."""


class NotFoundError(AppError):
    """Resource not found."""


class PermissionError(AppError):
    """Access denied."""


def might_fail(flag: bool) -> int:
    if flag:
        return 42
    raise NotFoundError("resource missing")


def error_demo() -> None:
    try:
        result = might_fail(True)
        print(result)
    except NotFoundError as e:
        print(f"Caught: {e}")
    except AppError:
        print("Generic app error")
    else:
        print("No exception")
    finally:
        print("Cleanup")


# ---------------------------------------------------------------------------
# 12. Decorators with arguments, functools.wraps
# ---------------------------------------------------------------------------

import functools


def retry(max_attempts: int = 3) -> Callable:
    """Retry a function up to max_attempts times."""

    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception:
                    if attempt == max_attempts - 1:
                        raise
            return None

        return wrapper

    return decorator


@retry(max_attempts=5)
def flaky_network_call() -> str:
    import random

    if random.random() < 0.7:
        raise ConnectionError("timeout")
    return "ok"


# ---------------------------------------------------------------------------
# 13. Walrus operator (:=), structural pattern matching with guards
# ---------------------------------------------------------------------------


def walrus_demo() -> None:
    nums = [1, 2, 3, 4, 5]
    if (n := len(nums)) > 3:
        print(f"Long list: {n}")


def match_guard(point: tuple[int, int]) -> str:
    match point:
        case (0, 0):
            return "origin"
        case (x, 0) if x > 0:
            return f"positive x-axis at {x}"
        case (0, y) if y > 0:
            return f"positive y-axis at {y}"
        case (x, y):
            return f"point ({x}, {y})"


# ---------------------------------------------------------------------------
# 14. Slots, properties, __slots__, descriptors
# ---------------------------------------------------------------------------


class FixedPoint:
    __slots__ = ("x", "y")

    def __init__(self, x: float, y: float) -> None:
        self.x = x
        self.y = y


class Temperature:
    def __init__(self, celsius: float = 0) -> None:
        self._celsius = celsius

    @property
    def celsius(self) -> float:
        return self._celsius

    @celsius.setter
    def celsius(self, value: float) -> None:
        if value < -273.15:
            raise ValueError("Below absolute zero")
        self._celsius = value

    @property
    def fahrenheit(self) -> float:
        return self._celsius * 9 / 5 + 32


# ---------------------------------------------------------------------------
# 15. Unit tests (using unittest)
# ---------------------------------------------------------------------------

import unittest


class TestMath(unittest.TestCase):
    def test_add(self) -> None:
        self.assertEqual(add(2, 3), 5)
        self.assertEqual(add(-1, 1), 0)

    def test_factorial(self) -> None:
        self.assertEqual(factorial(5), 120)
        self.assertEqual(factorial(0), 1)

    def test_classify_number(self) -> None:
        self.assertEqual(classify_number(10), "positive")
        self.assertEqual(classify_number(-3), "negative")
        self.assertEqual(classify_number(0), "zero")

    def test_sum_array(self) -> None:
        self.assertEqual(sum_array([1, 2, 3, 4, 5]), 15)

    def test_vec2(self) -> None:
        v1 = Vec2(3.0, 4.0)
        v2 = Vec2(1.0, 2.0)
        self.assertAlmostEqual(v1.length(), 5.0)
        v3 = v1 + v2
        self.assertAlmostEqual(v3.x, 4.0)
        self.assertAlmostEqual(v3.y, 6.0)

    def test_circle_area(self) -> None:
        c = Circle(5.0)
        self.assertAlmostEqual(c.area(), math.pi * 25)
        self.assertAlmostEqual(c.perimeter(), 2 * math.pi * 5)

    def test_rectangle(self) -> None:
        r = Rectangle(3.0, 4.0)
        self.assertAlmostEqual(r.area(), 12.0)
        self.assertAlmostEqual(r.perimeter(), 14.0)

    def test_direction_opposite(self) -> None:
        self.assertEqual(Direction.NORTH.opposite(), Direction.SOUTH)
        self.assertEqual(Direction.EAST.opposite(), Direction.WEST)

    def test_config_defaults(self) -> None:
        cfg = Config()
        self.assertEqual(cfg.host, "localhost")
        self.assertEqual(cfg.port, 8080)
        self.assertFalse(cfg.tls)

    def test_error_handling(self) -> None:
        self.assertEqual(might_fail(True), 42)
        with self.assertRaises(NotFoundError):
            might_fail(False)

    def test_generic_stack(self) -> None:
        s: Stack[int] = Stack()
        s.push(1)
        s.push(2)
        self.assertFalse(s.is_empty)
        self.assertEqual(s.pop(), 2)
        self.assertEqual(s.pop(), 1)

    def test_fibonacci(self) -> None:
        seq = list(fibonacci(50))
        self.assertEqual(seq, [0, 1, 1, 2, 3, 5, 8, 13, 21, 34])

    def test_temperature_property(self) -> None:
        t = Temperature(100)
        self.assertAlmostEqual(t.fahrenheit, 212.0)
        t.celsius = 0
        self.assertAlmostEqual(t.fahrenheit, 32.0)
        with self.assertRaises(ValueError):
            t.celsius = -300

    def test_match_guard(self) -> None:
        self.assertEqual(match_guard((0, 0)), "origin")
        self.assertEqual(match_guard((5, 0)), "positive x-axis at 5")
        self.assertEqual(match_guard((0, 3)), "positive y-axis at 3")
        self.assertEqual(match_guard((1, 2)), "point (1, 2)")


# ---------------------------------------------------------------------------
# 16. Module-level entry point
# ---------------------------------------------------------------------------


def main() -> None:
    unittest.main()


if __name__ == "__main__":
    main()

# ---------------------------------------------------------------------------
# End of file
# ---------------------------------------------------------------------------
