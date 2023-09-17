//
//  MovieViewModel.swift
//  Combine_Practice
//
//  Created by 하명관 on 2023/09/17.
//

import Combine
import Foundation

final class MovieViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    
    func fetchInitialData() {
        fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
//            .assign(to: \.movies, on: self)
//            .store(in: &cancellables)
            .assign(to: &$movies)
            
//            .sink { completion in
//                switch completion {
//                case .finished:()
//                case .failure(let error):
//                    print(error.localizedDescription)
//                }
//            } receiveValue: { [weak self] movies in
//                self?.movies = movies
//            }
//            .store(in: &cancellables)
    }
}

let apiKey = "83f27c2842e3896887360183f6b032c2"

func fetchMovies() -> some Publisher<MovieResponse, Error> {
    let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)")!
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MovieResponse.self, decoder: jsonDecoder)
}
