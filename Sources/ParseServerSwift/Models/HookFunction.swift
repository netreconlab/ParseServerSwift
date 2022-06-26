//
//  HookFunction.swift
//  
//
//  Created by Corey Baker on 6/23/22.
//

import Foundation
import ParseSwift
import Vapor

/**
 Parse Hook Functions can be created by conforming to
 `ParseHookFunctionable`.
 */
public struct HookFunction: ParseHookFunctionable {
    public var functionName: String?
    public var url: URL?

    public init() {}
}

// MARK: RoutesBuilder
public extension RoutesBuilder {
    /**
     Creates a new route and for a Parse Cloud Code hook function.
     - parameter path: A variadic list of paths.
     - parameter name: The name of the function.
     - parameter url: The endpoint of the hook.
     */
    @discardableResult
    func post<Response>(
        _ path: PathComponent...,
        name: String,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        do {
            let url = try buildServerPathname(path)
            let hookFunction = HookFunction(name: name,
                                            url: url)
            Task {
                do {
                    _ = try await hookFunction.create()
                } catch {
                    if !error.equalsTo(.invalidImageData) {
                        logger.error("Could not create \"\(hookFunction)\" function: \(error)")
                    }
                }
            }
        } catch {
            logger.error("\(error)")
        }
        return self.post(path, use: closure)
    }

    /**
     Creates a new route and for a Parse Cloud Code hook function.
     - parameter path: An array of paths.
     - parameter name: The name of the function.
     - parameter url: The endpoint of the hook.
     */
    @discardableResult
    func post<Response>(
        _ path: [PathComponent],
        name: String,
        triggerName: ParseHookTriggerType,
        use closure: @escaping (Request) async throws -> Response
    ) -> Route
        where Response: AsyncResponseEncodable
    {
        do {
            let url = try buildServerPathname(path)
            let hookFunction = HookFunction(name: name,
                                            url: url)
            Task {
                do {
                    _ = try await hookFunction.create()
                } catch {
                    if !error.equalsTo(.invalidImageData) {
                        logger.error("Could not create \"\(hookFunction)\" function: \(error)")
                    }
                }
            }
        } catch {
            logger.error("\(error)")
        }
        return self.post(path, use: closure)
    }
}
