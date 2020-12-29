//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public struct ASN1DistinguishedNames {
    public let oid: String
    public let representation: String
    
    init(oid: String, representation: String) {
        self.oid = oid
        self.representation = representation
    }
    
    public static let commonName = Self(oid: "2.5.4.3", representation: "CN")
    public static let dnQualifier = Self(oid: "2.5.4.46", representation: "DNQ")
    public static let serialNumber = Self(oid: "2.5.4.5", representation: "SERIALNUMBER")
    public static let givenName = Self(oid: "2.5.4.42", representation: "GIVENNAME")
    public static let surname = Self(oid: "2.5.4.4", representation: "SURNAME")
    public static let organizationalUnitName = Self(oid: "2.5.4.11", representation: "OU")
    public static let organizationName = Self(oid: "2.5.4.10", representation: "O")
    public static let streetAddress = Self(oid: "2.5.4.9", representation: "STREET")
    public static let localityName = Self(oid: "2.5.4.7", representation: "L")
    public static let stateOrProvinceName = Self(oid: "2.5.4.8", representation: "ST")
    public static let countryName = Self(oid: "2.5.4.6", representation: "C")
    public static let email = Self(oid: "1.2.840.113549.1.9.1", representation: "E")
}
