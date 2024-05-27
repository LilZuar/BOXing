//
//  HeadBarView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 24/05/24.
//

import SwiftUI

struct HeadBarView: View {
    @Binding var timerValue: Int
    
    var body: some View {
        HStack(spacing: 100){
            TimerModel(timerValue: $timerValue)
            
            
            Spacer()
            
//            PauseModel()
//                .padding()
        }
        .padding()
        
    }
}

#Preview {
    HeadBarView(timerValue: .constant(10))
}
