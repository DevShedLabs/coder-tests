// =============================================================================
// Zig Language Test Suite — Editor Feature Testing
// Exercises: syntax highlighting, bracket matching, code folding,
//            indentation, auto-completion, diagnostics, and more.
// =============================================================================

const std = @import("std");
const math = std.math;
const mem = std.mem;
const testing = std.testing;

// ---------------------------------------------------------------------------
// 1. Basic constants, variables, and types
// ---------------------------------------------------------------------------

const NAME: []const u8 = "ZigTest";
const VERSION: u32 = 1;
const PI: f64 = 3.141592653589793;
const DEBUG: bool = true;

var counter: i32 = 0;

// ---------------------------------------------------------------------------
// 2. Functions — declarations, parameters, return types, inline, export
// ---------------------------------------------------------------------------

/// Adds two i32 values and returns the result.
fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// Recursive factorial.
pub fn factorial(n: u64) u64 {
	if (n <= 1) return 1;
    return n * factorial(n - 1);
}

/// Inline function.
inline fn square(x: f64) f64 {
    return x * x;
}

/// Extern-exported function.
export fn greet() callconv(.C) void {
    _ = NAME; // suppress unused warning
}

// ---------------------------------------------------------------------------
// 3. Control flow — if/else, for, while, switch
// ---------------------------------------------------------------------------

fn classifyNumber(x: i32) []const u8 {
    if (x > 0) {
        return "positive";
    } else if (x < 0) {
        return "negative";
    } else {
        return "zero";
    }
}

fn sumArray(arr: []const i32) i32 {
    var total: i32 = 0;
    for (arr) |val| {
        total += val;
    }
    return total;
}

fn countdown(limit: usize) void {
    var i: usize = limit;
    while (i > 0) : (i -= 1) {
        // counting down…
    }
}

fn describeColor(rgb: u32) []const u8 {
    return switch (rgb) {
        0xFF0000 => "red",
        0x00FF00 => "green",
        0x0000FF => "blue",
        0x000000 => "black",
        0xFFFFFF => "white",
        else => "unknown",
    };
}

// ---------------------------------------------------------------------------
// 4. Structs, enums, tagged unions, and methods
// ---------------------------------------------------------------------------

/// A 2D vector.
const Vec2 = struct {
    x: f64,
    y: f64,

    pub fn length(self: Vec2) f64 {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub fn add(self: Vec2, other: Vec2) Vec2 {
        return .{ .x = self.x + other.x, .y = self.y + other.y };
    }
};

/// Compass directions.
const Direction = enum {
    north,
    south,
    east,
    west,

    pub fn opposite(self: Direction) Direction {
        return switch (self) {
            .north => .south,
            .south => .north,
            .east => .west,
            .west => .east,
        };
    }
};

/// Tagged union: parsed integer or error message.
const ParseResult = union(enum) {
    ok: i64,
    err: []const u8,

    pub fn isOk(self: ParseResult) bool {
        return switch (self) {
            .ok => true,
            .err => false,
        };
    }
};

/// Default-value struct.
const Config = struct {
    host: []const u8 = "localhost",
    port: u16 = 8080,
    tls: bool = false,
};

// ---------------------------------------------------------------------------
// 5. Pointers, slices, arrays, and sentinel-terminated arrays
// ---------------------------------------------------------------------------

fn ptrDemo() void {
    var x: i32 = 42;
    const p: *i32 = &x;
    p.* = 99;

    var arr: [5]u8 = .{ 1, 2, 3, 4, 5 };
    const slice: []u8 = arr[0..3];

    const sentinel: [3:0]u8 = .{ 'a', 'b', 'c' };
    _ = slice;
    _ = sentinel;
}

// ---------------------------------------------------------------------------
// 6. Strings — literals, multi-line, slicing, formatting
// ---------------------------------------------------------------------------

fn stringDemo() void {
    const hello: []const u8 = "hello, zig";
    const multiline: []const u8 =
        \\first line
        \\second line
        \\third line
    ;

    const upper = std.ascii.toUpperString(hello);
    _ = upper;
    _ = multiline;
}

// ---------------------------------------------------------------------------
// 7. Error handling — error sets, try, catch, if/else on errors
// ---------------------------------------------------------------------------

const AppError = error{
    NotFound,
    PermissionDenied,
    OutOfMemory,
};

fn mightFail(flag: bool) AppError!u8 {
    if (flag) return 42;
    return error.NotFound;
}

fn errorDemo() void {
    const result = mightFail(true) catch 0;
    const val = mightFail(false) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    _ = result;
    _ = val;

    // if/else error unwrapping
    if (mightFail(true)) |ok| {
        _ = ok;
    } else |err| {
        _ = err;
    }
}

// ---------------------------------------------------------------------------
// 8. Comptime — compile-time evaluation, reflection, generics
// ---------------------------------------------------------------------------

fn comptimeSquare(comptime x: i32) i32 {
    return x * x;
}

const SQUARE_OF_FIVE: i32 = comptime comptimeSquare(5);

fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

fn typeName(comptime T: type) []const u8 {
    return @typeName(T);
}

// ---------------------------------------------------------------------------
// 9. Generics / Duck-typing via `anytype`
// ---------------------------------------------------------------------------

fn describe(thing: anytype) void {
    const info = @typeInfo(@TypeOf(thing));
    std.debug.print("Type: {s}, value: {}\n", .{ @tagName(info), thing });
}

// ---------------------------------------------------------------------------
// 10. Async / Suspend / Resume
// ---------------------------------------------------------------------------

var async_frame: anyframe = undefined;

fn asyncWorker() void {
    suspend {
        async_frame = @frame();
    }
    // resume continues here
}

fn asyncDemo() void {
    var frame = async asyncWorker();
    resume async_frame;
    await frame;
}

// ---------------------------------------------------------------------------
// 11. Loops with labels, nested, and continue/break
// ---------------------------------------------------------------------------

fn labeledLoopDemo() void {
    outer: for (0..10) |i| {
        inner: for (0..10) |j| {
            if (i == j) continue :inner;
            if (i + j > 15) break :outer;
        }
    }
}

// ---------------------------------------------------------------------------
// 12. Defer, errdefer
// ---------------------------------------------------------------------------

fn deferDemo() !void {
    var file: std.fs.File = undefined;

    defer {
        file.close();
    }
    errdefer {
        // cleanup on error
    }

    file = try std.fs.cwd().openFile("test.txt", .{});
}

// ---------------------------------------------------------------------------
// 13. Opaque types, unions, packed structs
// ---------------------------------------------------------------------------

const OpaqueHandle = opaque {};

const BitField = packed struct(u32) {
    flag_a: bool,
    flag_b: bool,
    flag_c: bool,
    padding: u29 = 0,
};

const Register = extern union {
    raw: u32,
    parts: struct {
        low: u16,
        high: u16,
    },
};

// ---------------------------------------------------------------------------
// 14. Tests!
// ---------------------------------------------------------------------------

test "add works" {
    try testing.expectEqual(@as(i32, 5), add(2, 3));
    try testing.expectEqual(@as(i32, 0), add(-1, 1));
}

test "factorial of 5 is 120" {
    try testing.expectEqual(@as(u64, 120), factorial(5));
}

test "square" {
    try testing.expectApproxEqAbs(@as(f64, 25.0), square(5.0), 1e-12);
}

test "classify numbers" {
    try testing.expectEqualStrings("positive", classifyNumber(10));
    try testing.expectEqualStrings("negative", classifyNumber(-3));
    try testing.expectEqualStrings("zero", classifyNumber(0));
}

test "sum of slice" {
    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    try testing.expectEqual(@as(i32, 15), sumArray(&arr));
}

test "Vec2 operations" {
    const v1 = Vec2{ .x = 3.0, .y = 4.0 };
    const v2 = Vec2{ .x = 1.0, .y = 2.0 };

    try testing.expectApproxEqAbs(@as(f64, 5.0), v1.length(), 1e-12);
    const sum = v1.add(v2);
    try testing.expectApproxEqAbs(@as(f64, 4.0), sum.x, 1e-12);
    try testing.expectApproxEqAbs(@as(f64, 6.0), sum.y, 1e-12);
}

test "direction opposite" {
    try testing.expectEqual(Direction.south, Direction.north.opposite());
    try testing.expectEqual(Direction.west, Direction.east.opposite());
}

test "parse result tagged union" {
    const ok = ParseResult{ .ok = 42 };
    try testing.expect(ok.isOk());

    const err = ParseResult{ .err = "invalid input" };
    try testing.expect(!err.isOk());
}

test "generic max works" {
    try testing.expectEqual(@as(i32, 10), max(i32, 5, 10));
    try testing.expectEqual(@as(f64, 3.14), max(f64, 2.71, 3.14));
}

test "error handling with try" {
    const val = try mightFail(true);
    try testing.expectEqual(@as(u8, 42), val);
}

test "comptime square" {
    try testing.expectEqual(@as(i32, 25), SQUARE_OF_FIVE);
}

test "type name" {
    try testing.expectEqualStrings("u32", typeName(u32));
    try testing.expectEqualStrings("bool", typeName(bool));
}

// ---------------------------------------------------------------------------
// 15. End of file — marker comment
// ---------------------------------------------------------------------------
// Done.
