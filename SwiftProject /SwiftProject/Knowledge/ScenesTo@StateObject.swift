//
//  ScenesTo@StateObject.swift
//  SwiftProject
//
//  Created by kaki Yen on 2022/1/5.
//

import SwiftUI

struct LandMarkTabView: View {
    /**
     *  @StateObject 与 @ObservedObject不同之处
     *      1、@StateObject生命周期与拥有其的View的生命周期一致；
     *         而@ObservedObject则有很多不确定性
     */
    @StateObject var landmarkHomeModel: LandmarkHomeModel = LandmarkHomeModel()
    @State var selectedIndex: Int = appStorages.tabSelection
    var navTitle: String {
        landmarkHomeModel.landmarkModels.isEmpty ? "" : landmarkHomeModel.landmarkModels[selectedIndex].title
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(landmarkHomeModel.landmarkModels.enumerated()), id: \.element.title) { index, landmarkModel in
                LandmarkNavgation()
                    .environmentObject(landmarkModel)
                    .tabItem {
                        Label(landmarkModel.title, systemImage: landmarkModel.tabImgName)
                    }
                    .tag(index)
                    .onceOnAppear {
                        appStorages.tabSelection = selectedIndex
                        ScenesToCall.callTrace()
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(navTitle)
        .onceOnAppear {
            landmarkHomeModel.loadData()
        }
    }
}

struct LandMarkDetailView: View {
    @State var scrollOffset: CGRect = .zero
    var landmarkData: LandmarkData
    
    var body: some View {
        ScrollView {
            VStack {
                LandmarkMapView(coordinate: landmarkData.coordinates,
                                imageName: landmarkData.imageName)
                    .frame(height: 300)
                
                CycleImage(imageName: landmarkData.imageName)
                
                DetailInfoView(landmarkData: landmarkData)
            }
            .readScrollOffset($scrollOffset)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("\(scrollOffset.minY)")
                    .fontWeight(.semibold)
            }
        }
    }
    
    struct CycleImage: View {
        @State var imageSize: CGSize = .zero
        var imageName: String
        
        var body: some View {
            Image(imageName)
                .readSize($imageSize)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                .shadow(radius: 7)
                .overlay {
                    Circle().stroke(.white, lineWidth: 4)
                }
                .padding(.bottom, -imageSize.height / 2)
                .offset(y: -imageSize.height / 2)
        }
    }
    
    struct DetailInfoView: View {
        var landmarkData: LandmarkData
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(landmarkData.name)
                    .font(.title)
                
                HStack {
                    Text(landmarkData.park)
                    Spacer()
                    Text(landmarkData.state)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text("About " + landmarkData.name)
                    .font(.title2)
                Spacer()
                Text(landmarkData.description)
            }
            .padding()
        }
    }
}
