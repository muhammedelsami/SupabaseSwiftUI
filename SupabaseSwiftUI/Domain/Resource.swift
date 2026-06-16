//
//  Resource.swift
//  SupabaseSwiftUI
//
//  Universal result type for async repository operations.
//

import Foundation

enum Resource<T> {
    case loading
    case success(T)
    case error(String)
}
