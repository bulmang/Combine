//
//  MovieViewModel.swift
//  Combine_Practice
//
//  Created by 하명관 on 2023/09/17.
//

import Combine
import Foundation

final class MovieViewModel: ObservableObject {
    @Published var upcomingMovies: [Movie] = []
    @Published var searchQuery = ""
    @Published private var searchResults: [Movie] = []
    
    var movies: [Movie] {
        if searchQuery.isEmpty {
            return upcomingMovies
        } else {
            return searchResults
        }
    }
    
    private var cacnel = Set<AnyCancellable>()
    
    init() {
        $searchQuery
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { searchQuery in
                searchMovies(for: searchQuery)
                    .replaceError(with: MovieResponse(results: []))
            }
            .switchToLatest()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchResults)
    }
    
    func fetchInitialData() {
        fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .replaceError(with: [])
            .assign(to: &$upcomingMovies)
        
// MARK: 다른 방법 1
//            .assign(to: \.movies, on: self)
//            .store(in: &cacnel)

// MARK: 다른 방법 2
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
    // MARK: - 간단한 처리
        .decode(type: MovieResponse.self, decoder: jsonDecoder)
    
    // MARK: 복잡하거나 추가적인 요소를 넣을 때 처리
//        .tryMap { data in
//            let decoded = try jsonDecoder.decode(MovieResponse.self, from: data )
//            return decoded
//        }
}

func searchMovies(for query: String) -> some Publisher<MovieResponse, Error> {
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let url = URL(string:
                    "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery!)")!
    
    return URLSession
        .shared
        .dataTaskPublisher(for: url)
        .map { $0.data }
        .decode(type: MovieResponse.self, decoder: jsonDecoder)
}
