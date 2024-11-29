import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up environment paths
        let process = ProcessInfo.processInfo
        let env = process.environment
        let paths = ["/opt/homebrew/bin", "\(env["HOME"] ?? "")/bin", "/usr/local/bin", "/usr/bin", "/bin"]
        let pathString = paths.joined(separator: ":")
        
        var taskEnv = env
        taskEnv["PATH"] = pathString
        UserDefaults.standard.setValue(taskEnv, forKey: "shellEnvironment")
        
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "Display Layout")
        }
        setupMenu()
    }
    
    func setupMenu() {
        let menu = NSMenu()
        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        let displayLayout = "\(homePath)/.bin/display-layout"
        
        menu.addItem(NSMenuItem(title: "Right", action: #selector(rightLayout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Bottom", action: #selector(bottomLayout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Mirror", action: #selector(mirrorLayout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        UserDefaults.standard.setValue(displayLayout, forKey: "displayLayoutPath")
        statusItem?.menu = menu
    }
    
    @objc func rightLayout() {
        if let displayLayout = UserDefaults.standard.string(forKey: "displayLayoutPath") {
            shell("\(displayLayout) right")
        }
    }
    
    @objc func bottomLayout() {
        if let displayLayout = UserDefaults.standard.string(forKey: "displayLayoutPath") {
            shell("\(displayLayout) bottom")
        }
    }
    
    @objc func mirrorLayout() {
        if let displayLayout = UserDefaults.standard.string(forKey: "displayLayoutPath") {
            shell("\(displayLayout) mirror")
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    func shell(_ command: String) {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.currentDirectoryPath = FileManager.default.homeDirectoryForCurrentUser.path
        if let env = UserDefaults.standard.dictionary(forKey: "shellEnvironment") as? [String: String] {
            task.environment = env
        }
        
        NSLog("Executing command: \(command)")
        task.launchPath = "/bin/zsh"
        task.arguments = ["-c", command]
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                NSLog("Output: \(output)")
            }
        } catch {
            NSLog("Error: \(error)")
        }
    }
}