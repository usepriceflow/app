import antigone
import app/contexts/user_contexts.{type NewUser, type User, user_decoder}
import gleam/bit_array
import gleam/pgo.{type Connection, Returned}

pub fn create_user(connection: Connection, user: NewUser) -> Result(User, Nil) {
  let sql =
    "
  INSERT INTO users (name, email, password_hash)
  VALUES ($1, $2, $3)
  RETURNING id, name, email, password_hash;
"
  let password = bit_array.from_string(user.password)
  let hashed_password = antigone.hash(antigone.hasher(), password)

  let returned =
    pgo.execute(
      sql,
      connection,
      [pgo.text(user.name), pgo.text(user.email), pgo.text(hashed_password)],
      user_decoder,
    )

  case returned {
    Ok(Returned(_, [user, ..])) -> Ok(user)
    _ -> Error(Nil)
  }
}

pub fn list_users(connection: Connection) -> Result(List(User), Nil) {
  let sql =
    "
  SELECT id, name, email, password_hash
  FROM users;
  "

  let returned = pgo.execute(sql, connection, [], user_decoder)

  case returned {
    Ok(Returned(_, users)) -> Ok(users)
    _ -> Error(Nil)
  }
}
