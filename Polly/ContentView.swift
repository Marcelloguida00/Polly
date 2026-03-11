//
//  ContentView.swift
//  Polly
//

import SwiftUI

// Quale schermata è attiva
enum AppScreen {
    case home, hunger, education, chat
}

struct ContentView: View {
    @StateObject private var game = GameManager()
    @StateObject private var chatVM = ChatViewModel()
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    @State private var screen: AppScreen = .home
    @State private var showSplash: Bool = true

    func navigate(to newScreen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.32)) {
            screen = newScreen
        }
    }

    var body: some View {
        ZStack {

            // ── Schermata attiva
            ZStack {
                switch screen {
                case .home:
                    HomeView(navigate: navigate)
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading),
                            removal:   .move(edge: .leading)
                        ))
                        .zIndex(0)
                case .hunger:
                    NavigationShell(title: "Hungry", onBack: { navigate(to: .home) }) {
                        HungerView()
                            .environmentObject(game)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .trailing)
                    ))
                    .zIndex(1)
                case .education:
                    NavigationShell(title: "Learn", onBack: { navigate(to: .home) }) {
                        EducationView()
                            .environmentObject(game)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal:   .move(edge: .trailing)
                    ))
                    .zIndex(1)
                case .chat:
                    ChatView(vm: chatVM, onBack: { navigate(to: .home) })
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal:   .move(edge: .trailing)
                        ))
                        .zIndex(1)
                }
            }

            // ── Onboarding
            if !isOnboarded && !showSplash {
                OnboardingView(isOnboarded: $isOnboarded)
                    .transition(.opacity)
                    .zIndex(2)
            }

            // ── Splash (sopra tutto)
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .animation(.easeInOut(duration: 0.4), value: isOnboarded)
        .animation(.easeInOut(duration: 0.3), value: game.showOveruseWarning)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - NavigationShell

struct NavigationShell<Content: View>: View {
    let title: String
    let onBack: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.10, green: 0.10, blue: 0.09).ignoresSafeArea()

            VStack(spacing: 0) {
                // Navbar custom
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Home")
                                .font(.system(size: 15))
                        }
                        .foregroundColor(.orange)
                    }
                    Spacer()
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    // Bilanciamento visivo destra
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                    .foregroundColor(.clear)
                    .font(.system(size: 15))
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .background(Color(red: 0.10, green: 0.10, blue: 0.09))

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)

                content
            }
        }
    }
}

#Preview {
    ContentView()
}
