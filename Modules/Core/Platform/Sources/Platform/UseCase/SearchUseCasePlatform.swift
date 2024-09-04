import Combine
import Domain
import MusicKit

// MARK: - SearchUseCasePlatform

public struct SearchUseCasePlatform {
  public init() { }
}

// MARK: SearchUseCase

extension SearchUseCasePlatform: SearchUseCase {
  public var album: (MusicEntity.Search.Album.Request) -> AnyPublisher<
    MusicEntity.Search.Album.Response,
    CompositeErrorRepository
  > {
    { req in
      Future<MusicEntity.Search.Album.Response, CompositeErrorRepository> { promise in
        Task {
          do {
            var request = MusicCatalogSearchRequest(term: req.query, types: [Album.self])
            request.limit = 5
            let response = try await request.response()

            let albumItemList = response.albums

            let searchResponse = MusicEntity.Search.Album.Response(albums: albumItemList)
            return promise(.success(searchResponse))

          } catch {
            return promise(.failure(.other(error)))
          }
        }
      }
      .eraseToAnyPublisher()
    }
  }
}
