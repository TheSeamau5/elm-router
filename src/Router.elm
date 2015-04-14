module Router where
{-| Simple Router library for performing operations based on a list of string
routes. This is particularly useful for routing pages in single page applications
where the given list of strings are list of url paths.


# Types
@docs Route, Router

# Route Matching
@docs match, (:->)

# Useful Helper
@docs matchPrefix
-}

import String exposing (startsWith, dropLeft, length)

{-| A Route is a function from a string to some value or computation.
-}
type alias Route a = String -> a

{-| A Router is a tuple containing a string and its associated route
-}
type alias Router a = (String, Route a)


{-| `match` allows you to select an appropriate route depending on the
given input string. `match` takes a list of routers and a default route,
which acts as a catch-all and returns a route. Returning a route allows
for nested routes.

Example:

    mainRoute : Route Html
    mainRoute = match
      [ "/"           :-> displayHomePage
      , "/index.html" :-> displayHomePage
      , "/blog"       :-> blogRoute
      , "/contact"    :-> displayContactsPage
      ] display404Page

    blogRoute : Route Html
    blogRoute = match
      [ "/"             :-> displayBlogPostListing
      , "/entry1.html"  :-> displayEntry1
      , "/entry2.html"  :-> displayEntry2
      ] display404Page


In some cases, it important to understand how `match` works. Suppose you have
the input path "/users/4873/profile.html" and there is a router that matches
"/users" with an associated route `usersRoute`. The `usersRoute` function will
get called with "/4873/profile.html" as a parameter. This means that `match`
will strip away the string it has matched from the input string before passing
it onto the route. `match` will also match routes in the order you have stated
them. This means that if you have the following route:

    myRoute = match
      [ "/user"   :-> userRoute
      , "/users"  :-> displayUserListing
      ] display404Page

There is no way for `displayUserListing` to ever be called. Say you pass in
"/users.html", then this will be matched by "/user" which will pass "s.html"
to `userRoute`. To solve this, you may wish to reverse the order of the routes
as follows:

    myRoute = match
      [ "/users"  :-> displayUserListing
      , "/user"   :-> userRoute
      ] display404Page

And now things will work as intended.

You may notice that in the first example, I use "/" as a route at the very top.
This is because `match` special cases "/" and the empty string due to their
prevalence.
-}
match : List (Router a) -> Route a -> Route a
match routers defaultRoute url = case routers of
  [] -> defaultRoute url
  (prefix, route) :: rs ->
    if
      prefix == "" || prefix == "/"
    then
      if
        url == prefix
      then
        route url
      else
        match rs defaultRoute url
    else
      case matchPrefix prefix url of
        Just value -> route value
        Nothing    -> match rs defaultRoute url

{-| Takes a reference string and a string to match and returns the second string
stripped of the matched reference string. Used to implement `match`.

    matchPrefix "he" "hello" === Just "llo"

    matchPrefix "yo" "halo" === Nothing
-}
matchPrefix : String -> String -> Maybe String
matchPrefix prefix string =
  if
    startsWith prefix string
  then
    Just <| dropLeft (length prefix) string
  else
    Nothing

{-| Operator to offer easy-to-read DSL for matching routes. This is an alias
for the `(,)` tuple constructor function.
-}
(:->) : String -> Route a -> Router a
(:->) = (,)
