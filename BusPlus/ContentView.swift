//
//  ContentView.swift
//  BusPlus
//
//  Created by misono on 2021/08/05.
//

import SwiftUI
import CoreImage.CIFilterBuiltins


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
/// 4. wrap  current content in Tab view, the second tab has enter the name and enter  ticket reference number textfields
/// 5. add second content here and
/// * Day3-part4
/// 1. add Done buttton on keyboard toolbar area
/// 2. add "!" badges over MyTicket View if textfields have not been filled yet.
/// 3. add visual effect when user tap the list item
struct ContentView: View {
    @State private var buses = [Bus]()
    @State private var searchText = ""
    @State private var favorites = Set<Bus>()
    @State private var selectedBus: Bus?
    
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
            ZStack {
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
                            }
                            .tint(Color("lemon"))
                        }
                        .onTapGesture {
                            self.selectedBus = bus
                        }
                }
                if let selectedBus = selectedBus {
                    AsyncImage(url: URL(string: selectedBus.image)) { image in
                        image
                            .resizable()
                            .cornerRadius(10)
                    } placeholder: {
                        Image(systemName: "bus")
                    }
                    .frame(width: 275, height: 275)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .onTapGesture {
                        self.selectedBus = nil
                    }
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

struct MyTicketView: View {
    enum Field {
        case name
        case reference
    }
    
    @EnvironmentObject var userData: UserData
    @FocusState private var focusedField: Field?
    
    @State private var context = CIContext()
    @State private var filter = CIFilter.qrCodeGenerator()
    
    var qrCode: Image {
        let data = Data(userData.identifier.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                let uiimg = UIImage(cgImage: cgimg)
                return Image(uiImage: uiimg)
            }
        }
        return Image(systemName: "xmark.circle")
    }
    
    var body: some View {
        NavigationView {
            /// - Note: Form does't work with focus status.
            VStack {
                TextField("Jonny Appleseed", text: $userData.name)
                    .focused($focusedField, equals: .name)
                    .textContentType(.name)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.next)
                
                TextField("Ticket reference number", text: $userData.reference)
                    .focused($focusedField, equals: .reference)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                
                qrCode
                    .interpolation(.none)
                    .resizable()
                    .frame(width: 250, height: 250)
                Spacer()
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        focusedField = nil
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .reference
                default:
                    focusedField = nil
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
