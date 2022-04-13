/*
 Up Next
 1. Queueable
 2. Implement Required
    1. Text
    2. Email
    3. APNS
    4. Database
 3. Implement not required
 
 Bonus
 5. Slack
 */

import Foundation
import Papyrus

// MARK: Example

struct Tester {
    func main() async throws {
        let user = User(name: "Josh", phone: "8609902262", email: "josh@withapollo.com")
        try await user.send(SMSMessage(text: "yo"), via: .default)
        try await SMSMessage(text: "yo").send(to: user, via: .default)
        try await user.send(sms: "Welcome to Apollo!!!", via: .default)
        try await user.sendEmail("<p> Hello from Apollo! </p>")
        try await SMS.send(SMSMessage(text: "yo"), to: user)
        try await SMS.send("yo", to: "8609902262")
        try await WelcomeText().send(to: user)
        try await NewReward().send(to: user)
        try await DeploymentComplete().send(to: [user])
        
        // Wishlist
        try await user.send(WelcomeText())
        try await user.send(NewReward())
        try await [user].send(DeploymentComplete())
    }
}

struct DeploymentComplete: Notification {
    func send(to users: [User]) async throws {
        for user in users {
            try await user.send(sms: "Deployment complete!")
        }
    }
}

struct NewReward: Notification {
    func send(to user: User) async throws {
        for device in 0...10 {
            try await user.send(sms: "New reward, \(user.name)!")
        }
    }
}

struct WelcomeText: Notification {
    func send(to user: User) async throws {
        try await user.send(sms: "Welcome to Apollo, \(user.name)!")
    }
}

struct User: Model, SMSReceiver, EmailReceiver {
    var id: Int?
    let name: String
    let phone: String
    let email: String
    var token: String { "foo" }
}