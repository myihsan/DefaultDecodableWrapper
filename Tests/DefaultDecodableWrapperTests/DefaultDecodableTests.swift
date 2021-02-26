import XCTest
import Foundation
import DefaultDecodableWrapper

final class DefaultDecodableTests: XCTestCase {
    func testDecode() throws {
        // Given
        struct Foo: RawRepresentable, Decodable {
            let rawValue: Int
        }
        struct FooDefault: Default {
            static var defaultValue: Foo { .init(rawValue: 1) }
        }
        struct Target: Decodable {
            @DefaultDecodable<FooDefault> var foo: Foo
        }
        let decoder = JSONDecoder()

        try XCTContext.runActivity(named: "Decode an object without foo.") { _ in
            let jsonData = Data("{}".utf8)
            // When
            let target = try decoder.decode(Target.self, from: jsonData)
            // Then
            XCTAssertEqual(target.foo.rawValue, 1)
        }

        try XCTContext.runActivity(named: "Decode an object with null foo.") { _ in
            let jsonData = Data(#"{ "foo": null }"#.utf8)
            // When
            let target = try decoder.decode(Target.self, from: jsonData)
            // Then
            XCTAssertEqual(target.foo.rawValue, 1)
        }

        try XCTContext.runActivity(named: "Decode an object with different type foo.") { _ in
            let jsonData = Data(#"{ "foo": "1" }"#.utf8)
            // When
            XCTAssertThrowsError(try decoder.decode(Target.self, from: jsonData))
        }
    }

    func testDefaultBySelf() throws {
        // Given
        struct Foo: RawRepresentable, Decodable, SelfDefault {
            let rawValue: Int
            static var defaultValue: Foo { .init(rawValue: 1) }
        }
        struct Target: Decodable {
            @DefaultBy.Self var foo: Foo
        }
        let decoder = JSONDecoder()
        let jsonData = Data("{}".utf8)
        // When
        let target = try decoder.decode(Target.self, from: jsonData)
        // Then
        XCTAssertEqual(target.foo.rawValue, 1)
    }

    func testDefaultByEmpty() throws {
        // Given
        struct Target: Decodable {
            @DefaultBy.Empty var array: [Int]
            @DefaultBy.Empty var string: String
        }
        let decoder = JSONDecoder()
        let jsonData = Data("{}".utf8)
        // When
        let target = try decoder.decode(Target.self, from: jsonData)
        // Then
        XCTAssertEqual(target.array, [])
        XCTAssertEqual(target.string, "")
    }

    func testDefaultByNumeric() throws {
        // Given
        struct Target: Decodable {
            @DefaultBy.Zero var zero: Int
            @DefaultBy.One var one: Double
            @DefaultBy.MinusOne var minusOne: Decimal
        }
        let decoder = JSONDecoder()
        let jsonData = Data("{}".utf8)
        // When
        let target = try decoder.decode(Target.self, from: jsonData)
        // Then
        XCTAssertEqual(target.zero, 0)
        XCTAssertEqual(target.one, 1)
        XCTAssertEqual(target.minusOne, -1)
    }

    static var allTests = [
        ("testDecode", testDecode),
    ]
}
