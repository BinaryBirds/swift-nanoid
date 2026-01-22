//
//  NanoID.swift
//  swift-nanoid
//
//  Created by Kitti Bodecs on 2026. 01. 21..
//

/// `NanoID` can:
/// - Generate a random identifier of a given length using a fixed alphabet.
/// - Validate / construct an identifier from an existing string (only if it contains allowed characters).
/// - Encode and decode as a single JSON string value.
/// - Be used safely across concurrency domains (`Sendable`) and in hashed collections (`Hashable`).
///
/// The generated IDs are **not cryptographically secure** because they rely on `Int.random(in:)`.
public struct NanoID {

    /// The underlying identifier string.
    public let rawValue: String

    /// Creates a new random `NanoID`.
    ///
    /// - Parameter size: The number of characters to generate. Defaults to `21`.
    ///
    /// The ID is constructed by selecting `size` random characters from `NanoID.alphabet`.
    public init(
        size: Int = 21
    ) {
        var value = ""
        for _ in 0..<size {
            let offset = Int.random(in: 0..<Self.alphabet.count)
            let index = Self.alphabet.index(
                Self.alphabet.startIndex,
                offsetBy: offset
            )
            value.append(Self.alphabet[index])
        }
        self.rawValue = value
    }
}

public extension NanoID {

    /// The allowed characters used for generation and validation.
    ///
    /// Only strings composed entirely of characters from this alphabet can be converted
    /// into a `NanoID` via `LosslessStringConvertible` (`NanoID("...")`).
    static let alphabet: String =
        "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"
}

public extension NanoID {

    /// The character length of the identifier.
    ///
    /// Equivalent to `rawValue.count`.
    var size: Int { rawValue.count }
}

/// `NanoID` is safe to pass across concurrency boundaries.
extension NanoID: Sendable {}

/// Supports equality comparison (two IDs are equal if their `rawValue` is equal).
extension NanoID: Equatable {}

/// Supports hashing (usable as dictionary keys / in sets).
extension NanoID: Hashable {}

/// Encodes the ID as a single string value (e.g. JSON: `"abc123"`).
extension NanoID: Encodable {
    /// Encodes `NanoID` as a single string value (e.g. JSON: `"abc123"`).
    /// This ensures the encoded representation matches the underlying `rawValue`
    /// rather than producing a keyed container.
    public func encode(to encoder: Encoder) throws {
        // Use a single value container since NanoID is represented by one String
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

/// Decodes `NanoID` from a single string value.
/// Throws a `DecodingError.dataCorrupted` error if the string cannot be
/// converted into a valid `NanoID` instance.
extension NanoID: Decodable {
    /// Initializes a `NanoID` by decoding a single string value.
    public init(from decoder: Decoder) throws {
        // Decode the value from a single value container
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        // Validate and initialize NanoID from the decoded string
        guard let id = NanoID(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: """
                    Failed to convert an instance of \(NanoID.self) from "\(string)"
                    """
            )
        }
        // Assign the validated raw value
        self.rawValue = id.rawValue
    }
}

/// Enables lossless conversion between `NanoID` and `String`.
///
/// `NanoID("someString")` succeeds only if all characters are present in `NanoID.alphabet`.
extension NanoID: LosslessStringConvertible {

    /// Creates a `NanoID` from a string if it contains only allowed characters.
    ///
    /// - Parameter description: The source string.
    public init?(_ description: String) {
        for char in description {
            guard Self.alphabet.firstIndex(of: char) != nil else {
                return nil
            }
        }
        self.rawValue = description
    }

    /// The string representation of this ID.
    public var description: String {
        rawValue
    }
}
