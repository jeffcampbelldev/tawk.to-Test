//
//  TypeAlias.swift
//  GitHubUsers
//
//  Created by Jeff on 27/01/2022.
//

typealias NetworkRequestSuccess  = ((Container)->())
typealias NetworkRequestError    = ((Any, String)->())
typealias NetworkRequestMessage  = ((Any, String)->())
typealias NotificationHandler    = (()->())
