import Foundation

struct GameData {
    static let defaultPeggleMaster = peggleMasters["battler"]!
    static let peggleMasters: [String: PeggleMaster] = [
        "beatrice": PeggleMaster(
            id: "beatrice",
            name: "Beatrice",
            age: 100,
            title: "The Endless Witch",
            description: "",
            special: .spooky()
        ),
        "battler": PeggleMaster(
            id: "battler",
            name: "Battler",
            age: 18,
            title: "The Endless Sorcerer",
            description: "",
            special: .spooky()
        ),
        "maria": PeggleMaster(
            id: "maria",
            name: "Maria",
            age: 9,
            title: "The Witch of Origins",
            description: "",
            special: .multiball
        ),
        "krauss": PeggleMaster(
            id: "krauss",
            name: "Krauss",
            age: 52,
            title: "Visionary Investor, Crypto Guru, NFT Trader",
            description: "",
            special: .moonTourist
        ),
        "featherine": PeggleMaster(
            id: "featherine",
            name: "Featherine Augustus Aurora",
            age: 10_000,
            title: "The Witch of Theatergoing",
            description: "",
            special: .author
        ),
        "lambdadelta": PeggleMaster(
            id: "lambdadelta",
            name: "Lambdadelta",
            age: 1000,
            title: "The Witch of Certainty",
            description: "",
            special: .smallBombs
        )
    ]
}
