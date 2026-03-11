//
//  InfoView.swift
//  Polly
//
//  Created by Marcello Guida on 10/03/26.
//


//
//  InfoView.swift
//  Polly
//

import SwiftUI

struct InfoView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.10, green: 0.10, blue: 0.09).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    // ── Top bar
                    HStack {
                        Text("ABOUT POLLY")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(3)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 28)

                    // ── Mascot + title
                    VStack(spacing: 12) {
                        Rob8View(mood: .happy, size: 90)

                        Text("Hi, I'm Polly.")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Your digital eco-companion.")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 36)

                    // ── Concept card
                    InfoCard {
                        VStack(alignment: .leading, spacing: 10) {
                            InfoSectionLabel(text: "Why Polly exists")

                            Text(
                                "Every photo you never delete, every email sitting unread, every video stored but never watched — all of this consumes real energy. Data centers run 24/7 and still largely depend on non-renewable sources.\n\nThis is called **Data Pollution**: an invisible environmental impact that grows with every byte we neglect."
                            )
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.65))
                            .lineSpacing(4)
                        }
                    }

                    Spacer().frame(height: 14)

                    // ── Features
                    InfoCard {
                        VStack(alignment: .leading, spacing: 18) {
                            InfoSectionLabel(text: "What you can do")

                            InfoFeatureRow(
                                icon: "pause.fill",
                                color: .orange,
                                title: "Hunger — Clean Photos",
                                description: "Swipe through your library. Right to delete, left to keep. Every photo removed is real storage freed and CO₂ saved."
                            )

                            Divider().background(Color.white.opacity(0.07))

                            InfoFeatureRow(
                                icon: "book.fill",
                                color: .yellow,
                                title: "Education — Quiz",
                                description: "Answer questions about data pollution and digital sustainability. Learn surprising facts while boosting Polly's knowledge."
                            )

                            Divider().background(Color.white.opacity(0.07))

                            InfoFeatureRow(
                                icon: "bubble.left.fill",
                                color: .green,
                                title: "Fun — Chat with Polly",
                                description: "Open a conversation with your eco-companion. Ask her anything about your digital footprint."
                            )
                        }
                    }

                    Spacer().frame(height: 14)

                    // ── Moods
                    InfoCard {
                        VStack(alignment: .leading, spacing: 14) {
                            InfoSectionLabel(text: "Polly's moods")

                            VStack(alignment: .leading) {
                                MoodRow(mood: .happy,    label: "Happy",    description: "All stats are healthy. Keep it up!")
                                MoodRow(mood: .hungry,   label: "Hungry",   description: "Hunger is low — clean your photo library.")
                                MoodRow(mood: .tired,    label: "Tired",    description: "Energy is low — take a break.")
                                MoodRow(mood: .curious,  label: "Curious",  description: "Education is low — take a quiz.")
                                MoodRow(mood: .bored,    label: "Bored",    description: "Fun is low — chat with Polly.")
                                MoodRow(mood: .chatting, label: "Chatting", description: "Polly is in conversation with you.")
                            }
                        }
                    }

                    Spacer().frame(height: 14)

                    // ── Privacy
                    InfoCard {
                        VStack(alignment: .leading, spacing: 14) {
                            InfoSectionLabel(text: "Privacy & permissions")

                            InfoPrivacyRow(
                                icon: "photo.on.rectangle",
                                title: "Photo Library",
                                description: "Used only to show and delete photos you choose. Nothing is uploaded or shared."
                            )
                            InfoPrivacyRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                description: "Sent when a stat drops below 50%. Disable anytime in Settings."
                            )
                            InfoPrivacyRow(
                                icon: "lock.fill",
                                title: "On-Device Only",
                                description: "Your photos and usage data never leave your device."
                            )
                            InfoPrivacyRow(
                                icon: "brain",
                                title: "AI Chat",
                                description: "Chat messages are processed on-device via Apple Intelligence. No data is sent to external servers."
                            )
                        }
                    }

                    Spacer().frame(height: 14)

                    // ── Team
                    InfoCard {
                        VStack(alignment: .leading, spacing: 12) {
                            InfoSectionLabel(text: "Made by")

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach([
                                    "Gennaro Biagino",
                                    "Ivan Ferrara",
                                    "Marcello Guida",
                                    "Sara Riccone",
                                    "Marzieh Salehnia",
                                    "Sepideh Shahbazi"
                                ], id: \.self) { name in
                                    HStack(spacing: 10) {
                                        Circle()
                                            .fill(Color.orange.opacity(0.25))
                                            .frame(width: 6, height: 6)
                                        Text(name)
                                            .font(.system(size: 13, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.75))
                                    }
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)

                    // ── Footer
                    VStack(spacing: 6) {
                        Text("POLLY")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.2))
                            .tracking(2)
                        Text("Made to fight data pollution")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(.bottom, 48)
                }
            }
        }
    }
}

// MARK: - Subcomponents

private struct InfoCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.14, green: 0.14, blue: 0.13))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
            .padding(.horizontal, 20)
    }
}

private struct InfoSectionLabel: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(.orange)
            .tracking(2)
            .padding(.bottom, 2)
    }
}

private struct InfoFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
                .padding(10)
                .background(color.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
        }
    }
}

private struct MoodRow: View {
    let mood: RobotMood
    let label: String
    let description: String

    var body: some View {
        HStack(spacing: 12) {
            Rob8View(mood: mood, size: 32, animate: false)

            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
    }
}

private struct InfoPrivacyRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
        }
    }
}

#Preview {
    InfoView()
}
