//
//  ContentView.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI

// { "id": 1, "name": "Al Bus Dumbledore", "location": "Broughton", "destination": "Ashley", "passengers": 32, "fuel": 54, "image": "https:\/\/www.hackingwithswift.com\/samples\/img\/bus-1.jpg" }
struct Bus: Decodable, Identifiable {
    let id: Int
    let name: String
    let location: String
    let destination: String
    let passengers: Int
    let fuel: Int
    let image: String
}
//HW
//decode
//bus struct
//image layout

struct ContentView: View {
    @State private var buses = [Bus]()
    
    var body: some View {
        NavigationView {
            List(buses) { bus in
                HStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: bus.image)) { image in
                        image.resizable()
                    } placeholder: {
                        Color.mint
                    }
                    .frame(width: 110, height: 90)
                
                    VStack(alignment: .leading) {
                        Text(bus.name).font(.headline)
                        Text("\(bus.location) → \(bus.destination)")
                        Spacer()
                        HStack(alignment: .top) {
                            Image(systemName: "person.2.circle")
                            Text("\(bus.passengers)").font(.subheadline)
                            Image(systemName: "fuelpump.circle")
                            Text("\(bus.fuel)").font(.subheadline)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Bus+")
        }
        .task(loadData)
        
    }
    
    func loadData() async {
        Task {
            do {
                let url = URL(string: "https://hws.dev/bus-timetable")!
                let (data, _) = try await URLSession.shared.data(from: url)
                buses = try JSONDecoder().decode([Bus].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

//struct ContentView: View {
//    var body: some View {
//        AsyncImage(url: URL(string: "https://www.hackingwithswift.com/img/bg-plus.jpg")) { phase in
//            switch phase {
//            case .empty:
//                ProgressView()
//            case .success(let image):
//                image.resizable()
//            default:
//                Image(systemName: "bus")
//            }
        
//            image.resizable()
//        } placeholder: {
//            Color.mint
//        }
//        .frame(width: 50, height: 50)
//    }
//}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
