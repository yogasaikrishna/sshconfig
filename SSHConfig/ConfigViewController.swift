//
//  ConfigViewController.swift
//  SSHEdit
//
//  Created by Sai Koneru on 19/08/2021.
//

import Cocoa

class ConfigViewController: NSViewController {
    let configController = ConfigController.shared
    var config: Config?
    
    @IBOutlet var configTable: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func deleteConfig(_ sender: NSView) {
        if let config = self.config {
            let alert = NSAlert()
            alert.messageText = "Are you sure?"
            alert.informativeText = "Do you want to delete the selected config"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: self.view.window!) { [unowned self] response in
                if response == .alertFirstButtonReturn {
                    guard let index = configController.configs.firstIndex(where: { $0.id == config.id }) else { return }
                    configController.configs.remove(at: index)
                    configTable.reloadData()
                    view.window?.subtitle = ""
                    configController.saveFile()
                    
                    if let showConfigVC = parent?.children[1] as? ShowConfigViewController {
                        showConfigVC.configStackView.isHidden = true
                        showConfigVC.labelStackView.isHidden = false
                    }
                    
                    (NSApplication.shared.delegate as? AppDelegate)?.configureMenuItems()
                }
            }
        }
    }
}

// MARK: Table Data Source
extension ConfigViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        configController.configs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let view = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        view.textField?.stringValue = configController.configs[row].host
        return view
    }
}

// MARK: Table Delegate
extension ConfigViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard configTable.selectedRow != -1 else { return }
        guard let splitView = parent as? NSSplitViewController else { return }
        if let showConfigView = splitView.children[1] as? ShowConfigViewController {
            self.config = configController.configs[configTable.selectedRow]
            showConfigView.showConfig(configController.configs[configTable.selectedRow])
        }
    }
}
