import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var firstName = ""
    @State private var level: String? = nil
    @State private var selectedPosition: String? = nil
    @State private var selectedItems: Set<String> = []
    @State private var grade = false
    @State private var flCoach = false

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var userImage: UIImage? = nil

    @State private var navigateToExport = false
    @State private var previewToken = UUID()   // ✅ force-fresh ExportView each submit

    let position = ["Complex Manager", "Operations Manager", "CoOrdinator", "Supervisor", "AO", "Specialist", "Team Member"]
    let supervisor = ["In The Home Supervisor", "Lifestyles Supervisor", "Builders Supervisor", "Trade Supervisor", "Front End Supervisor", "Goods Inwards Supervisor", "Admin Supervisor"]
    let coord = ["Builder's Coordinator", "Trade CoOrdinator", "In the Home CoOrdinator", "Lifestyles CoOrdinator"]
    let specialist = ["Trade Specialist", "Inventory Expert"]
    let teamMember = ["Front End", "Cafe", "Goods Inwards", "Reception", "Price Integrity", "In The Home", "Trade", "Builders", "Lifestyles"]
    let qualifications = ["First Aider", "Fire Warden", "Fork Lifter", "Combi Driver", "Walkie Stacker Operator", "Scissor Lift Operator", "Return to Work Organiser"]

    var body: some View {
        NavigationStack {
            VStack {
                Text("Superhero Card Generator")
                    .font(.title)
                    .padding()

                Form {
                    TextField("First Name", text: $firstName)

                    Picker("Position", selection: $level) {
                        Text("Select a position").tag(String?.none)
                        ForEach(position, id: \.self) { item in
                            Text(item).tag(Optional(item))
                        }
                    }

                    if let level = level {
                        switch level {
                        case "Team Member":
                            Picker("Team Member Role", selection: $selectedPosition) {
                                Text("Select a role").tag(String?.none)
                                ForEach(teamMember, id: \.self) { item in
                                    Text(item).tag(Optional(item))
                                }
                            }
                        case "CoOrdinator":
                            Picker("CoOrdinator Role", selection: $selectedPosition) {
                                Text("Select a role").tag(String?.none)
                                ForEach(coord, id: \.self) { item in
                                    Text(item).tag(Optional(item))
                                }
                            }
                        case "Specialist":
                            Picker("Specialist Role", selection: $selectedPosition) {
                                Text("Select a role").tag(String?.none)
                                ForEach(specialist, id: \.self) { item in
                                    Text(item).tag(Optional(item))
                                }
                            }
                        case "Supervisor":
                            Picker("Supervisor Role", selection: $selectedPosition) {
                                Text("Select a role").tag(String?.none)
                                ForEach(supervisor, id: \.self) { item in
                                    Text(item).tag(Optional(item))
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }

                    Section(header: Text("Qualifications")) {
                        ForEach(qualifications, id: \.self) { item in
                            Toggle(isOn: Binding<Bool>(
                                get: { selectedItems.contains(item) },
                                set: { isSelected in
                                    if isSelected {
                                        selectedItems.insert(item)
                                    } else {
                                        selectedItems.remove(item)
                                    }
                                }
                            )) {
                                Text(item)
                            }
                        }

                        if selectedItems.contains("Fork Lifter") {
                            HStack {
                                Text("B Grade")
                                Toggle("", isOn: $grade)
                                Spacer()
                                Text("A Grade")
                            }

                            if grade {
                                Toggle("Forklift Coach", isOn: $flCoach)
                            }
                        }

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("Choose a Photo", systemImage: "photo")
                        }
                        .onChange(of: selectedPhoto) {
                            Task {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    userImage = image
                                }
                            }
                        }
                    }
                }

                Button("Submit") {
                    // Don’t mutate selectedItems; derive what Preview should see:
                    var finalQualifications = selectedItems

                    if finalQualifications.contains("Fork Lifter") {
                        finalQualifications.remove("Fork Lifter")
                        finalQualifications.insert(grade ? "A Grade Forklifter" : "B Grade Forklifter")
                        if grade && flCoach {
                            finalQualifications.insert("Forklift Coach")
                        }
                    }

                    // Bump the token so ExportView is a brand-new instance (resets its local state)
                    previewToken = UUID()
                    navigateToExport = true

                    // Navigate with derived data
                    pendingName = firstName
                    pendingLevel = level ?? ""
                    pendingPosition = (selectedPosition ?? level) ?? ""
                    pendingQualifications = Array(finalQualifications)
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationDestination(isPresented: $navigateToExport) {
                ExportView(
                    name: pendingName,
                    level: pendingLevel,
                    position: pendingPosition,
                    qualifications: pendingQualifications,
                    photo: userImage
                )
                .id(previewToken)   // ✅ force a clean preview each time
            }
        }
    }

    // Temp holders just for navigation payload
    @State private var pendingName: String = ""
    @State private var pendingLevel: String = ""
    @State private var pendingPosition: String = ""
    @State private var pendingQualifications: [String] = []
}
