//
//  RootBuilder.swift
//
//
//  Created by iletai on 24/11/2023.
//

import Foundation

public protocol RootBuilder {}
extension RootBuilder {
    public func mutating<T>(
        _ keyPath: WritableKeyPath<Self, T>,
        value: T
    ) -> Self {
        var newReference = self
        newReference[keyPath: keyPath] = value
        return newReference
    }
}
