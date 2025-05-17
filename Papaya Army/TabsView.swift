//
//  TabsView.swift
//  Papaya Army
//
//  Created by 马传智 on 2025/3/14.
//

import SwiftUI

struct TabsView: View {
	@State private var activeTab: TabModel = .schedule
	@State private var cards: [Card] = [
		Card(offset: 0, id: 0, roundIndex: 3),
		Card(offset: 1, id: 1, roundIndex: 2),
		Card(offset: 2, id: 2, roundIndex: 1),
		Card(offset: 3, id: 3, roundIndex: 0),
	]
	var seasonId: String
	var body: some View {
		ZStack {
//			AnimatedBackgroundView()
			
			TabContainer(cards: $cards, selection: $activeTab) {
				GrandPrixSchedulesView(cards: $cards, seasonid: seasonId)
					.tabBarItem(tab: .schedule, selection: $activeTab)
				
				StandingsView(seasonId: seasonId)
					.tabBarItem(tab: .standing, selection: $activeTab)
			}
		}
	}
}

#Preview {
	TabsView(seasonId: "2025")
}
