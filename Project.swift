import ProjectDescription

let bundleId = "com.kaiquemagno.magnonetwork"
let mainName = "MagnoNetwork"
let projectt = Project(name: mainName,
                       organizationName: "Kaique Magno",
                       settings: nil,
                       targets: [
                        .init(name: mainName,
                              platform: .iOS,
                              product: .framework,
                              bundleId: bundleId,
                              infoPlist: "\(mainName)/Supporting Files/Info.plist",
                              sources: ["\(mainName)/Sources/**"],
                              resources: nil,
                              dependencies: [],
                              settings: nil),
                        .init(name: "\(mainName)Sample",
                              platform: .iOS,
                              product: .app,
                              bundleId: "\(bundleId).sample",
                              infoPlist: "\(mainName)Sample/Supporting Files/Info.plist",
                              sources: ["\(mainName)Sample/Sources/**"],
                              resources: ["\(mainName)Sample/Resources/**"],
                              dependencies: [
                                .target(name: mainName)
                              ],
                              settings: nil),
                        .init(name: "\(mainName)Tests",
                              platform: .iOS,
                              product: .unitTests,
                              bundleId: "\(bundleId).unit-tests",
                              infoPlist: "\(mainName)Tests/Supporting Files/Info.plist",
                              sources: ["\(mainName)Tests/Sources/**"],
                              resources: nil,
                              dependencies: [
                                .target(name: mainName)
                              ],
                              settings: nil),
                       ]
)
