//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Максим Лозебной on 22.09.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

private let imdbKey = "k_zcuw1ytf"
private let imdbUrl = "https://tv-api.com/en/API/Top250Movies/"

struct MoviesLoader: MoviesLoading {
    private let networkClient = NetworkClient()
    private var popularMoviesUrl: URL {
        guard let url = URL(string: "\(imdbUrl)\(imdbKey)") else {
            preconditionFailure("Unable to construct mostPopularMoviesUrl")
        }
        
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
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
