import Router exposing (..)
import History exposing (..)
import Graphics.Element exposing (show)
import Signal

route : Route String
route = match
  [ "/index.html" :-> displayHome
  , "/"           :-> displayHome
  , "/blog"       :-> blogRoute
  , "/contacts"   :-> displayContacts
  ] display404

blogRoute : Route String
blogRoute = match
  [ "/mario.html" :-> displayMario
  ] displayBlog



displayHome = always "Home Page"
displayBlog url = "Some Blog : " ++ url
displayContacts url = "Some Contacts Page : " ++ url
display404 = always "Lost in 404"
displayMario = always "It's a me, mario"

test = route "/blog/mario.html"

main = show test
--main = Signal.map show path
