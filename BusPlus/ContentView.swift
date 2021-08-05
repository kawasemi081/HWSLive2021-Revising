//
//  ContentView.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI


/// - Note: Day2-part4 assignment
/// 1. add bus struct and decoding
/// 2. use AsyncImage for image
/// 3.  layout image
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
                try Task.checkCancellation()
                buses = try JSONDecoder().decode([Bus].self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct Bus: Decodable, Identifiable {
    let id: Int
    let name: String
    let location: String
    let destination: String
    let passengers: Int
    let fuel: Int
    let image: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
