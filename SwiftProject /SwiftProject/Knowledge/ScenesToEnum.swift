//
//  ScenesToEnum.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import Foundation

enum LandmarkCategory: String, Decodable {
    var imageName: String {
        var imageName: String = ""
        switch self {
            case .LandmarkCategoryTotal:
                imageName = "allergens"
                break
            case .LandmarkCategoryLakes:
                imageName = "drop"
                break
            case .LandmarkCategoryRivers:
                imageName = "flame"
                break
            case .LandmarkCategoryMountains:
                imageName = "bolt"
                break
        }
        
        return imageName
    }
    
    case LandmarkCategoryTotal = "Total list"
    case LandmarkCategoryLakes = "Lakes"
    case LandmarkCategoryRivers = "Rivers"
    case LandmarkCategoryMountains = "Mountains"
}
