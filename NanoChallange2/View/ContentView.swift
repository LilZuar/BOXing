//
//  ContentView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 22/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pageViewModel = PageViewModel()
    

    
    var body: some View {
        if pageViewModel.currentPage == PageType.homePage {
            HomePageView(pageViewModel: pageViewModel)
        }else if pageViewModel.currentPage == PageType.gamePage{
            GamePageView(pageViewModel: pageViewModel)
        }
    }
}

#Preview {
    ContentView()
}
