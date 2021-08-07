//
//  ContentView.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI


/// - Note: Assignments
/// * Day2-part4
/// 1. add bus struct and decoding
/// 2. use AsyncImage for image
/// 3.  layout image
/// * Day3-part2
/// 1. add the refreshable
struct ContentView: View {
    @State private var buses = [Bus]()
    
    var body: some View {
        NavigationView {
            // make more tidy than using List(buses)
            List(buses, rowContent: BusRow.init)
            .listStyle(.plain)
            .navigationTitle("Bus+")
            .task(loadData)
            .refreshable(action: loadData)
        }
        
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

struct BusRow: View {
    let bus: Bus
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: bus.image)) { image in
                image.resizable()
            } placeholder: {
                Color.mint
            }
            .frame(width: 110, height: 90)

            VStack(alignment: .leading, spacing: 8) {
                Text(bus.name).font(.headline)
                HStack(spacing: 8) {
                    Image(systemName: "person.2.circle")
                    Text("\(bus.passengers)")
                    Image(systemName: "fuelpump.circle")
                    Text("\(bus.fuel) %")
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(bus.passengers) passengers and \(bus.fuel) per cent fuel.")
                
                Text("\(bus.location) → \(bus.destination)")
                    .font(.subheadline)
                    .accessibilityLabel("Traveling from \(bus.location) to \(bus.destination)")
                
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
