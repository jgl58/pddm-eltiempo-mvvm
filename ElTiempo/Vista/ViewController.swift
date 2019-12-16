//
//  ViewController.swift
//  ElTiempo
//
//  Created by Otto Colomina Pardo on 2/10/16.
//  Copyright © 2016 Universidad de Alicante. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate {
    let viewModel = TiempoViewModel()
    
    @IBOutlet weak var estadoLabel: UILabel!    
    @IBOutlet weak var estadoImagen: UIImageView!
    @IBOutlet weak var localidadField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //consultarTiempo(localidad: "Madrid")
        localidadField.delegate = self
        self.viewModel.estado.bind(to:self.estadoLabel.reactive.text)
        self.viewModel.icono
            .filter {
                icon in
                return (icon != "") ? true : false
        }
        .map {
            imagen in
            let url = URL(string:imagen)
            let datos = try! Data(contentsOf: url!)
            return UIImage(data: datos)!
        }
        .bind(to:self.estadoImagen.reactive.image)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func consultarTiempoPulsado(_ sender: AnyObject) {
        if let loc = self.localidadField.text {
            self.viewModel.consultarTiempo(de: loc)
        }
    }
    
    
}

