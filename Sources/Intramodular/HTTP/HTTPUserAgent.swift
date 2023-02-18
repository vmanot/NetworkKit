//
// Copyright (c) Vatsal Manot
//

import Swift

public enum HTTPUserAgent: Codable, Hashable, RawRepresentable, Sendable {
    case bot
    case chrome
    case chromeAndroid
    case chromeiOS
    case firefoxMac
    case firefoxWindows
    case internetExplorer
    case opera
    case safari
    
    case custom(String)
    
    public var rawValue: String {
        switch self {
            case .bot:
                return "Googlebot/2.1 (+http://www.google.com/bot.html)"
            case .chrome:
                return "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
            case .chromeAndroid:
                return "Mozilla/5.0 (Linux; <Android Version>; <Build Tag etc.>) AppleWebKit/<WebKit Rev> (KHTML, like Gecko) Chrome/<Chrome Rev> Mobile Safari/<WebKit Rev>"
            case .chromeiOS:
                return "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1"
            case .firefoxMac:
                return "Mozilla/5.0 (Macintosh; Intel Mac OS X x.y; rv:42.0) Gecko/20100101 Firefox/42.0"
            case .firefoxWindows:
                return "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
            case .internetExplorer:
                return "Mozilla/5.0 (compatible; MSIE 9.0; Windows Phone OS 7.5; Trident/5.0; IEMobile/9.0)"
            case .opera:
                return "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36 OPR/38.0.2220.41"
            case .safari:
                return "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
                
            case .custom(let value):
                return value
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self.bot.rawValue:
                self = .bot
            case Self.chrome.rawValue:
                self = .chrome
            case Self.chromeAndroid.rawValue:
                self = .chromeAndroid
            case Self.chromeiOS.rawValue:
                self = .chromeiOS
            case Self.firefoxMac.rawValue:
                self = .firefoxMac
            case Self.firefoxWindows.rawValue:
                self = .firefoxWindows
            case Self.internetExplorer.rawValue:
                self = .internetExplorer
            case Self.opera.rawValue:
                self = .opera
            case Self.safari.rawValue:
                self = .safari
                
            default:
                self = .custom(rawValue)
        }
    }
}
