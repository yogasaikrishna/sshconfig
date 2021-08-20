//
//  AppDelegate.swift
//  SSHConfig
//
//  Created by Sai Koneru on 19/08/2021.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let configController = ConfigController.shared
    @IBOutlet var menu: NSMenu!
    @IBOutlet var firstMenuItem: NSMenuItem!
    @IBOutlet var lastMenuItem: NSMenuItem!
    
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = NSImage(systemSymbolName: "terminal", accessibilityDescription: nil)
        statusItem.menu = menu
        configureMenuItems()
    }

    @objc func launchConfig(_ sender: NSMenuItem) {
        let script = """
            tell application "Terminal"
                do script "ssh \(sender.title)"
                delay 0.25
                activate
            end tell
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
    }
    
    @IBAction func launchApp(_ sender: NSMenuItem) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: Bundle.main)
        let window = storyboard.instantiateController(withIdentifier: "MainWindow") as! NSWindowController
        window.showWindow(self)
        let script = "tell application \"SSHConfig\" to activate"
        var error: NSDictionary?
        if let activateScript = NSAppleScript(source: script) {
            activateScript.executeAndReturnError(&error)
        }
    }
    
    func configureMenuItems() {
        let firstIndex = menu.index(of: firstMenuItem)
        let lastIndex = menu.index(of: lastMenuItem)
        for _ in firstIndex..<lastIndex - 1 {
            menu.removeItem(at: 1)
        }
        for config in configController.configs.reversed() {
            let menuItem = NSMenuItem(title: config.host, action: #selector(launchConfig), keyEquivalent: "")
            menu.insertItem(menuItem, at: firstIndex + 1)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}

