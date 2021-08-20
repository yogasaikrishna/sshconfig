//
//  ShowConfigViewController.swift
//  SSHEdit
//
//  Created by Sai Koneru on 19/08/2021.
//

import Cocoa

class ShowConfigViewController: NSViewController {
    let configController = ConfigController.shared
    var config: Config?

    @IBOutlet var configStackView: NSStackView!
    @IBOutlet var labelStackView: NSStackView!

    @IBOutlet var host: NSTextField!
    @IBOutlet var hostName: NSTextField!
    @IBOutlet var port: NSTextField!
    @IBOutlet var user: NSTextField!
    @IBOutlet var identityFile: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showConfig(_ config: Config) {
        self.config = config
        host.stringValue = config.host
        hostName.stringValue = config.hostName
        port.stringValue = config.port
        user.stringValue = config.user
        identityFile.stringValue = config.identityFilePath
        
        labelStackView.isHidden = true
        configStackView.isHidden = false

        view.window?.subtitle = config.host
    }
    
    @IBAction func saveConfig(_ sender: NSView) {
        guard let config = self.config else {
            fatalError("No configuration selected")
        }
        guard let index = configController.configs.firstIndex(where: { $0.id == config.id }) else {
            fatalError("Configuration not found for \(config.host)")
        }
        configController.configs[index].host = host.stringValue
        configController.configs[index].hostName = hostName.stringValue
        configController.configs[index].port = port.stringValue
        configController.configs[index].user = user.stringValue
        configController.configs[index].identityFilePath = identityFile.stringValue
        
        configController.saveFile()
        
        view.window?.subtitle = host.stringValue
        
        (NSApplication.shared.delegate as? AppDelegate)?.configureMenuItems()
        
        (parent?.children[0] as? ConfigViewController)?.configTable.reloadData()
    }
}
