//
//  Card.swift
//  Koodos
//
//  Created by Dimas on 23/03/23.
//

import UIKit

struct Card {
    var emoji: String
    var title: String
    var color: CardColor
    
    static let emojis = [
        "emoji-star",
        "emoji-love",
        "emoji-laughing",
        "emoji-100",
        "emoji-heart"
    ]
    
    static let titles = [
        "You Are\nAwesome!",
        "Thank You!",
        "You Are\nThe Best!"
    ]
    
    private let compactTitles = Card.emojis.map { "\($0)-compact" }
    
    private init(emoji: String, title: String, color: CardColor) {
        self.emoji = emoji
        self.title = title
        self.color = color
    }
    
    init() {
        self.emoji = Card.emojis.randomElement()!
        self.title = Card.titles.randomElement()!
        self.color = CardColor.colors.randomElement()!
    }
    
    static func random() -> Card {
        let randomEmoji = Card.emojis.randomElement()!
        let randomTitle = Card.titles.randomElement()!
        let randomColor = CardColor.colors.randomElement()!
        
        return Card(emoji: randomEmoji, title: randomTitle, color: randomColor)
    }
}
