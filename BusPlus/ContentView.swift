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
/// * Day3-part3
/// 1. add SwipeAction for "Favorite"
/// 2. add markdown on somewhere my own
/// 3. give some colored icon with palette option
struct ContentView: View {
    @State private var buses = [Bus]()
    @State private var searchText = ""
    @State private var favorites = Set<Bus>()
    
    var filteredData: [Bus] {
        if searchText.isEmpty {
            return buses
        } else {
            return buses.filter { bus in
                return bus.name.localizedCaseInsensitiveContains(searchText)
                || bus.destination.localizedCaseInsensitiveContains(searchText)
                || bus.location.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredData) { bus in
                BusRow(bus: bus, isFavorite: favorites.contains(bus))
                    .swipeActions {
                        Button {
                            toggle(favorite: bus)
                        } label: {
                            if favorites.contains(bus) {
                                Label("Undo", systemImage: "star.slash")
                            } else {
                                Label("Favorite", systemImage: "star")
                            }
                        }.tint(.mint)
                    }
            }
            .listStyle(.grouped)
            .navigationTitle("Bus+")
            .task(loadData)
            .refreshable(action: loadData)
            .searchable(text: $searchText.animation(), prompt: "Filtered results")
            {
                ForEach(filteredData) { bus in
                    HStack {
                        Image(systemName: "location.fill.viewfinder")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.indigo, Color("palepink"))
                        Text("***\(bus.name)***")
                            .searchCompletion(bus.name)
                            .foregroundColor(.mint)
                    }
                }
            }
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
    
    func toggle(favorite bus: Bus) {
        if favorites.contains(bus) {
            favorites.remove(bus)
        } else {
            favorites.insert(bus)
        }
    }
}

struct BusRow: View {
    let bus: Bus
    let isFavorite: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: bus.image)) { image in
                image.resizable()
            } placeholder: {
                Color.mint
            }
            .frame(width: 110, height: 90)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "bus")
                        .foregroundStyle(LinearGradient(colors: [Color("palepink"), .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text(bus.name).font(.headline)
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color("lemon"))
                    }
                }
                HStack(spacing: 8) {
                    Image(systemName: "person.2.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.indigo, Color("palepink"))
                    Text("**\(bus.passengers)** passengers").font(.caption)
                    Image(systemName: "fuelpump.circle")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.indigo, Color("palepink"))
                    Text("**\(bus.fuel)** %").font(.caption)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(bus.passengers) passengers and \(bus.fuel) per cent fuel.")
                HStack(spacing: 2) {
                    Image(systemName: "arrow.triangle.turn.up.right.circle")
                        .foregroundStyle(LinearGradient(colors: [Color("palepink"), .indigo], startPoint: .top, endPoint: .bottom))
                    Text("*\(bus.destination)*").font(.subheadline) + Text(" from *\(bus.location)*").font(.caption)
                        .accessibilityLabel("Traveling from \(bus.location) to \(bus.destination)")
                }
            }
        }
        .listRowSeparator(.hidden, edges: .top)
        .listRowSeparatorTint(.indigo, edges: .bottom)
    }
}

struct Bus: Decodable, Identifiable, Hashable {
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
