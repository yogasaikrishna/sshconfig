//
//  MainViewController.swift
//  SSHConfig
//
//  Created by Sai Koneru on 20/08/2021.
//

import Cocoa

class MainViewController: NSSplitViewController {
    let configController = ConfigController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func createConfig(_ sender: NSView) {
        let config = Config(host: "New Host", hostName: "", port: "", user: "", identityFilePath: "")
        configController.configs.append(config)
        if let configVC = children[0] as? ConfigViewController {
            let configTable = configVC.configTable
            configTable!.reloadData()
            
            let index = configController.configs.count - 1
            
            configTable!.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            configTable?.scrollRowToVisible(index)
        }
    }
}
