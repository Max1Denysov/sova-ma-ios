//
//  AssistantModel.swift
//  SOVA
//
//  Created by Мурат Камалов on 02.10.2020.
//

import Foundation
import UIKit

struct Assitant: Codable{
    var id: String = UUID().uuidString
    var name: String
    
    var wordActive: Bool = false
    var word: String? = nil
    
    var url: URL
    var uuid: UUID
    var cuid: UUID? = nil
    var euid: UUID? = nil
//    var context: [String: Any]? = nil
    
    var messageListId: [String] = []
    
    func save(){
        let encoder = JSONEncoder()
        guard let encoded = try? encoder.encode(self) else { return }
        UserDefaults.standard.setValue(encoded, forKey: self.id)
        guard DataManager.shared.assistantsId.contains(where: {$0 == self.id}) == false else { return }
        //Никогда не будет nil т.к до этого обращаемся к assistants, который собирает потом _assitants
        DataManager.shared._assitantsId?.append(self.id)
    }
    
    func delete(){
        UserDefaults.standard.removeObject(forKey: self.id)
    }
    
}
