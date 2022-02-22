import Foundation

struct GameData {
    static let defaultPeggleMaster = peggleMastersMap["battler"]!
    static let peggleMastersMap: [String: PeggleMaster] = [
        "beatrice": PeggleMaster(
            id: "beatrice",
            name: "Beatrice",
            title: "The Endless Witch",
            description: """
                The territory lord of Rokkenjima welcomes you to this 'video' game-board.
                No one else is more apt to start off this game with.
                """,
            special: .spooky()
        ),
        "battler": PeggleMaster(
            id: "battler",
            name: "Battler",
            title: "The Endless Sorcerer",
            description: "",
            special: .smallBombs
        ),
        "maria": PeggleMaster(
            id: "maria",
            name: "Maria",
            title: "The Witch of Origins",
            description: """
                As an apprentice witch, she has yet to master the endless magic.
                But as a future Creator, she can create many from none, or more aptly, 1 from 0.
                In this regard, she has surpassed even the endless witch.
                """,
            special: .multiball
        ),
        "krauss": PeggleMaster(
            id: "krauss",
            name: "Krauss",
            title: "Visionary",
            description: """
                Crypto Guru, NFT Trader, Moon tourism trailblazer.
                No one else is a bigger investor than he is, or maybe not...
                """,
            special: .moonTourist
        ),
        "featherine": PeggleMaster(
            id: "featherine",
            name: "Featherine Augustus Aurora",
            title: "The Witch of Theatergoing",
            description: """
                An ancient witch who has reached the realm of Creator,
                she has the free will to author her own tales, and rules.
                Omniscience is but within reach, if only she wishes for it.
                Warning: With great power comes great lag...
                """,
            special: .superDuperGuide()
        ),
        "lambdadelta": PeggleMaster(
            id: "lambdadelta",
            name: "Lambdadelta",
            title: "The Witch of Certainty",
            description: """
                Certainly made of candy.
                """,
            special: .blackHole
        ),
        "bernkastel": PeggleMaster(
            id: "bernkastel",
            name: "Bernkastel",
            title: "The Witch of Miracles",
            description: """
                An all-around asshole.
                Hates you, probably everyone else you know. Nipah.
                """,
            special: .iHatePeople
        )
    ]
    static let peggleMasters: [PeggleMaster] = [
        peggleMastersMap["beatrice"]!,
        peggleMastersMap["battler"]!,
        peggleMastersMap["maria"]!,
        peggleMastersMap["krauss"]!,
        peggleMastersMap["featherine"]!,
        peggleMastersMap["lambdadelta"]!,
        peggleMastersMap["bernkastel"]!
    ]
    struct AudioEffects {
        static let ahahaEffect = globalAudio.getSoundEffect(for: .ahaha)
        static let boingEffect = globalAudio.getSoundEffect(for: .boing)
        static let thunkEffect = globalAudio.getSoundEffect(for: .thunk)
        static let wheeEffect = globalAudio.getSoundEffect(for: .whee)
    }

    static func loadData() {
        // Remark: This triggers loading of sounds.
        // I believe audio is lazily loaded, without this, the game will freeze upon first load
        // of sound effect.
        _ = AudioEffects.ahahaEffect
    }
}
