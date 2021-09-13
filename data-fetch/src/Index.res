Dotenv.config()
@val external optGraphEndpoint: option<string> = "process.env.GRAPH_ENDPOINT"

let graphEndpoint =
  optGraphEndpoint->Option.getWithDefault("https://thegraph.com/something/something/default")

let client = ClientConfig.createInstance(
  ~graphqlEndpoint="https://api.thegraph.com/subgraphs/name/alejandro-larumbe/chainlink-matic-mainnet",
  (),
)

// let client = ClientConfig.createInstance(
//   ~graphqlEndpoint="https://api.thegraph.com/subgraphs/name/skofman/chainlink",
//   (),
// )

%%raw(`var Promise = require('bluebird');`)

let promiseWhile: (unit => bool, unit => JsPromise.t<unit>) => JsPromise.t<unit> = %raw(`
  // some random javascript from the internet
  function(condition, action) {
    var resolver = Promise.defer();

    var loop = function() {
      if (!condition()) return resolver.resolve();
      return Promise.cast(action())
        .then(loop)
        .catch(resolver.reject);
    };

    process.nextTick(loop);

    return resolver.promise;
  }
`)

let _getAllFeeds = client.query(~query=module(Query.GetAllFeeds), ())->JsPromise.map(result => {
  switch result {
  | Ok({data: {feeds}}) =>
    let _feedFetching = feeds->Array.reduce(Js.Promise.resolve(), (
      previousPromise,
      {id: feedId, name},
    ) => {
      previousPromise->JsPromise.then(_ => {
        let feedData = ref("number,timestamp,value")
        let finishedProcessing = ref(false)
        let offset = ref(0)

        promiseWhile(
          () => !finishedProcessing.contents,
          _ => {
            client.query(
              ~query=module(Query.GetFeedData),
              Query.GetFeedData.makeVariables(~offset=offset.contents, ~feedId, ()),
            )->JsPromise.map(result => {
              Js.log(
                `making another query, with parameters offset=${offset.contents->Int.toString} and feedId=${feedId}`,
              )
              switch result {
              | Ok({data: {feed: Some({rounds})}}) =>
                let _processRound = rounds->Array.map(({number, unixTimestamp, value}) => {
                  feedData :=
                    feedData.contents ++
                    `\n${number->BN.toString},${unixTimestamp->Int.toString},${value->Option.mapWithDefault(
                        "0",
                        BN.toString,
                      )}`
                  ()
                })
                offset := offset.contents + 1000
                if rounds->Array.length < 1000 {
                  finishedProcessing := true
                }
              | Ok({data: {feed: None}}) => Js.log("No data available")
              | Error(error) =>
                finishedProcessing := true
                Js.log2(
                  `Error error making round query with parameters offset=${offset.contents->Int.toString} and feedId=${feedId}: `,
                  error,
                )
              }
            })
          },
        )->JsPromise.map(_ =>
          Node.Fs.writeFileAsUtf8Sync(
            `../rawData/${name->Js.String2.replace("/", "--")}.csv`,
            feedData.contents,
          )
        )
      })
    })
  | Error(error) => Js.log2("Error (with GetAllFeeds): ", error)
  }
})
