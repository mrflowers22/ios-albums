//
//  AlbumController.swift
//  AlbumHWRepeat
//
//  Created by Michael Flowers on 6/17/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation

class AlbumController {
    
    var albums: [Album] = []
    let baseURL = URL(string: "https://albums-9e167.firebaseio.com/")!
    typealias CompletionHandler = (Error?) -> Void
    
    func createAlbum(artist: String, name: String, genres: [String], coverArt: [URL], songs: [Song]){
    let newAlbum = Album(artist: artist, name: name, genres: genres, coverArt: coverArt, songs: songs)
        albums.append(newAlbum)
        //call the put function so the new Album gets saved to the api
        put(album: newAlbum)
    }
    
    func createSong(name: String, duration: String) -> Song {
        let newSong = Song(name: name, duration: duration)
        return newSong
    }
    
    func update(album: Album, newArtist: String, newName: String, NewGenres: [String], newCoverArt: [URL], newSongs: [Song] ){
        guard let index = albums.firstIndex(of: album) else { print("Error with updating function"); return }
        albums[index].artist = newArtist
        albums[index].name = newName
        albums[index].genres = NewGenres
        albums[index].coverArt = newCoverArt
        albums[index].songs = newSongs
        put(album: albums[index])
    }
    
    func testDecodingExampleAlbum(){
        guard let bundleData = Bundle.main.url(forResource: "exampleAlbum", withExtension: "json") else { print("Error with bundle") ; return }
        do {
            let decode = JSONDecoder()
            let data = try! Data(contentsOf: bundleData)
            let song = try decode.decode(Album.self, from: data)
            print("this is the song: \(song.artist)")
        } catch  {
            print("this is the error: \(error.localizedDescription), this is a better definition: \(error)")
        }
    }
    
    func testEncodingExampleAlbum(){
        guard let bundleData = Bundle.main.url(forResource: "exampleAlbum", withExtension: "json") else { print("Error with bundle") ; return }
        do {
            let decode = JSONDecoder()
            let data = try! Data(contentsOf: bundleData)
            let song = try decode.decode(Album.self, from: data)
            let jsonEncode = JSONEncoder()
            jsonEncode.outputFormatting = [.prettyPrinted, .sortedKeys]
          let songData = try jsonEncode.encode(song)
            let songString = String(data: songData, encoding: .utf8)!
            print("songString: \(songString)")
        } catch  {
            print("this is the error: \(error.localizedDescription), this is a better definition: \(error)")
        }
    }

    func getAlbums(completion: @escaping CompletionHandler = {_ in }){
        let url = baseURL.appendingPathExtension("json")
        let requestURL = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("This is the status code for fetching albums: \(response.statusCode)")
            }
            
            if let error = error {
                print("Error with network call getting albums: \(error.localizedDescription), better description \(error)")
                completion(error)
                return
            }
            
            guard let data = data else { print("Error with data fetching from server"); completion(NSError()); return }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let albumDictionary = try jsonDecoder.decode([ String: Album ].self, from: data)
                self.albums = Array(albumDictionary.values)
            } catch {
                print("Error decoding data: \(error.localizedDescription), detailed description of error: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
    func put(album: Album, completion: @escaping CompletionHandler = {_ in }){
        let albumId = album.id.uuidString
        let url = baseURL.appendingPathComponent(albumId).appendingPathExtension("json")
        var requestURL = URLRequest(url: url)
        requestURL.httpMethod = "PUT"
        
        let jE = JSONEncoder()
        do {
           let jsonData =  try jE.encode(album)
            requestURL.httpBody = jsonData
        } catch  {
            print("Error encoding album: \(error.localizedDescription), detailed description of error: \(error)")
            return
        }
        
        //now that we have constructed our urlRequest we can make the network call
        URLSession.shared.dataTask(with: requestURL) { (_, response, error) in
            if let response = response as? HTTPURLResponse {
                print("This is the status code for putting to server: \(response.statusCode)")
            }
            
            if let error = error {
                print("This is the error putting Album to server: \(error.localizedDescription), this is the error with more description: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
    
}
