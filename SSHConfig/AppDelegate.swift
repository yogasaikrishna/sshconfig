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
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "SSH"
        statusItem.menu = NSMenu()
        configureMenuItems()
    }

    @objc func launchConfig(_ sender: NSMenuItem) {
        let script = "tell application \"Terminal\" to do script \"ssh \(sender.title)\""
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
    }
    
    func configureMenuItems() {
        statusItem.menu?.removeAllItems()
        for config in configController.configs {
            statusItem.menu?.addItem(
                NSMenuItem(title: config.host, action: #selector(launchConfig), keyEquivalent: "")
            )
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }
}

