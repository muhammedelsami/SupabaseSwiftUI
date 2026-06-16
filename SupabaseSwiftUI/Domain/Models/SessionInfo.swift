//
//  SessionInfo.swift
//  SupabaseSwiftUI
//

import Foundation

struct SessionInfo: Equatable {
    let accessToken: String
    let refreshToken: String?
    let userId: String
    let email: String
}
