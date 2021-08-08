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
/// 2.
struct ContentView: View {
    @State private var buses = [Bus]()
    @State private var searchText = ""

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
            List(filteredData, rowContent: BusRow.init)
            .listStyle(.grouped)
            .navigationTitle("Bus+")
            .task(loadData)
            .refreshable(action: loadData)
            .searchable(text: $searchText.animation(), prompt: "Filtered results")
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
    @State private var isFavorite = false
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
                HStack {
                    Text(bus.name).font(.headline)
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.mint)
                    }
                }
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
        .listRowSeparatorTint(.mi, edges: .bottom)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button {
                guard !isFavorite else { return }
                
                isFavorite.toggle()
            } label: {
                Label("Favorite", systemImage: "star.fill")
            }.tint(.mint)
        }
        .swipeActions(edge: .leading) {
            Button {
                guard isFavorite else { return }
                
                isFavorite.toggle()
            } label: {
                Label("Undo", systemImage: "star.slash")
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
