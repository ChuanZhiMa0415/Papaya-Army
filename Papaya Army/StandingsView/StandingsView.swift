//
//  StandingsView.swift
//  Papaya Army
//
//  Created by 马传智 on 2025/3/14.
//

import SwiftUI

enum Standings: String, CaseIterable, Identifiable {
	var id: String {
		self.rawValue
	}

	case drivers
	case constructors
}

struct StandingsView: View {
	var seasonId: String
	private let headerHeight: CGFloat = 60
	@State private var selectedStandings: Standings = .drivers
	var body: some View {
		VStack {
			#warning("not implement yet: hide the header as scroll up, and show the header as scroll down. Might be solution: onScrollGeometryChange / GeometryReader")
			VStack { // header
				Text("Standings")
					.foregroundStyle(.primary.opacity(0.8))
					.font(.title.weight(.bold))

				Picker("Choose you standings", selection: self.$selectedStandings.animation()) {
					ForEach(Standings.allCases) {
						Text($0.rawValue.capitalized).tag($0)
					}
				}
				.pickerStyle(.segmented)
				.padding(.top)
				.frame(width: 300)
			}
			.frame(maxWidth: .infinity)
			.safeAreaPadding(.top, self.headerHeight)

			switch self.selectedStandings {
			case .drivers:
				DriverStandingsView(seasonId: self.seasonId)
			case .constructors:
				ConstructorStandingsView()
			}
		}
	}
}

#Preview {
//	StandingsView(seasonId: "2025")
	TabsView(seasonId: "2025")
}
