//
//  NetworkURL.swift
//  kernel_frenzy
//
//  Created by admin49 on 28/02/25.
//

import Foundation

struct NetworkURL {
    static let baseURL = URL(string: "https://kernel-frenzy.onrender.com/")!
    static let ws = URL(string: "wss://kernel-frenzy.onrender.com/ws")!
    static let localhost = URL(string:"http://0.0.0.0:8000")!
    static let localhostWS = URL(string:"ws://0.0.0.0:8000/ws")!
}
