//
//  ViewController.swift
//  Pavel Krigin Surf Camp 23
//
//  Created by Pavel Krigin on 01.08.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - UI Elements
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let taglineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let skillsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Data Source
    var user: User = User(name: "Павел Кригин",
                          tagline: "Краткий девиз пользователя",
                          location: "Место жительства пользователя",
                          about: "Текстовый блок о себе",
                          skills: ["ООП и SOLID", "MVC/MVP/MVVM/VIPER", "Навык 3"])

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .lightGray
        title = "Профиль"
        
        // Add UI elements to the view hierarchy
        view.addSubview(photoImageView)
        view.addSubview(taglineLabel)
        view.addSubview(locationLabel)
        view.addSubview(skillsTableView)
        view.addSubview(aboutTextView)
        view.addSubview(editButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // ... Add constraints for all UI elements ...
        ])
        
        // Заполнение UI данными пользователя
        taglineLabel.text = user.tagline
        locationLabel.text = user.location
        aboutTextView.text = user.about
        
        // Setup TableView
        skillsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SkillCell")
        skillsTableView.delegate = self
        skillsTableView.dataSource = self
    }

    // MARK: - Button Actions
    @objc private func editButtonTapped() {
        if skillsTableView.isEditing {
            // Сохранение изменений, если таблица находится в режиме редактирования
            skillsTableView.setEditing(false, animated: true)
            editButton.setTitle("Редактировать", for: .normal)
        } else {
            // Вход в режим редактирования
            skillsTableView.setEditing(true, animated: true)
            editButton.setTitle("Готово", for: .normal)
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.skills.count + (tableView.isEditing ? 1 : 0) // +1 для строки с плюсиком в режиме редактирования
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SkillCell", for: indexPath)
        
        if tableView.isEditing {
            // В режиме редактирования, добавляем строку с плюсиком для добавления нового навыка
            if indexPath.row == user.skills.count {
                cell.textLabel?.text = "Добавить навык"
                cell.textLabel?.textColor = .systemBlue
            } else {
                cell.textLabel?.text = user.skills[indexPath.row]
                cell.textLabel?.textColor = .black
            }
        } else {
            cell.textLabel?.text = user.skills[indexPath.row]
            cell.textLabel?.textColor = .black
        }
        
        return cell
    }
    
    // Разрешить перемещение строк в режиме редактирования
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing && indexPath.row < user.skills.count
    }
    
    // Обработка перемещения строк в режиме редактирования
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedSkill = user.skills.remove(at: sourceIndexPath.row)
        user.skills.insert(movedSkill, at: destinationIndexPath.row)
    }
    
    // Обработка нажатия на ячейку в режиме редактирования
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing && indexPath.row == user.skills.count {
            // Добавление нового навыка через UIAlertController
            let alertController = UIAlertController(title: "Добавить навык", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Введите название навыка"
            }
            let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
                guard let skill = alertController.textFields?.first?.text else { return }
                self?.user.skills.append(skill)
                self?.skillsTableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alertController.addAction(addAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // Разрешение или запрещение удаления ячейки в режиме редактирования
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView.isEditing && indexPath.row < user.skills.count
    }
    
    // Обработка удаления ячейки в режиме редактирования
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            user.skills.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
