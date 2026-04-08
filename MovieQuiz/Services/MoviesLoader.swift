//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 22.09.2025.
//

import Foundation

// MARK: - Alias

typealias MostPopularMoviesCompletion = (Result<MostPopularMovies, Error>) -> Void

// MARK: - MoviesLoading

protocol MoviesLoading {
    func loadMovies(handler: @escaping MostPopularMoviesCompletion)
}

struct MoviesLoader: MoviesLoading {
    
    // MARK: - Properties
    
    private let networkClient: NetworkRouting
    private static let imdbKey = "k_zcuw1ytf"
    private static let imdbUrl = "https://tv-api.com/en/API/Top250Movies/"
    
    private var popularMoviesUrl: URL {
        guard let url = URL(string: "\(MoviesLoader.imdbUrl)\(MoviesLoader.imdbKey)") else {
            preconditionFailure("Unable to construct popularMoviesUrl")
        }
        
        return url
    }
    
    // MARK: - Init
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - Load Movies
    
    func loadMovies(handler: @escaping MostPopularMoviesCompletion) {
        print("loadMovies called, url:", popularMoviesUrl)
        
        networkClient.fetch(url: popularMoviesUrl) { result in
            switch result {
            case .success(let data):
                do {
                    let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                    handler(.success(mostPopularMovies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
