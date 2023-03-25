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
    var pen: UIColor
    var divider: UIColor
}

extension CardColor {
    static let colors: [CardColor] = [
        CardColor(
            background: UIColor(named: "orange-bg")!,
            text: UIColor(named: "orange-text")!,
            pen: UIColor(named: "orange-pen")!,
            divider: UIColor(named: "orange-divider")!
        ),
        CardColor(
            background: UIColor(named: "yellow-bg")!,
            text: UIColor(named: "yellow-text")!,
            pen: UIColor(named: "yellow-pen")!,
            divider: UIColor(named: "yellow-divider")!
        ),
        CardColor(
            background: UIColor(named: "red-bg")!,
            text: UIColor(named: "red-text")!,
            pen: UIColor(named: "red-pen")!,
            divider: UIColor(named: "red-divider")!
        ),
        CardColor(
            background: UIColor(named: "pink-bg")!,
            text: UIColor(named: "pink-text")!,
            pen: UIColor(named: "pink-pen")!,
            divider: UIColor(named: "pink-divider")!
        ),
        CardColor(
            background: UIColor(named: "lime-bg")!,
            text: UIColor(named: "lime-text")!,
            pen: UIColor(named: "lime-pen")!,
            divider: UIColor(named: "lime-divider")!
        ),
        CardColor(
            background: UIColor(named: "emerald-bg")!,
            text: UIColor(named: "emerald-text")!,
            pen: UIColor(named: "emerald-pen")!,
            divider: UIColor(named: "emerald-divider")!
        ),
        CardColor(
            background: UIColor(named: "blue-bg")!,
            text: UIColor(named: "blue-text")!,
            pen: UIColor(named: "blue-pen")!,
            divider: UIColor(named: "blue-divider")!
        ),
        CardColor(
            background: UIColor(named: "violet-bg")!,
            text: UIColor(named: "violet-text")!,
            pen: UIColor(named: "violet-pen")!,
            divider: UIColor(named: "violet-divider")!
        ),
    ]
}
