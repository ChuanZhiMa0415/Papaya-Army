//
//  SchedulesView.swift
//  Papaya Army
//
//  Created by 马传智 on 2025/3/14.
//

import SwiftUI
import UIKit

struct Card: Identifiable {
	var offset: Double
	let id: Int
	var roundIndex: Int
}

struct GrandPrixSchedulesView: View {
	@Binding var cards: [Card]
	@State private var grandPrixSchedules: [GrandPrixSchedule]? // 每一站的比赛信息
	@State private var dragAmount = CGSize.zero // 拖动的坐标
	@State private var draggingCard: Card? // 拖动的卡片
	@State private var selectedCard: Card? // 弹 sheet 的卡片（控制哪张卡要弹 sheet）
	@State private var isShortPressed = false // 存有没有被短按
	@State private var isLongPressed = false // 存有没有被长按
	@State private var pressedID: Int? // 被按的卡片(控制哪张卡要放大)
	private var fileURL: StorageManager.FileManagers<[GrandPrixSchedule]> {
		StorageManager.FileManagers(filename: "GrandPrixSchedules.json")
	}

	private var grandPrixSchedulesCount: Int {
		grandPrixSchedules?.count ?? 0
	}

	var seasonid: String
	var body: some View {
		ZStack {
			if let grandPrixSchedules {
				// ForEach 的 id：
				// 如果 id 不变 → 认为是同一个视图，属性变化会渐变动画
				// 如果 id 变了 → 认为是新视图，删除旧视图，新建一个视图
				ForEach(cards, id: \.id) { card in
					CardView(gpName: grandPrixSchedules[card.roundIndex].gpName)
						.frame(width: 280, height: 250)
						.scaleEffect(((isLongPressed || isShortPressed) && pressedID == card.id) ? 1.12 : 1)
						.shadow(color: .black, radius: 5)
						.offset(y: card.offset * 5)
						.offset(draggingCard?.id == card.id ? dragAmount : .zero)
						.onLongPressGesture(minimumDuration: 0.3) { // 长按松开后的处理
							withAnimation {
								isLongPressed = true
								selectedCard = card
							}
						} onPressingChanged: { isPressingNow in // 从不按到按走一次，从按到不按走一次，只要按压变了，都会走的
							withAnimation(.spring(response: 0.5, dampingFraction: 2, blendDuration: 0)) {
								if isPressingNow {
									pressedID = card.id
									isShortPressed = true
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
										if isLongPressed {
											triggerHapticFeedback()
										}
									}
								} else {
									isShortPressed = false
								}
							}
						}
						.gesture(
							DragGesture()
								.onChanged {
									dragAmount = $0.translation
									draggingCard = card
								}
								.onEnded { _ in
									withAnimation {
										dragAmount = .zero
										draggingCard = nil

										let cardsCount = cards.count
										var topCard = cards.removeLast()
										topCard.roundIndex = (topCard.roundIndex + cardsCount) % grandPrixSchedulesCount
										cards.insert(topCard, at: cards.startIndex)

										// 改变每张卡片的 offset
										for index in cards.indices {
											cards[index].offset = Double(index) + 1
										}
									}
								}
						)
				}
			} else {
				LottieView(name: .loading, animationSpeed: 0.5, loopMode: .loop)
			}
		}
		.sheet(item: $selectedCard, onDismiss: {
			withAnimation {
				isLongPressed = false
			}
		}, content: { card in
			if let grandPrix = grandPrixSchedules?[card.roundIndex] {
				StagesScheduleView(gpSchedule: grandPrix)
					.presentationBackground(.ultraThinMaterial)
					.presentationDetents([.medium, .large])
			} else {
				LottieView(name: .loading, animationSpeed: 0.5, loopMode: .loop)
			}
		})
		.onAppear {
			Task {
				await loadSchedules()
			}
		}
	}

	/// load gp schedules asyncronously
	func loadSchedules() async {
		if let grandPrixSchedules = fileURL.loadDataFromFileManager() {
			self.grandPrixSchedules = grandPrixSchedules
		}
		grandPrixSchedules = await GrandPrixSchedulesManager.shared.retrieveGrandPrixSchedules()
		if grandPrixSchedules != grandPrixSchedules {
			grandPrixSchedules = grandPrixSchedules
			fileURL.saveDataToFileManager(grandPrixSchedules ?? nil)
		}
	}

	/// 制造手机震动
	func triggerHapticFeedback() {
		let generator = UIImpactFeedbackGenerator(style: .heavy)
		generator.prepare()
		generator.impactOccurred()
	}
}

#Preview {
	GrandPrixSchedulesView(cards: .constant([
		Card(offset: 0, id: 0, roundIndex: 3),
		Card(offset: 1, id: 1, roundIndex: 2),
		Card(offset: 2, id: 2, roundIndex: 1),
		Card(offset: 3, id: 3, roundIndex: 0),
	]), seasonid: "2025")
//	TabsView(seasonId: "2025")
}
