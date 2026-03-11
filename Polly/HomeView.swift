//
//  HomeView.swift
//  Polly
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var game: GameManager
    let navigate: (AppScreen) -> Void

    @State private var starOpacities: [Double] = Array(repeating: 0, count: 18)
    @State private var showInfo: Bool = false

    var moodLabel: String {
        switch game.currentMood {
        case .chatting: return "Polly is chatting"
        case .happy:    return "Polly is happy"
        case .hungry:   return "Polly is hungry"
        case .tired:    return "Polly needs rest"
        case .curious:  return "Polly wants to learn"
        case .bored:    return "Polly is bored"
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                Color(.black).ignoresSafeArea()

                VStack(spacing: 0) {

                    HStack {
                        Text("POLLY")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.5))
                            .tracking(4)
                            .accessibilityHidden(true)
                        Spacer()
                        Button { showInfo = true } label: {
                            Image(systemName: "info.circle")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.5))
                        }
                        .accessibilityLabel("About Polly")
                        .accessibilityHint("Opens information about the app")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Spacer()

                    VStack(spacing: 0) {
                        Rob8View(mood: game.currentMood, size: 260)
                            .id(game.currentMood)
                            .accessibilityLabel(moodLabel)
                            .accessibilityHint("Polly's appearance changes based on her current mood")

                        Ellipse()
                            .fill(Color.black.opacity(0.28))
                            .frame(width: 110, height: 12)
                            .blur(radius: 6)
                            .padding(.top, -4)
                            .accessibilityHidden(true)

                        Text(moodLabel)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.45))
                            .padding(.top, 12)
                            .accessibilityHidden(true) // già letto da Rob8View sopra
                    }

                    Spacer()

                    VStack(spacing: 10) {
                        StatCard(icon: "pause.fill", label: "HUNGER",    value: game.hunger,    color: .orange) { navigate(.hunger) }
                        StatCard(icon: "book.fill",  label: "EDUCATION", value: game.education, color: .yellow) { navigate(.education) }
                        StatCard(icon: "bubble.left.fill", label: "FUN", value: game.fun,       color: .yellow) { navigate(.chat) }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            InfoView()
        }
    }
}

// MARK: - StatCard

struct StatCard: View {
    let icon: String
    let label: String
    let value: Double
    let color: Color
    let onTap: () -> Void

    private var barColor: Color {
        value < 30 ? .red : value < 60 ? .orange : color
    }

    private var statusDescription: String {
        if value < 30 { return "critical" }
        if value < 60 { return "low" }
        return "good"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(barColor)
                    .frame(width: 22)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(label)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(Int(value))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(barColor)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.12))
                                .frame(height: 5)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barColor)
                                .frame(width: geo.size.width * (value / 100), height: 5)
                                .animation(.easeInOut(duration: 0.6), value: value)
                        }
                    }
                    .frame(height: 5)
                    .accessibilityHidden(true)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.25))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label.capitalized): \(Int(value)) percent, \(statusDescription)")
        .accessibilityHint("Double tap to open \(label.capitalized.lowercased()) section")
    }
}

#Preview {
    HomeView(navigate: { _ in })
        .environmentObject(GameManager())
}
