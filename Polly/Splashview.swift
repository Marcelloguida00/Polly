//
//  SplashView.swift
//  Polly
//

import SwiftUI

struct SplashView: View {

    @State private var mascotScale:   CGFloat = 0.75
    @State private var mascotOpacity: Double  = 0.0
    @State private var logoOpacity:   Double  = 0.0

    var body: some View {
        ZStack {
            // Sfondo arancione Polly
            Color(hex: "#e67233")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // Mascotte (faccia Rob8)
                SVGWebView(svg: splashMascotSVG)
                    .frame(width: 250, height: 335)
                    .scaleEffect(mascotScale)
                    .opacity(mascotOpacity)

                Spacer()
                

                // Logo scritta "POLY"
                SVGWebView(svg: splashLogoSVG)
                    .frame(width: 220, height: 63)
                    .opacity(logoOpacity)

                Spacer()
            }
        }
        .onAppear { startAnimations() }
    }

    private func startAnimations() {
        // Mascotte entra con spring
        withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
            mascotScale   = 1.0
            mascotOpacity = 1.0
        }
        // Logo fa fade in dopo
        withAnimation(.easeIn(duration: 0.4).delay(0.45)) {
            logoOpacity = 1.0
        }
    }
}

// MARK: - SVG Assets

private let splashMascotSVG = """
<?xml version="1.0" encoding="UTF-8"?>
<svg id="Livello_1" data-name="Livello 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 195.06 286.1">
  <defs>
    <style>
      .cls-1 { fill: #f1edc9; }
      .cls-2 { fill: #363120; }
    </style>
  </defs>
  <path class="cls-2" d="M152.6,128.61c4.97,3.85,8.61,9.63,10.15,15.74.98,3.89.68,6.88.81,10.78.68,21.7.65,44.49,0,66.19-.23,7.77,0,11.55-3.95,18.51-6.48,11.42-16.19,14.17-29.01,14.5-21.86.56-45.59.59-67.39-.26-8.17-.32-14.62-1.22-21.07-6.71-12.51-10.65-9.87-25.63-10.02-40.47-.15-14.85-.49-29.81-.26-44.69.1-6.58-.18-13.46,1.73-19.78,3.44-11.35,13.82-18.81,25.58-19.82h78.04c5.63.99,10.82,2.48,15.4,6.02Z"/>
  <path class="cls-1" d="M66.3,160.53c3.81,0,7.67.26,11.49.2,1.16.18,1.78,1.14,2.05,2.21-.89,15.46-.9,30.92-1.88,46.33-.05.81-.22,2.87-.53,3.49s-1.07,1.24-1.73,1.34c-2.18.35-6.95.16-9.41.16s-7.09.18-9.25-.16c-.97-.15-1.78-1.11-1.97-2.05-.46-2.25-.42-5.79-.54-8.21-.59-12.16-1-24.29-1.4-36.43-.07-2.17-1.25-6.25,2.02-6.71,2.83-.4,8.05-.17,11.13-.17Z"/>
  <path class="cls-1" d="M129.2,160.53c3.81,0,7.67.26,11.49.2,1.16.18,1.78,1.14,2.05,2.21-.89,15.46-.9,30.92-1.88,46.33-.05.81-.22,2.87-.53,3.49s-1.07,1.24-1.73,1.34c-2.16.34-6.81.16-9.25.16s-7.23.19-9.41-.16c-.95-.15-1.8-1.11-1.97-2.05-.64-3.6-.34-8.29-.52-12.01-.6-12.39-1.31-24.86-1.61-37.3.39-1.14.96-1.87,2.21-2.04,2.83-.4,8.05-.17,11.13-.17Z"/>
  <path class="cls-1" d="M85,214.64c1.45-.24,3.19.96,4.6,1.43,4.75,1.58,9.59,1.87,14.47.63,2.73-.7,6.57-3.69,8.52-.68,3.14,4.85-5.49,7.56-8.81,8.19-4.97.95-17.76.71-20.67-4.26-1.16-1.98-.51-4.93,1.88-5.32Z"/>
</svg>
"""

private let splashLogoSVG = """
<?xml version="1.0" encoding="UTF-8"?>
<svg id="Livello_1" data-name="Livello 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 447.6 128.09">
  <defs>
    <style>
      .cls-1 { fill: #ffffff; }
      .cls-2 { fill: #ffffff; }
    </style>
  </defs>
  <path class="cls-2" d="M195.31,11.4c40.91,28.42,34.76,91.08-10.6,111.09-49.15,21.69-101.53-23.14-87.9-74.96C108.02,4.97,158.89-13.89,195.31,11.4ZM155.39,18.36c-33.92,2.39-53.54,40.42-35.68,69.55,18.13,29.56,62.04,28.83,78.93-1.48,17.77-31.89-6.88-70.64-43.26-68.07Z"/>
  <path class="cls-2" d="M0,5.7h49.64c39.85,3.13,42.7,59.28,3.34,66.47-12.22.61-24.52.13-36.76.28v51.67H0V5.7ZM49.35,22.18H16.22v33.79h33.41c2.69,0,8.16-3.08,10.08-5.02,9.89-10.02,3.46-27.38-10.36-28.78Z"/>
  <polygon class="cls-2" points="447.6 5.43 395.32 57.79 395.32 124.96 379.11 124.96 379.11 57.51 327.11 5.43 349.61 5.43 387.11 42.83 387.64 42.59 424.82 5.43 447.6 5.43"/>
  <path class="cls-2" d="M260.01,108.49h60.95v16.48h-76.74s-.42-.39-.42-.42V6.68s.39-.42.42-.42h15.38s.42.39.42.42v101.8Z"/>
  <path class="cls-2" d="M290.76,6.82v69.54h29.91v16.48h-45.71s-.42-.39-.42-.42V6.82h16.22Z"/>
  <path class="cls-1" d="M156.78,50.19c15.09-1.73,21.71,17.46,9.37,25.28-6.02,3.82-13.84,2.33-18.25-3.16-6.45-8.03-1.42-20.94,8.88-22.12Z"/>
</svg>
"""

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)          / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    SplashView()
}

