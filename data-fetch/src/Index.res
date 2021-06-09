Dotenv.config()
@val external optGraphEndpoint: option<string> = "process.env.GRAPH_ENDPOINT"

let graphEndpoint = optGraphEndpoint->Option.getWithDefault("https://thegraph.com/something/something/default")

createInstance(~graphqlEndpoint="https://api.thegraph.com/subgraphs/name/alejandro-larumbe/chainlink-matic-mainnet")
