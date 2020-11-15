//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

public class X509PublicKey {
    
    var pkBlock: ASN1Object!
    
    init(pkBlock: ASN1Object) {
        self.pkBlock = pkBlock
    }
    
    public var algOid: String? {
        return pkBlock.sub(0)?.sub(0)?.value as? String
    }
    
    public var algName: String? {
        return ASN1Object.oidDecodeMap[algOid ?? ""]
    }
    
    public var algParams: String? {
        return pkBlock.sub(0)?.sub(1)?.value as? String
    }
    
    public var key: Data? {
        guard
            let algOid = algOid,
            let oid = OID(rawValue: algOid),
            let keyData = pkBlock.sub(1)?.value as? Data else {
            return nil
        }
        
        switch oid {
            case .ecPublicKey:
                return keyData
                
            case .rsaEncryption:
                guard let publicKeyAsn1Objects = (try? ASN1DERDecoder.decode(data: keyData)) else {
                    return nil
                }
                guard let publicKeyModulus = publicKeyAsn1Objects.first?.sub(0)?.value as? Data else {
                    return nil
                }
                return publicKeyModulus
                
            default:
                return nil
        }
    }
}
