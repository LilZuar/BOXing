//
//  PageViewModel.swift
//  NanoChallange2
//
//  Created by Lazuardhi Imani Ahfar on 22/05/24.
//

import SwiftUI


enum PageType{
    case homePage, gamePage
}

@Observable class PageViewModel: ObservableObject{
    var currentPage: PageType = PageType.homePage
}
