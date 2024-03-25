//
//  RootBuilder.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation

/// A protocol that defines a builder for the root object.
public protocol RootBuilder {}

extension RootBuilder {
    /// A method that creates a new instance of the builder by mutating a value at the specified key path.
    ///
    /// - Parameters:
    ///   - keyPath: The key path to the value that needs to be mutated.
    ///   - value: The new value to be assigned to the key path.
    /// - Returns: A new instance of the builder with the mutated value.
    public func mutating<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        value: T
    ) -> Self {
        var newReference = self
        newReference[keyPath: keyPath] = value
        return newReference
    }
}
