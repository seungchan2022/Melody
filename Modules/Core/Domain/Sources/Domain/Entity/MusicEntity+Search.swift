import Foundation
import MusicKit

// MARK: - MusicEntity.Search

extension MusicEntity {
  public enum Search {
    public enum Album { }
  }
}

extension MusicEntity.Search.Album {
  public struct Request: Equatable, Codable, Sendable {
    public let query: String

    public init(query: String) {
      self.query = query
    }
  }

  public struct Response: Equatable, Codable, Sendable {
    public let albums: MusicItemCollection<Album>
    public let track: MusicItemCollection<Track>?

    public init(
      albums: MusicItemCollection<Album>,
      track: MusicItemCollection<Track>? = .none)
    {
      self.albums = albums
      self.track = track
    }
  }

  public struct Item: Equatable, Codable, Sendable {
    public let album: Album
  }
}

// MARK: - MusicEntity.Search.Album.Composite

extension MusicEntity.Search.Album {
  public struct Composite: Equatable, Codable, Sendable {
    public let request: MusicEntity.Search.Album.Request
    public let response: MusicEntity.Search.Album.Response

    public init(
      request: MusicEntity.Search.Album.Request,
      response: MusicEntity.Search.Album.Response)
    {
      self.request = request
      self.response = response
    }
  }
}
