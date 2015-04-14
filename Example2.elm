import Html             exposing (button, text, Html, div, a)
import Html.Events      exposing (onClick)
import Html.Attributes  exposing (href)
import Task             exposing (Task, sleep, andThen)
import Router           exposing (Route, match, (:->))
import History          exposing (setPath, path, back, forward, length, hash)
import Signal           exposing (Mailbox, mailbox, Signal, send, message)

displayBlog _ hash length =
  div []
    [ button
      [ onClick (message pathChangeMailbox.address (setPath "/contacts.html")) ]
      [ text "Contacts"]
    , button
      [ onClick (message pathChangeMailbox.address back) ]
      [ text "Back"]
    , text "Blog"
    , text ("Length : " ++ toString length)
    , text ("hash : " ++ toString hash)
    ]

displayContacts _ hash length =
  div []
    [ button
      [ onClick (message pathChangeMailbox.address (setPath "/blog.html")) ]
      [ text "Blog"]
    , button
      [ onClick (message pathChangeMailbox.address back) ]
      [ text "Back"]
    , text "Contacts"
    , text ("Length : " ++ toString length)
    , text ("hash : " ++ toString hash)
    ]

display404 _ _ _ = text "404"

route : Route (String -> Int -> Html)
route = match
  [ "/Example2.elm" :-> app
  , "/blog"         :-> displayBlog
  , "/contacts"     :-> displayContacts
  ] display404


pathChangeMailbox : Mailbox (Task error ())
pathChangeMailbox = mailbox (Task.succeed ())


app _ hash length =
  div []
    [ button
      [ onClick (message pathChangeMailbox.address (setPath "/blog.html")) ]
      [ text "Blog"]
    , button
      [ onClick (message pathChangeMailbox.address (setPath "/contacts.html")) ]
      [ text "Contacts"]
    , button
      [ onClick (message pathChangeMailbox.address back) ]
      [ text "Back"]
    , button
      [ onClick (message pathChangeMailbox.address forward) ]
      [ text "Forward"]
    , text ("Length : " ++ toString length)
    , a [ href "#yo" ] [ text "yo tag" ]
    , a [ href "#hello" ] [ text "hello tag" ]
    , text ("hash : " ++ toString hash)
    ]


port runTask : Signal (Task error ())
port runTask =
  pathChangeMailbox.signal

main = Signal.map3 route path hash length
