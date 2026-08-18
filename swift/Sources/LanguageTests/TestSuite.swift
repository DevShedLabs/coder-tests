// =============================================================================
// Swift Language Test Suite — Editor Feature Testing
// Exercises: syntax highlighting, bracket matching, code folding,
//            indentation, auto-completion, diagnostics, go-to-definition,
//            find-references, renaming, and more.
// =============================================================================

import Foundation

// ---------------------------------------------------------------------------
// 1. Constants, variables, and basic types
// ---------------------------------------------------------------------------

let name = "SwiftTest"
let version = 1
let pi = 3.141592653589793
let isDebug = true

// ---------------------------------------------------------------------------
// 2. Structs, classes, and value/reference semantics
// ---------------------------------------------------------------------------

/// A 2D vector value type.
struct Vec2: Equatable {
    var x: Double
    var y: Double

    var length: Double {
        sqrt(x * x + y * y)
    }

    func dot(_ other: Vec2) -> Double {
        x * other.x + y * other.y
    }

    static func + (lhs: Vec2, rhs: Vec2) -> Vec2 {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

/// A reference-type user.
final class User {
    let id: Int
    var name: String
    let email: String

    init(id: Int, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}

// ---------------------------------------------------------------------------
// 3. Enums with associated values and computed properties
// ---------------------------------------------------------------------------

/// Compass directions.
enum Direction: Equatable {
    case north
    case south
    case east
    case west

    var opposite: Direction {
        switch self {
        case .north: return .south
        case .south: return .north
        case .east: return .west
        case .west: return .east
        }
    }
}

/// Parsed integer or failure.
enum ParseResult {
    case ok(Int)
    case err(String)

    var isOk: Bool {
        if case .ok = self { return true }
        return false
    }
}

/// Roles with a backing raw value.
enum Role: String, CaseIterable {
    case admin
    case editor
    case viewer
}

// ---------------------------------------------------------------------------
// 4. Protocols, generics, and extensions
// ---------------------------------------------------------------------------

/// A generic container that can build values.
protocol Buildable {
    associatedtype Output
    func build() -> Output
}

/// A generic stack.
struct Stack<Element> {
    private var items: [Element] = []

    var isEmpty: Bool { items.isEmpty }

    mutating func push(_ element: Element) {
        items.append(element)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    func peek() -> Element? {
        items.last
    }
}

/// Generic max over Comparable types.
func maximum<T: Comparable>(_ a: T, _ b: T) -> T {
    a > b ? a : b
}

// ---------------------------------------------------------------------------
// 5. Closures, higher-order functions, and optionals
// ---------------------------------------------------------------------------

/// Reverses the order of elements.
func transform(_ values: [Int], using op: (Int) -> Int) -> [Int] {
    values.map(op)
}

/// Decomposes an optional value with a fallback.
func unwrap(_ value: Int?, fallback: Int) -> Int {
    guard let value else { return fallback }
    return value
}

// ---------------------------------------------------------------------------
// 6. Error handling — throws, do/catch, Result
// ---------------------------------------------------------------------------

enum AppError: Error, Equatable {
    case notFound(String)
    case validation(String)
    case server(String)
}

struct UserService {
    private var storage: [Int: User] = [:]

    mutating func register(user: User) throws -> Int {
        guard !user.name.isEmpty else {
            throw AppError.validation("Name must not be empty.")
        }
        guard user.email.contains("@") else {
            throw AppError.validation("Invalid email address.")
        }
        storage[user.id] = user
        return user.id
    }

    func fetch(id: Int) -> Result<User, AppError> {
        guard let user = storage[id] else {
            return .failure(.notFound("User \(id) not found."))
        }
        return .success(user)
    }
}

// ---------------------------------------------------------------------------
// 7. Inheritance, polymorphism, and overrides
// ---------------------------------------------------------------------------

/// A base animal.
class Animal {
    var name: String

    init(name: String) {
        self.name = name
    }

    func speak() -> String {
        "\(name) makes a sound."
    }
}

/// A speccific animal.
final class Dog: Animal {
    override func speak() -> String {
        "\(name) barks."
    }
}

// ---------------------------------------------------------------------------
// 8. Options, cached values, and lazy computation
// ---------------------------------------------------------------------------

/// A lazily-computed value wrapper.
struct Lazy<T> {
    private var value: T?
    private let factory: () -> T

    init(_ factory: @escaping () -> T) {
        self.factory = factory
    }

    var resolved: T {
        mutating get {
            if let value { return value }
            let computed = factory()
            value = computed
            return computed
        }
    }
}

// ---------------------------------------------------------------------------
// 9. Concurrency — async/await, TaskGroup, actors, Sendable
// ---------------------------------------------------------------------------

/// An actor protecting a counter.
actor Counter {
    private var count = 0

    func increment() -> Int {
        count += 1
        return count
    }

    func value() -> Int {
        count
    }
}

/// A Sendable payload carrying a result.
struct Payload: Sendable {
    let id: Int
    let value: Int
}

/// Fetches multiple values concurrently within a TaskGroup.
func fetchAll(ids: [Int]) async -> [Payload] {
    await withTaskGroup(of: Payload.self) { group in
        for id in ids {
            group.addTask {
                Payload(id: id, value: id * id)
            }
        }
        var results: [Payload] = []
        results.reserveCapacity(ids.count)
        for await payload in group {
            results.append(payload)
        }
        return results.sorted { $0.id < $1.id }
    }
}
