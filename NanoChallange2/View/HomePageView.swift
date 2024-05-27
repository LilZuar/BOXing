//
//  HomePageView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 22/05/24.
//

import SwiftUI



struct HomePageView: View {
    @ObservedObject var pageViewModel: PageViewModel
    
    let soundEffect = SoundPlayer()

    
    var body: some View {
        ZStack {
            Image("Background")
//                .onAppear{
//                    soundEffect.playSound(soundName: "Backsound", soundExtension: "mp3")
//                }
                .ignoresSafeArea(.all)
            VStack{
                Button(action: {
                    withAnimation {
                        pageViewModel.currentPage = PageType.gamePage
                    }
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                        Text("Start Game")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color.white)
                        
                    }
                })
                .padding()
                .frame(width: 332, height: 120)
            }
        }
    }
}

#Preview {
    HomePageView(pageViewModel: PageViewModel())
}
