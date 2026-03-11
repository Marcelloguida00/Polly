import SwiftUI

struct HungerViewQuickDeleteSandbox: View {
    @StateObject private var vm = PhotosSwipeViewModel()
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingOut = false
    @State private var deleteCompleted = false

    @State private var showQuickDeleteConfirm = false

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack {
            if vm.assets.isEmpty && vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if vm.currentAsset != nil {
                ZStack {
                    // Swipe UI content here

                    VStack {
                        Spacer()

                        HStack {
                            Text("← Keep")
                            Spacer()
                            Text("Delete →")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 52)
                        .padding(.top, 16)
                        .accessibilityHidden(true)

                        // Quick delete button when there are items marked for deletion
                        if vm.pendingDelete.count > 0 {
                            Button {
                                showQuickDeleteConfirm = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill").accessibilityHidden(true)
                                    Text("Quick delete selected (") + Text("\(vm.pendingDelete.count)").bold() + Text(")")
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(14)
                                .padding(.horizontal, 40)
                            }
                            .accessibilityLabel("Quick delete selected items now")
                            .accessibilityHint("Immediately removes the selected photos without going to the summary")
                        }

                        Spacer()
                    }
                }
            } else {
                Text("No photos available")
            }
        }
        .onAppear {
            guard vm.assets.isEmpty && !vm.isLoading else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                vm.loadIfNeeded()
            }
        }
        .confirmationDialog(
            "Remove the selected shots?",
            isPresented: $showQuickDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button(role: .destructive) {
                Task { @MainActor in
                    await vm.confirmDeleteAll()
                    deleteCompleted = true
                }
            } label: {
                Text("Delete them now")
            }
            Button("Never mind", role: .cancel) { }
        } message: {
            Text("This will permanently erase the chosen items from your library.")
        }
    }
}
