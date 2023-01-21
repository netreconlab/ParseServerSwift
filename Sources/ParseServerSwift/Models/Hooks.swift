//
//  Hooks.swift
//  
//
//  Created by Corey Baker on 1/21/23.
//

import Foundation

/// An actor containing all of the current Hooks.
public actor Hooks {
    var functions = [String: HookFunction]()
    var triggers = [String: HookTrigger]()
}

// MARK: Hook Functions
extension Hooks {
    /// Get all of the current functions.
    /// - returns: A dictionary where the keys are Parse Server `URL`'s and the respective `HookFunction`.
    func getFunctions() -> [String: HookFunction] {
        functions
    }

    /// Update curent functions.
    /// - parameter functions: A dictionary where the keys are Parse Server `URL`'s and the respective `HookFunction`.
    func updateFunctions(_ functions: [String: HookFunction]) {
        for (url, function) in functions {
            self.functions[url] = function
        }
    }

    /// Remove curent functions.
    /// - parameter url: An array of Parse Server `URL`'s.
    func removeFunctions(_ urls: [String]) {
        for url in urls {
            self.functions.removeValue(forKey: url)
        }
    }

    /// Remove all curent functions.
    func removeAllFunctions() {
        self.functions.removeAll()
    }
}

// MARK: Hook Triggers
extension Hooks {
    /// Get all of the current triggers.
    /// - returns: A dictionary where the keys are Parse Server `URL`'s and the respective `HookTrigger`.
    func getTriggers() -> [String: HookTrigger] {
        triggers
    }

    /// Update curent triggers.
    /// - parameter triggers: A dictionary where the keys are Parse Server `URL`'s and the respective `HookTrigger`.
    func updateTriggers(_ triggers: [String: HookTrigger]) {
        for (url, trigger) in triggers {
            self.triggers[url] = trigger
        }
    }

    /// Remove curent triggers.
    /// - parameter urls: An array of Parse Server `URL`'s.
    func removeTriggers(_ urls: [String]) {
        for url in urls {
            self.triggers.removeValue(forKey: url)
        }
    }

    /// Remove all curent triggers.
    func removeAllTriggers() {
        self.triggers.removeAll()
    }
}
