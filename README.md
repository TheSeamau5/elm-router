# elm-router

This library contains a couple functions to assist in doing client-side routing in Elm. The way this library achieves this is by introducing the concepts of routes and routers and a `match` function to match url paths to different routes.

*Note: This library offers very simplistic mechanisms for routing and is mainly intended for small applications and to serve as an example API for what can be achieved in Elm in terms of routing. Please do not consider this API as a definitive solution to routing or that it somehow represents how routing should be done. I'd like to think that it merely represents one way routing could be done.*

### Motivating Example

`elm-router` allows you do define routes as follows:

```elm
mainRoute : Route Html
mainRoute = match
  [ "/"               :-> displayHomePage
  , "/index.html"     :-> displayHomePage
  , "/blog"           :-> blogRoute
  , "/contacts.html"  :-> displayContactsPage
  ] display404Page

blogRoute : Route Html
blogRoute = match
  [ "/"             :-> displayBlogListing
  , "/entry1.html"  :-> displayEntry1
  , "/entry2.html"  :-> displayEntry2
  ] display404Page

```

Routes are created with the `match` function. Match takes a list of strings and functions (or Routers) and a default route and creates a route from them. In this example, if the user were to go to "/contacts.html", the `displayContactsPage` function would be called. You may also notice that these routes nest, as shown with `blogRoute`. In this example, if the user were to go to "/blog/entry2.html", the `displayEntry2` function would be called.

Hopefully, you can see from this example that the DSL provided by `elm-router` makes it easy to work with routes. The only thing you might notice is that these routes require other routes. So, how do you make those? To this, we will explore what are routes.

## Routes and Routers

##### Route:

A `Route` is defined as a function from a `String` to some value or computation.

```elm
type alias Route a = String -> a
```

The input `String` of a `Route`, in the case of the example, would be a url path. So, in our example, `mainRoute` is simply a function that, given a url path, produces `Html`. This is exactly what we intend with routers, to produce different views based on an input url path.


An example function that would fit this description could be:

```elm
displayHelloWorld : Route Html
displayHelloWorld _ = text "Hello World"
```

This is a function which ignores the input path and displays "Hello World" as text.

##### Router:

A `Router` is simply defined as a tuple of `String` and `Route`.

```elm
type alias Router a = (String, Route a)
```

As such, a `Router` contains sufficient information for performing a simple pattern match on strings. We can trivially take a string, match on the Router's string, and if the match succeeds, call the Router's route.

So, now that we understand the fundamental types, let's understand how `match` works.

## Match

As stated in the example, `match` takes a list of routers and a default route and returns a route.

```elm
match : List (Router a) -> Route a -> Route a
```

Basically what happens is that `match` will take an input string and go through each router one by one to see if there is a match. If there is one, it will call on the matched router's route. If no strings match, then it will call on the default route.

So, in our example above, the default route is `display404Page`. This is the common catch-all for websites where they refer you to a 404 page to tell the user that they have entered an unknown url.

A minimal example `match` would be:

```elm
route : Route String
route = match
  ["/index.html" :-> (\_ -> "Hello world")]
  (\_ -> "Nothing Here")

-- route "/index.html" == "Hello world"
-- route "/someotherthing" == "Nothing Here"
-- route "/" == "Nothing Here"
-- route "/index.htmlejnuz" == "Hello world"
-- route "/index.htm" == "Nothing Here"
```

From this example we can see that, if the given string **starts with** one of the reference strings in the list of routers, the appropriate function will be called, even if the given string is non-sensical. If the given string is not matched completely, then `match` will default to the given default route.


So, ok, `match` sees if the given string starts with one of the reference strings and then calls the appropriate route. But what does it call that route with?

To answer this, let's tweak our minimal example a bit.

```elm
route : Route String
route = match
  ["/index.html" :-> (\string -> string)]
  (\string -> string)

-- route "/index.html" == ""
-- route "/someotherthing" == "/someotherthing"
-- route "/" == "/"
-- route "/index.htmlejnuz" == "ejnuz"
-- route "/index.htm" == "/index.htm"
```

So, now we have modified our route to simply output what it was given. We can already see the behavior of `match` from this example.

In the case that an input string was matched against a reference string in a router, `match` will pass the remainder of the input string to the route. In essence, `match` will string the part of the input string that is matched and pass what is left to the route.

So, if we had "hello" as input and matched against "he", `match` would pass "llo" to the route.

In the case that an input string was not matched, it will pass the entire input to the default route. This is partly because, since there is nothing to match, there is nothing to string and partly because this may be useful for debugging and analytics purposes.

It is also important to note that `match` matches routers in the order you state them. This means that in the following example:

```elm
route = match
  [ "/user"       :-> userRoute
  , "/users.html" :-> displayUserListing
  ] display404Page

```
the "/users.html" router will never be matched. This is because if you pass "/users.html" to `route`, then the "/user" router will be matched and `userRoute` will be called with the string "s.html". In order to solve this issue, you must re-order the routers as follows:

```elm
route = match
  [ "/users.html" :-> displayUserListing
  , "/user"       :-> userRoute
  ] display404Page
```

Now, `match` will try "/users.html" first.

At this point, you may note that in our very first example, we used "/" as a router before all the other routers. You would assume that all the other routes are unreachable. **This is not the case because `match` special cases the empty string and "/" due to their prevalence.**


Finally, you may have noticed the weird `:->` operator. This is just an alias for the `(,)` tuple constructor.

```elm
(:->) : String -> Route a -> Router a
(:->) = (,)
```

For more details on usage, please refer to the examples in the repo. Note that this library is best used in conjunction with [`elm-history`](https://github.com/TheSeamau5/elm-history) as it allows you to capture the url path as it changes and thus match on it.
