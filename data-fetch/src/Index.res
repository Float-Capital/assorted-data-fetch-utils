Dotenv.config()
@val external optGraphEndpoint: option<string> = "process.env.GRAPH_ENDPOINT"

let graphEndpoint =
  optGraphEndpoint->Option.getWithDefault("https://thegraph.com/something/something/default")

let client = ClientConfig.createInstance(
  ~graphqlEndpoint="https://api.thegraph.com/subgraphs/name/alejandro-larumbe/chainlink-matic-mainnet",
  (),
)

let _getAllFeeds = client.query(~query=module(Query.GetAllFeeds), ())->JsPromise.map(result => {
  switch result {
  | Ok({data: {feeds}}) =>
    let _feedFetching = feeds->Array.map(({id: feedId, name}) => {
      let feedData = ref("number,timestamp,value")
      let finishedProcessing = ref(false)
      let offset = ref(0)
      while !finishedProcessing.contents {
        let _getSpecifFeed = _ =>
          client.query(
            ~query=module(Query.GetFeedData),
            Query.GetFeedData.makeVariables(~offset=offset.contents, ~feedId, ()),
          )->JsPromise.map(result =>
            switch result {
            | Ok({data: {feed: Some({rounds})}}) =>
              let processRound = rounds->Array.map(({number, unixTimestamp, value}) => {
                feedData :=
                  feedData.contents ++
                  `\n${number->BN.toString},${unixTimestamp->Int.toString},${value->Option.mapWithDefault(
                      "0",
                      BN.toString,
                    )}`
                ()
              })
              if rounds->Array.length < 1000 {
                finishedProcessing := true
              }
            | Error(error) =>
              finishedProcessing := true
              Js.log2("Error: ", error)
            }
          )
      }

      Node.Fs.writeFileAsUtf8Sync(`../rawData/${name}.csv`, feedData.contents)
    })
  | Error(error) => Js.log2("Error (with GetAllFeeds): ", error)
  }
})
