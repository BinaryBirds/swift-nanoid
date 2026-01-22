//
//  NanoIDTestSuite.swift
//  swift-nanoid
//
//  Created by Kitti Bodecs on 2026. 01. 21..
//

import Testing

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

@testable import NanoID

@Suite
struct NanoIDTestSuite {

    @Test
    func alphabet() {
        let id = NanoID()

        for char in id.rawValue {
            guard NanoID.alphabet.firstIndex(of: char) != nil else {
                Issue.record("Invalid character")
                return
            }
        }
    }

    @Test
    func defaultSize() {
        let size = 21
        let id = NanoID(size: size)
        #expect(id.rawValue.count == id.size)

        #expect(size == id.size)
    }

    @Test
    func testCustomSize() {
        let size = 4
        let id = NanoID(size: size)
        #expect(id.rawValue.count == id.size)
        #expect(size == id.size)
    }

    @Test
    func validAlphabet() {
        let id = NanoID("abc")
        #expect(id != nil)
        #expect(id?.rawValue == "abc")
        #expect(id?.size == 3)
        #expect(id?.description == "abc")
    }

    @Test
    func invalidAlphabet() {
        let id = NanoID("!!!")
        #expect(id == nil)
    }

    @Test
    func equatable() {
        let id1 = NanoID("abc")
        let id2 = NanoID("abc")
        let id3 = NanoID()

        #expect(id1 == id2)
        #expect(id1 != id3)

    }

    @Test
    func decodable() throws {
        struct Wrapper: Codable {
            let id: NanoID
        }

        let jsonString = #"{"id":"abc"}"#
        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let wrapper = try decoder.decode(Wrapper.self, from: jsonData)
        #expect(wrapper.id.rawValue == "abc")
    }

    @Test
    func encodable() throws {
        struct Wrapper: Codable {
            let id: NanoID
        }
        let wrapper = Wrapper(id: .init("abc")!)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(wrapper)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        #expect(jsonString == #"{"id":"abc"}"#)
    }

    @Test
    func collision() {
        var ids = Set<NanoID>()
        for _ in 0..<10_000 {
            let id = NanoID()
            #expect(!ids.contains(id))
            ids.insert(id)
        }
    }

    // LoslessStringConvertible

    @Test
    func initFailsForInvalidCharacters() {
        #expect(NanoID("abc def") == nil)
        #expect(NanoID("abc🙂def") == nil)
        #expect(NanoID("abc\ndef") == nil)
    }

    @Test
    func initSucceedsForValidCharacters() {
        let s = String(NanoID.alphabet.prefix(10))
        let id = NanoID(s)

        #expect(id != nil)
        #expect(id?.rawValue == s)
    }

    @Test
    func descriptionReturnsRawValue() {
        let s = String(NanoID.alphabet.suffix(12))
        let id = NanoID(s)!

        #expect(id.description == s)
        #expect(id.description == id.rawValue)
    }

    @Test
    func losslessRoundTrip() {
        let original = NanoID(size: 21)
        let roundTripped = NanoID(original.description)!

        #expect(roundTripped.rawValue == original.rawValue)
        #expect(roundTripped.description == original.description)
    }

    // Decoding failure path

    @Test
    func decodableFailsForInvalidString() {
        struct Wrapper: Codable { let id: NanoID }

        let jsonData = #"{"id":"!!!"}"#.data(using: .utf8)!
        let decoder = JSONDecoder()

        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(Wrapper.self, from: jsonData)
        }
    }

    @Test
    func decodableFailsWithDataCorrupted() {
        struct Wrapper: Codable { let id: NanoID }

        let jsonData = #"{"id":"!!!"}"#.data(using: .utf8)!
        let decoder = JSONDecoder()

        do {
            _ = try decoder.decode(Wrapper.self, from: jsonData)
            Issue.record("Expected decoding to fail, but it succeeded.")
        }
        catch let DecodingError.dataCorrupted(context) {
            #expect(context.debugDescription.contains("Failed to convert"))
        }
        catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
