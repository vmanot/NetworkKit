import Testing
import Foundation
@testable import NetworkKit

// MARK: - HTTPMethod

@Suite
struct HTTPMethodTests {
    @Test(arguments: [
        (HTTPMethod.get, "GET"),
        (.post, "POST"),
        (.put, "PUT"),
        (.delete, "DELETE"),
        (.patch, "PATCH"),
        (.head, "HEAD"),
        (.options, "OPTIONS"),
        (.connect, "CONNECT"),
        (.trace, "TRACE"),
    ])
    func rawValueRoundtrip(method: HTTPMethod, expected: String) {
        #expect(method.rawValue == expected)
        #expect(HTTPMethod(rawValue: expected) == method)
        #expect(method.description == expected)
    }

    @Test
    func prefersQueryParameters() {
        let queryMethods: [HTTPMethod] = [.get, .head, .delete]
        let bodyMethods: [HTTPMethod] = [.post, .put, .patch, .connect, .options, .trace]

        for method in queryMethods {
            #expect(method.prefersQueryParameters, "\(method) should prefer query parameters")
        }
        for method in bodyMethods {
            #expect(!method.prefersQueryParameters, "\(method) should not prefer query parameters")
        }
    }
}

// MARK: - HTTPMediaType

@Suite
struct HTTPMediaTypeTests {
    @Test(arguments: [
        (HTTPMediaType.json, "application/json"),
        (.plainText, "text/plain"),
        (.html, "text/html"),
        (.css, "text/css"),
        (.javascript, "text/javascript"),
        (.csv, "text/csv"),
        (.markdown, "text/markdown"),
        (.jpeg, "image/jpeg"),
        (.png, "image/png"),
        (.gif, "image/gif"),
        (.svg, "image/svg+xml"),
        (.webp, "image/webp"),
        (.xml, "application/xml"),
        (.pdf, "application/pdf"),
        (.zip, "application/zip"),
        (.form, "application/x-www-form-urlencoded"),
        (.eventStream, "text/event-stream"),
        (.octetStream, "application/octet-stream"),
        (.anything, "*/*"),
        (.m4a, "audio/m4a"),
        (.mp4, "audio/mp4"),
        (.mpeg, "audio/mpeg"),
        (.webm, "audio/webm"),
        (.wav, "audio/wav"),
    ])
    func rawValueOutput(mediaType: HTTPMediaType, expected: String) {
        #expect(mediaType.rawValue == expected)
    }

    @Test
    func roundtripForKnownTypes() {
        let knownTypes: [HTTPMediaType] = [
            .json, .plainText, .html, .css, .javascript, .csv, .markdown,
            .jpeg, .png, .gif, .svg, .webp,
            .xml, .pdf, .zip, .form, .m4a, .mp4, .mpeg, .webm, .wav,
            .eventStream, .octetStream, .anything,
        ]
        for type in knownTypes {
            let parsed = HTTPMediaType(rawValue: type.rawValue)
            #expect(parsed == type, "Roundtrip failed for \(type.rawValue)")
        }
    }

    @Test
    func customType() {
        let custom = HTTPMediaType.custom("application/vnd.api+json")
        #expect(custom.rawValue == "application/vnd.api+json")

        let parsed = HTTPMediaType(rawValue: "application/vnd.api+json")
        #expect(parsed == .custom("application/vnd.api+json"))
    }

    @Test
    func initFromSwiftType() {
        #expect(HTTPMediaType(_swiftType: Data.self) == .octetStream)
        #expect(HTTPMediaType(_swiftType: String.self) == .plainText)
        #expect(HTTPMediaType(_swiftType: Int.self) == nil)
    }
}

// MARK: - HTTPResponseStatusCode

@Suite
struct HTTPResponseStatusCodeTests {
    @Test(arguments: [
        (100, HTTPResponseStatusCode.CodeType.information),
        (199, .information),
        (200, .success),
        (204, .success),
        (299, .success),
        (301, .redirect),
        (399, .redirect),
        (400, .clientError),
        (404, .clientError),
        (499, .clientError),
        (500, .serverError),
        (503, .serverError),
        (599, .serverError),
        (600, .unknown),
        (0, .unknown),
        (99, .unknown),
    ])
    func codeTypeClassification(rawValue: Int, expected: HTTPResponseStatusCode.CodeType) {
        let code = HTTPResponseStatusCode(rawValue: rawValue)
        #expect(code.codeType == expected)
    }

    @Test
    func description() {
        #expect(HTTPResponseStatusCode(rawValue: 200).description == "200 SUCCESS")
        #expect(HTTPResponseStatusCode(rawValue: 404).description == "404 CLIENT-ERROR")
        #expect(HTTPResponseStatusCode(rawValue: 500).description == "500 SERVER-ERROR")
        #expect(HTTPResponseStatusCode(rawValue: 301).description == "301 REDIRECT")
        #expect(HTTPResponseStatusCode(rawValue: 100).description == "100 INFO")
        #expect(HTTPResponseStatusCode(rawValue: 999).description == "999 UNKNOWN")
    }

    @Test
    func comparisonSuccess() {
        let ok = HTTPResponseStatusCode(rawValue: 200)
        #expect(ok == .success)
        #expect(ok != .error)

        let created = HTTPResponseStatusCode(rawValue: 201)
        #expect(created == .success)
    }

    @Test
    func comparisonError() {
        let notFound = HTTPResponseStatusCode(rawValue: 404)
        #expect(notFound == .error)
        #expect(notFound != .success)

        let serverError = HTTPResponseStatusCode(rawValue: 500)
        #expect(serverError == .error)
    }

    @Test
    func comparisonCode() {
        let code = HTTPResponseStatusCode(rawValue: 204)
        #expect(code == .code(204))
        #expect(code != .code(200))
    }

    @Test
    func codableRoundtrip() throws {
        let original = HTTPResponseStatusCode(rawValue: 418)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HTTPResponseStatusCode.self, from: data)
        #expect(decoded == original)
        #expect(decoded.rawValue == 418)
    }
}

// MARK: - HTTPCacheControlType

@Suite
struct HTTPCacheControlTypeTests {
    @Test(arguments: [
        ("no-cache", HTTPCacheControlType.noCache),
        ("no-store", .noStore),
        ("no-transform", .noTransform),
        ("only-if-cached", .onlyIfCached),
    ])
    func simpleDirectives(rawValue: String, expected: HTTPCacheControlType) {
        let parsed = HTTPCacheControlType(rawValue: rawValue)
        #expect(parsed == expected)
        #expect(parsed?.rawValue == rawValue)
    }

    @Test
    func maxAge() {
        let parsed = HTTPCacheControlType(rawValue: "max-age=3600")
        #expect(parsed == .maxAge(seconds: 3600))
        #expect(parsed?.rawValue == "max-age=3600")
    }

    @Test
    func maxStaleWithSeconds() {
        let parsed = HTTPCacheControlType(rawValue: "max-stale=600")
        #expect(parsed == .maxStale(seconds: 600))
        #expect(parsed?.rawValue == "max-stale=600")
    }

    @Test
    func maxStaleWithoutSeconds() {
        let parsed = HTTPCacheControlType(rawValue: "max-stale")
        #expect(parsed == .maxStale(seconds: nil))
        #expect(parsed?.rawValue == "max-stale")
    }

    @Test
    func minFresh() {
        let parsed = HTTPCacheControlType(rawValue: "min-fresh=120")
        #expect(parsed == .minFresh(seconds: 120))
        #expect(parsed?.rawValue == "min-fresh=120")
    }

    @Test
    func invalidDirective() {
        #expect(HTTPCacheControlType(rawValue: "invalid") == nil)
        #expect(HTTPCacheControlType(rawValue: "max-age=abc") == nil)
        #expect(HTTPCacheControlType(rawValue: "min-fresh=") == nil)
    }

    @Test
    func caseInsensitive() {
        #expect(HTTPCacheControlType(rawValue: "NO-CACHE") == .noCache)
        #expect(HTTPCacheControlType(rawValue: "Max-Age=300") == .maxAge(seconds: 300))
    }
}

// MARK: - HTTPAuthorizationType

@Suite
struct HTTPAuthorizationTypeTests {
    @Test(arguments: [
        ("Basic", HTTPAuthorizationType.basic),
        ("Bearer", .bearer),
        ("Digest", .digest),
        ("HOBA", .hoba),
        ("Mutual", .mutual),
        ("AWS4-HMAC-SHA256", .aws),
    ])
    func knownTypes(rawValue: String, expected: HTTPAuthorizationType) {
        #expect(HTTPAuthorizationType(rawValue: rawValue) == expected)
        #expect(expected.rawValue == rawValue)
    }

    @Test
    func customType() {
        let custom = HTTPAuthorizationType(rawValue: "OAuth")
        #expect(custom == .custom("OAuth"))
        #expect(custom.rawValue == "OAuth")
    }
}

// MARK: - HTTPUserAgent

@Suite
struct HTTPUserAgentTests {
    @Test
    func knownAgentsRoundtrip() {
        let agents: [HTTPUserAgent] = [
            .bot, .chrome, .chromeAndroid, .chromeiOS,
            .firefoxMac, .firefoxWindows, .internetExplorer, .opera, .safari,
        ]
        for agent in agents {
            let parsed = HTTPUserAgent(rawValue: agent.rawValue)
            #expect(parsed == agent, "Roundtrip failed for \(agent)")
        }
    }

    @Test
    func customAgent() {
        let custom = HTTPUserAgent(rawValue: "MyApp/1.0")
        #expect(custom == .custom("MyApp/1.0"))
        #expect(custom.rawValue == "MyApp/1.0")
    }
}

// MARK: - HTTPHeaderField

@Suite
struct HTTPHeaderFieldTests {
    @Test
    func acceptHeader() {
        let field = HTTPHeaderField(key: "Accept", value: "application/json")
        #expect(field.key == .accept)
        #expect(field.value == "application/json")
    }

    @Test
    func contentTypeHeader() {
        let field = HTTPHeaderField(key: "Content-Type", value: "text/html")
        #expect(field.key == .contentType)
        #expect(field.value == "text/html")
    }

    @Test
    func cookieHeader() {
        let field = HTTPHeaderField(key: "Cookie", value: "session=abc123")
        #expect(field.key == .cookie)
        #expect(field.value == "session=abc123")
    }

    @Test
    func customHeader() {
        let field = HTTPHeaderField(key: "X-Request-Id", value: "12345")
        #expect(field.key == .custom("X-Request-Id"))
        #expect(field.value == "12345")
    }

    @Test
    func contentLengthValue() {
        let field = HTTPHeaderField.contentLength(octets: 1024)
        #expect(field.key == .contentLength)
        #expect(field.value == "1024")
    }

    @Test
    func authorizationValue() {
        let field = HTTPHeaderField.authorization(.bearer, "token123")
        #expect(field.key == .authorization)
        #expect(field.value == "Bearer token123")
    }

    @Test
    func codableRoundtrip() throws {
        let field = HTTPHeaderField.accept(.json)
        let data = try JSONEncoder().encode(field)
        let decoded = try JSONDecoder().decode(HTTPHeaderField.self, from: data)
        #expect(decoded == field)
    }

    @Test
    func sequenceSubscript() {
        let headers: [HTTPHeaderField] = [
            .accept(.json),
            .contentType(.html),
            .custom(key: "X-Foo", value: "bar"),
        ]
        #expect(headers[.accept] == "application/json")
        #expect(headers[.contentType] == "text/html")
        #expect(headers[.custom("X-Foo")] == "bar")
        #expect(headers[.cookie] == nil)
    }

    @Test
    func debugDescription() {
        let field = HTTPHeaderField.accept(.json)
        #expect(field.debugDescription == "Accept: application/json")
    }

    @Test
    func userAgentKeyRawValue() {
        #expect(HTTPHeaderField.Key.userAgent.rawValue == "User-Agent")
    }

    @Test
    func userAgentHeaderParsing() {
        let field = HTTPHeaderField(key: "User-Agent", value: "MyApp/1.0")
        #expect(field.key == .userAgent)
    }

    @Test
    func authorizationParsing() {
        let field = HTTPHeaderField(key: "Authorization", value: "Bearer token123")
        #expect(field.key == .authorization)
        if case .authorization(let scheme, let credentials) = field {
            #expect(scheme == .bearer)
            #expect(credentials == "token123")
        } else {
            Issue.record("Expected .authorization case")
        }
    }

    @Test
    func authorizationParsingBasic() {
        let field = HTTPHeaderField(key: "Authorization", value: "Basic dXNlcjpwYXNz")
        if case .authorization(let scheme, let credentials) = field {
            #expect(scheme == .basic)
            #expect(credentials == "dXNlcjpwYXNz")
        } else {
            Issue.record("Expected .authorization case")
        }
    }

    @Test
    func authorizationValueReconstruction() {
        let field = HTTPHeaderField.authorization(.bearer, "mytoken")
        #expect(field.value == "Bearer mytoken")
    }

    @Test
    func sensitiveHeaderDebugDescriptionIsRedacted() {
        #expect(
            HTTPHeaderField.authorization(.bearer, "mytoken").debugDescription
                == "Authorization: <redacted>"
        )
        #expect(
            HTTPHeaderField.custom(key: "X-API-Key", value: "secret").debugDescription
                == "X-API-Key: <redacted>"
        )
    }

    @Test
    func hostValueIncludesColon() {
        let field = HTTPHeaderField.host(host: "example.com", port: "8080")
        #expect(field.value == "example.com:8080")
    }
}

// MARK: - HTTPHeaderField.Link

@Suite
struct HTTPHeaderFieldLinkTests {
    @Test
    func parseSimpleLink() throws {
        let link = try HTTPHeaderField.Link(header: "<https://example.com/next>; rel=\"next\"")
        #expect(link.uri == "https://example.com/next")
        #expect(link.relationType == "next")
        #expect(link.url == URL(string: "https://example.com/next"))
    }

    @Test
    func parseMultipleParameters() throws {
        let link = try HTTPHeaderField.Link(header: "<https://example.com/style.css>; rel=\"stylesheet\"; type=\"text/css\"")
        #expect(link.uri == "https://example.com/style.css")
        #expect(link.relationType == "stylesheet")
        #expect(link.type == "text/css")
    }

    @Test
    func headerGeneration() {
        let link = HTTPHeaderField.Link(uri: "https://example.com/next", parameters: ["rel": "next"])
        #expect(link.header.contains("<https://example.com/next>"))
        #expect(link.header.contains("rel=\"next\""))
    }

    @Test
    func htmlGeneration() {
        let link = HTTPHeaderField.Link(uri: "https://example.com/style.css", parameters: ["rel": "stylesheet"])
        let html = link.html
        #expect(html.contains("href=\"https://example.com/style.css\""))
        #expect(html.contains("rel=\"stylesheet\""))
        #expect(html.hasPrefix("<link "))
        #expect(html.hasSuffix(" />"))
    }

    @Test
    func initWithNoParameters() {
        let link = HTTPHeaderField.Link(uri: "https://example.com")
        #expect(link.uri == "https://example.com")
        #expect(link.parameters.isEmpty)
        #expect(link.relationType == nil)
    }
}

// MARK: - HTTPRequest Builder

@Suite
struct HTTPRequestBuilderTests {
    @Test
    func basicInit() {
        let request = HTTPRequest(url: URL(string: "https://api.example.com")!)
        #expect(request.host == URL(string: "https://api.example.com")!)
        #expect(request.path == nil)
        #expect(request.url == URL(string: "https://api.example.com")!)
    }

    @Test
    func stringInit() {
        let request = HTTPRequest(url: "https://api.example.com")!
        #expect(request.host == URL(string: "https://api.example.com")!)
    }

    @Test
    func stringInitNil() {
        let request = HTTPRequest(url: "")
        #expect(request == nil)
    }

    @Test
    func pathAppending() {
        let request = HTTPRequest(url: URL(string: "https://api.example.com")!)
            .path("/v1/users")
        #expect(request.url.absoluteString.contains("v1/users"))
    }

    @Test
    func methodSetting() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .method(.post)
        #expect(request.method == .post)
    }

    @Test
    func queryFromDictionary() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .query(["page": "1", "limit": "10"])
        #expect(request.query.count == 2)
        let queryDict = Dictionary(uniqueKeysWithValues: request.query.map { ($0.name, $0.value) })
        #expect(queryDict["page"] == "1")
        #expect(queryDict["limit"] == "10")
    }

    @Test
    func queryFromString() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .query("foo=bar&baz=qux")
        #expect(request.query.count == 2)
        let queryDict = Dictionary(uniqueKeysWithValues: request.query.map { ($0.name, $0.value) })
        #expect(queryDict["foo"] == "bar")
        #expect(queryDict["baz"] == "qux")
    }

    @Test
    func queryAccumulates() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .query(["a": "1"])
            .query(["b": "2"])
        #expect(request.query.count == 2)
    }

    @Test
    func headerSetting() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .header(.accept(.json))
            .header(.contentType(.json))
        #expect(request.header.count == 2)
        #expect(request.header[.accept] == "application/json")
    }

    @Test
    func deleteHeader() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .header(.accept(.json))
            .header(.contentType(.html))
            .deleteHeader(.accept)
        #expect(request.header.count == 1)
        #expect(request.header[.accept] == nil)
        #expect(request.header[.contentType] == "text/html")
    }

    @Test
    func bodySetsMethodToPost() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .body(Data("hello".utf8))
        #expect(request.method == .post)
    }

    @Test
    func bodyDoesNotOverrideMethod() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .method(.put)
            .body(Data("hello".utf8))
        #expect(request.method == .put)
    }

    @Test
    func urlRequestConversion() throws {
        let request = HTTPRequest(url: URL(string: "https://api.example.com")!)
            .method(.get)
            .query(["key": "value"])
            .header(.accept(.json))
            .body(Data("test".utf8))

        let urlRequest = try URLRequest(request)
        #expect(urlRequest.httpMethod == "GET")
        #expect(urlRequest.url?.query?.contains("key=value") == true)
        #expect(urlRequest.httpBody == Data("test".utf8))
    }

    @Test
    func headersFromDictionary() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .headers(["X-Api-Key": "abc", "X-Trace-Id": "123"])
        #expect(request.header.count == 2)
    }

    @Test
    func descriptionOmitsCredentialsAndRequestData() {
        let request = HTTPRequest(url: URL(string: "https://user:password@api.example.com")!)
            .path("repos/example")
            .query(["access_token": "secret"])
            .header(.authorization(.bearer, "secret"))

        #expect(request.description == "HTTP https://api.example.com/repos/example")
        #expect(!request.debugDescription.contains("secret"))
        #expect(!request.debugDescription.contains("password"))
    }

    @Test
    func cookies() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .cookies(["session": "abc", "token": "xyz"])
        let cookieHeader = request.header.first(where: { $0.key == .cookie })
        #expect(cookieHeader != nil)
    }

    @Test
    func nilBodyIsIgnored() {
        let request = HTTPRequest(url: URL(string: "https://example.com")!)
            .body(nil as HTTPRequest.Body?)
        #expect(request.body == nil)
        #expect(request.method == nil)
    }
}

// MARK: - HTTPRequest.Body

@Suite
struct HTTPRequestBodyTests {
    @Test
    func dataFactory() {
        let body = HTTPRequest.Body.data(Data("hello".utf8))
        #expect(body.data == Data("hello".utf8))
        #expect(body.header.isEmpty)
    }

    @Test
    func dataWithHeaders() {
        let body = HTTPRequest.Body.data(
            Data("body".utf8),
            headers: [.contentType(.json)]
        )
        #expect(body.data == Data("body".utf8))
        #expect(body.header.count == 1)
    }

    @Test
    func contentDataValue() {
        let dataContent = HTTPRequest.Body.Content.data(Data("test".utf8))
        #expect(dataContent.dataValue == Data("test".utf8))
    }

    @Test
    func inputStreamHasNoDataValue() {
        let stream = InputStream(data: Data("test".utf8))
        let content = HTTPRequest.Body.Content.inputStream(stream)
        #expect(content.dataValue == nil)
    }
}

// MARK: - Multipart

@Suite
struct MultipartTests {
    @Test
    func boundaryFormat() {
        let boundary = HTTPRequest.Multipart.Content.Boundary()
        #expect(!boundary.stringValue.isEmpty)
        #expect(!boundary.stringValue.contains("-"))
        #expect(boundary.delimiter == "--\(boundary.stringValue)")
        #expect(boundary.distinguishedDelimiter == "--\(boundary.stringValue)--")
    }

    @Test
    func boundaryDataConsistency() {
        let boundary = HTTPRequest.Multipart.Content.Boundary()
        #expect(boundary.delimiterData == boundary.delimiter.data(using: .utf8))
        #expect(boundary.distinguishedDelimiterData == boundary.distinguishedDelimiter.data(using: .utf8))
    }

    @Test
    func formDataPart() {
        let part = HTTPRequest.Multipart.Part.formData(name: "username", value: "john")
        #expect(part.body == Data("john".utf8))
        let desc = part.description
        #expect(desc.contains("form-data"))
        #expect(desc.contains("name=\"username\""))
    }

    @Test
    func filePart() {
        let fileData = Data("file contents".utf8)
        let part = HTTPRequest.Multipart.Part.file(
            named: "document",
            data: fileData,
            filename: "test.txt",
            contentType: .plainText
        )
        #expect(part.body == fileData)
        let desc = part.description
        #expect(desc.contains("filename=\"test.txt\""))
        #expect(desc.contains("text/plain"))
    }

    @Test
    func textPart() {
        let part = HTTPRequest.Multipart.Part.text(named: "note", value: "hello world")
        #expect(part.body == Data("hello world".utf8))
    }

    @Test
    func contentBodyContainsBoundaries() {
        let content = HTTPRequest.Multipart.Content(type: .formData, parts: [
            .formData(name: "field1", value: "value1"),
            .formData(name: "field2", value: "value2"),
        ])
        let body = content.body
        let bodyString = String(data: body, encoding: .utf8)!

        #expect(bodyString.contains("value1"))
        #expect(bodyString.contains("value2"))
        #expect(bodyString.contains("--")) // boundary delimiters
    }

    @Test
    func emptyContentHasBoundary() {
        let content = HTTPRequest.Multipart.Content()
        let body = content.body
        #expect(!body.isEmpty)
    }

    @Test
    func appendPart() {
        var content = HTTPRequest.Multipart.Content()
        content.append(.formData(name: "key", value: "val"))
        let body = content.body
        let bodyString = String(data: body, encoding: .utf8)!
        #expect(bodyString.contains("val"))
    }
}

// MARK: - SSE Message Parsing

@Suite
struct SSEParserTests {
    private func sseData(_ string: String) -> Data {
        Data(string.utf8)
    }

    @Test
    func parseSingleMessage() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("event:message\ndata:hello world\n\n")
        let messages = parser.parsed(from: data)
        #expect(messages.count == 1)
        #expect(messages.first?.event == "message")
        #expect(messages.first?.data == "hello world")
    }

    @Test
    func parseMessageWithId() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("id:42\nevent:update\ndata:payload\n\n")
        let messages = parser.parsed(from: data)
        #expect(messages.count == 1)
        #expect(messages.first?.id == "42")
        #expect(messages.first?.event == "update")
        #expect(messages.first?.data == "payload")
    }

    @Test
    func parseMultipleMessages() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("data:first\n\ndata:second\n\n")
        let messages = parser.parsed(from: data)
        #expect(messages.count == 2)
        #expect(messages[0].data == "first")
        #expect(messages[1].data == "second")
    }

    @Test
    func multiLineData() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("data:line1\ndata:line2\ndata:line3\n\n")
        let messages = parser.parsed(from: data)
        #expect(messages.count == 1)
        #expect(messages.first?.data == "line1\nline2\nline3")
    }

    @Test
    func lastMessageIDTracking() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("id:1\ndata:a\n\nid:2\ndata:b\n\ndata:c\n\n")
        let _ = parser.parsed(from: data)
        #expect(parser.lastMessageID == "2")
    }

    @Test
    func reset() {
        let parser = SSE._ServerMessageParser()
        let _ = parser.parsed(from: sseData("id:42\ndata:x\n\n"))
        #expect(parser.lastMessageID == "42")
        parser.reset()
        #expect(parser.lastMessageID == "")
    }

    @Test
    func emptyMessageIsSkipped() {
        let parser = SSE._ServerMessageParser()
        let messages = parser.parsed(from: sseData("\n\n"))
        #expect(messages.isEmpty)
    }

    @Test
    func messageWithTime() {
        let parser = SSE._ServerMessageParser()
        let data = sseData("data:hello\ntime:2024-01-01\n\n")
        let messages = parser.parsed(from: data)
        #expect(messages.first?.time == "2024-01-01")
    }
}

// MARK: - HTTPRequest.Error

@Suite
struct HTTPRequestErrorTests {
    @Test
    func systemErrorFromSwiftError() {
        struct TestError: Error {}
        let error = HTTPRequest.Error.system(TestError())
        if case .system = error {
            // correct case
        } else {
            Issue.record("Expected .system case")
        }
    }
}

// MARK: - HTTPConnectionType

@Suite
struct HTTPConnectionTypeTests {
    @Test
    func rawValues() {
        #expect(HTTPConnectionType.close.rawValue == "close")
        #expect(HTTPConnectionType.keepAlive.rawValue == "keep-alive")
    }
}

// MARK: - HTTPProtocol

@Suite
struct HTTPProtocolTests {
    @Test
    func rawValues() {
        #expect(HTTPProtocol.http.rawValue == "http")
        #expect(HTTPProtocol.https.rawValue == "https")
    }

    @Test
    func codableRoundtrip() throws {
        let original = HTTPProtocol.https
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HTTPProtocol.self, from: data)
        #expect(decoded == original)
    }
}
