//
//  FormView.swift
//  FormView
//
//  Created by misono on 2021/08/09.
//

import SwiftUI

struct FormView: View {
    enum Field {
        case name
        case ticket
    }

    @State private var name = ""
    @State private var numberOfTicket = ""
    @FocusState private var focusedField: Field?
    var body: some View {
        NavigationView {
            Form {
                TextField("Enter your name", text: $name)
                    .focused($focusedField, equals: .name)
                    .textContentType(.username)
                    .submitLabel(.next)

                TextField("Enter ticket count", text: $numberOfTicket)
                    .focused($focusedField, equals: .ticket)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
                
                if !name.isEmpty && !numberOfTicket.isEmpty {
                    Text("Hello, \(name). You book \(numberOfTicket) \(Int(numberOfTicket) ?? 0 > 1 ? "tickets" : "ticket").")
                }

            }
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .ticket
                default:
                    focusedField = nil
                }
            }
//            .onAppear {
//                focusedField = .name
//            }
            .textFieldStyle(.roundedBorder)
            .navigationTitle("Ticket Reference")
        }
        
    }
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}

@MainActor
class UserData: ObservableObject {
    @Published var name = ""
    @Published var reference = ""
    
    var identifier: String {
        name + reference
    }
}
