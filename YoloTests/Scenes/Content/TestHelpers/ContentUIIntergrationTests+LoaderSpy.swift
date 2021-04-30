//
//  ContentUIIntergrationTests+LoaderSpy.swift
//  YoloTests
//
//  Created by Gordon Smith on 30/04/2021.
//

import Foundation
import Yolo
import Combine

class LoaderSpy {
            
    // Content
    var loadContentCallCount: Int {
        contentRequests.count
    }

    private var contentRequests: [PassthroughSubject<(content: Content, comments: [Comment]), Error>] = []
    
    func loadContentPublisher() -> AnyPublisher<(content: Content, comments: [Comment]), Error> {
        let publisher = PassthroughSubject<(content: Content, comments: [Comment]), Error>()
        contentRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func loadContentCompletes(with result: Result<(content: Content, comments: [Comment]), Error>, at index: Int = 0) {
        switch result {
        case let .success(values): contentRequests[index].send(values)
        default: break
        }
    }
    
    // Image Loader
    var imageLoaderURLs: [URL] {
        loadImageRequests.map(\.url)
    }
    
    private(set) var cancelledImageLoaderURLs: [URL] = []
    
    private var loadImageRequests: [(url: URL, publisher: PassthroughSubject<Data, Error>)] = []
    
    func loadImagePublisher(_ imageURL: URL) -> AnyPublisher<Data, Error> {
        let publisher = PassthroughSubject<Data, Error>()
        loadImageRequests.append((imageURL, publisher))
        return publisher
            .handleEvents(receiveCancel: { [weak self] in self?.cancelledImageLoaderURLs.append(imageURL) })
            .eraseToAnyPublisher()
    }
    
    func loadImageCompletes(with result: Result<Data, Error>, at index: Int = 0) {
        switch result {
        case let .success(data): loadImageRequests[index].publisher.send(data)
        case let .failure(error): loadImageRequests[index].publisher.send(completion: .failure(error))
        }
    }
    
    // Interactions
    var interactionRequests: [(id: String, op: Interaction)] {
        return interactionsRequests.map { ($0.id, $0.interaction) }
    }
    
    private var interactionsRequests: [(id: String, interaction: Interaction, publisher: PassthroughSubject<Interactions, Error>)] = []
    
    func toggleInteractionPublisher(id: String, interaction: Interaction) -> AnyPublisher<Interactions, Error> {
        let publisher = PassthroughSubject<Interactions, Error>()
        interactionsRequests.append((id, interaction, publisher))
        return publisher.eraseToAnyPublisher()
    }
    
    func toggleInteractionCompletes(with result: Result<Interactions, Error>, at index: Int = 0) {
        switch result {
        case let .success(value): interactionsRequests[index].publisher.send(value)
        case let .failure(error): interactionsRequests[index].publisher.send(completion: .failure(error))
        }
    }
}
