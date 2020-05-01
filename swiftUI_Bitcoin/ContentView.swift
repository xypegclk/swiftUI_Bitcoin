//
//  ContentView.swift
//  swiftUI_Bitcoin
//
//  Created by 薛義郎 on 2020/5/1.
//  Copyright © 2020 薛義郎. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

struct ContentView: View {
    
    @ObservedObject var service = WebSocketService()
    
    var body: some View {
        VStack {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 150))
                .foregroundColor(Color(red: 247 / 255, green: 142 / 255, blue: 26 / 255))
                .padding()
            
            Text("USD")
                .font(.largeTitle)
                .padding()
            
            Text(service.priceResult)
                .font(.system(size: 60))
        }.onAppear {
            self.service.connect()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


