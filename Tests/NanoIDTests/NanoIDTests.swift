import XCTest
@testable import NanoID

final class NanoIDTests: XCTestCase {

    func testAlphabet() {
        let id = NanoID()

        for char in id.value {
            guard NanoID.alphabet.firstIndex(of: char) != nil else {
                return XCTFail("Invalid character")
            }
        }
    }

    func testDefaultSize() {
        let size = 21
        let id = NanoID(size: size)
        XCTAssertEqual(id.value.count, id.size)
        XCTAssertEqual(size, id.size)
    }

    func testCustomSize() {
        let size = 4
        let id = NanoID(size: size)
        XCTAssertEqual(id.value.count, id.size)
        XCTAssertEqual(size, id.size)
    }

    func testValidAlphabet() {
        let id = NanoID("abc")
        XCTAssertNotNil(id)
        XCTAssertEqual(id?.value, "abc")
        XCTAssertEqual(id?.size, 3)
        XCTAssertEqual(id?.description, "abc")
    }

    func testInvalidAlphabet() {
        let id = NanoID("!!!")
        XCTAssertNil(id)
    }

    func testEquatable() {
        let id1 = NanoID("abc")
        let id2 = NanoID("abc")
        let id3 = NanoID()

        XCTAssertEqual(id1, id2)
        XCTAssertNotEqual(id1, id3)
    }

    func testDecodable() throws {
        struct Wrapper: Codable {
            let id: NanoID
        }

        let jsonString = #"{"id":"abc"}"#
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let wrapper = try decoder.decode(Wrapper.self, from: jsonData)
        XCTAssertEqual(wrapper.id.value, "abc")
    }

    func testEncodable() throws {
        struct Wrapper: Codable {
            let id: NanoID
        }
        let wrapper = Wrapper(id: .init("abc")!)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(wrapper)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        XCTAssertEqual(jsonString, #"{"id":"abc"}"#)
    }

    func testCollision() {
        var ids = Set<NanoID>()
        for _ in 0..<10_000 {
            let id = NanoID()
            XCTAssertFalse(ids.contains(id))
            ids.insert(id)
        }
    }
}
