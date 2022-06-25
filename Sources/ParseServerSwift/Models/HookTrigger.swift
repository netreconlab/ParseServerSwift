//
//  HookTrigger.swift
//  
//
//  Created by Corey Baker on 6/23/22.
//

import Foundation
import ParseSwift
import Vapor

/**
 Parse Hook Triggers can be created by conforming to
 `ParseHookFunctionable`.
 */
public struct HookTrigger: ParseHookTriggerable {
    public var className: String?
    public var triggerName: ParseHookTriggerType?
    public var url: URL?

    public init() {}
}

// MARK: RoutesBuilder
public extension RoutesBuilder {
    /**
     Creates a new route and for a Parse Cloud Code hook trigger.
     - parameter path: A variadic list of paths.
     - parameter className: The name of the `ParseObject` the trigger should act on.
     - parameter triggerName: The `ParseHookTriggerType` type.
     - parameter url: The endpoint of the hook.
     */
    @discardableResult
    func post<Response>(
        _ path: PathComponent...,
        className: String,
        triggerName: ParseHookTriggerType,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        do {
            let url = try buildServerPathname(path)
            let hookTrigger = HookTrigger(className: className,
                                          triggerName: triggerName,
                                          url: url)
            Task {
                do {
                    _ = try await hookTrigger.create()
                } catch {
                    if !error.equalsTo(.invalidImageData) {
                        print("Could not create \"\(hookTrigger)\" trigger: \(error)")
                    }
                }
            }
        } catch {
            print(error)
        }
        return self.post(path, use: closure)
    }

    /**
     Creates a new route and for a Parse Cloud Code hook trigger.
     - parameter path: An array of paths.
     - parameter className: The name of the `ParseObject` the trigger should act on.
     - parameter triggerName: The `ParseHookTriggerType` type.
     - parameter url: The endpoint of the hook.
     */
    @discardableResult
    func post<Response>(
        _ path: [PathComponent],
        className: String,
        triggerName: ParseHookTriggerType,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        do {
            let url = try buildServerPathname(path)
            let hookTrigger = HookTrigger(className: className,
                                          triggerName: .afterSave,
                                          url: url)
            Task {
                do {
                    _ = try await hookTrigger.create()
                } catch {
                    if !error.equalsTo(.invalidImageData) {
                        print("Could not create \"\(hookTrigger)\" trigger: \(error)")
                    }
                }
            }
        } catch {
            print(error)
        }
        return self.post(path, use: closure)
    }
}
