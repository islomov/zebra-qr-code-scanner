//
//  SplashScreenView.swift
//  ZebraCodeScanner
//
//  Created by Sardor Islomov on 27/02/26.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var rotationY: Double = 0
    @State private var rotationX: Double = 0
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var isFinished = false

    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            Image("AppIcon-Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .primary.opacity(0.15), radius: 20, x: 0, y: 10)
                .rotation3DEffect(
                    .degrees(rotationY),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
                .rotation3DEffect(
                    .degrees(rotationX),
                    axis: (x: 1, y: 0, z: 0),
                    perspective: 0.5
                )
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            // Phase 1: Fade in and scale up
            withAnimation(.easeOut(duration: 0.5)) {
                opacity = 1
                scale = 1.0
            }

            // Phase 2: 3D Y-axis rotation
            withAnimation(
                .easeInOut(duration: 0.8)
                .delay(0.4)
            ) {
                rotationY = 360
            }

            // Phase 3: Subtle X-axis tilt for depth
            withAnimation(
                .easeInOut(duration: 0.6)
                .delay(0.8)
            ) {
                rotationX = 15
            }

            // Phase 4: Settle back
            withAnimation(
                .spring(response: 0.4, dampingFraction: 0.6)
                .delay(1.2)
            ) {
                rotationX = 0
            }

            // Phase 5: Finish
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.3)) {
                    isFinished = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onFinished()
                }
            }
        }
    }
}
