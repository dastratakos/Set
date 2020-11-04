//
//  ViewController.swift
//  Set
//
//  Created by Dean Stratakos on 4/2/20.
//  Copyright © 2020 Dean Stratakos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = SetGame(numberOfSpaces: cardButtons.count)

    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var deckButton: UIButton!
    @IBOutlet weak var deckCountLabel: UILabel!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var hintCountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addBackground()
        
        for button in cardButtons {
            button.layer.cornerRadius = 8
            button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            button.layer.borderWidth = 1
            button.setTitle("", for: .normal)
        }
        
        updateViewFromModel()
    }
    
    @IBAction func touchCard(_ sender: UIButton) {
        if game.gameOver { return }
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
            print("Card not in array")
        }
    }
    
    @IBAction func touchNewGame(_ sender: UIButton) {
        game = SetGame(numberOfSpaces: cardButtons.count)
        updateViewFromModel()
    }
    
    @IBAction func touchDeck(_ sender: UIButton) {
        if game.gameOver { return }
        game.dealCards(number: 3)
        updateViewFromModel()
    }
    
    @IBAction func touchHint(_ sender: UIButton) {
        if game.gameOver { return }
        game.showHint()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        let font = UIFont(name: "Trebuchet MS", size: 20.0)
        let metrics = UIFontMetrics(forTextStyle: .body)
        deckCountLabel.font = metrics.scaledFont(for: font!)
        hintCountLabel.font = metrics.scaledFont(for: font!)
        
        deckCountLabel.text = "x \(game.deck.count)"
        deckCountLabel.textColor = !game.canDealMore ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : (game.highlightDeal ? #colorLiteral(red: 0.6323155165, green: 1, blue: 0.7813562751, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        deckButton.tintColor = !game.canDealMore ? #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) : (game.highlightDeal ? #colorLiteral(red: 0.6323155165, green: 1, blue: 0.7813562751, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        
        hintCountLabel.text = "x \(game.hintCount)"
        hintCountLabel.textColor = game.canHint ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        hintButton.tintColor = game.canHint ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        
        let over = game.gameOver
        for index in cardButtons.indices {
            let button = cardButtons[index]
            if over {
                button.setAttributedTitle(NSAttributedString(string: "🏆"), for: .normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                button.flash()
            } else if let card = game.cardsInPlay[index] {
                let selected = game.selected.contains(card)
                let matched = game.status == .match && selected
                let unmatched = game.status == .mismatch && selected
                if matched {
                    button.pulsate()
                    button.backgroundColor = #colorLiteral(red: 0.6323155165, green: 1, blue: 0.7813562751, alpha: 1)
                } else if unmatched {
                    button.shake()
                    button.backgroundColor = #colorLiteral(red: 0.9828143716, green: 0.4827000499, blue: 0.4975417256, alpha: 1)
                } else {
                    button.backgroundColor = selected ? #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0.6311536815, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                }
                button.layer.borderWidth = 0
                button.setAttributedTitle(getText(for: card), for: .normal)
            } else {
                button.layer.borderWidth = 1
                button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
                button.setAttributedTitle(nil, for: .normal)
            }
        }
    }
    
    private let numbers = [1, 2, 3]
    private let shadings = [0, 0.40, 1.0]
    private let colors = [#colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1), #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1), #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)]
    private let shapes = ["▲", "●", "■"]
    
    private func getText(for card: Card) -> NSAttributedString {
        var attributes: [NSAttributedString.Key : Any] = [:]
        var char: String
        var firstChar = ""
        var secondChar = ""
        var thirdChar = ""
        var color: UIColor
        
        switch card.shape {
        case .one: char = shapes[0]
        case .two: char = shapes[1]
        case .three: char = shapes[2]
        }
        
        switch card.number {
        case .three:
            thirdChar = char
            fallthrough
        case .two:
            secondChar = char
            fallthrough
        case .one:
            firstChar = char
        }
        
        switch card.color {
        case .one:
            attributes[.strokeColor] = colors[0]
            color = colors[0]
        case .two:
            attributes[.strokeColor] = colors[1]
            color = colors[1]
        case .three:
            attributes[.strokeColor] = colors[2]
            color = colors[2]
        }
        
        switch card.shading {
        // outline
        case .one: attributes[.strokeWidth] = 5
        // striped
        case .two: attributes[.foregroundColor] =  color.withAlphaComponent(CGFloat(shadings[1]))
        // filled
        case .three:
            attributes[.strokeWidth] = -5
            attributes[.foregroundColor] = color.withAlphaComponent(CGFloat(shadings[2]))
        }
        
        return NSAttributedString(string: "\(firstChar)\(secondChar)\(thirdChar)", attributes: attributes)
    }

}

extension UIView {
    func addBackground() {
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = UIImage(named: "background")

        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}

extension UIButton {
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.5
        pulse.fromValue = 1.05
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 1.0
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: nil)
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.5
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 4, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 4, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: nil)
    }
}
