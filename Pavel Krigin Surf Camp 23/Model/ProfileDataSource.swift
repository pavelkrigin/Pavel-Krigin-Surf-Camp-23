//
//  ProfileDataSource.swift
//  Pavel Krigin Surf Camp 23
//
//  Created by Дарья Леонова on 16.09.2023.
//

import Foundation

final class ProfileDataSource {

    private var user = User(name: "Павел Кригин",
                            tagline: "iOS разработчик, опыт менее года",
                            location: "Подгорица",
                            about: "Researcher of SWIFT and technologies in the field of iOS development. I am undergoing intensive training. At the moment I know the basics of SWIFT. Participant of 24 hours Hackaton, with the team, we have been developing a new boat-sharing service for the Adriatic coast, https://flshackathon.com.",
                            skills: ["ООП и SOLID", "MVC/MVP/MVVM/VIPER", "UIKit", "SwiftUI"],
                            photoString: "Photo")

    func fetchData() -> User {
        user
    }

    func deleteSkill(at index: Int) {

    }

    func addSkill(_ skill: String) {
        
    }

}
