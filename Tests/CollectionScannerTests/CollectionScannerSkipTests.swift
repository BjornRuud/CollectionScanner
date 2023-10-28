import XCTest
@testable import CollectionScanner

final class CollectionScannerSkipTests: XCTestCase {
    func testSkipOne() throws {
        let scanner = CollectionScanner("ab")
        scanner.skip(1)
        XCTAssertEqual(scanner.currentElement, "b")
    }

    func testSkipTwo() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(2)
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipElement() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(element: "c")
        XCTAssertEqual(scanner.currentElement, "a")
        scanner.skip(element: "a")
        XCTAssertEqual(scanner.currentElement, "b")
    }

    func testSkipCollection() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(collection: "bc")
        XCTAssertEqual(scanner.currentElement, "a")
        scanner.skip(collection: "ac")
        XCTAssertEqual(scanner.currentElement, "a")
        scanner.skip(collection: "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipSet() throws {
        let scanner = CollectionScanner("abc")
        let set = Set<Character>("ab")
        let wrongSet = Set<Character>("bc")
        scanner.skip(set: wrongSet)
        XCTAssertEqual(scanner.currentElement, "a")
        scanner.skip(set: set)
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testSkipUpToElement() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip(upTo: "c")
        XCTAssertEqual(scanner.currentElement, "c")
        scanner.skip(upTo: "!")
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testSkipWhile() throws {
        let scanner = CollectionScanner("abc")
        scanner.skip { $0 == "!" }
        XCTAssertEqual(scanner.currentElement, "a")
        scanner.skip { $0 == "a" || $0 == "b" }
        XCTAssertEqual(scanner.currentElement, "c")
        scanner.skip { $0 != "!" }
        XCTAssertTrue(scanner.isAtEnd)
    }
}
