//
//  ScenesTo@Environment.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI

struct LandmarkNavgation: View {
    @EnvironmentObject var landmarkModel: LandmarkModel
    
    var body: some View {
        if let _ = landmarkModel.landmarkModels {
            LandmarkTotalList()
        } else {
            LandmarkList()
        }
    }
}

struct LandmarkTotalList: View {
    @EnvironmentObject var landmarkModel: LandmarkModel
    
    var body: some View {
        List {
            ForEach(landmarkModel.landmarkModels ?? [], id: \.title) { subLandmarkModel in
                LandmarkSubList(landmarkModel: subLandmarkModel)
            }
        }
        .listStyle(.grouped)
    }
}

struct LandmarkList: View {
    @EnvironmentObject var landmarkModel: LandmarkModel
    
    var body: some View {
        List {
            LandmarkSubList(landmarkModel: landmarkModel)
        }
        .listStyle(.grouped)
    }
}

struct LandmarkSubList: View {
    @StateObject var landmarkModel: LandmarkModel
    
    var body: some View {
        LandmarkListSection(title: landmarkModel.title) {
            ForEach(landmarkModel.landmarkDatas ?? [], id: \.id) { landmarkData in
                LandmarkListRow(destination: {
                    LandMarkDetailView(landmarkData: landmarkData)
                }, landmarkData: landmarkData)
            }
            .onDelete {
                landmarkModel.remove(at: $0.first!)
            }
        }
    }
}

struct LandmarkListSection<Content: View>: View {
    @State var headerSize: CGSize = .zero
    @State var footererSize: CGSize = .zero
    @TypeWrapper var title: String!
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Section(content: content) {
            ZStack {
                Color.indigo
                
                Text(title)
                    .foregroundColor(.secondary)
                    .background {
                        colorFromHex(0xFFFFFF)
                    }
                    .frame(width: headerSize.width, height: headerSize.height)
            }
            .readSize($headerSize)
        } footer: {
            ZStack {
                Color.clear
                
                Divider()
                    .frame(width: footererSize.width, height: footererSize.height)
                    .background {
                        Color.blue
                    }
                
                Text("The \(title.lowercased()) end line")
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .font(.subheadline)
                    .background {
                        Color.blue
                    }
            }
            .readSize($footererSize)
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
    }
}

struct LandmarkListRow<Destination: View>: View {
    @ViewBuilder var destination: () -> Destination
    var landmarkData: LandmarkData!
    var enableNavigation = true
    
    var body: some View {
        if enableNavigation {
            NavigationLink(destination: destination) {
                HStack {
                    Image(landmarkData.imageName)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 50.0, height: 50.0)
                    Text(landmarkData.name)
                }
            }
            .padding(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
        } else {
            HStack {
                Image(landmarkData.imageName)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 50.0, height: 50.0)
                Text(landmarkData.name)
            }
            .padding(EdgeInsets(top: 8.0, leading: 16.0, bottom: 8.0, trailing: 16.0))
        }
    }
}
