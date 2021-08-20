//
//  AppDelegate.swift
//  SSHEdit
//
//  Created by Sai Koneru on 19/08/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let configController = ConfigController.shared
    @IBOutlet var menu: NSMenu!
    @IBOutlet var firstMenuItem: NSMenuItem!
    
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)
        statusItem.menu = menu
        configureMenuItems()
    }

    @objc func launchConfig(_ sender: NSMenuItem) {
        let script = "tell application \"Terminal\" to do script \"ssh \(sender.title)\""
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
    }
    
    @IBAction func launchApp(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle.main)
        let window = storyboard.instantiateController(withIdentifier: "MainWindow") as! NSWindowController
        window.showWindow(self)
        window.becomeFirstResponder()
        
    }
    
    func configureMenuItems() {
        let index = menu.index(of: firstMenuItem)
        for itemIndex in 0..<index {
            menu.removeItem(at: itemIndex)
        }
        for config in configController.configs.reversed() {
            let menuItem = NSMenuItem(title: config.host, action: #selector(launchConfig), keyEquivalent: "")
            menu.insertItem(menuItem, at: 0)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

