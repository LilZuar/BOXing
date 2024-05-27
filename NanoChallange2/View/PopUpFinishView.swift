//
//  PopUpFinishView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 26/05/24.
//

import SwiftUI

struct PopUpFinishView: View {
    @ObservedObject var pageViewModel: PageViewModel
    @Binding var destroyedBox: Int


    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 30)
                .frame(width: 480, height: 640)
                .foregroundColor(Color(red: 0.573, green: 0.061, blue: 0.131))
            VStack {
                Spacer()
                ZStack{
                    RoundedRectangle(cornerRadius: 30)
                        .frame(width: 400, height: 320)
                        .foregroundColor(Color(red: 0.908, green: 0.849, blue: 0.794))
                    VStack {
                        Text("Destroyed Box :")
                            .font(.system(size: 40))
                            .padding()
                        
                        
                        Text("\(destroyedBox)")
                            .font(.system(size: 40, weight: .bold))
                            .padding()
                    }
                    
                }
                .padding()
                
//                Spacer()
                
                Button(action: {
                    withAnimation {
                        pageViewModel.currentPage = PageType.homePage
                    }
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                        Text("Exit")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(Color.white)
                        
                    }
                })
                .padding()
                .frame(width: 300, height: 100)
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    PopUpFinishView(pageViewModel: PageViewModel(), destroyedBox: .constant(5))
}
