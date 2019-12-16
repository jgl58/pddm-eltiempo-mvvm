//
//  TiempoViewModel.swift
//  ElTiempo
//
//  Created by Jonay Gilabert López on 16/12/2019.
//  Copyright © 2019 Universidad de Alicante. All rights reserved.
//

import Foundation
import Bond

class TiempoViewModel{
    let estado = Observable<String>("")
    let modelo = TiempoModelo()
    
    func consultarTiempo(de localidad : String) {
        self.modelo.consultarTiempo(localidad: localidad){
            tiempo, url in
            self.estado.value = tiempo
            print("Estado: "+tiempo)
        }
    }
    
}
