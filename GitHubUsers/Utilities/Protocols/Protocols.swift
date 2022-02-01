//
//  Protocols.swift
//  GitHubUsers
//
//  Created by Jeffon 29/01/2022.
//

import Foundation

protocol CellConfigurable {
    func configure(withUser user: RowViewModel)
}

protocol RowViewModel { var id: Int { get set }  }
