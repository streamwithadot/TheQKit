//
//  TQKProfanityFilter.swift
//  Pods
//
//  Created by Jonathan Spohn on 11/20/19.
//

import Foundation

class TQKProfanityResources {
    
    class func profanityFileURL() -> URL? {
        return TheQKit.bundle.url(forResource: "TQKProfanity", withExtension: "json")
    }
}

struct TQKProfanityDictionary {
    
    static let profaneWords: Set<String> = {
        
        guard let fileURL = TQKProfanityResources.profanityFileURL() else {
            return Set<String>()
        }
        
        do {
            let fileData = try Data(contentsOf: fileURL, options: NSData.ReadingOptions.uncached)
            
            guard let words = try JSONSerialization.jsonObject(with: fileData, options: []) as? [String] else {
                return Set<String>()
            }
            
            return Set(words)
            
        } catch {
            return Set<String>()
        }
    }()
}


public extension String {
    
    public func profaneWords() -> Set<String> {
        
        var delimiterSet = CharacterSet()
        delimiterSet.formUnion(CharacterSet.punctuationCharacters)
        delimiterSet.formUnion(CharacterSet.whitespacesAndNewlines)
        
        let words = Set(self.lowercased().components(separatedBy: delimiterSet))
        
        return words.intersection(TQKProfanityDictionary.profaneWords)
    }
    
    public func containsProfanity() -> Bool {
        return !profaneWords().isEmpty
    }
    
  
}


