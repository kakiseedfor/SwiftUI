//
//  ScenesToCodable.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import Foundation

struct Landmark: Decodable {
    var id: Int?
    var name: String?
    var city: String?
    var park: String?
    var state: String?
    var category: LandmarkCategory?
    var imageName: String?
    var description: String?
    var isFeatured: Bool?
    var isFavorite: Bool?
    var coordinates: LandmarkCoordinate?
}

struct LandmarkCoordinate: Decodable {
    var longitude: Double?
    var latitude: Double?
}

extension Bundle {
    func loadJsonData<T: Decodable>(_ fileName: String) -> T? {
        guard let url = self.url(forResource: fileName, withExtension: "json") else {
            print("Couldn't find \(fileName).json")
            return nil
        }
        
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("Couldn't read data from \(fileName).json")
            return nil
        }
        
        var decodeData: T?
        do {
            decodeData = try JSONDecoder().decode(T.self, from: data!)
        } catch {
            print("Couldn't decode data from \(fileName).json")
            return nil
        }
        return decodeData
    }
}
