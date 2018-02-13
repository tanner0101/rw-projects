import Vapor

struct UserCredentials: Content {
    var email: String
    var cleartextPassword: String

    /// Override the Content's coding keys.
    enum CodingKeys: String, CodingKey {
        case email = "email"
        case cleartextPassword = "password"
    }
}
