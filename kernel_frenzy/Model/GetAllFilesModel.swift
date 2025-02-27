//
//  GetAllFilesModel.swift
//  kernel_frenzy
//
//  Created by admin49 on 27/02/25.
//

import Foundation

struct FileItem: Identifiable, Codable {
    let id: String
    let name: String
    let updatedAt: String
    let createdAt: String
    let lastAccessedAt: String
    let metadata: FileMetadata
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case lastAccessedAt = "last_accessed_at"
        case metadata
    }
}

struct FileMetadata: Codable {
    let size: Int
    let mimetype: String
    let eTag: String
    let cacheControl: String
    let lastModified: String
    let contentLength: Int
    let httpStatusCode: Int
}

struct APIResponse: Codable {
    let message: String
    let data: [FileItem]
}
