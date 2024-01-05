//
//  ScenesToMap.swift
//  SwiftProject
//
//  Created by kaki Yen on 2021/12/28.
//

import SwiftUI
import MapKit

struct LandmarkMapView: View {
    @State private var region = MKCoordinateRegion()
    var coordinate: LandmarkDataCoordinates
    var imageName: String

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [AnnotationItem(latitude: coordinate.latitude, longitude: coordinate.longitude)]) {
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) {
                MapAnnotationImage(imageName: imageName)
            }
        }
            .onAppear {
                setRegion(coordinate)
            }
    }

    private func setRegion(_ coordinate: LandmarkDataCoordinates) {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    }
    
    struct AnnotationItem: Identifiable {
        var id: String?
        var latitude: Double
        var longitude: Double
    }
    
    struct MapAnnotationImage: View {
        @State private var animationToggle = true
        var imageName: String
        
        var body: some View {
            NavigationLink {
                LandMarkSpriteView(imageName: imageName)
            } label: {
                Image(imageName)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 54.0, height: 54.0)
                    .overlay {
                        Circle()
                            .stroke(.orange, lineWidth: 2.0)
                    }
                    .overlay {
                        Circle()
                            .stroke(.orange, lineWidth: 2.0)
                            .scaleEffect(animationToggle ? 1.0 : 2.0)
                            .opacity(animationToggle ? 1.0 : 0.0)
                    }
                    .onAppear {
                        withAnimation(.easeOut(duration: 3.0).repeatForever(autoreverses: false)) {
                            animationToggle.toggle()
                        }
                    }
            }
        }
    }
}
