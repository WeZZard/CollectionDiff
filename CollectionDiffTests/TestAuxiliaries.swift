//
//  TestAuxiliaries.swift
//  CollectionDiff
//
//  Created by WeZZard on 1/3/16.
//
//

internal let strings = [
    "Sample Text",
    "What is design?",
    "Design",
    "Design is not just",
    "what it looks like",
    "and feels like.",
    "Design",
    "is how it works.",
    "- Steve Jobs",
    "Older people",
    "sit down and ask,",
    "'What is it?'",
    "but the boy asks,",
    "'What can I do with it?'.",
    "- Steve Jobs",
    "",
    "Swift",
    "Objective-C",
    "iPhone",
    "iPad",
    "Mac Mini",
    "MacBook Pro🔥",
    "Mac Pro⚡️",
    "That is a big truth.",
    "To do list",
    "Tassadar, Savior of the Templar",
    "AVFoundation",
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
    "Design is about how it works.",
    "Simple not equals to elegant.",
    "To live each day as it was your last, someday you will be certainly right.",
    "I'm not kidding you."
]

internal struct JustEquatable<E: Equatable>: Equatable, CustomStringConvertible {
    internal let element: E
    
    internal init(_ element: E) {
        self.element = element
    }
    
    internal static func == (lhs: JustEquatable, rhs: JustEquatable) -> Bool {
        return lhs.element == rhs.element
    }
    
    internal var description: String { return "\(element)" }
}

internal struct JustHashable<E: Hashable>: Hashable, CustomStringConvertible {
    internal let element: E
    
    internal init(_ element: E) {
        self.element = element
    }
    
    internal static func == (lhs: JustHashable, rhs: JustHashable) -> Bool {
        return lhs.element == rhs.element
    }
    
    internal var hashValue: Int { return element.hashValue }
    
    internal var description: String { return "\(element)" }
}
