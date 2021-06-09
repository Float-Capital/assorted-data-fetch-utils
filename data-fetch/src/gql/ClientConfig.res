%raw("require('isomorphic-fetch')")
@val
external fetch: ApolloClient.Link.HttpLink.HttpOptions.Js_.t_fetch = "fetch"

let httpLink = (~headers=?, ~graphqlEndpoint, ()) =>
  ApolloClient.Link.HttpLink.make(
    ~uri=_ => graphqlEndpoint,
    ~headers=Obj.magic(headers),
    ~fetch,
    (),
  )

let createInstance = (~headers=?, ~graphqlEndpoint, ()) => {
  open ApolloClient
  make(
    ~cache=Cache.InMemoryCache.make(),
    ~connectToDevTools=true,
    ~defaultOptions=DefaultOptions.make(
      ~mutate=DefaultMutateOptions.make(~awaitRefetchQueries=true, ~errorPolicy=All, ()),
      ~query=DefaultQueryOptions.make(~fetchPolicy=NetworkOnly, ~errorPolicy=All, ()),
      ~watchQuery=DefaultWatchQueryOptions.make(~fetchPolicy=NetworkOnly, ~errorPolicy=All, ()),
      (),
    ),
    ~link=httpLink(~graphqlEndpoint, ~headers, ()),
    (),
  )
}
