import Combine

public protocol SearchUseCase {
  var album: (MusicEntity.Search.Album.Request)
    -> AnyPublisher<MusicEntity.Search.Album.Response, CompositeErrorRepository> { get }
}
