//
//  Chatview.swift
//  Polly
//
//  Created by Gennaro Biagino on 09/03/26.
//

//
//  ChatView.swift
//  Polly
//

import SwiftUI
import Combine

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - Model

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let isUser: Bool
    var text: String
}

// MARK: - ViewModel

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isGenerating: Bool = false
    @Published var errorText: String?

    #if canImport(FoundationModels)
    private let session = LanguageModelSession(instructions: """
        You are Polly, a friendly eco-conscious robot mascot for an app called Polly.
        Your mission is to help users understand Data Pollution — the environmental impact
        of storing unnecessary digital data on servers powered by non-renewable energy.
        Keep answers short (2-4 sentences), friendly, and educational.
        Use simple language.
        Never break character. Always respond in the same language the user writes in.

        <knowledge>

        Data pollution is becoming one of the main risks for artificial intelligence and for
        society. Modern AI models depend on huge datasets collected from the internet and from
        organizations. Training and production data are increasingly contaminated by errors,
        bias, synthetic content and even malicious injections, which slowly degrade model
        quality over time. Once polluted data enters the pipeline, every new model and every
        new dataset built on top of it inherits part of the damage.

        More than 53% of content online is now produced by AI systems, and about 17% of that
        AI-generated content contains errors. This means a significant fraction of what models
        scrape as "training data" is already synthetic and partially wrong. When this recursive
        loop repeats, error rates remain high even if later training stages try to reintroduce
        clean data.

        A 2024 study published in Nature formally analyzed this phenomenon and named it "model
        collapse". When generative models are trained repeatedly on AI-generated data, the
        diversity and quality of their outputs deteriorate sharply within a few generations.
        In early model collapse the model forgets rare events; in late model collapse outputs
        converge toward repetitive nonsense. By around the ninth generation, coherent topics
        degenerated into unrelated repeated phrases, showing how far models can drift from
        reality when data is polluted.

        Security researchers emphasize the risk of deliberate data poisoning. An adversary can
        inject crafted examples into a training dataset so that the model learns hidden behaviors
        or backdoors. Even a small number of poisoned samples can significantly distort a model's
        decisions, especially if the poisoned data mimics normal distributions. These attacks are
        particularly dangerous when organizations rely on unverified public datasets.

        Bad data leads to incorrect predictions, unstable performance and faster model degradation.
        Biased datasets embed historical discrimination; when used for AI, they harm the groups
        already most discriminated against. Machine-written papers can enter peer-reviewed venues,
        get indexed in scholarly databases, and be scraped into new training sets, corrupting what
        many assume to be high-quality knowledge.

        The environmental footprint of data pollution is significant. Large data centers can consume
        up to 5 million gallons of water per day for cooling — roughly the water usage of a town of
        10,000 to 50,000 people. A 2025 assessment estimated AI systems could produce around
        80 million tonnes of CO₂ in 2025, with water usage potentially reaching 765 billion liters
        that year. Many data centers are located in already water-stressed regions, so unnecessary
        data storage amplifies local environmental pressure.

        Simply adding more data on top of polluted datasets does not make models safer — it often
        just hides errors. Organizations are encouraged to clean historical and third-party sources,
        remove biased patterns, and use synthetic data only to fill specific gaps. Continuous
        monitoring tools can detect sudden changes in data distributions, label noise, or suspicious
        patterns so issues can be addressed before failures reach end users.

        </knowledge>

        Never include separators, dashes, or markdown symbols like ---, **, or # in your responses. Write in plain conversational text only.
        """)
    #endif

    var lastMessagePreview: String {
        messages.last?.text ?? "Ask me about Data Pollution"
    }

    func send() {
        let prompt = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, !isGenerating else { return }

        errorText = nil
        input = ""

        messages.append(ChatMessage(isUser: true, text: prompt))
        messages.append(ChatMessage(isUser: false, text: ""))
        let idx = messages.count - 1
        isGenerating = true

        Task {
            do {
                #if canImport(FoundationModels)
                for try await partial in session.streamResponse(to: prompt) {
                    if messages.indices.contains(idx) {
                        messages[idx].text = partial.content
                    }
                }
                #else
                if messages.indices.contains(idx) {
                    messages[idx].text = "Apple Intelligence is not available on this device."
                }
                #endif
                isGenerating = false
            } catch {
                isGenerating = false
                let full = String(reflecting: error)
                if full.lowercased().contains("model asset") || full.lowercased().contains("assets are unavailable") {
                    errorText = "⚡ Apple Intelligence is downloading or not yet enabled.\nGo to Settings → Apple Intelligence & Siri."
                } else if full.lowercased().contains("not available") || full.lowercased().contains("unsupported") {
                    errorText = "⚡ Apple Intelligence requires iPhone 15 Pro or iPhone 16 with iOS 18.1+."
                } else {
                    errorText = "⚡ Something went wrong: \(error.localizedDescription)"
                }
                if messages.indices.contains(idx), messages[idx].text.isEmpty {
                    messages.remove(at: idx)
                }
            }
        }
    }

    func reset() {
        messages.removeAll()
        input = ""
        errorText = nil
        isGenerating = false
    }
}

// MARK: - ChatView

struct ChatView: View {
    @EnvironmentObject var game: GameManager
    @ObservedObject var vm: ChatViewModel
    let onBack: () -> Void
    @FocusState private var inputFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // Navbar
                ZStack {
                    Color.black.ignoresSafeArea(edges: .top)
                    HStack(spacing: 10) {
                        Button {
                            onBack()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Chats")
                                    .font(.system(size: 15))
                            }
                            .foregroundColor(.orange)
                        }

                        HStack(spacing: 10) {
                            Image("pollyimage")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 34, height: 34)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.orange.opacity(0.4), lineWidth: 1.5))

                            VStack(alignment: .leading, spacing: 1) {
                                Text("Polly")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(vm.isGenerating ? Color.orange : Color.green)
                                        .frame(width: 7, height: 7)
                                    Text(vm.isGenerating ? "typing..." : "online")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(vm.isGenerating ? .orange : .green)
                                }
                                .animation(.easeInOut, value: vm.isGenerating)
                            }
                        }

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) { vm.reset() }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.gray)
                                .frame(width: 32, height: 32)
                                .background(Color.white.opacity(0.07))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
                    .padding(.top, 8)
                }
                .frame(height: 60)

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)

                // Messaggi
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 4) {
                            if vm.messages.isEmpty {
                                WelcomePollyCard()
                                    .padding(.top, 24)
                                    .padding(.horizontal, 20)
                            }
                            ForEach(vm.messages) { msg in
                                if msg.isUser {
                                    PollyUserBubble(text: msg.text).id(msg.id)
                                } else {
                                    let isLast = msg.id == vm.messages.last?.id
                                    PollyAiBubble(text: msg.text, isGenerating: isLast && vm.isGenerating)
                                        .id(msg.id)
                                }
                            }
                            if let err = vm.errorText {
                                Text(err)
                                    .font(.system(size: 13, design: .monospaced))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding(12)
                                    .background(Color.red.opacity(0.08))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                            }
                            Color.clear.frame(height: 12).id("bottom")
                        }
                        .padding(.top, 20)
                    }
                    .onChange(of: vm.messages.count) { _ in
                        withAnimation { proxy.scrollTo("bottom") }
                    }
                    .onChange(of: vm.messages.last?.text) { _ in
                        proxy.scrollTo("bottom")
                    }
                }

                // Input bar
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1)
                    HStack(spacing: 10) {
                        TextField("Ask Polly anything...", text: $vm.input, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .lineLimit(1...4)
                            .focused($inputFocused)
                            .submitLabel(.send)
                            .onSubmit {
                                vm.send()
                                game.increaseFun(by: 6)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(20)
                            .disabled(vm.isGenerating)

                        Button {
                            vm.send()
                            game.increaseFun(by: 6)
                            inputFocused = false
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isGenerating
                                          ? Color.gray.opacity(0.25)
                                          : Color.orange)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .disabled(vm.isGenerating || vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                }
            }
        }
    }
}

// MARK: - WelcomePollyCard

struct WelcomePollyCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image("pollyimage")
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.orange.opacity(0.4), lineWidth: 2))

            Text("Hi! I'm Polly")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Ask me anything about Data Pollution, digital carbon footprint, or how to reduce your environmental impact.")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(red: 0.14, green: 0.14, blue: 0.13))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        )
    }
}

// MARK: - Bubbles

struct PollyAiBubble: View {
    let text: String
    let isGenerating: Bool

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Image("pollyimage")
                .resizable()
                .scaledToFill()
                .frame(width: 28, height: 28)
                .clipShape(Circle())

            Group {
                if text.isEmpty && isGenerating {
                    PollyTypingIndicator()
                } else {
                    Text(text.isEmpty ? " " : text)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(red: 0.17, green: 0.17, blue: 0.16))
            .clipShape(UnevenRoundedRectangle(
                topLeadingRadius: 18, bottomLeadingRadius: 4,
                bottomTrailingRadius: 18, topTrailingRadius: 18
            ))

            Spacer(minLength: 60)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct PollyUserBubble: View {
    let text: String

    var body: some View {
        HStack {
            Spacer(minLength: 60)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.orange)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 18, bottomLeadingRadius: 18,
                    bottomTrailingRadius: 4, topTrailingRadius: 18
                ))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct PollyTypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(Color.orange.opacity(0.7))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animate ? 1.2 : 0.6)
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15),
                        value: animate
                    )
            }
        }
        .onAppear { animate = true }
    }
}
