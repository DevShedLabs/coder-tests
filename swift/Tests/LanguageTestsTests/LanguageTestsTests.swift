// =============================================================================
// Swift Test Cases — Editor Feature Testing
// Backing lib `Sources/LanguageTests/TestSuite.swift`; run with `swift test`.
// =============================================================================

import XCTest
@testable import LanguageTests

// ---------------------------------------------------------------------------
// Tests for Vec2 value semantics and operators
// ---------------------------------------------------------------------------

final class Vec2Tests: XCTestCase {
    func testLength() {
        let v = Vec2(x: 3, y: 4)
        XCTAssertEqual(v.length, 5, accuracy: 1e-12)
    }

    func testDot() {
        let a = Vec2(x: 1, y: 2)
        let b = Vec2(x: 3, y: 4)
        XCTAssertEqual(a.dot(b), 11, accuracy: 1e-12)
    }

    func testAddOperator() {
        let a = Vec2(x: 1, y: 1)
        let b = Vec2(x: 2, y: 3)
        XCTAssertEqual(a + b, Vec2(x: 3, y: 4))
    }
}

// ---------------------------------------------------------------------------
// Tests for Direction enum and its computed property
// ---------------------------------------------------------------------------

final class DirectionTests: XCTestCase {
    func testOpposite() {
        XCTAssertEqual(Direction.north.opposite, .south)
        XCTAssertEqual(Direction.south.opposite, .north)
        XCTAssertEqual(Direction.east.opposite, .west)
        XCTAssertEqual(Direction.west.opposite, .east)
    }
}

// ---------------------------------------------------------------------------
// Tests for ParseResult associated values
// ---------------------------------------------------------------------------

final class ParseResultTests: XCTestCase {
    func testIsOkForSuccess() {
        XCTAssertTrue(ParseResult.ok(42).isOk)
    }

    func testIsOkForFailure() {
        XCTAssertFalse(ParseResult.err("invalid").isOk)
    }
}

// ---------------------------------------------------------------------------
// Tests for Role raw values and CaseIterable conformance
// ---------------------------------------------------------------------------

final class RoleTests: XCTestCase {
    func testRawValues() {
        XCTAssertEqual(Role.admin.rawValue, "admin")
        XCTAssertEqual(Role.viewer.rawValue, "viewer")
    }

    func testAllCasesCount() {
        XCTAssertEqual(Role.allCases.count, 3)
    }
}

// ---------------------------------------------------------------------------
// Tests for generic Stack
// ---------------------------------------------------------------------------

final class StackTests: XCTestCase {
    func testPushPopLIFO() {
        var stack = Stack<Int>()
        XCTAssertTrue(stack.isEmpty)

        stack.push(1)
        stack.push(2)
        stack.push(3)

        XCTAssertEqual(stack.pop(), 3)
        XCTAssertEqual(stack.pop(), 2)
        XCTAssertEqual(stack.peek(), 1)
        XCTAssertEqual(stack.pop(), 1)
        XCTAssertNil(stack.pop())
        XCTAssertTrue(stack.isEmpty)
    }

    func testGenericMax() {
        XCTAssertEqual(maximum(5, 10), 10)
        XCTAssertEqual(maximum("a", "b"), "b")
    }
}

// ---------------------------------------------------------------------------
// Tests for closures and optional handling
// ---------------------------------------------------------------------------

final class ClosureTests: XCTestCase {
    func testTransformDouble() {
        let result = transform([1, 2, 3]) { $0 * 2 }
        XCTAssertEqual(result, [2, 4, 6])
    }

    func testUnwrapUsesFallback() {
        XCTAssertEqual(unwrap(nil, fallback: 7), 7)
        XCTAssertEqual(unwrap(3, fallback: 7), 3)
    }
}

// ---------------------------------------------------------------------------
// Tests for error handling and Result
// ---------------------------------------------------------------------------

final class UserServiceTests: XCTestCase {
    func testRegisterSucceeds() throws {
        var service = UserService()
        let user = User(id: 1, name: "Jeff", email: "jeff@example.com")
        XCTAssertEqual(try service.register(user: user), 1)
    }

    func testRegisterRejectsEmptyName() {
        var service = UserService()
        let user = User(id: 2, name: "", email: "x@example.com")
        XCTAssertThrowsError(try service.register(user: user)) { error in
            XCTAssertEqual(error as? AppError, .validation("Name must not be empty."))
        }
    }

    func testFetchReturnsFailureWhenMissing() {
        let service = UserService()
        let result = service.fetch(id: 99)
        guard case let .failure(.notFound(message)) = result else {
            return XCTFail("Expected notFound failure")
        }
        XCTAssertEqual(message, "User 99 not found.")
    }
}

// ---------------------------------------------------------------------------
// Tests for inheritance and polymorphism
// ---------------------------------------------------------------------------

final class AnimalTests: XCTestCase {
    func testDogSpeaksPolymorphically() {
        let animals: [Animal] = [Animal(name: "Generic"), Dog(name: "Rex")]
        let sounds = animals.map { $0.speak() }
        XCTAssertEqual(sounds[0], "Generic makes a sound.")
        XCTAssertEqual(sounds[1], "Rex barks.")
    }
}

// ---------------------------------------------------------------------------
// Tests for the Lazy computed value wrapper
// ---------------------------------------------------------------------------

final class LazyTests: XCTestCase {
    func testResolvesOnce() {
        var count = 0
        var lazy = Lazy<Int> {
            count += 1
            return count
        }
        XCTAssertEqual(lazy.resolved, 1)
        XCTAssertEqual(lazy.resolved, 1)
        XCTAssertEqual(count, 1)
    }
}

// ---------------------------------------------------------------------------
// Tests for actors and TaskGroup concurrency
// ---------------------------------------------------------------------------

@available(macOS 13.0, *)
final class ConcurrencyTests: XCTestCase {
    func testCounterIncrements() async {
        let counter = Counter()
        let first = await counter.increment()
        XCTAssertEqual(first, 1)
        let second = await counter.increment()
        XCTAssertEqual(second, 2)
    }

    func testTaskGroupFetchAll() async {
        let payloads = await fetchAll(ids: [3, 1, 2])
        XCTAssertEqual(payloads.map(\.id), [1, 2, 3])
        XCTAssertEqual(payloads.map(\.value), [1, 4, 9])
    }
}
