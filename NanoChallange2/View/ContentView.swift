//
//  ContentView.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 22/05/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pageViewModel = PageViewModel()
    
//TODO: KALO BISA SATU PAGE SATU FUNCTION
    
    var body: some View {
        // TODO: condition di if dan else if sama saja, jadi langsung aja tulis codenya tanpa harus pakai condition if else
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
