import Foundation


public struct ExtrinsicConstants {
    static let version: UInt8 = 4
    static let signedMask: UInt8 = 1 << 7
}

public struct Extrinsic: Codable {
    enum CodingKeys: String, CodingKey {
        case signature
        case call
    }

    public let signature: ExtrinsicSignature?
    public let call: JSON

    public init(signature: ExtrinsicSignature?, call: JSON) {
        self.signature = signature
        self.call = call
    }
}

public struct ExtrinsicSignature: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case signature
        case extra
    }

    public let address: JSON
    public let signature: JSON
    public let extra: ExtrinsicExtra

    public init(address: JSON, signature: JSON, extra: ExtrinsicExtra) {
        self.address = address
        self.signature = signature
        self.extra = extra
    }
}

enum MultiSignatureError: Error {
    case unexpectedType
}

public enum MultiSignature: Codable {
    static let sr25519Field = "Sr25519"
    static let ed25519Field = "Ed25519"
    static let ecdsaField = "Ecdsa"

    case sr25519(data: Data)
    case ed25519(data: Data)
    case ecdsa(data: Data)

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let type = try container.decode(String.self)

        let data: Data

        // we support both data and byte arrays representation
        if let dataRepresentation = try? container.decode(Data.self) {
            data = dataRepresentation
        } else {
            let byteArray = try container.decode([StringScaleMapper<UInt8>].self).map { $0.value }
            data = Data(byteArray)
        }

        switch type {
        case Self.sr25519Field:
            self = .sr25519(data: data)
        case Self.ed25519Field:
            self = .ed25519(data: data)
        case Self.ecdsaField:
            self = .ecdsa(data: data)
        default:
            throw MultiSignatureError.unexpectedType
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        switch self {
        case .sr25519(let data):
            try container.encode(Self.sr25519Field)
            try container.encode(data)
        case .ed25519(let data):
            try container.encode(Self.ed25519Field)
            try container.encode(data)
        case .ecdsa(let data):
            try container.encode(Self.ecdsaField)
            try container.encode(data)
        }
    }
}
