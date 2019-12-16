//
//  TiempoModelo.swift
//  ElTiempo
//
//  Created by Otto Colomina Pardo on 13/2/17.
//  Copyright © 2017 Universidad de Alicante. All rights reserved.
//

import Foundation


class TiempoModelo {
    let OW_URL_BASE = "http://api.openweathermap.org/data/2.5/weather?lang=es&units=metric&appid=1adb13e22f23c3de1ca37f3be90763a9&q="
    let OW_URL_BASE_ICON = "http://openweathermap.org/img/w/"
    
    
    /*
       método para consultar el tiempo de una localidad. Asíncrono.
       Parámetros:
         - localidad
         - clausura o función que hace de callback, se llamará cuando el servidor nos devuelva el estado del tiempo. La clausura o función debe aceptar dos parámetros de tipo String:
              * la descripción del estado del tiempo (ej. "lluvia")
              * la url donde está el icono que lo representa
    */
    func consultarTiempo(localidad:String, callback: @escaping (String, String)-> Void) {
        let urlString = OW_URL_BASE+localidad
        let url = URL(string:urlString)
        let dataTask = URLSession.shared.dataTask(with: url!) {
            datos, respuesta, error in
            let jsonStd = try! JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String:AnyObject]
            let weather = jsonStd["weather"]! as! [AnyObject]
            let currentWeather = weather[0] as! [String:AnyObject]
            let descripcionEstado = currentWeather["description"]! as! String
            let icono = currentWeather["icon"]! as! String
            let urlIcono = self.OW_URL_BASE_ICON+icono+".png"
            callback(descripcionEstado,urlIcono)
        }
        dataTask.resume()
    }
}
