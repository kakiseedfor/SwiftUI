//
//  ScenesTo@ObservedObject.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import Foundation

struct LandmarkDataCoordinates {
    @TypeWrapper var longitude: Double!
    @TypeWrapper var latitude: Double!
}

struct LandmarkData {
    @TypeWrapper var id: Int!
    @TypeWrapper var name: String!
    @TypeWrapper var city: String!
    @TypeWrapper var park: String!
    @TypeWrapper var state: String!
    @TypeWrapper var category: LandmarkCategory!
    @TypeWrapper var imageName: String!
    @TypeWrapper var description: String!
    @TypeWrapper var isFeatured: Bool!
    @TypeWrapper var isFavorite: Bool!
    @TypeWrapper var coordinates: LandmarkDataCoordinates!
    
    init(_ landmark:Landmark) {
        id = landmark.id
        name = landmark.name
        city = landmark.city
        park = landmark.park
        state = landmark.state
        category = landmark.category
        imageName = landmark.imageName
        description = landmark.description
        isFeatured = landmark.isFeatured
        isFavorite = landmark.isFavorite
        coordinates = LandmarkDataCoordinates(longitude: landmark.coordinates?.longitude,
                                              latitude: landmark.coordinates?.latitude)
    }
}

class LandmarkModel: ObservableObject, Identifiable, NSCopying {
    @TypeWrapper var tabImgName: String!
    @TypeWrapper var title: String!
    @Published var landmarkModels: [LandmarkModel]?
    @Published var landmarkDatas: [LandmarkData]?
    
    init() {
        tabImgName = LandmarkCategory.LandmarkCategoryTotal.imageName
        title = LandmarkCategory.LandmarkCategoryTotal.rawValue
    }
    
    convenience init(_ landMarkModels: [LandmarkModel]?) {
        self.init()
        self.landmarkModels = landMarkModels
    }
    
    convenience init(_ landmarkDatas: [LandmarkData]?, _ title: LandmarkCategory?) {
        self.init()
        self.landmarkDatas = landmarkDatas
        self.tabImgName = title?.imageName
        self.title = title?.rawValue
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let tmpModel = LandmarkModel()
        tmpModel.landmarkModels = landmarkModels
        tmpModel.landmarkDatas = landmarkDatas
        tmpModel.tabImgName = tabImgName
        tmpModel.title = title
        return tmpModel
    }
    
    func remove(at index: Int) {
        self.landmarkDatas?.remove(at: index)
    }
}

class LandmarkHomeModel: ObservableObject {
    @Published var landmarkModels = [LandmarkModel]()
    
    func loadData() {
        let landmarks: [Landmark]? = Bundle.main.loadJsonData("landmarkData")
        
        let catagories = landmarks?[\.category].unique()
        guard let _ = catagories?.count else {
            return
        }
        
        catagories?.forEach{ category in
            let findLandmarks: [Landmark]? = landmarks?.findElements(\.category, category)
            let landmarkDatas: [LandmarkData]? = findLandmarks?.map {
                LandmarkData($0)
            }
            landmarkModels.append(LandmarkModel(landmarkDatas, category))
        }
        
        let landmarkTotalModel: LandmarkModel = LandmarkModel(landmarkModels.copy())
        landmarkModels.insert(landmarkTotalModel, at: 0)
    }
}
