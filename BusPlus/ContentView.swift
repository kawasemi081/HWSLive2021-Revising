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
/// 1. add a refreshable
/// 2. add a searchable and suggestions
/// 3. add a listRowSeparatorTint
struct ContentView: View {
    @State private var buses = [Bus]()
    @State private var searchText = ""
//    @Environment(\.isSearching) var isSearching
    
    var filteredData: [Bus] {
        if searchText.isEmpty {
            return buses
        } else {
            return buses.filter { bus in
                /// - Note: Mirror is the way to look up meta data for the object. Nomaly, use this for debug
//                let busMirror = Mirror(reflecting: bus)
//                var isGood =  false
//                for child in busMirror.children {
//                    guard let value = child.value as? String else { continue }
//
//                    isGood = value.localizedCaseInsensitiveContains(searchText)
//                    return isGood
//                }
//                return isGood
                return bus.name.localizedCaseInsensitiveContains(searchText)
                || bus.destination.localizedCaseInsensitiveContains(searchText)
                || bus.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            // make more tidy than using List(buses)
            List(filteredData, rowContent: BusRow.init)
            .listStyle(.grouped)
            .navigationTitle("Bus+")
            .task(loadData)
            .refreshable(action: loadData)
            .searchable(text: $searchText.animation(), prompt: "Filtered results")
//            {
//                ForEach(filteredData) { bus in
//                    Label(bus.name, systemImage: "bus")
//                        .searchCompletion(bus.name)
//                        .foregroundColor(.mint)
//                }
//            }
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
        .listRowSeparator(.hidden, edges: .top)
        .listRowSeparatorTint(.indigo, edges: .bottom)
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
