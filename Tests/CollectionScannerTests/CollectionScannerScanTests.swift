import XCTest
@testable import CollectionScanner

final class CollectionScannerScanTests: XCTestCase {
    func testScanOneElement() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.scan(1), "a")
        XCTAssertEqual(scanner.currentElement, "b")
    }

    func testScanTwoElements() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.scan(2), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
    }

    func testScanElement() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertTrue(scanner.scan(element: "c").isEmpty)
        XCTAssertEqual(scanner.scan(element: "a"), "a")
        XCTAssertEqual(scanner.currentElement, "b")
    }

    func testScanSet() throws {
        let scanner = CollectionScanner("ab!")
        var set = Set<Character>()
        set.insert("a")
        set.insert("b")
        XCTAssertEqual(scanner.scan(set: set), "ab")
        XCTAssertEqual(scanner.currentElement, "!")
    }

    func testScanUpToElement() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertTrue(scanner.scan(upTo: "a").isEmpty)
        XCTAssertEqual(scanner.scan(upTo: "c"), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
        XCTAssertEqual(scanner.scan(upTo: "d"), "c")
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testScanUpToCollection() throws {
        let scanner = CollectionScanner("abcd")
        XCTAssertEqual(scanner.scan(upToCollection: "cd"), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
        XCTAssertEqual(scanner.scan(upToCollection: "ef"), "cd")
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testScanUpToSet() throws {
        let scanner = CollectionScanner("abcd!")
        var set = Set<Character>()
        set.insert("c")
        set.insert("d")
        XCTAssertEqual(scanner.scan(upToSet: set), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
        scanner.skip(2)
        XCTAssertEqual(scanner.scan(upToSet: set), "!")
        XCTAssertTrue(scanner.isAtEnd)
    }

    func testScanWhile() throws {
        let scanner = CollectionScanner("abc")
        XCTAssertEqual(scanner.scan(while: { $0 != "c" }), "ab")
        XCTAssertEqual(scanner.currentElement, "c")
        XCTAssertEqual(scanner.scan(while: { $0 != "!" }), "c")
        XCTAssertTrue(scanner.isAtEnd)
    }
}
