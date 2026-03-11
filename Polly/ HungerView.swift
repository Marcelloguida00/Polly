// HungerView.swift
import SwiftUI
import Photos
import Combine

// MARK: - ViewModel
@MainActor
final class PhotosSwipeViewModel: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var co2Saved: Double = 0
    @Published var keptCount: Int = 0
    @Published var deletedCount: Int = 0
    @Published var pendingDelete: [PHAsset] = []

    var currentAsset: PHAsset? {
        guard currentIndex < assets.count else { return nil }
        return assets[currentIndex]
    }

    var nextAsset: PHAsset? {
        guard currentIndex + 1 < assets.count else { return nil }
        return assets[currentIndex + 1]
    }

    var isFinished: Bool { currentIndex >= assets.count && !assets.isEmpty }

    var pendingMB: Double {
        pendingDelete.reduce(0) { $0 + sizeInMB($1) }
    }

    var pendingCO2: Double { co2ForMB(pendingMB) }

    func loadIfNeeded() {
        Task {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized, .limited:
                await fetchAssets()
            case .notDetermined:
                let result = await withCheckedContinuation { cont in
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { cont.resume(returning: $0) }
                }
                if result == .authorized || result == .limited {
                    await fetchAssets()
                } else {
                    error = "Permission denied. Go to Settings > Privacy > Photos."
                }
            default:
                error = "Access denied. Go to Settings > Privacy > Photos."
            }
        }
    }

    private func fetchAssets() async {
        isLoading = true
        let options = PHFetchOptions()
        options.predicate = NSPredicate(
            format: "mediaType == %d OR mediaType == %d",
            PHAssetMediaType.image.rawValue,
            PHAssetMediaType.video.rawValue
        )
        let result = PHAsset.fetchAssets(with: options)
        var list: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in list.append(asset) }
        assets = list.shuffled()
        currentIndex = 0
        isLoading = false
    }

    func sizeInMB(_ asset: PHAsset) -> Double {
        let resources = PHAssetResource.assetResources(for: asset)
        guard let resource = resources.first else { return 0 }
        if let size = resource.value(forKey: "fileSize") as? Int64 { return Double(size) / (1024 * 1024) }
        if let size = resource.value(forKey: "fileSize") as? CLong  { return Double(size) / (1024 * 1024) }
        return 0
    }

    func co2ForMB(_ mb: Double) -> Double { mb * 0.0244 }

    func markForDelete() {
        guard let asset = currentAsset else { return }
        pendingDelete.append(asset)
        currentIndex += 1
    }

    func markKeep() {
        keptCount += 1
        currentIndex += 1
    }

    func confirmDeleteAll() async {
        guard !pendingDelete.isEmpty else { return }
        let count = pendingDelete.count
        let savedCO2 = pendingCO2
        let toDelete = pendingDelete as NSArray

        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.deleteAssets(toDelete)
            }, completionHandler: { [weak self] success, _ in
                guard let self else { cont.resume(); return }
                DispatchQueue.main.async {
                    if success {
                        self.deletedCount = count
                        self.co2Saved = savedCO2
                        self.pendingDelete = []
                    }
                    cont.resume()
                }
            })
        }
    }

    func cancelDeleteAll() {
        pendingDelete = []
    }

    func restart() {
        currentIndex = 0
        co2Saved = 0
        keptCount = 0
        deletedCount = 0
        pendingDelete = []
        Task { await fetchAssets() }
    }
}

// MARK: - AssetImageView
struct AssetImageView: View {
    let asset: PHAsset
    @State private var image: UIImage? = nil

    var body: some View {
        ZStack {
            Color(red: 0.14, green: 0.14, blue: 0.13)
            if let img = image {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                ProgressView().tint(.orange)
            }
        }
        .onAppear { loadImage() }
        .accessibilityLabel("Photo")
        .accessibilityHidden(false)
    }

    private func loadImage() {
        let opts = PHImageRequestOptions()
        opts.deliveryMode = .highQualityFormat
        opts.isNetworkAccessAllowed = true
        opts.isSynchronous = false
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: CGSize(width: 600, height: 800),
            contentMode: .aspectFill,
            options: opts
        ) { img, _ in
            if let img { DispatchQueue.main.async { self.image = img } }
        }
    }
}

// MARK: - HungerView
struct HungerView: View {
    @EnvironmentObject var game: GameManager
    @StateObject private var vm = PhotosSwipeViewModel()
    @State private var dragOffset: CGSize = .zero
    @State private var isAnimatingOut = false
    @State private var deleteCompleted = false

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    private var swipeRight: Bool { dragOffset.width >  60 }
    private var swipeLeft:  Bool { dragOffset.width < -60 }

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack {
                Rob8View(mood: .hungry, size: 48, animate: false)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Clean Your Library")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("Swipe right to delete · left to keep")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 16)

            // Stats
            HStack(spacing: 12) {
                StatChip(icon: "photo.stack.fill",
                         value: "\(max(0, vm.assets.count - vm.currentIndex))",
                         label: "remaining")
                StatChip(icon: "trash.fill",
                         value: "\(vm.pendingDelete.count)",
                         label: "to delete")
                StatChip(icon: "leaf.fill",
                         value: String(format: "%.2fg", vm.pendingCO2),
                         label: "CO2 saved")
            }
            .padding(.horizontal, 20).padding(.top, 12)

            if vm.isLoading {
                Spacer()
                VStack(spacing: 16) {
                    Rob8View(mood: .curious, size: 90)
                        .accessibilityHidden(true)
                    ProgressView("Loading your library...")
                        .tint(.orange)
                        .foregroundColor(.gray)
                        .accessibilityLabel("Loading your photo library")
                }
                Spacer()

            } else if let error = vm.error {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                    Text(error)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .accessibilityLabel("Open Settings")
                    .accessibilityHint("Opens the iOS Settings app to grant photo library access")
                }
                Spacer()

            } else if deleteCompleted {
                successView

            } else if game.hunger >= 100 {
                fullView

            } else if vm.isFinished {
                summaryView

            } else if vm.currentAsset != nil {
                Spacer()

                ZStack {
                    if let next = vm.nextAsset {
                        AssetImageView(asset: next)
                            .id("next-\(next.localIdentifier)")
                            .frame(width: 280, height: 370)
                            .clipped()
                            .cornerRadius(24)
                            .scaleEffect(0.93)
                            .opacity(0.5)
                            .accessibilityHidden(true)
                    }

                    if let current = vm.currentAsset {
                        currentCard(current)
                            .id("current-\(current.localIdentifier)")
                            .gesture(
                                DragGesture()
                                    .onChanged { v in
                                        guard !isAnimatingOut else { return }
                                        dragOffset = v.translation
                                    }
                                    .onEnded { _ in
                                        guard !isAnimatingOut else { return }
                                        handleSwipeEnd(asset: current)
                                    }
                            )
                            .animation(reduceMotion ? nil : .interactiveSpring(response: 0.3, dampingFraction: 0.7), value: dragOffset)
                            .accessibilityLabel("Photo card")
                            .accessibilityHint("Swipe right to mark for deletion, swipe left to keep")
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .frame(height: 390)

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

                Spacer()
            }
        }
        .onAppear {
            guard vm.assets.isEmpty && !vm.isLoading else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                vm.loadIfNeeded()
            }
        }
    }

    // MARK: - Summary View
    private var summaryView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Rob8View(mood: .happy, size: 100)
                    .accessibilityHidden(true)

                Text("You're done swiping!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                VStack(spacing: 0) {
                    summaryRow(icon: "trash.fill",  color: .red,    label: "Marked for deletion", value: "\(vm.pendingDelete.count) photos")
                    Divider().background(Color.white.opacity(0.08))
                    summaryRow(icon: "heart.fill",  color: .green,  label: "Kept",                value: "\(vm.keptCount) photos")
                    Divider().background(Color.white.opacity(0.08))
                    summaryRow(icon: "leaf.fill",   color: .orange, label: "CO2 you could save",  value: String(format: "%.2f g", vm.pendingCO2))
                }
                .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                .padding(.horizontal, 20)
                .accessibilityElement(children: .contain)

                if vm.pendingDelete.count > 0 {
                    Text("The \(vm.pendingDelete.count) photos haven't been deleted yet.\nConfirm below to remove them all at once.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 12) {
                        Button {
                            Task { @MainActor in
                                await vm.confirmDeleteAll()
                                deleteCompleted = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .accessibilityHidden(true)
                                Text("Delete All \(vm.pendingDelete.count) Photos")
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(16)
                            .shadow(color: .red.opacity(0.4), radius: 10, y: 5)
                        }
                        .accessibilityLabel("Delete all \(vm.pendingDelete.count) marked photos")
                        .accessibilityHint("Permanently removes these photos from your library. This cannot be undone.")

                        Button {
                            vm.cancelDeleteAll()
                            vm.restart()
                        } label: {
                            Text("Keep Everything — Start Over")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                        }
                        .accessibilityLabel("Keep everything and start over")
                        .accessibilityHint("Cancels all deletions and restarts the swiping session")
                    }
                    .padding(.horizontal, 20)

                } else {
                    Button("Start Over") { vm.restart() }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .accessibilityLabel("Start over")
                        .accessibilityHint("Reload your photo library and begin swiping again")
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Success View
    private var successView: some View {
        VStack(spacing: 20) {
            Spacer()
            Rob8View(mood: .happy, size: 110)
                .accessibilityHidden(true)

            Text("Library cleaned!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)

            VStack(spacing: 6) {
                Text("You deleted \(vm.deletedCount) photos")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(String(format: "CO2 saved: %.2f g", vm.co2Saved))
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("You deleted \(vm.deletedCount) photos, saving \(String(format: "%.2f", vm.co2Saved)) grams of CO2")

            Spacer()
        }
    }

    // MARK: - Full View
    private var fullView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Rob8View(mood: .happy, size: 120)
                    .accessibilityHidden(true)

                VStack(spacing: 10) {
                    Text("Polly is full!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("You've cleaned enough for today.\nPolly doesn't need more photos deleted!")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                VStack(spacing: 6) {
                    HStack {
                        Label("HUNGER", systemImage: "pause.fill")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("100%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.orange)
                                .frame(width: geo.size.width, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(18)
                .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.08)))
                .padding(.horizontal, 20)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Hunger stat: 100 percent")

                if vm.pendingDelete.count > 0 {
                    VStack(spacing: 12) {
                        VStack(spacing: 0) {
                            summaryRow(icon: "trash.fill",  color: .red,    label: "Marked for deletion", value: "\(vm.pendingDelete.count) photos")
                            Divider().background(Color.white.opacity(0.08))
                            summaryRow(icon: "leaf.fill",   color: .orange, label: "CO2 you could save",  value: String(format: "%.2f g", vm.pendingCO2))
                        }
                        .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                        .padding(.horizontal, 20)
                        .accessibilityElement(children: .contain)

                        Text("Confirm to permanently delete these photos.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button {
                            Task { @MainActor in
                                await vm.confirmDeleteAll()
                                deleteCompleted = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "trash.fill")
                                    .accessibilityHidden(true)
                                Text("Delete All \(vm.pendingDelete.count) Photos")
                                    .font(.body)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(16)
                            .shadow(color: .red.opacity(0.4), radius: 10, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Delete all \(vm.pendingDelete.count) marked photos")
                        .accessibilityHint("Permanently removes these photos. This cannot be undone.")

                        Button {
                            vm.cancelDeleteAll()
                        } label: {
                            Text("Cancel — Keep All")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                        }
                        .padding(.horizontal, 20)
                        .accessibilityLabel("Cancel — keep all photos")
                        .accessibilityHint("Cancels all pending deletions")
                    }
                } else {
                    Text("Come back when Polly gets hungry again!")
                        .font(.caption)
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Summary Row
    private func summaryRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
                .accessibilityHidden(true)
            Text(label).font(.subheadline).foregroundColor(.gray)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Swipe Card
    private func currentCard(_ current: PHAsset) -> some View {
        let mb = vm.sizeInMB(current)
        return ZStack(alignment: .bottom) {
            AssetImageView(asset: current)
                .frame(width: 280, height: 370)
                .clipped()

            LinearGradient(colors: [.clear, .black.opacity(0.85)],
                           startPoint: .center, endPoint: .bottom)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: current.mediaType == .video ? "video.fill" : "photo.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .accessibilityHidden(true)
                    Text(current.mediaType == .video ? "VIDEO" : "PHOTO")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Spacer()
                    if let date = current.creationDate {
                        Text(date, format: .dateTime.day().month().year())
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                HStack {
                    Text(String(format: "%.1f MB", mb))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Text(String(format: "CO2 %.2f g", vm.co2ForMB(mb)))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
            }
            .padding(16)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(current.mediaType == .video ? "Video" : "Photo"), \(String(format: "%.1f", mb)) megabytes, \(String(format: "%.2f", vm.co2ForMB(mb))) grams CO2")

            if swipeRight {
                VStack {
                    HStack {
                        Spacer()
                        Text("DELETE")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.white).padding(10)
                            .background(Color.red).cornerRadius(10).padding(16)
                    }
                    Spacer()
                }
                .accessibilityHidden(true)
            }
            if swipeLeft {
                VStack {
                    HStack {
                        Text("KEEP")
                            .font(.caption)
                            .fontWeight(.black)
                            .foregroundColor(.white).padding(10)
                            .background(Color.green).cornerRadius(10).padding(16)
                        Spacer()
                    }
                    Spacer()
                }
                .accessibilityHidden(true)
            }
        }
        .frame(width: 280, height: 370)
        .cornerRadius(24)
        .shadow(color: swipeRight ? .red.opacity(0.6) : swipeLeft ? .green.opacity(0.6) : .black.opacity(0.4), radius: 24)
        .rotationEffect(.degrees(reduceMotion ? 0 : Double(dragOffset.width) * 0.05))
        .offset(x: dragOffset.width, y: dragOffset.height * 0.1)
    }

    // MARK: - Swipe Logic
    private func handleSwipeEnd(asset: PHAsset) {
        if dragOffset.width > 60        { animateOut(asset: asset, delete: true) }
        else if dragOffset.width < -60  { animateOut(asset: asset, delete: false) }
        else {
            withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.75)) {
                dragOffset = .zero
            }
        }
    }

    private func animateOut(asset: PHAsset, delete: Bool) {
        guard !isAnimatingOut else { return }
        isAnimatingOut = true
        let duration = reduceMotion ? 0.05 : 0.2
        withAnimation(.easeIn(duration: duration)) {
            dragOffset = CGSize(width: delete ? 700 : -700, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            dragOffset = .zero
            if delete {
                vm.markForDelete()
                game.increaseHunger(by: 0.5)
            } else {
                vm.markKeep()
            }
            isAnimatingOut = false
        }
    }
}

// MARK: - StatChip
struct StatChip: View {
    let icon: String; let value: String; let label: String
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon).font(.caption).foregroundColor(.orange)
                .accessibilityHidden(true)
            Text(value).font(.subheadline).fontWeight(.bold).foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 10)
        .background(Color(red: 0.14, green: 0.14, blue: 0.13)).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.07)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

#Preview {
    HungerView().environmentObject(GameManager())
        .background(Color.black)
}
