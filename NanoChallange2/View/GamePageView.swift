//
//  GamePageView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 23/05/24.
//

import SwiftUI
import Combine

struct GamePageView: View {
    @ObservedObject var pageViewModel: PageViewModel
    @State var timerValue: Int = 20
    @State var timer: AnyCancellable?
    @State var destroyedBox: Int = 0

    var body: some View {
    ZStack{
        
            ZStack {
                ARPageView(timerValue: $timerValue, destroyedBox: $destroyedBox)
                    .ignoresSafeArea(.all)
                
                VStack {
                    HeadBarView(timerValue: $timerValue)
                    
                    Spacer()
                }
                .padding()
                if timerValue > 18{
                    Text("PUNCH THE BOX!!!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                }else if timerValue == 18{
                    Image(systemName: "3.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: 160, height: 160)
                }else if timerValue == 17{
                    Image(systemName: "2.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: 160, height: 160)
                }else if timerValue == 16{
                    Image(systemName: "1.circle")
                        .resizable()
                        .foregroundColor(Color.white)
                        .frame(width: 160, height: 160)
                }else if timerValue <= 0{
                    PopUpFinishView(pageViewModel: pageViewModel, destroyedBox: $destroyedBox)
                }
                
                
            }
        }
        .onAppear {
            startTimer()
        }
        
        
    }
    
    func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            if timerValue > 0 {
                timerValue -= 1
            } else {
                timerValue = 0
            }
        }
    }
    
//    func stopTimer() {
//        timer?.cancel()
//        timer = nil
//    }
}

#Preview {
    GamePageView(pageViewModel: PageViewModel())
}

