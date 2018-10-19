//
//  Collection+Diff.swift
//  CollectionDiff
//
//  Created on 19/10/2018.
//


// MARK: Diff with Comparison Computational Model
public func diff<C1: Collection, C2: Collection>(
    from fromCollection: C1,
    to toCollection: C2,
    isEqual: @escaping (C1.Element, C2.Element) -> Bool,
    isIdentical: ((C1.Element, C2.Element) -> Bool)? = nil
    ) -> CollectionDiffSequence<C1, C2>
{
    return .init(fromCollection: fromCollection, toCollection: toCollection, isEqual: isEqual, isIdentical: isIdentical)
}


public func diff<C1: Collection, C2: Collection>(
    from fromCollection: C1,
    to toCollection: C2,
    isIdentical: ((C1.Element, C2.Element) -> Bool)? = nil
    ) -> CollectionDiffSequence<C1, C2> where
    C1.Element: Equatable,
    C1.Element == C2.Element
{
    return diff(from: fromCollection, to: toCollection, isEqual: ==, isIdentical: isIdentical)
}


extension Collection {
    /// Diffs from `self` to `toCollection`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<ToCollection>(
        to toCollection: ToCollection,
        isEqual: @escaping (Element, ToCollection.Element) -> Bool,
        isIdentical: ((Element, ToCollection.Element) -> Bool)? = nil
        ) -> CollectionDiffSequence<Self, ToCollection>
    {
        return CollectionDiffSequence(
            fromCollection: self,
            toCollection: toCollection,
            isEqual: isEqual,
            isIdentical: isIdentical
        )
    }
    
    /// Diffs from `fromCollection` to `self`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<FromCollection>(
        from fromCollection: FromCollection,
        isEqual: @escaping (FromCollection.Element, Element) -> Bool,
        isIdentical: ((FromCollection.Element, Element) -> Bool)? = nil
        ) -> CollectionDiffSequence<FromCollection, Self>
    {
        return CollectionDiffSequence(
            fromCollection: fromCollection,
            toCollection: self,
            isEqual: isEqual,
            isIdentical: isIdentical
        )
    }
}


extension Collection where Element: Equatable {
    /// Diffs from `self` to `toCollection`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<ToCollection>(
        to toCollection: ToCollection,
        isIdentical: ((Element, Element) -> Bool)? = nil
        ) -> CollectionDiffSequence<Self, ToCollection> where
        ToCollection.Element == Element
    {
        return CollectionDiffSequence(
            fromCollection: self,
            toCollection: toCollection,
            isEqual: {$0 == $1},
            isIdentical: isIdentical
        )
    }
    
    /// Diffs from `fromCollection` to `self`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<FromCollection>(
        from fromCollection: FromCollection,
        isIdentical: ((Element, Element) -> Bool)? = nil
        ) -> CollectionDiffSequence<FromCollection, Self> where
        FromCollection.Element == Element
    {
        return CollectionDiffSequence(
            fromCollection: fromCollection,
            toCollection: self,
            isEqual: {$0 == $1},
            isIdentical: isIdentical
        )
    }
}


// MARK: Diff with Counting Computational Model
public func diff<C1: Collection, C2: Collection, I: Hashable>(
    from fromCollection: C1,
    to toCollection: C2,
    identifierForFromItem: @escaping (C1.Element) -> I,
    identifierForToItem: @escaping (C2.Element) -> I,
    isIdentical: @escaping ((C1.Element, C2.Element) -> Bool)
    ) -> CollectionDiffSequence<C1, C2>
{
    return .init(fromCollection: fromCollection, toCollection: toCollection, identifierForFromItem: identifierForFromItem, identifierForToItem: identifierForToItem, isIdentical: isIdentical)
}


public func diff<C1: Collection, C2: Collection>(
    from fromCollection: C1,
    to toCollection: C2,
    isIdentical: @escaping ((C1.Element, C2.Element) -> Bool) = {$0.hashValue == $1.hashValue}
    ) -> CollectionDiffSequence<C1, C2> where
    C1.Element: Hashable,
    C2.Element: Hashable
{
    return diff(from: fromCollection, to: toCollection, identifierForFromItem: {$0.hashValue}, identifierForToItem: {$0.hashValue}, isIdentical: isIdentical)
}


public func diff<C1: Collection, C2: Collection>(
    from fromCollection: C1,
    to toCollection: C2
    ) -> CollectionDiffSequence<C1, C2> where
    C1.Element: Hashable,
    C2.Element == C1.Element
{
    return diff(from: fromCollection, to: toCollection, identifierForFromItem: {$0.hashValue}, identifierForToItem: {$0.hashValue}, isIdentical: ==)
}


extension Collection {
    /// Diffs from `self` to `toCollection`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<ToCollection, I: Hashable>(
        to toCollection: ToCollection,
        identifierForFromItem: @escaping (Element) -> I,
        identifierForToItem: @escaping (ToCollection.Element) -> I,
        isIdentical: @escaping ((Element, ToCollection.Element) -> Bool)
        ) -> CollectionDiffSequence<Self, ToCollection>
    {
        return CollectionDiffSequence(
            fromCollection: self,
            toCollection: toCollection,
            identifierForFromItem: identifierForFromItem,
            identifierForToItem: identifierForToItem,
            isIdentical: isIdentical
        )
    }
    
    /// Diffs from `fromCollection` to `self`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<FromCollection, I: Hashable>(
        from fromCollection: FromCollection,
        identifierForFromItem: @escaping (FromCollection.Element) -> I,
        identifierForToItem: @escaping (Element) -> I,
        isIdentical: @escaping ((FromCollection.Element, Element) -> Bool)
        ) -> CollectionDiffSequence<FromCollection, Self>
    {
        return CollectionDiffSequence(
            fromCollection: fromCollection,
            toCollection: self,
            identifierForFromItem: identifierForFromItem,
            identifierForToItem: identifierForToItem,
            isIdentical: isIdentical
        )
    }
}


extension Collection where Element: Hashable {
    /// Diffs from `self` to `toCollection`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<ToCollection>(
        to toCollection: ToCollection,
        isIdentical: @escaping ((Element, ToCollection.Element) -> Bool)
        = {$0.hashValue == $1.hashValue}
        ) -> CollectionDiffSequence<Self, ToCollection> where
        ToCollection.Element: Hashable
    {
        return CollectionDiffSequence(
            fromCollection: self,
            toCollection: toCollection,
            identifierForFromItem: {$0.hashValue},
            identifierForToItem: {$0.hashValue},
            isIdentical: isIdentical
        )
    }
    
    /// Diffs from `fromCollection` to `self`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<FromCollection>(
        from fromCollection: FromCollection,
        isIdentical: @escaping ((FromCollection.Element, Element) -> Bool)
        = {$0.hashValue == $1.hashValue}
        ) -> CollectionDiffSequence<FromCollection, Self> where
        FromCollection.Element: Hashable
    {
        return CollectionDiffSequence(
            fromCollection: fromCollection,
            toCollection: self,
            identifierForFromItem: {$0.hashValue},
            identifierForToItem: {$0.hashValue},
            isIdentical: isIdentical
        )
    }
}


extension Collection where Element: Hashable {
    /// Diffs from `self` to `toCollection`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<ToCollection>(
        to toCollection: ToCollection,
        isIdentical: @escaping ((Element, ToCollection.Element) -> Bool)
        = (==)
        ) -> CollectionDiffSequence<Self, ToCollection> where
        ToCollection.Element == Self.Element
    {
        return CollectionDiffSequence(
            fromCollection: self,
            toCollection: toCollection,
            identifierForFromItem: {$0.hashValue},
            identifierForToItem: {$0.hashValue},
            isIdentical: isIdentical
        )
    }
    
    /// Diffs from `fromCollection` to `self`.
    ///
    /// The Turn of Diffing Info
    /// ========================
    /// The diffing info are guarranteed to be sorted in the trun of
    /// .identical(ascendant by index), .update(ascendant by index),
    /// .move(ascendant by index), .deletion(descendant by index),
    /// .insertion(ascendant by index).
    public func diff<FromCollection>(
        from fromCollection: FromCollection,
        isIdentical: @escaping ((FromCollection.Element, Element) -> Bool)
        = (==)
        ) -> CollectionDiffSequence<FromCollection, Self> where
        FromCollection.Element == Self.Element
    {
        return CollectionDiffSequence(
            fromCollection: fromCollection,
            toCollection: self,
            identifierForFromItem: {$0.hashValue},
            identifierForToItem: {$0.hashValue},
            isIdentical: isIdentical
        )
    }
}
