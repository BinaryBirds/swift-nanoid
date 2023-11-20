public struct NanoID {
    public let value: String

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
        self.value = value
    }
}

public extension NanoID {
    static let alphabet: String =
        "useandom-26T198340PX75pxJACKVERYMINDBUSHWOLF_GQZbfghjklqvwyzrict"
}

public extension NanoID {
    var size: Int { value.count }
}

extension NanoID: Sendable {}
extension NanoID: Equatable {}
extension NanoID: Hashable {}
extension NanoID: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.value)
    }
}
extension NanoID: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let id = NanoID(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: """
                    Failed to convert an instance of \(NanoID.self) from "\(string)"
                    """
            )
        }
        self.value = id.value
    }
}

extension NanoID: LosslessStringConvertible {

    public init?(_ description: String) {
        for char in description {
            guard Self.alphabet.firstIndex(of: char) != nil else {
                return nil
            }
        }
        self.value = description
    }

    public var description: String {
        value
    }
}
