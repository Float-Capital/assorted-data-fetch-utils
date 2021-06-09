
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
  query getFeedData($offset: int!, $feedId: string!) {
    feeds(id: $feedId) {
      id
      name
      rounds (first: 1000, skip: $offset) {
        unixTimestamp
        number
        value
      }
    }
  }
`)
