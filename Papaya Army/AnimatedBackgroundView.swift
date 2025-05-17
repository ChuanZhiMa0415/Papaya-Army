//
//  AnimatedBackgroundView.swift
//  Papaya Army
//
//  Created by 马传智 on 2025/5/5.
//

import SwiftUI

struct AnimatedBackgroundView: View {
	@State private var colors = MeshGradientData.randomColors()
	private let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()

	var body: some View {
		MeshGradient(width: 4, height: 4, points: MeshGradientData.points, colors: colors)
			.onReceive(timer, perform: { _ in
				withAnimation(.easeInOut(duration: 6)) {
					colors = MeshGradientData.randomColors()
				}
			})
			.ignoresSafeArea()
	}
}

#Preview {
	AnimatedBackgroundView()
}
