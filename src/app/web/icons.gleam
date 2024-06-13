import lustre/attribute.{attribute, class}
import lustre/element.{type Element, element}
import lustre/element/svg.{svg}

pub fn logo_icon() -> Element(a) {
  svg(
    [
      attribute("xmlns", "http://www.w3.org/2000/svg"),
      attribute("viewBox", "0 0 24 24"),
      attribute("fill", "currentColor"),
      attribute("class", "size-6"),
    ],
    [
      element(
        "path",
        [attribute("d", "M12 7.5a2.25 2.25 0 1 0 0 4.5 2.25 2.25 0 0 0 0-4.5Z")],
        [],
      ),
      element(
        "path",
        [
          attribute("fill-rule", "evenodd"),
          attribute(
            "d",
            "M1.5 4.875C1.5 3.839 2.34 3 3.375 3h17.25c1.035 0 1.875.84 1.875 1.875v9.75c0 1.036-.84 1.875-1.875 1.875H3.375A1.875 1.875 0 0 1 1.5 14.625v-9.75ZM8.25 9.75a3.75 3.75 0 1 1 7.5 0 3.75 3.75 0 0 1-7.5 0ZM18.75 9a.75.75 0 0 0-.75.75v.008c0 .414.336.75.75.75h.008a.75.75 0 0 0 .75-.75V9.75a.75.75 0 0 0-.75-.75h-.008ZM4.5 9.75A.75.75 0 0 1 5.25 9h.008a.75.75 0 0 1 .75.75v.008a.75.75 0 0 1-.75.75H5.25a.75.75 0 0 1-.75-.75V9.75Z",
          ),
          attribute("clip-rule", "evenodd"),
        ],
        [],
      ),
      element(
        "path",
        [
          attribute(
            "d",
            "M2.25 18a.75.75 0 0 0 0 1.5c5.4 0 10.63.722 15.6 2.075 1.19.324 2.4-.558 2.4-1.82V18.75a.75.75 0 0 0-.75-.75H2.25Z",
          ),
        ],
        [],
      ),
    ],
  )
}

pub fn home_icon() -> Element(a) {
  svg(
    [
      class("size-4"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 576 512"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute(
            "d",
            "M575.8 255.5c0 18-15 32.1-32 32.1h-32l.7 160.2c0 2.7-.2 5.4-.5 8.1V472c0 22.1-17.9 40-40 40H456c-1.1 0-2.2 0-3.3-.1c-1.4 .1-2.8 .1-4.2 .1H416 392c-22.1 0-40-17.9-40-40V448 384c0-17.7-14.3-32-32-32H256c-17.7 0-32 14.3-32 32v64 24c0 22.1-17.9 40-40 40H160 128.1c-1.5 0-3-.1-4.5-.2c-1.2 .1-2.4 .2-3.6 .2H104c-22.1 0-40-17.9-40-40V360c0-.9 0-1.9 .1-2.8V287.6H32c-18 0-32-14-32-32.1c0-9 3-17 10-24L266.4 8c7-7 15-8 22-8s15 2 21 7L564.8 231.5c8 7 12 15 11 24z",
          ),
        ],
        [],
      ),
    ],
  )
}

pub fn organizations_icon() -> Element(a) {
  svg(
    [
      class("size-4"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 384 512"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute(
            "d",
            "M48 0C21.5 0 0 21.5 0 48V464c0 26.5 21.5 48 48 48h96V432c0-26.5 21.5-48 48-48s48 21.5 48 48v80h96c26.5 0 48-21.5 48-48V48c0-26.5-21.5-48-48-48H48zM64 240c0-8.8 7.2-16 16-16h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H80c-8.8 0-16-7.2-16-16V240zm112-16h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H176c-8.8 0-16-7.2-16-16V240c0-8.8 7.2-16 16-16zm80 16c0-8.8 7.2-16 16-16h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H272c-8.8 0-16-7.2-16-16V240zM80 96h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H80c-8.8 0-16-7.2-16-16V112c0-8.8 7.2-16 16-16zm80 16c0-8.8 7.2-16 16-16h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H176c-8.8 0-16-7.2-16-16V112zM272 96h32c8.8 0 16 7.2 16 16v32c0 8.8-7.2 16-16 16H272c-8.8 0-16-7.2-16-16V112c0-8.8 7.2-16 16-16z",
          ),
        ],
        [],
      ),
    ],
  )
}

pub fn users_icon() -> Element(a) {
  svg(
    [
      class("size-4"),
      attribute("fill", "currentColor"),
      attribute("viewBox", "0 0 448 512"),
      attribute("xmlns", "http://www.w3.org/2000/svg"),
    ],
    [
      element(
        "path",
        [
          attribute(
            "d",
            "M224 256A128 128 0 1 0 224 0a128 128 0 1 0 0 256zm-45.7 48C79.8 304 0 383.8 0 482.3C0 498.7 13.3 512 29.7 512H418.3c16.4 0 29.7-13.3 29.7-29.7C448 383.8 368.2 304 269.7 304H178.3z",
          ),
        ],
        [],
      ),
    ],
  )
}
