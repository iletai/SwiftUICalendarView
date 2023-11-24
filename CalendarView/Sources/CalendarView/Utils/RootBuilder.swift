//
//  File.swift
//  
//
//  Created by tailqt on 24/11/2023.
//

import Foundation

public protocol RootBuilder {}
public extension RootBuilder {
    func mutating<T>(_ keyPath: WritableKeyPath<Self, T>, value: T) -> Self {
        var newReference = self
        newReference[keyPath: keyPath] = value
        return newReference
    }
}
