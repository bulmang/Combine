//
//  NetworkCallView.swift
//  Basic_Combine
//
//  Created by 하명관 on 2023/09/17.
//

import SwiftUI

struct MoviesView: View {
    @StateObject private var viewModel = MovieViewModel()
    var body: some View {
        List(viewModel.movies) { movie in
            HStack{
                AsyncImage(url: movie.posterURL) { poster in
                    poster
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100)
                } placeholder: {
                    ProgressView()
                        .frame(width: 100)
                }
                VStack(alignment: .leading) {
                    Text(movie.title)
                        .font(.headline)
                    Text(movie.overView)
                        .font(.callout)
                        .lineLimit(3)
                }
                
            }
            
        }
        .onAppear {
            viewModel.fetchInitialData()
            print(viewModel.movies)
            print("HI")
        }
    }
}

struct NetworkCallView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}
