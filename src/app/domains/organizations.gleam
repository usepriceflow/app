import app/web.{type AppErrors, InternalError}
import gleam/dynamic.{type DecodeError, type Dynamic}
import gleam/list
import wisp.{type FormData}

// Types -----------------------------------------------------------------------

pub type MaybeOrganization {
  MaybeOrganization(name: String)
}

pub type Organization {
  Organization(id: Int, name: String)
}

// Decoders --------------------------------------------------------------------

/// Decodes the return from the db insert
pub fn organization_decoder(
  tuple: Dynamic,
) -> Result(Organization, List(DecodeError)) {
  let decoder =
    dynamic.decode2(
      Organization,
      dynamic.element(0, dynamic.int),
      dynamic.element(1, dynamic.string),
    )

  decoder(tuple)
}

pub fn maybe_organization_decoder(
  form: FormData,
) -> Result(MaybeOrganization, AppErrors) {
  let name = list.key_find(form.values, "name")

  case name {
    Ok(name) -> Ok(MaybeOrganization(name: name))
    Error(_) -> Error(InternalError)
  }
}
