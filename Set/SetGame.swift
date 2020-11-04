//
//  SetGame.swift
//  Set
//
//  Created by Dean Stratakos on 4/3/20.
//  Copyright © 2020 Dean Stratakos. All rights reserved.
//

import Foundation

class SetGame {
    
    var deck = [Card]()
    private(set) var cardsInPlay = [Card?]() // always has length numberOfSpaces
    private(set) var selected = [Card]()
    private(set) var status = Status.neither
    private(set) var highlightDeal = false
    private var debug = false
    lazy private(set) var hintCount = 3
    private(set) var lastMoveHint = false
    var canDealMore: Bool {
        return deck.count > 0 && (cardsInPlay.count > cardsInPlay.compactMap{ $0 }.count || isMatch(cards: selected))
    }
    private var numSetsInPlay: Int {
        return setsInPlay().count
    }
    var canHint: Bool {
        return !gameOver && hintCount > 0
    }
    var gameOver: Bool {
        return deck.count == 0 && numSetsInPlay == 0
    }
    
    func chooseCard(at index: Int) {
        // check if the card is in play
        guard let chosenCard = cardsInPlay[index] else {
            return
        }
        highlightDeal = false
        lastMoveHint = false
        
        if selected.count < 3 {
            select(card: chosenCard)
            if selected.count == 3 {
                if isMatch(cards: selected) {
                    status = .match
                } else {
                    status = .mismatch
                }
            }
        } else if selected.count == 3 {
            if status == .match {
                dealCards(number: 3)
            }
            status = .neither
            selected.removeAll()
            select(card: chosenCard)
        } else {
            assertionFailure("SetGame.chooseCard(at: \(index): too many cards selected.")
        }
    }
    
    func dealCards(number: Int) {
        highlightDeal = false
        lastMoveHint = false
        switch status {
        case .match:
            removeSelectedFromPlay()
            selected.removeAll()
            status = .neither
        case .mismatch:
            selected.removeAll()
            status = .neither
        case .neither:
            break
        }
        
        if !canDealMore { return }
        
        var chosenCards = deck[randomPick: number]
        
        // iterate through game spaces, depositing cards until there are no more
        for index in cardsInPlay.indices {
            if cardsInPlay[index] == nil {
                cardsInPlay[index] = chosenCards.remove(at: 0)
                removeCardsFromDeck(cards: [cardsInPlay[index]!])
            }
            if chosenCards.count == 0 {
                break
            }
        }
    }
    
    // Selects 2 cards that make a set
    func showHint() {
        if debug {
            if status == .match || numSetsInPlay == 0 { dealCards(number: 3); return }
            let hint = setsInPlay()[0]
            for i in 0...2 {
                chooseCard(at: cardsInPlay.firstIndex(of: hint[i])!)
            }
            return
        }
        
        if hintCount <= 0 || lastMoveHint { return }
        lastMoveHint = true
        if status == .match {
            if numSetsInPlay == 1 {
                dealCards(number: 3)
            } else {
                let hint = setsInPlay()[0][randomPick: 2]
                dealCards(number: 3)
                selected = hint
            }
        } else {
            hintCount -= 1
            if numSetsInPlay == 0 {
                selected = []
                highlightDeal = true
            } else {
                selected = setsInPlay()[0][randomPick: 2]
            }
            status = .neither
        }
    }
    
    private func select(card: Card) {
        if !cardsInPlay.contains(card) { return }
        if let cardIndex = selected.firstIndex(of: card) {
            selected.remove(at: cardIndex)
        } else {
            selected.append(card)
        }
    }
    
    private func isMatch(cards: [Card]) -> Bool {
        if cards.count != 3 { return false }
        if Set([cards[0].number, cards[1].number, cards[2].number]).count == 2 { return false }
        if Set([cards[0].shading, cards[1].shading, cards[2].shading]).count == 2 { return false }
        if Set([cards[0].color, cards[1].color, cards[2].color]).count == 2 { return false }
        if Set([cards[0].shape, cards[1].shape, cards[2].shape]).count == 2 { return false }
        return true
    }
    
    private func removeCardsFromDeck(cards: [Card]) {
        for index in 0..<cards.count {
            if let cardToRemoveIndex = deck.firstIndex(of: cards[index]) {
                deck.remove(at: cardToRemoveIndex)
            }
        }
    }
    
    private func removeSelectedFromPlay() {
        for index in 0..<selected.count {
            if let cardIndex = cardsInPlay.firstIndex(of: selected[index]) {
                cardsInPlay[cardIndex] = nil
            } else {
                assertionFailure("SetGame.removeSelectedFromPlay: status = \(status)")
            }
        }
    }
    
    private func setsInPlay() -> [[Card]] {
        var sets = [[Card]]()
        for i in 0..<cardsInPlay.count {
            guard let firstCard = cardsInPlay[i] else { continue }
            for j in (i + 1)..<cardsInPlay.count {
                guard let secondCard = cardsInPlay[j] else { continue }
                for k in (j + 1)..<cardsInPlay.count {
                    guard let thirdCard = cardsInPlay[k] else { continue }
                    let set = [firstCard, secondCard, thirdCard]
                    if isMatch(cards: set) {
                        sets.append(set)
                    }
                }
            }
        }
        return sets
    }
    
    init(numberOfSpaces: Int) {
        // initialize full deck of cards
        for number in [Card.Number.one, Card.Number.two, Card.Number.three] {
            for shading in [Card.Shading.one, Card.Shading.two, Card.Shading.three] {
                for color in [Card.Color.one, Card.Color.two, Card.Color.three] {
                    for shape in [Card.Shape.one, Card.Shape.two, Card.Shape.three] {
                        deck.append(Card(number: number, shading: shading, color: color, shape: shape))
                    }
                }
            }
        }
        cardsInPlay = Array(repeating: nil, count: numberOfSpaces)
        dealCards(number: numberOfSpaces / 2)
    }
}

extension Array {
    subscript(randomPick n: Int) -> [Element] {
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        return Array(copy.suffix(n))
    }
}

enum Status {
    case match, mismatch, neither
}
