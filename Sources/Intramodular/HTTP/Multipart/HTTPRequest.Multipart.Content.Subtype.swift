//
// Copyright (c) Vatsal Manot
//

import Swift

extension HTTPRequest.Multipart.Content {
    public enum Subtype: String {
        
        /// The "multipart/alternative" type defines each of the body parts as an pe"alternative" version of the same
        /// information.
        ///
        /// In general, user agents that compose "multipart/alternative" entities must place the body parts in
        /// increasing order of preference, that is, with the preferred format last. For fancy text, the sending user
        /// agent should put the plainest format first and the richest format last.
        /// - SeeAlso: Defined in [RFC 2046, Section 5.1.4](http://tools.ietf.org/html/rfc2046#section-5.1.4)
        case alternative = "multipart/alternative"
        
        /// The "multipart/byteranges" type is used to represent noncontiguous byte ranges of a single message. It is
        /// used by HTTP when a server returns multiple byte ranges.
        /// - SeeAlso: Defined in [RFC 2616](https://tools.ietf.org/html/rfc2616).
        case byteranges = "multipart/byteranges"
        
        /// The "multipart/digest" type changes the default Content-Type value for a body part from "text/plain" to
        /// "message/rfc822". This is done to allow a more readable digest format that is largely compatible (except for
        /// the quoting convention) with [RFC 934](https://tools.ietf.org/html/rfc934).
        ///
        /// - Note: Though it is possible to specify a Content-Type value for a body part in a digest which is other
        /// than "message/rfc822", such as a "text/plain" part containing a description of the material in the digest,
        /// actually doing so is undesireble. The "multipart/digest" Content-Type is intended to be used to send
        /// collections of messages. If a "text/plain" part is needed, it should be included as a seperate part of a
        /// "multipart/mixed" message.
        /// - SeeAlso: Defined in [RFC 2046, Section 5.1.5](http://tools.ietf.org/html/rfc2046#section-5.1.5)
        case digest = "multipart/digest"
        
        /// The "multipart/encrypted" content type must contain exactly two body parts. The first part has control
        /// information that is needed to decrypt the "application/octet-stream" second part. Similar to signed
        /// messages, there are different implementations which are identified by their separate content types for the
        /// control part. The most common types are "application/pgp-encrypted" and "application/pkcs7-mime".
        /// - SeeAlso: Defined in [RFC 1847, Section 2.2](http://tools.ietf.org/html/rfc1847#section-2.2)
        case encrypted = "multipart/encrypted"
        
        /// The "multipart/form-data" type can be used by a wide variety of applications and transported by a wide
        /// variety of protocols as a way of returning a set of values as the result of a user filling out a form.
        /// Originally defined as part of HTML 4.0, it is most commonly used for submitting files via HTTP.
        /// - SeeAlso: Defined in [RFC 7578](https://tools.ietf.org/html/rfc7578)
        case formData = "multipart/form-data"
        
        /// The "multipart/mixed" type is intended for use when the body parts are independent and need to be bundled in
        /// a particular order. Any "multipart" subtypes that an implementation does not recognize must be treated as
        /// being of subtype "mixed".
        ///
        /// It is commonly used for sending files with different "Content-Type" headers inline (or as attachments).
        /// If sending pictures or other easily readable files, most mail clients will display them inline (unless
        /// otherwise specified with the "Content-Disposition" header). Otherwise it will offer them as attachments.
        /// The default content-type for each part is "text/plain".
        /// - SeeAlso: Defined in [RFC 2046, Section 5.1.3](https://tools.ietf.org/html/rfc2046#section-5.1.3)
        case mixed = "multipart/mixed"
        
        /// The "multipart/x-mixed-replace" type was developed as part of a technology to emulate server push and
        /// streaming over HTTP. All parts of a mixed-replace message have the same semantic meaning. However, each part
        /// invalidates - "replaces" - the previous parts as soon as it is received completely. Clients should process
        /// the individual parts as soon as they arrive and should not wait for the whole message to finish.
        case mixedReplace = "multipart/x-mixed-replace"
        
        /// The "multipart/parallel" type indicates that the order of body parts is not significant.
        ///
        /// A common presentation of this type is to display all of the parts simultaneously on hardware and software
        /// that are capable of doing so. However, composing agents should be aware that many mail readers will lack
        /// this capability and will show the parts serially in any event.
        /// - SeeAlso: Defined in [RFC 2046, Section 5.1.6](https://tools.ietf.org/html/rfc2046#section-5.1.6)
        case parallel = "multipart/parallel"
        
        /// The "multipart/related" type provides a common mechanism for representing objects that are aggregates of
        /// related MIME body parts, where proper display cannot be achieved by individually displaying the constituent
        /// parts.
        ///
        /// The message consists of a root part (by default the first) which reference other parts inline, which may in
        /// turn reference other parts. Message parts are commonly referenced by the "Content-ID" part header. The
        /// syntax of a reference is unspecified and is instead dictated by the encoding or protocol used in the part.
        /// - SeeAlso: Defined in [RFC 2387](https://tools.ietf.org/html/rfc2387)
        case related = "multipart/related"
        
        /// The "multipart/report" type contains data formatted for a mail server to read. It is split between a
        /// human-readable message part and a machine-parsable body part containing an account of the reported message
        /// handling event. The purpose of this body part is to provide a machine-readable description of the
        /// condition(s) that caused the report to be generated, along with details not present in the first body part
        /// that might be useful to human experts.
        /// - SeeAlso: Defined in [RFC 2387](https://tools.ietf.org/html/rfc2387)
        case report = "multipart/report"
        
        /// The "multipart/signed" type contains exactly two body parts. The first body part is the body part over which
        /// the digital signature was created, including its MIME headers. The second body part contains the control
        /// information necessary to verify the digital signature. The first body part may contain any valid MIME
        /// content type, labeled accordingly. The second body part is labeled according to the value of the protocol
        /// parameter.
        /// - SeeAlso: Defined in [RFC 1847, Section 2.1](https://tools.ietf.org/html/rfc1847#section-2.1)
        case signed = "multipart/signed"
    }
}
