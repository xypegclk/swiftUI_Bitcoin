//
//  WebSocketService.swift
//  swiftUI_Bitcoin
//
//  Created by 薛義郎 on 2020/5/1.
//  Copyright © 2020 薛義郎. All rights reserved.
//

import Foundation
import Combine

class WebSocketService: ObservableObject {
    
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask? = nil
    
    private let baseURL = URL(string: "wss://ws.finnhub.io?token=bqlfl4nrh5rfdbi8o5fg")!
    
    let didChange = PassthroughSubject<Void, Never>()
    @Published var price: String = ""
    
    private var cancellable: AnyCancellable? = nil
    
    var priceResult: String = "" {
        didSet {
            didChange.send()
        }
    }
    
    init() {
        cancellable = AnyCancellable($price
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.priceResult, on: self))
    }
    
    func connect() {
        
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        
        sendMessage()
        receiveMessage()
    }
    
    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    private func sendMessage() {
        
        let string = "{\"type\":\"subscribe\",\"symbol\":\"BINANCE:BTCUSDT\"}"
        
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket could not send messae because: \(error)")
            }
        }
    }
    
    private func receiveMessage() {
        
        webSocketTask?.receive { [weak self] result in
            
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case.success(.string(let str)):
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIRespone.self, from: Data(str.utf8))
                    DispatchQueue.main.async {
                        self?.price = "\(result.data[0].p)"
                    }
                }catch {
                    print("error is \(error.localizedDescription)")
                }
                
                self?.receiveMessage()
                
            default:
                print("default")
            }
        }
    }
}

struct APIRespone: Codable {
    
    var data: [PriceData]
    var type: String
    
    private enum codingKeys: String, CodingKey {
        case data, type
    }
}

struct PriceData: Codable{
 
    public var p: Float
 
    private enum CodingKeys: String, CodingKey {
        case p
    }
}
