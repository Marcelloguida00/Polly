//
//   EducationView.swift
//  Polly
//
//  Created by Gennaro Biagino on 03/03/26.
//

import SwiftUI

struct Quiz: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct EducationView: View {
    @EnvironmentObject var game: GameManager
    @State private var quizIndex: Int = 0
    @State private var selected: Int? = nil
    @State private var score: Int = 0
    @State private var initialized: Bool = false
    @State private var sessionQuizzes: [Quiz] = []
    @State private var correctThisSession: Int = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    let allQuizzes: [Quiz] = [
        .init(question: "How much CO₂ does 3 hours of HD YouTube streaming produce?",
              options: ["5 g", "7 g", "35 g", "150 g"], correctIndex: 2,
              explanation: "HD streaming emits ~35g CO₂ per 3 hours due to data center energy use."),
        .init(question: "What share of global electricity do data centers consume?",
              options: ["1%", "3%", "10%", "25%"], correctIndex: 1,
              explanation: "Data centers use ~3% of global electricity — similar to the aviation industry."),
        .init(question: "How much CO₂ does sending one email with attachment produce?",
              options: ["0.3 g", "4 g", "12 g", "50 g"], correctIndex: 1,
              explanation: "A typical email with an attachment generates about 4g of CO₂."),
        .init(question: "Which country hosts the most data centers?",
              options: ["China", "Germany", "USA", "India"], correctIndex: 2,
              explanation: "The USA hosts the largest share of the world's data centers."),
        .init(question: "How much CO₂ does a single Google search produce?",
              options: ["0.2 g", "1 g", "5 g", "20 g"], correctIndex: 0,
              explanation: "A single Google search produces about 0.2g of CO₂."),
        .init(question: "What percentage of global CO₂ emissions come from the ICT sector?",
              options: ["0.5%", "2%", "4%", "10%"], correctIndex: 2,
              explanation: "The ICT sector accounts for about 4% of global CO₂ emissions — and growing."),
        .init(question: "How much water do data centers use globally per year?",
              options: ["100 million liters", "1 billion liters", "Hundreds of billions of liters", "1 trillion liters"], correctIndex: 2,
              explanation: "Data centers use hundreds of billions of liters of water annually for cooling."),
        .init(question: "Which activity produces the most digital carbon footprint per hour?",
              options: ["Browsing websites", "Sending emails", "Video conferencing", "Playing online games"], correctIndex: 2,
              explanation: "Video conferencing requires constant data transfer and produces more CO₂ than browsing."),
        .init(question: "What is 'dark data'?",
              options: ["Encrypted files", "Data stored on dark web", "Unused data consuming storage energy", "Classified government data"], correctIndex: 2,
              explanation: "Dark data is information collected but never used, wasting energy just by being stored."),
        .init(question: "How much of stored enterprise data is estimated to be 'dark data'?",
              options: ["10%", "33%", "52%", "80%"], correctIndex: 2,
              explanation: "Gartner estimates that 52% of enterprise data is 'dark' — collected but never analyzed."),
        .init(question: "What is the carbon footprint of training a large AI model?",
              options: ["1 kg CO₂", "10 kg CO₂", "100 kg CO₂", "300+ tonnes CO₂"], correctIndex: 3,
              explanation: "Training a large AI model like GPT-3 can emit over 300 tonnes of CO₂."),
        .init(question: "Which type of email contributes most to collective digital pollution?",
              options: ["Spam", "Business emails", "Newsletter subscriptions", "Attachments over 10MB"], correctIndex: 0,
              explanation: "Over 45% of all emails are spam, wasting enormous energy resources globally."),
        .init(question: "How many emails are sent globally every day?",
              options: ["1 billion", "50 billion", "300 billion", "1 trillion"], correctIndex: 2,
              explanation: "Approximately 300 billion emails are sent every day worldwide."),
        .init(question: "What does 'digital sobriety' mean?",
              options: ["Avoiding social media", "Reducing unnecessary digital consumption", "Using only open-source software", "Switching to offline work"], correctIndex: 1,
              explanation: "Digital sobriety means being mindful of our digital consumption to reduce its environmental impact."),
        .init(question: "Approximately how many smartphones are discarded globally each year?",
              options: ["10 million", "100 million", "1.5 billion", "5 billion"], correctIndex: 2,
              explanation: "About 1.5 billion smartphones are replaced each year, creating enormous e-waste."),
        .init(question: "Which is more energy-efficient for video calls?",
              options: ["Camera on always", "Camera off when not presenting", "Using 4K quality", "Recording every session"], correctIndex: 1,
              explanation: "Turning your camera off during video calls can reduce your footprint by up to 96%."),
        .init(question: "How much CO₂ does streaming music for 1 hour produce?",
              options: ["0.2 g", "2 g", "20 g", "200 g"], correctIndex: 1,
              explanation: "Streaming music for 1 hour produces roughly 2g CO₂, mainly from data centers."),
        .init(question: "What is e-waste?",
              options: ["Email spam", "Electronic waste from discarded devices", "Wasted electricity", "Data errors"], correctIndex: 1,
              explanation: "E-waste is discarded electronic devices, which is the world's fastest-growing waste stream."),
        .init(question: "Which country generates the most e-waste per capita?",
              options: ["USA", "China", "Norway", "Australia"], correctIndex: 0,
              explanation: "The USA generates the most e-waste per capita among large nations."),
        .init(question: "How much of global e-waste is formally recycled?",
              options: ["5%", "17%", "40%", "65%"], correctIndex: 1,
              explanation: "Only about 17% of e-waste is formally documented and recycled — the rest is lost."),
        .init(question: "What is the main cause of data center energy consumption?",
              options: ["Employee computers", "Network equipment", "Servers and cooling systems", "LED lighting"], correctIndex: 2,
              explanation: "Servers and their cooling systems account for the vast majority of data center energy use."),
        .init(question: "What is 'data hoarding'?",
              options: ["Buying extra storage", "Keeping unnecessary digital files indefinitely", "Backing up to multiple clouds", "Password protecting all files"], correctIndex: 1,
              explanation: "Data hoarding means keeping files, emails, and media that are never accessed, wasting server energy."),
        .init(question: "Compared to a text site, how much more data does a video-heavy site use?",
              options: ["2x", "10x", "50x", "500x"], correctIndex: 2,
              explanation: "Video-heavy websites consume roughly 50 times more data than text-based equivalents."),
        .init(question: "What percentage of internet traffic is video streaming?",
              options: ["20%", "40%", "60%", "80%"], correctIndex: 2,
              explanation: "Video streaming now accounts for approximately 60% of all internet traffic globally."),
        .init(question: "What is a 'green data center'?",
              options: ["A data center painted green", "A facility using renewable energy and efficient cooling", "A center storing environmental data", "A small local server room"], correctIndex: 1,
              explanation: "Green data centers use renewable energy and optimize cooling to minimize environmental impact."),
        .init(question: "How much CO₂ does one hour of Netflix streaming produce?",
              options: ["3 g", "36 g", "100 g", "500 g"], correctIndex: 0,
              explanation: "One hour of Netflix streaming produces about 3g CO₂ with modern compression technologies."),
        .init(question: "Which action reduces digital carbon footprint the most?",
              options: ["Deleting old emails", "Unsubscribing from newsletters", "Reducing video streaming quality", "All equally effective"], correctIndex: 2,
              explanation: "Reducing video quality has the biggest impact as video drives the majority of data traffic."),
        .init(question: "What does PUE stand for in data centers?",
              options: ["Power Usage Effectiveness", "Processing Unit Efficiency", "Peak Usage Energy", "Primary Utility Estimate"], correctIndex: 0,
              explanation: "PUE (Power Usage Effectiveness) measures how efficiently a data center uses energy."),
        .init(question: "What is a good PUE score for a data center?",
              options: ["Close to 1.0", "Around 2.0", "Above 3.0", "PUE doesn't matter"], correctIndex: 0,
              explanation: "A PUE close to 1.0 is ideal — meaning almost all power goes to computing, not cooling."),
        .init(question: "How many tonnes of CO₂ does the internet produce per year?",
              options: ["10 million", "500 million", "1.6 billion", "10 billion"], correctIndex: 2,
              explanation: "The internet produces approximately 1.6 billion tonnes of CO₂ annually."),
        .init(question: "What is the environmental benefit of turning off unused devices?",
              options: ["Negligible", "Reduces energy use and extends device lifespan", "Only useful for batteries", "Saves bandwidth"], correctIndex: 1,
              explanation: "Powering down unused devices reduces energy consumption and decreases overall carbon emissions."),
        .init(question: "What generates more CO₂ — a physical letter or an email with large attachment?",
              options: ["Physical letter", "Email with large attachment", "They're roughly equal", "Depends on the country"], correctIndex: 1,
              explanation: "A large email attachment can produce more CO₂ than a physical letter when accounting for data center energy."),
        .init(question: "What is 'vampire power' in digital devices?",
              options: ["Malware stealing electricity", "Energy consumed by devices on standby", "Overclocking CPUs", "Power surges"], correctIndex: 1,
              explanation: "Vampire power (standby power) is electricity consumed by devices when switched off but still plugged in."),
        .init(question: "How much of global electricity is wasted by devices in standby mode?",
              options: ["0.1%", "1%", "5%", "10%"], correctIndex: 2,
              explanation: "Standby power accounts for approximately 5-10% of household energy use globally."),
        .init(question: "What is the most eco-friendly way to store data long-term?",
              options: ["External hard drives", "USB flash drives", "Optimized cloud with renewable energy", "Printing everything"], correctIndex: 2,
              explanation: "Cloud storage powered by renewables combined with data minimization is the most sustainable approach."),
        .init(question: "How does 5G compare to 4G in energy efficiency per bit?",
              options: ["5G uses more energy", "Similar consumption", "5G is more efficient per bit", "5G uses 10x more energy"], correctIndex: 2,
              explanation: "5G is designed to be more energy-efficient per bit transferred than 4G, despite more base stations."),
        .init(question: "What is 'digital minimalism' in sustainability context?",
              options: ["Using only essential apps", "Reducing unnecessary digital activities to lower footprint", "Avoiding social media", "Using monochrome displays"], correctIndex: 1,
              explanation: "Digital minimalism means critically reducing our digital footprint to only what's truly necessary."),
        .init(question: "How much CO₂ can be saved annually by turning off a monitor overnight?",
              options: ["0.5 kg", "14 kg", "50 kg", "200 kg"], correctIndex: 1,
              explanation: "Turning off a monitor overnight saves approximately 14 kg of CO₂ per year."),
        .init(question: "What is the carbon footprint of one hour of video conferencing?",
              options: ["3 g", "55 g", "200 g", "1 kg"], correctIndex: 1,
              explanation: "One hour of video conferencing produces approximately 55g CO₂ with camera on."),
        .init(question: "Which tech giant was first to commit to 100% renewable energy?",
              options: ["Microsoft", "Amazon", "Apple", "Google"], correctIndex: 3,
              explanation: "Google achieved 100% renewable energy for global operations in 2017."),
        .init(question: "What is 'scope 3 emissions' in tech companies?",
              options: ["Internal server emissions", "Building heating/cooling", "Indirect emissions from users and supply chain", "CEO travel emissions"], correctIndex: 2,
              explanation: "Scope 3 covers indirect emissions including product use by customers and supply chain manufacturing."),
        .init(question: "How can auto-play in streaming apps worsen digital pollution?",
              options: ["It doesn't affect pollution", "Forces passive viewing, increasing data usage", "Causes server crashes", "Reduces stream quality"], correctIndex: 1,
              explanation: "Auto-play encourages passive viewing, increasing unnecessary data transmission and energy consumption."),
        .init(question: "What is the most effective action to reduce email carbon footprint?",
              options: ["Sending fewer emails", "Using shorter subject lines", "Unsubscribing from unwanted lists", "Avoiding Reply All"], correctIndex: 2,
              explanation: "Unsubscribing from mailing lists prevents thousands of future emails from being sent and stored."),
        .init(question: "How does blockchain technology impact energy consumption?",
              options: ["It always saves energy", "Proof-of-Work blockchains consume enormous electricity", "It's carbon neutral by design", "It uses the same as regular databases"], correctIndex: 1,
              explanation: "Proof-of-Work blockchains like Bitcoin consume more electricity than some entire countries."),
        .init(question: "What does 'serverless computing' mean for sustainability?",
              options: ["No physical servers exist", "Computing resources only used when needed", "Servers powered by solar only", "Data stored locally on devices"], correctIndex: 1,
              explanation: "Serverless computing allocates resources on demand, reducing idle server energy waste."),
        .init(question: "How much data does the average person generate per day?",
              options: ["100 MB", "1 GB", "2.5 GB", "100 GB"], correctIndex: 2,
              explanation: "The average person generates approximately 2.5 GB of data per day in modern digital life."),
        .init(question: "What is 'greenwashing' in the context of tech companies?",
              options: ["Using green color in marketing", "Making false or exaggerated environmental claims", "Installing solar panels", "Offsetting all emissions"], correctIndex: 1,
              explanation: "Greenwashing is when companies exaggerate or falsify their environmental commitments for marketing purposes."),
        .init(question: "How much CO₂ does posting one photo on social media produce?",
              options: ["0.2 g", "0.6 g", "5 g", "20 g"], correctIndex: 1,
              explanation: "A single social media photo post generates about 0.6g CO₂ including upload, storage and views."),
        .init(question: "What is 'edge computing' and how does it help sustainability?",
              options: ["Dangerous computing practice", "Processing data closer to source, reducing data transfer", "Computing at the edge of a network", "Storing data on personal devices only"], correctIndex: 1,
              explanation: "Edge computing processes data near its source, reducing the need to send data to distant data centers."),
        .init(question: "What is the biggest driver of data center growth today?",
              options: ["Social media", "Email services", "AI and machine learning workloads", "Online gaming"], correctIndex: 2,
              explanation: "AI and machine learning are the fastest-growing drivers of data center expansion and energy demand."),
    ]

    var currentQuiz: Quiz {
        guard !sessionQuizzes.isEmpty else { return allQuizzes[0] }
        return sessionQuizzes[min(quizIndex, sessionQuizzes.count - 1)]
    }

    var totalQuestions: Int { sessionQuizzes.count }

    var body: some View {
            VStack(spacing: 20) {

                // Header
                HStack {
                    Rob8View(mood: .curious, size: 48, animate: false)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Data Pollution Quiz")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Q\(min(quizIndex + 1, totalQuestions))/\(totalQuestions) · Score: \(score)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .accessibilityLabel("Question \(min(quizIndex + 1, totalQuestions)) of \(totalQuestions), score \(score)")
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // ── EDUCATION PIENA ──
                if game.education >= 100 {
                    fullEducationView

                // ── QUIZ IN CORSO ──
                } else if quizIndex < totalQuestions {

                    Text(currentQuiz.question)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                        .padding(.horizontal, 20)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(Array(currentQuiz.options.enumerated()), id: \.offset) { index, option in
                        Button {
                            guard selected == nil else { return }
                            selected = index
                            if index == currentQuiz.correctIndex {
                                score += 1
                                correctThisSession += 1
                                let remaining = max(0, 100.0 - game.education)
                                let stepsLeft = max(1, 5 - (correctThisSession - 1))
                                let increment = remaining / Double(stepsLeft)
                                game.increaseEducation(by: increment)
                            }
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(optionTextColor(index))
                                Spacer()
                                if let sel = selected {
                                    if index == currentQuiz.correctIndex {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .accessibilityHidden(true)
                                    } else if index == sel {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .accessibilityHidden(true)
                                    }
                                }
                            }
                            .padding(16)
                            .background(optionBg(index))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(optionBorder(index), lineWidth: 1))
                        }
                        .padding(.horizontal, 20)
                        .disabled(selected != nil)
                        .accessibilityLabel(option)
                        .accessibilityHint(selected == nil ? "Double tap to select this answer" : "")
                        .accessibilityAddTraits(selected == index ? .isSelected : [])
                    }

                    if selected != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(currentQuiz.explanation)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                            Button("Next Question →") {
                                if reduceMotion {
                                    selected = nil; quizIndex += 1
                                } else {
                                    withAnimation { selected = nil; quizIndex += 1 }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .accessibilityLabel("Next question")
                            .accessibilityHint("Go to question \(quizIndex + 2) of \(totalQuestions)")
                        }
                        .padding(16)
                        .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                        .padding(.horizontal, 20)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    }

                // ── QUIZ COMPLETATO (tutte le domande esaurite) ──
                } else {
                    VStack(spacing: 12) {
                        Text("Quiz completato! 🎉")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Hai risposto correttamente a \(score) su \(totalQuestions) domande.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Button("Ricomincia Quiz") {
                            if reduceMotion {
                                startNewSession()
                            } else {
                                withAnimation { startNewSession() }
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .accessibilityLabel("Restart quiz")
                        .accessibilityHint("Shuffles all 50 questions and starts from the beginning")
                    }
                    .padding(16)
                    .background(Color(red: 0.14, green: 0.14, blue: 0.13))
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 20)
        
        .onAppear {
            if !initialized {
                initialized = true
                startNewSession()
            }
        }
    }

    // MARK: - Full Education View
    private var fullEducationView: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 20)

            Rob8View(mood: .curious, size: 120)
                .accessibilityHidden(true)

            VStack(spacing: 10) {
                Text("Polly has learned enough!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("You've already studied today.\nPolly doesn't need to learn more right now.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 6) {
                HStack {
                    Label("EDUCATION", systemImage: "book.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Spacer()
                    Text("100%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.yellow)
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
            .accessibilityLabel("Education stat: 100 percent")

            Text("Come back when Polly gets curious again!")
                .font(.caption)
                .foregroundColor(.yellow.opacity(0.7))

            Spacer().frame(height: 20)
        }
    }

    // MARK: - Helpers
    func randomized(_ q: Quiz) -> Quiz {
        let correct = q.options[q.correctIndex]
        let shuffled = q.options.shuffled()
        let newIndex = shuffled.firstIndex(of: correct) ?? 0
        return Quiz(question: q.question, options: shuffled, correctIndex: newIndex, explanation: q.explanation)
    }

    func startNewSession() {
        correctThisSession = 0
        score = 0
        quizIndex = 0
        selected = nil
        sessionQuizzes = allQuizzes.shuffled().map { randomized($0) }
    }

    func optionBg(_ i: Int) -> Color {
        guard let sel = selected else { return Color(red: 0.14, green: 0.14, blue: 0.13) }
        if i == currentQuiz.correctIndex { return Color(red: 0.10, green: 0.23, blue: 0.16) }
        if i == sel { return Color(red: 0.23, green: 0.10, blue: 0.10) }
        return Color(red: 0.14, green: 0.14, blue: 0.13)
    }

    func optionBorder(_ i: Int) -> Color {
        guard let sel = selected else { return Color.white.opacity(0.08) }
        if i == currentQuiz.correctIndex { return .green }
        if i == sel { return .red }
        return Color.white.opacity(0.08)
    }

    func optionTextColor(_ i: Int) -> Color {
        guard let sel = selected else { return .white }
        if i == currentQuiz.correctIndex { return .green }
        if i == sel { return .red }
        return Color.gray
    }
}

#Preview {
    EducationView().environmentObject(GameManager())
        .background(Color(red: 0.10, green: 0.10, blue: 0.09))
}
