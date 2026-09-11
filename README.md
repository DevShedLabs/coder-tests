# Language Tests

https://coderide.dev 

A collection of per-language test files used to exercise editor features:
**syntax highlighting, bracket matching, code folding, indentation,
auto-completion, diagnostics, go-to-definition, find-references**, and more.

Each file is written to cover a broad slice of its language's syntax and
semantics (structs/classes, generics, enums, concurrency, error handling,
unit tests, decorators, etc.) so you can verify the editor behaves well
across real-world constructs.

## Language matrix

| Language   | File / project        | Run tests                | Requirements                         |
| ---------- | --------------------- | ------------------------ | ------------------------------------ |
| C          | `c/test.c`             | compile, then run        | C compiler (C17)                     |
| C++        | `cpp/test.cpp`         | compile, then run        | C++ compiler (C++20)                 |
| Go         | `go/test.go`          | `go run test.go`         | Go toolchain                         |
| HTML/CSS/JS| `html/test.html`      | open in a browser        | none (static file)                   |
| PHP        | `php/test.php`        | `php test.php`           | PHP ≥ 8.1                            |
| Python     | `python/test.py`      | `python -m unittest -v`  | Python ≥ 3.10                        |
| Rust       | `rust/` (Cargo bin)   | `cargo run`              | Rust toolchain                       |
| Swift      | `swift/` (SPM package) | `swift test`            | Swift toolchain (Xcode / swift.org) |
| TypeScript | `typescript/test.ts`  | `npx tsx test.ts`        | Node.js + `tsx`, or `tsc` to type-check |
| Zig        | `zig/test.zig`        | `zig test test.zig`      | Zig ≥ 0.14 (current stable)          |

---

## C — `c/test.c`

Compile and run from the `c` directory:

```sh
cd c
cc -std=c17 -Wall -Wextra -pedantic -O2 test.c -o test
./test
```

You can use `gcc` instead of `cc`. For additional static diagnostics:

```sh
cc -std=c17 -Wall -Wextra -pedantic -fanalyzer test.c -o /tmp/c-language-test
```

## C++ — `cpp/test.cpp`

Compile and run from the `cpp` directory. The test requires C++20 for concepts and ranges:

```sh
cd cpp
c++ -std=c++20 -Wall -Wextra -pedantic -O2 test.cpp -o test
./test
```

You can use `clang++` or `g++` instead of `c++`. For sanitizer checks:

```sh
c++ -std=c++20 -Wall -Wextra -pedantic -fsanitize=address,undefined -g test.cpp -o /tmp/cpp-language-test
/tmp/cpp-language-test
```

The `/tmp` output paths keep diagnostic binaries out of the language-test directories.

## Go — `go/test.go`

A single runnable file exercising structs, interfaces, JSON, `defer`,
goroutines, channels, `select`, and an HTTP server.

```sh
cd go
go run test.go
```

Starts an HTTP server on `:8080`. Try it in another terminal:

```sh
curl http://localhost:8080/users                  # GET list
curl -X POST -d '{"name":"Zed","email":"z@x.io"}' http://localhost:8080/users
```

Editor checks:

- `go build ./...` / `go vet ./...` for diagnostics
- `gofmt -l .` to verify formatting integration

> Note: there are no `_test.go` files here, so `go test ./...` reports "no test
> files". The file is meant to be run, not unit-tested.

## HTML / CSS / JS — `html/test.html`

A self-contained webpage with embedded `<style>` and `<script>` blocks.
Open it directly in a browser:

```sh
open html/test.html        # macOS
```

Use the form: submit a name/role/notes to see entries appear in the dynamic
list; use the *Toggle Theme* / *Clear* buttons. This exercises:

- HTML tag/attribute completion and Emmet expansion
  (`div.card>h2{Title}+p{Content}` is hinted at the bottom of the file)
- CSS custom properties, nesting in selectors, color previews
- JS DOM APIs, `addEventListener`, template literals

## PHP — `php/test.php`

A script covering classes, `readonly` promoted properties, static analysis
via `?:`-free nullsafe/`match` expressions, fibers, enums, and interfaces.

```sh
cd php
php test.php
```

Output is the top-level fiber demo (suspends, resumes, prints). No output is
printed for the `User` class / `paginate()` / `statusLabel()` — those exist to
exercise highlighting, diagnostics, and go-to-definition.

Editor checks: install a PHP language server (e.g. Intelephense) to verify
diagnostics on the deliberate `restrict_types`/`db()` calls.

## Python — `python/test.py`

Requires **Python 3.10+** (`match`/`case`, `|` union syntax, walrus).

Run the unittest suite:

```sh
cd python
python -m unittest -v test    # discovery by module name
# or
python test.py                # uses the built-in unittest.main() entry point
```

Note: module-level code in this file is only executed when run directly
(`python test.py`); `python -m unittest` imports it without running `main()`.

The file covers type hints, decorators (incl. `@retry`), dataclasses,
generics (`Stack[T]`), generators, context managers, `async`/`await`,
`__slots__`, properties, and 15 unittest cases.

## Rust — `rust/` (Cargo project)

A small Cargo project (`rust/src/main.rs`, binary `test`) covering traits,
enums, generics, `Arc<Mutex<>>`, iterators, closures, and error handling.

```sh
cd rust
cargo run          # build + run the demo program
cargo build        # just compile
cargo test         # run any #[test]s added
cargo fmt --check  # formatting check
```

`cargo run` prints users, admins, and expected errors. `target/` is build
output; `Cargo.lock` is checked in intentionally.

## Swift — `swift/` (Swift Package)

A Swift package (`swift/Package.swift`) whose library target
(`Sources/LanguageTests/TestSuite.swift`) exercises structs/classes, enums
with associated values, generics (`Stack<T>`), protocols, closures, error
handling (`throws`, `Result`, `do/catch`), inheritance, lazy computation,
and Swift concurrency (`actor`, `async`/`await`, `TaskGroup`, `Sendable`).
The `XCTest` suite lives at `Tests/LanguageTestsTests/`.

```sh
cd swift
swift build       # compile + fetch diagnostics
swift test        # run the XCTest suite
swift test --list-tests   # verify test discovery
```

Formatting check (requires `swift-format`, part of the Swift toolchain):

```sh
swift-format lint --strict Sources Tests
```

Build artifacts go to `swift/.build/` (git-ignored).

## TypeScript — `typescript/test.ts`

A self-contained module (no imports) covering generics, mapped/conditional
types, template literal types, discriminated unions, typed event emitter,
`async`/`yield*` generators.

Type-check without running:

```sh
cd typescript
npx tsc --noEmit --target es2022 --module esnext --strict test.ts
```

Run it with `tsx` (or `bun`, or Node ≥ 23 with type-stripping):

```sh
npx tsx test.ts
bun test.ts
node test.ts      # Node 23.6+ strips types at runtime
```

## Zig — `zig/test.zig`

A single file with compile-time evaluation, error unions, tagged unions,
slices/sentinels, packages via `@import`, and an embedded test block.

```sh
cd zig
zig test test.zig        # runs all `test "..."` blocks
zig fmt --check test.zig # formatting check
```

Expected output: a compact `[n/...]` test-runner summary. Note that the
async/`suspend` section was deliberately removed because Zig ≥ 0.11 removed
those features from the language; keep it that way to avoid syntax errors
that would abort the whole file's test run.

---

## Image Tests

![Image Test](./images/future-ai-coding.png)

## How to test editor features

Across any language file, try:

| Feature            | What to do                                                     |
| ------------------ | -------------------------------------------------------------- |
| Highlighting       | Open the file; scan for mis-colored comments/strings/keywords  |
| Bracket matching   | Click on `{`, `(`, `[` and jump between matching pairs         |
| Code folding       | Fold function/class/struct/test bodies and comment blocks      |
| Indentation        | New line inside a block; paste a block and re-indent           |
| Completion         | Type a known identifier / call a method (e.g. `repo.`, `self.`)|
| Diagnostics        | Introduce a typo; the language server should flag it           |
| Go-to-definition   | Cmd/Alt-click an identifier to jump to its definition          |
| Find references    | Right-click a function name → Find All References              |
| Rename             | Rename a symbol; cross-references should update                |
| Formatting         | Run the language's formatter (gofmt/rustfmt/`zig fmt`/…)       |
