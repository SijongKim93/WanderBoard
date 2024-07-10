//
//  SignInWithKakao.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import SwiftUI

struct PageControlButton: View {
    @State private var selectedIndex = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    var onIndexChanged: ((Int) -> Void)?
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                ZStack {
                    if selectedIndex == index {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("PageCtrlSelectedBG"))
                            .opacity(1)
                            .frame(width: widthForIndex(index), height: 35)
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)) // 상하 3, 좌우 4의 패딩
                        
                        HStack {
                            Image(systemName: iconName(for: index))
                                .foregroundColor(Color("textColor"))
                                .font(.system(size: 17)) // 아이콘 크기 설정
                                .frame(width: 17, height: 17) // 아이콘 크기 설정
//                            Spacer().frame(width: 5) // 아이콘과 텍스트 간격
//                            Text(title(for: index))
//                                .foregroundColor(Color("textColor"))
//                                .font(.system(size: 11)) // 텍스트 크기 설정
                        }
                        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)) // 상하좌우 5의 패딩
                    } else {
                        Image(systemName: iconName(for: index))
                            .foregroundColor(Color.darkgray)
                            .font(.system(size: 17)) // 아이콘 크기 설정
                            .frame(width: 17, height: 17) // 아이콘 크기 설정
                    }
                }
                .frame(width: selectedIndex == index ? widthForIndex(index) : 50, height: 50) // 선택되지 않은 버튼의 크기 고정
                .background(Color.clear)
                .clipShape(Capsule())
                .disabled(selectedIndex == index)
                .onTapGesture {
                    guard selectedIndex != index else { return }
                    withAnimation(.interactiveSpring) {
                        selectedIndex = index
                    }
                    hapticFeedback.impactOccurred()
                    onIndexChanged?(index)
                }
            }
        }
        .frame(width: 160, height: 44) // HStack의 크기를 고정
        .background(Color("BackgroundColor"))
        .clipShape(Capsule())
        .shadow(color: .pageCtrlShadow, radius: 4, x: 0, y: 4)
        .padding()
        .gesture(
            DragGesture().updating($dragOffset, body: { value, state, _ in
                state = value.translation.width
            }).onEnded { value in
                let threshold: CGFloat = 45
                if value.translation.width < -threshold {
                    selectedIndex = min(selectedIndex + 1, 2)
                } else if value.translation.width > threshold {
                    selectedIndex = max(selectedIndex - 1, 0)
                }
                hapticFeedback.impactOccurred()
                onIndexChanged?(selectedIndex)
                NotificationCenter.default.post(name: .didChangePage, object: nil, userInfo: ["selectedIndex": selectedIndex])
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: .didChangePage)) { notification in
            if let index = notification.userInfo?["selectedIndex"] as? Int {
                withAnimation(.interactiveSpring) {
                    selectedIndex = index
                }
            }
        }
    }
    
    private func widthForIndex(_ index: Int) -> CGFloat {
        switch index {
            case 0: return 50
            case 1: return 50
            case 2: return 50
            default: return 50
        }
    }
    
    private func iconName(for index: Int) -> String {
        switch index {
            case 0: return "globe.americas"
            case 1: return "square.on.square"
            case 2: return "gearshape"
            default: return ""
        }
    }
    
//    private func title(for index: Int) -> String {
//        switch index {
//            case 0: return "Wander Board"
//            case 1: return "My Board"
//            case 2: return "Settings"
//            default: return ""
//        }
//    }
}

#Preview {
    PageControlButton()
}
