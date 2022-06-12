//
//  NewsModel.swift
//  PlayoAssignment
//
//  Created by kishlay kishore on 11/06/22.
//

import Foundation

// MARK: - NewsModelElement
struct NewsModelElement: Codable {
    let source: Source
    let author, title, newsModelDescription: String
    let url: String
    let urlToImage: String
    let publishedAt: String
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case source, author, title
        case newsModelDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
}
