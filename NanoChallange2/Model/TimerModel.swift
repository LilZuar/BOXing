//
//  TimerModel.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 23/05/24.
//

import SwiftUI

struct TimerModel: View {
    @Binding var timerValue: Int
    var body: some View {
        ZStack{
            Circle()
                .foregroundColor(.red)
                .frame(width: 160, height: 160)
            if timerValue > 15 {
                Text("15")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(Color.white)
            }else{
                Text("\(timerValue)")
                    .font(.system(size: 96, weight: .bold))
                    .foregroundColor(Color.white)
            }
            
        }
        
    }
}

#Preview {
    TimerModel(timerValue: .constant(10))
}
