[![Build Status](https://travis-ci.com/WeZZard/CollectionDiff.svg?branch=master)](https://travis-ci.com/WeZZard/CollectionDiff)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

[中文](./使用說明.md)

A diff tool for Swift collections.

## Highlights

This library implements an algorithm of time complexity of **O(N+M)** and
spatial complexity of **O(N+M)** which takes advantages of counting
computational model to diff Swift collections.

This library offers both **dot syntax** and **standalone function** to access to
diffing infrastructure.

This library supports lazy evaluation and on-demand computation. The computation
would not happen unless you get started to iterate the diff results. Once you
exit the iteration of diff result, the computation stopped at the same time.

## Detectable Differences

- Identical
- Update (Needs to pass an additional closure to handle)
- Move
- Delete
- Insert

> "Identical" just means "equal" when update detection was not enabled, but
> different when update detection was enabled.
>
> When update detection was enabled, "equal" means an element is equatable to
> another but there may be slightly differences between them such as different
> memory addresses. "Identical" means an element is totally identical to another
> and there are no difference between them.
>
> Enabling `Update` detection causes the time complexity comes to degenerate to
> **O(N*M)**. When each element is equal to another and was updated at the same
> time, the time complexity of diffing them went to **O(N^2)** in the worst
> case.

## Usage

Diffing without update detection.

```swift
import CollectionDiff

let old = [1, 2, 3, 4]
let new = [0, 3, 2, 4]

// Standlone function
for eachDiff in diff(from: old, to: new) {
	switch eachDiff {
        case let .identical(fromIndex, fromItem, toIndex, toItem):
            return "Identical; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .update(fromIndex, fromItem, toIndex, toItem):
            return "Update; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .move(fromIndex, fromItem, toIndex, toItem):
            return "Move; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .insertion(toIndex, toItem):
            return "Insertion; To-Index: \(toIndex); To-Item: \(toItem)"
        case let .deletion(fromIndex, fromItem):
            return "Deletion; From-Index: \(fromIndex); From-Item: \(fromItem)"
	}
}

// Dot syntax
for eachDiff in old.diff( to: new) {
	switch eachDiff {
        case let .identical(fromIndex, fromItem, toIndex, toItem):
            return "Identical; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .update(fromIndex, fromItem, toIndex, toItem):
            return "Update; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .move(fromIndex, fromItem, toIndex, toItem):
            return "Move; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .insertion(toIndex, toItem):
            return "Insertion; To-Index: \(toIndex); To-Item: \(toItem)"
        case let .deletion(fromIndex, fromItem):
            return "Deletion; From-Index: \(fromIndex); From-Item: \(fromItem)"
	}
}
```

Diffing with update detection.

> This is useful for diffing objects(in Object-Oriented semantic) with identical
> contents but different memory addresses.

```swift
import CollectionDiff

class IntegerLiteralObject: ExpressibleByIntegerLiteral, Equatable {
	var intValue: Int

	init(intValue: Int) {
		self.intValue = intValue
	}

	typealias IntegerLiteralType = Int

	init(integerLiteral value: IntegerLiteralType) {
		self.intValue = value
	}

	static func == (lhs: IntegerLiteralObject, rhs: IntegerLiteralObject) -> Bool {
		return lhs.intValue == rhs.intValue
	}
}

let old: [IntegerLiteralObject] = [1, 2, 3, 4]
let new: [IntegerLiteralObject] = [0, 3, 2, 4]

// Standlone function
for eachDiff in diff(from: old, to: new, isIdentical: ===) {
	switch eachDiff {
        case let .identical(fromIndex, fromItem, toIndex, toItem):
            return "Identical; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .update(fromIndex, fromItem, toIndex, toItem):
            return "Update; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .move(fromIndex, fromItem, toIndex, toItem):
            return "Move; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .insertion(toIndex, toItem):
            return "Insertion; To-Index: \(toIndex); To-Item: \(toItem)"
        case let .deletion(fromIndex, fromItem):
            return "Deletion; From-Index: \(fromIndex); From-Item: \(fromItem)"
	}
}

// Dot syntax
for eachDiff in old.diff( to: new, isIdentical: ===) {
	switch eachDiff {
        case let .identical(fromIndex, fromItem, toIndex, toItem):
            return "Identical; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .update(fromIndex, fromItem, toIndex, toItem):
            return "Update; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .move(fromIndex, fromItem, toIndex, toItem):
            return "Move; From-Index: \(fromIndex); From-Item: \(fromItem); To-Index: \(toIndex); To-Item: \(toItem)"
        case let .insertion(toIndex, toItem):
            return "Insertion; To-Index: \(toIndex); To-Item: \(toItem)"
        case let .deletion(fromIndex, fromItem):
            return "Deletion; From-Index: \(fromIndex); From-Item: \(fromItem)"
	}
}
```

Customize equity checking.

> You don't have to offer equity checking function when the collections being
> diffed are of the same type of `Equatable`. The library utilizes the
> `static func ==(lhs:, rhs:)` function of `Equatable` by default.
>
> If you wanna change the function being used to checking the equity, you can
> do things like below:


```swift
import CollectionDiff

class IntegerLiteralObject: ExpressibleByIntegerLiteral, Equatable {
	var intValue: Int

	init(intValue: Int) {
		self.intValue = intValue
	}

	typealias IntegerLiteralType = Int

	init(integerLiteral value: IntegerLiteralType) {
		self.intValue = value
	}

	static func == (lhs: IntegerLiteralObject, rhs: IntegerLiteralObject) -> Bool {
		return lhs.intValue == rhs.intValue
	}
}

let old: [IntegerLiteralObject] = [1, 2, 3, 4]
let new: [IntegerLiteralObject] = [0, 3, 2, 4]

// Standlone function
for eachDiff in diff(from: old, to: new, isEqual: ===) {
	// ...
}

// Dot syntax
for eachDiff in old.diff( to: new, isEqual: ===) {
	// ...
}
```

## Notes

Since `Collection` in Swift offers `Index` accessing which `Sequence` does not
and you have to "name" a difference with an index, this library only supports
Swift types of `Collection`.

If you wanna diff instances of type of `Sequence`, convert them into types of
`Collection`, or say `Array`, firstly.

## License

MIT
