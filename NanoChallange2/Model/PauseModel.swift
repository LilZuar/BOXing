//
//  PauseModel.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 23/05/24.
//

import SwiftUI

struct PauseModel: View {
    var body: some View {
        Image(systemName: "pause.fill")
            .resizable()
            .foregroundColor(.black)
            .frame(width: 80, height: 80)
    }
}

#Preview {
    PauseModel()
}
