//
//  CardColor.swift
//  Koodos
//
//  Created by Dimas on 23/03/23.
//

import UIKit

struct CardColor {
    var background: UIColor
    var text: UIColor
    var divider: UIColor
}

extension CardColor {
    static let colors: [CardColor] = [
        CardColor(
            background: UIColor(named: "orange-bg")!,
            text: UIColor(named: "orange-text")!,
            divider: UIColor(named: "orange-divider")!
        ),
        CardColor(
            background: UIColor(named: "yellow-bg")!,
            text: UIColor(named: "yellow-text")!,
            divider: UIColor(named: "yellow-divider")!
        ),
        CardColor(
            background: UIColor(named: "red-bg")!,
            text: UIColor(named: "red-text")!,
            divider: UIColor(named: "red-divider")!
        ),
        CardColor(
            background: UIColor(named: "pink-bg")!,
            text: UIColor(named: "pink-text")!,
            divider: UIColor(named: "pink-divider")!
        ),
        CardColor(
            background: UIColor(named: "lime-bg")!,
            text: UIColor(named: "lime-text")!,
            divider: UIColor(named: "lime-divider")!
        ),
        CardColor(
            background: UIColor(named: "emerald-bg")!,
            text: UIColor(named: "emerald-text")!,
            divider: UIColor(named: "emerald-divider")!
        ),
        CardColor(
            background: UIColor(named: "blue-bg")!,
            text: UIColor(named: "blue-text")!,
            divider: UIColor(named: "blue-divider")!
        ),
        CardColor(
            background: UIColor(named: "violet-bg")!,
            text: UIColor(named: "violet-text")!,
            divider: UIColor(named: "violet-divider")!
        ),
    ]
}
