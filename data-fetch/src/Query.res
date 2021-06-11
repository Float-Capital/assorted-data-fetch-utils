open GqlConverters

// NOTE: only gets first 1000, won't get more than that
module GetAllFeeds = %graphql(`
  query getAllFeeds {
    feeds(first: 1000) {
      id
      name
    }
  }
`)

module GetFeedData = %graphql(`
  query getFeedData($offset: Int!, $feedId: String!) {
    feed (id: $feedId) {
      id
      name
      rounds (first: 1000, skip: $offset, orderBy: unixTimestamp, orderDirection: asc) {
        number
        value
        unixTimestamp
      }
    }
  }
`)
