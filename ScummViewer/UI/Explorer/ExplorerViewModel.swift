//
//  ExplorerViewModel.swift
//  ScummViewer
//
//  Created by Michael Borgmann on 14/04/2026.
//


import Foundation
import Observation

@MainActor
@Observable
final class ExplorerViewModel {

    private(set) var gameDirectoryURL: URL?

    var hasOpenGame: Bool {
        gameDirectoryURL != nil
    }

    func openGame() {
        // Next step: choose and open a game directory.
    }

    func export() {
        guard hasOpenGame else {
            return
        }

        // Implement later when export behavior is defined.
    }
}
