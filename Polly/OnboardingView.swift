//
//  OnboardingView.swift
//  Polly
//
//  Created by Gennaro Biagino on 03/03/26.
//

import SwiftUI

struct OnboardingSlide: Identifiable {
    let id = UUID()
    let tag: String
    let title: String
    let description: String
    let detail: String
    let mood: RobotMood
}

struct OnboardingView: View {
    @Binding var isOnboarded: Bool
    @State private var currentPage: Int = 0
    @State private var showHint: Bool = true

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let slides: [OnboardingSlide] = [
        .init(
            tag: "WELCOME",
            title: "Hi, I'm Polly.",
            description: "Your digital eco-companion. I help you understand and reduce your Data Pollution.",
            detail: "Every byte you store but never use keeps consuming energy — silently.",
            mood: .happy
        ),
        .init(
            tag: "THE PROBLEM",
            title: "Storing unused data\nconsumes real energy.",
            description: "Data centers run 24/7 and still largely depend on non-renewable sources. Every photo or file you never open keeps consuming power.",
            detail: "This is called Data Pollution: an invisible environmental impact that grows with every byte we neglect.",
            mood: .tired
        ),
        .init(
            tag: "HUNGER",
            title: "Clean your\nphoto library.",
            description: "Swipe through your photos. Right to delete, left to keep. Every file removed is real storage freed — and I get happier.",
            detail: "I track the CO₂ you save with each swipe, so you can see the real impact of your choices.",
            mood: .hungry
        ),
        .init(
            tag: "EDUCATION",
            title: "Learn about\ndata pollution.",
            description: "Answer quiz questions about the environmental cost of digital data. Did you know data centers use ~3% of global electricity?",
            detail: "Every correct answer raises my education stat. Just 5 correct answers fills it to 100%.",
            mood: .curious
        ),
        .init(
            tag: "FUN",
            title: "Chat with\nme anytime.",
            description: "Ask me anything about data pollution or reducing your digital footprint. I'm powered by Apple Intelligence — fully on-device.",
            detail: "Your conversations never leave your phone. Chatting with me keeps my Fun stat high.",
            mood: .chatting
        ),
        .init(
            tag: "ENERGY",
            title: "Take care of\nyour screen time.",
            description: "If you use the app for more than 5 minutes continuously, my Energy starts to drop. A short break resets it.",
            detail: "This is a gentle reminder that digital wellbeing matters too — for you and for me.",
            mood: .tired
        ),
        .init(
            tag: "NOTIFICATIONS",
            title: "Let me reach\nyou when it matters.",
            description: "When one of my stats drops below 50%, I'll send you a nudge. Not to bother you — but to remind you that your digital habits have a real impact.",
            detail: "Enable notifications to get timely reminders to clean, learn, chat or take a break. You can turn them off anytime in Settings.",
            mood: .bored
        ),
        .init(
            tag: "YOU'RE ALL SET",
            title: "Ready to fight\ndata pollution?",
            description: "Keep all four stats healthy: feed me by cleaning your library, teach me with quizzes, chat with me to have fun, and rest to keep my energy up.",
            detail: "Small daily habits = a real reduction in your digital carbon footprint. Let's go. 🌱",
            mood: .happy
        ),
    ]

    var body: some View {
        ZStack {
            Color(red: 0.10, green: 0.10, blue: 0.09).ignoresSafeArea()

            TabView(selection: $currentPage) {
                ForEach(Array(slides.enumerated()), id: \.offset) { index, slide in
                    OnboardingSlideView(slide: slide)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: currentPage)
            .onChange(of: currentPage) { _ in
                if reduceMotion {
                    showHint = false
                } else {
                    withAnimation { showHint = false }
                }
            }
            .accessibilityLabel("Onboarding, slide \(currentPage + 1) of \(slides.count)")

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 20) {

                    // Swipe hint
                    HStack(spacing: 6) {
                        Image(systemName: "hand.point.right.fill")
                            .font(.caption)
                            .foregroundColor(.orange.opacity(0.7))
                        Text("swipe to continue")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .opacity(showHint ? 1 : 0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: showHint)
                    .accessibilityHidden(true)

                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<slides.count, id: \.self) { i in
                            Capsule()
                                .fill(i == currentPage ? Color.orange : Color.gray.opacity(0.35))
                                .frame(width: i == currentPage ? 24 : 8, height: 8)
                                .animation(reduceMotion ? nil : .spring(response: 0.3), value: currentPage)
                        }
                    }
                    .accessibilityHidden(true)

                    // Button
                    Button {
                        if currentPage < slides.count - 1 {
                            if reduceMotion {
                                currentPage += 1
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
                            }
                        } else {
                            if reduceMotion {
                                isOnboarded = true
                            } else {
                                withAnimation(.easeInOut(duration: 0.35)) { isOnboarded = true }
                            }
                        }
                    } label: {
                        Text(currentPage < slides.count - 1 ? "NEXT →" : "LET'S GO →")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .cornerRadius(16)
                            .shadow(color: .orange.opacity(0.4), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 40)
                    .accessibilityLabel(currentPage < slides.count - 1 ? "Next" : "Get started")
                    .accessibilityHint(currentPage < slides.count - 1
                        ? "Go to slide \(currentPage + 2) of \(slides.count)"
                        : "Enter the app")
                }
                .padding(.top, 20)
                .padding(.bottom, 52)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.10, green: 0.10, blue: 0.09).opacity(0),
                            Color(red: 0.10, green: 0.10, blue: 0.09)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
    }
}

// MARK: - OnboardingSlideView

private struct OnboardingSlideView: View {
    let slide: OnboardingSlide

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Rob8View(mood: slide.mood, size: 120)
                .padding(.bottom, 32)
                .accessibilityHidden(true)

            Text(slide.tag)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .tracking(3)
                .padding(.bottom, 10)
                .accessibilityHidden(true)

            Text(slide.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
                .accessibilityAddTraits(.isHeader)

            Text(slide.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.65))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 36)
                .padding(.bottom, 20)

            Text(slide.detail)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
                .padding(.horizontal, 36)

            Spacer()
            Color.clear.frame(height: 160)
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    OnboardingView(isOnboarded: .constant(false))
}
