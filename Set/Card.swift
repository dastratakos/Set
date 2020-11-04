//
//  Card.swift
//  Set
//
//  Created by Dean Stratakos on 4/3/20.
//  Copyright © 2020 Dean Stratakos. All rights reserved.
//

import Foundation

struct Card : Equatable {
    let number: Number
    let shading: Shading
    let color: Color
    let shape: Shape
    
    enum Number { case one, two, three }
    enum Shading { case one, two, three }
    enum Color { case one, two, three }
    enum Shape { case one, two, three }
}
