//
//  ExplorerCommands.swift
//  ScummViewer
//
//  Created by Michael Borgmann on 28/09/2026.
//

import SwiftUI

struct ExplorerViewModelKey: FocusedValueKey {
    typealias Value = ExplorerViewModel
}

extension FocusedValues {

    var explorerViewModel: ExplorerViewModel? {
        get { self[ExplorerViewModelKey.self] }
        set { self[ExplorerViewModelKey.self] = newValue }
    }
}

struct ExplorerCommands: Commands {

    @FocusedValue(\.explorerViewModel)
    private var viewModel

    var body: some Commands {

        CommandGroup(replacing: .newItem) {
            Button("Open Game…") {
                viewModel?.openGame()
            }
            .keyboardShortcut("o", modifiers: .command)
            .disabled(viewModel == nil)
        }

        CommandGroup(replacing: .importExport) {
            Button("Export…") {
                viewModel?.export()
            }
            .disabled(viewModel?.hasOpenGame != true)
        }
    }
}
