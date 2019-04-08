//
//  ViewController.swift
//  Desappstre Keychain
//
//  Created by Adolfo Vera Blasco on 03/04/2019.
//  Copyright © 2019 desappstre {estudio}. All rights reserved.
//

import UIKit
import Foundation

import DesappstreSecureKit

internal class LoginViewController: UIViewController
{
    ///
    @IBOutlet private weak var textfieldAccount: UITextField!
    ///
    @IBOutlet private weak var textfieldPassword: UITextField!
    ///
    @IBOutlet private weak var labelMessage: UILabel!
    ///
    @IBOutlet private weak var buttonLogin: UIButton!
    ///
    @IBOutlet private weak var buttonDelete: UIButton!
    ///
    @IBOutlet private weak var buttonSave: UIButton!
    
    private var appSecurity: SecurityBC!
    
    //
    // MARK: - Life Cycle
    //
    
    /**
 
    */
    override internal func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.appSecurity = SecurityBC()
                
    }

    
    //
    // MARK: - Actions
    //
    
    /**
 
    */
    @IBAction private func handleLoginButtonTap(sender: UIButton) -> Void
    {
        guard let account = self.textfieldAccount.text,
              let password = self.textfieldPassword.text,
              (!account.isEmpty && !password.isEmpty)
        else
        {
            return
        }
        
        let user = User(named: account, withPassword: password)
        
        let searchResult = self.appSecurity.fetchUser(user)
        
        switch searchResult
        {
            case .success(let searchUser):
                if searchUser.password == user.password
                {
                    self.labelMessage.text = searchUser.description
                }
                else
                {
                    self.labelMessage.text = "Contraseña incorrecta"
                }
        
            case .failure(let error):
                switch error
                {
                    case .passwordNotFound:
                        self.labelMessage.text = "No hay ninguna password para el usuario \(account)"
                    @unknown default:
                        self.labelMessage.text = "Error al obtener la clave del Keychain"
                }
        }
    }
    
    /**
 
    */
    @IBAction private func handleSaveButtonTap(sender: UIButton) -> Void
    {
        guard let account = self.textfieldAccount.text,
            let password = self.textfieldPassword.text,
            (!account.isEmpty && !password.isEmpty)
            else
        {
            return
        }
        
        let user = User(named: account, withPassword: password)
        
        do
        {
            if self.appSecurity.existsUser(user)
            {
                try self.appSecurity.updateSecureUser(user)
                self.labelMessage.text = "Se ha actualizado la clave del usuario \(account)"
            }
            else
            {
                try self.appSecurity.saveSecureUser(user)
                self.labelMessage.text = "Nuevo elemento en el Keychain.\r\nUsuario: \(account)\r\nClave: \(password)"
            }
        }
        catch(KeychainError.malformedData)
        {
            self.labelMessage.text = "El contenido de la password no es legible"
        }
        catch(KeychainError.passwordNotFound)
        {
            self.labelMessage.text = "No hay ninguna password para el usuario \(account)"
        }
        catch(KeychainError.unknown(let status))
        {
            self.labelMessage.text = "Error \(status) al guardar la clave del Keychain"
        }
        catch
        {
            
        }
    }
    
    /**
 
    */
    @IBAction private func handleDeleteButtonTap(sender: UIButton) -> Void
    {
        guard let account = self.textfieldAccount.text,
            let password = self.textfieldPassword.text,
            (!account.isEmpty && !password.isEmpty)
            else
        {
            return
        }
        
        let user = User(named: account, withPassword: password)
        
        let result = Result { try self.appSecurity.deleteUser(user) }
        
        switch result
        {
            case .success:
                self.labelMessage.text = "Se ha borrado la clave para el usuario \(account)"
            
            case .failure(let error):
                switch (error as! KeychainError)
                {
                    case .passwordNotFound:
                        self.labelMessage.text = "No hay ninguna password para el usuario \(account)"
                    case .unknown(let status):
                        self.labelMessage.text = "Error \(status) al borrar la clave del Keychain"
                    @unknown default:
                        self.labelMessage.text = "Error al borrar la clave del Keychain"
                }
        }
    }
}

