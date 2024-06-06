import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/result

pub type NewUser {
  NewUser(name: String, email: String, password: String)
}

pub type User {
  User(id: Int, name: String, email: String, password_hash: String)
}

// Decodes the JSON blob from the POST to /users
pub fn new_user_decoder(json: Dynamic) -> Result(NewUser, Nil) {
  let decoder =
    dynamic.decode3(
      NewUser,
      dynamic.field("name", dynamic.string),
      dynamic.field("email", dynamic.string),
      dynamic.field("password", dynamic.string),
    )

  json
  |> decoder()
  |> result.nil_error()
}

// Decodes the return from the db insert
pub fn user_decoder(tuple: Dynamic) -> Result(User, List(DecodeError)) {
  let decoder =
    dynamic.decode4(
      User,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
      dynamic.element(2, dynamic.string),
      dynamic.element(3, dynamic.string),
    )

  decoder(tuple)
}
