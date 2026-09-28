//
//  ExplorerView.swift
//  ScummViewer
//
//  Created by Michael Borgmann on 14/04/2026.
//

import SwiftUI

struct ExplorerView: View {
    
    @State private var viewModel = ExplorerViewModel()
    @State private var isInspectorPresented = false

    var body: some View {
        
        NavigationSplitView {
            ResourceNavigatorView()
        } detail: {
            WorkspaceView()
        }
        .inspector(isPresented: $isInspectorPresented) {
            InspectorView()
        }
        .focusedSceneValue(
            \.explorerViewModel,
            viewModel
        )
        .toolbar {
            
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.openGame()
                } label: {
                    Label("Open Game", systemImage: "folder")
                }
                .help("Open Game…")
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.export()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .disabled(!viewModel.hasOpenGame)
                .help("Export…")
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    isInspectorPresented.toggle()
                } label: {
                    Label(
                        isInspectorPresented
                            ? "Hide Inspector"
                            : "Show Inspector",
                        systemImage: "sidebar.trailing"
                    )
                }
                .help(
                    isInspectorPresented
                        ? "Hide Inspector"
                        : "Show Inspector"
                )
            }
        }
    }
}

#Preview {
    ExplorerView()
        .frame(width: 450, height: 480)
}
