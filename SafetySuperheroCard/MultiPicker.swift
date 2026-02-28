import SwiftUI

struct MultiPicker: View {
    let allItems: [String]
    @Binding var selectedItems: [String]

    var body: some View {
        List(allItems, id: \.self) { item in
            Button {
                withAnimation {
                    toggleSelection(for: item)
                }
            } label: {
                HStack {
                    Image(systemName: selectedItems.contains(item) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedItems.contains(item) ? .accentColor : .secondary)
                    Text(item)
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func toggleSelection(for item: String) {
        if let index = selectedItems.firstIndex(of: item) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(item)
        }
    }
}
