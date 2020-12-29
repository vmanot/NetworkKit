//
// Copyright (c) Vatsal Manot
//

import Darwin
import Swift

public struct IPv4Header {
    var versionAndHeaderLength: UInt8
    var differentiatedServices: UInt8
    var totalLength: UInt16
    var identification: UInt16
    var flagsAndFragmentOffset: UInt16
    var timeToLive: UInt8
    var `protocol`: UInt8
    var headerChecksum: UInt16
    var sourceAddress: (UInt8, UInt8, UInt8, UInt8)
    var destinationAddress: (UInt8, UInt8, UInt8, UInt8)
}
