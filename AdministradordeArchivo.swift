//
//  AdministradordeArchivo.swift
//  Proyect01
//
//  Created by Lambda on 6/11/24.
//

import Foundation
import SwiftUI

class AdministradordeArchivo: ObservableObject {
  
    func tiempodeconsumo() async throws -> String {
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
        //this is the return as algo
        return "Encendido"
     
        
    }
    
        func fun() async throws -> String {
            
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
       
        return "off"
            
        }
    
 
    
    
}
