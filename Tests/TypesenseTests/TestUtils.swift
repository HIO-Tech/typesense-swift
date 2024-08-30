import Typesense
let NODES = [Node(host: "localhost", port: "8108", nodeProtocol: "http")]
let CONFIG = Configuration(nodes: NODES, apiKey: "xyz", logger: Logger(debugMode: true))
let client = Client(config: CONFIG)
let utilClient = Client(config: Configuration(nodes: NODES, apiKey: "xyz"))

func tearDownCollections() async throws {
    let (collResp, _) = try await utilClient.collections.retrieveAll()
    guard let validData = collResp else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try await utilClient.collection(name: item.name).delete()
    }
}

func tearDownPresets() async throws {
    let (presets, _) = try await utilClient.presets().retrieve()
    guard let validData = presets else {
        throw DataError.dataNotFound
    }
    for item in validData.presets {
        let _ = try await utilClient.preset(item.name).delete()
    }
}

func tearDownStopwords() async throws {
    let (data, _) = try await utilClient.stopwords().retrieve()
    guard let validData = data else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try await utilClient.stopword(item._id).delete()
    }
}

func tearDownAnalyticsRules() async throws {
    let (data, _) = try await utilClient.analytics().rules().retrieveAll()
    guard let validData = data?.rules else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try await utilClient.analytics().rule(id: item.name).delete()
    }
}

func tearDownAPIKeys() async throws {
    let (data, _) = try await utilClient.keys().retrieve()
    guard let validData = data?.keys else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try await utilClient.keys().delete(id: item._id)
    }
}

func tearDownAliases() async throws {
    let (data, _) = try await utilClient.aliases().retrieve()
    guard let validData = data?.aliases else {
        throw DataError.dataNotFound
    }
    for item in validData {
        let _ = try await utilClient.aliases().delete(name: item.name)
    }
}

func createCollection() async throws {
    let schema = CollectionSchema(name: "companies", fields: [
        Field(name: "company_name", type: "string"),
        Field(name: "num_employees", type: "int32", facet: true),
        Field(name: "country", type: "string", facet: true),
        Field(name: "metadata", type: "object", _optional: true, facet: true)
    ], defaultSortingField: "num_employees", enableNestedFields: true)
    let _ = try await utilClient.collections.create(schema: schema)
}

func createDocument() async throws {
    let data = try encoder.encode(Company(id: "test-id", company_name: "Stark Industries", num_employees: 5215, country: "USA", metadata: ["open":false]))
    let _ = try await utilClient.collection(name: "companies").documents().create(document: data)
}

func createAnOverride() async throws {
    let _ = try await utilClient.collection(name: "companies").overrides().upsert(
        overrideId: "test-id",
        params: SearchOverrideSchema<SearchOverrideExclude>(rule: SearchOverrideRule(filterBy: "test"), filterBy: "test:=true", metadata: SearchOverrideExclude(_id: "exclude-id"))
    )
}

func createSingleCollectionSearchPreset() async throws {
    let _ = try await utilClient.presets().upsert(
        presetName: "test-id",
        params: PresetUpsertSchema(
            value: .singleCollectionSearch(SearchParameters(q: "apple"))
        )
    )
}

func createMultiSearchPreset() async throws {
    let _ = try await utilClient.presets().upsert(
        presetName: "test-id-preset-multi-search",
        params: PresetUpsertSchema(
            value: .multiSearch(MultiSearchSearchesParameter(searches: [MultiSearchCollectionParameters(q: "banana")]))
        )
    )
}

func createStopwordSet() async throws {
    let _ = try await utilClient.stopwords().upsert(
        stopwordsSetId: "test-id-stopword-set",
        params: StopwordsSetUpsertSchema(
            stopwords: ["states","united"],
            locale: "en"
        )
    )
}

func createAnalyticRule() async throws {
    let _ = try await utilClient.analytics().rules().upsert(params: AnalyticsRuleSchema(
        name: "product_queries_aggregation",
        type: .counter,
        params: AnalyticsRuleParameters(
            source: AnalyticsRuleParametersSource(collections: ["products"], events: [AnalyticsRuleParametersSourceEvents(type: "click", weight: 1, name: "products_click_event")]),
            destination: AnalyticsRuleParametersDestination(collection: "companies", counterField: "num_employees"),
            limit: 1000
            )
        )
    )
}

func createAPIKey() async throws -> ApiKey {
    let (data, _) =  try await utilClient.keys().create( ApiKeySchema(_description: "Test key with all privileges", actions: ["*"], collections: ["*"]))
    return data!
}

func createAlias() async throws {
    let _ =  try await utilClient.aliases().upsert(name: "companies", collection:  CollectionAliasSchema(collectionName: "companies_june"))
}

func createConversationCollection() async throws {
    let schema = CollectionSchema(name: "conversation_store", fields: [
        Field(name: "conversation_id", type: "string"),
        Field(name: "model_id", type: "string"),
        Field(name: "timestamp", type: "int32"),
        Field(name: "role", type: "string", index: false),
        Field(name: "message", type: "string", index: false)
    ])
    let _ = try await utilClient.collections.create(schema: schema)
}

struct Product: Codable, Equatable {
    var name: String?
    var price: Int?
    var brand: String?
    var desc: String?

    static func == (lhs: Product, rhs: Product) -> Bool {
            return
                lhs.name == rhs.name &&
                lhs.price == rhs.price &&
                lhs.brand == rhs.brand &&
                lhs.desc == rhs.desc
    }
}

//Example Struct to match the Companies Collection
struct Company: Codable {
    var id: String
    var company_name: String
    var num_employees: Int
    var country: String
    var metadata: [String: Bool]?
}