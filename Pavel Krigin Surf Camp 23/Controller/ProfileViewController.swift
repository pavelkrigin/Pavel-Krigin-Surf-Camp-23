//
//  ProfileViewController.swift
//  Pavel Krigin Surf Camp 23
//
//  Created by Pavel Krigin on 01.08.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - UI Elements

    // наполнение данныеми (то есть простановка фото или скилов)
    // должно быть не на момент инициализации,
    // а где-то в отдельной функции, например, fillData(from model: Model)
    // потому что эти данные приходят извне - из интернета, грузятся из памяти и тд
    // Понятно, что сейчас у данные зашиты в приложение, но это просто для теста
    // и концептуально правильно разделить логику заполнения данными и инициализацию UI элементов

    // убрав translatesAutoresizingMaskIntoConstraints ниже и данные,
    // получается сократить иниты самих UI элементов

    // обычно все UI элементы внутри UIView/UIViewController'a отмечаются private
    // потому что только сам родитель UIView/UIViewController может управлять своими детьми
    // это важно с архитектурной точки зрения - инкапсулирование логики

    // вообще можно по началу ввести для себя такое правило:
    // каждую переменную и функцию всегда делать private
    // а затем уже исходя из логики убирать этот модификатор по необходимости

    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        // чтобы картинка сохраняла свое соотношение сторон, а не растягивалась
        imageView.contentMode = .scaleAspectFill
        // закругляем углы radius = width / 2
        imageView.layer.cornerRadius = 50
        // просим картинку не вылезать за свои границы
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private let locationLabel = UILabel()

    // тут должна быть коллекция
    // в крайнем случае stack view
    // я предлагаю пойти самым простым путем - коллекцией с CompositionalLayout
    private lazy var skillsCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    )
    
    private let aboutTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        return textView
    }()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать", for: .normal)
        // таргет - это конкретная сущность, которая будет отвечать за обработку нажатия
        // тут - это сам контроллер, просто self

        // компилятор ругается, потому что иниты сабпропертей вызываются в ините самого объекта родителя
        // то есть вызывается ProfileViewController.init(), а в нем editButton.init()
        // соответствено получается, что в editButton.init() мы уже обращаемся к себе (self),
        // при этом self не закончил свою инициализацию, и в этот момент его просто нет.
        // поэтому добавляем  lazy var для нашей кнопки - то есть инитим кнопку не сразу, а только тогда, когда к ней первый раз обратятся.
        // это произойдет в setupUI()
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Data Source
    // Хотелось бы вынести данные из ViewController'a
    // Например, сделаем отдельный DataSource
    // у которого будет метод "получить данные" и "сохранить/изменить"
    // то есть всю работу с данными мы выносим из ViewController'a, который ответственен только за управление view

    // В зависимости от архитектуры dataSource будет либо создаваться тут, как сейчас,
    // либо прокидываться извне
    private let dataSource = ProfileDataSource()

    // достаем нашу модель из dataSource, а не создаем тут
    private var user: User {
        dataSource.fetchData()
    }

    private var isSkillsEditing = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Разделяем настройку UI и заполнение данными
        setupUI()
        fillData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        title = "Профиль"
        
        // Добавление UI элементов в иерархию представления

        // Чтобы не было такого большого количества дублирования кода, можно объединять subview в массивы
        // Также можно убрать $0.translatesAutoresizingMaskIntoConstraints = false из инициализации
        [
            photoImageView,
            taglineLabel,
            locationLabel,
            skillsCollectionView,
            aboutTextView,
            editButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Обозначение констрейтов
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 100),
            photoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            taglineLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 16),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            skillsCollectionView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            skillsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skillsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skillsCollectionView.heightAnchor.constraint(lessThanOrEqualToConstant: 150),
            
            aboutTextView.topAnchor.constraint(equalTo: skillsCollectionView.bottomAnchor, constant: 16),
            aboutTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aboutTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            aboutTextView.bottomAnchor.constraint(equalTo: editButton.topAnchor, constant: -16),

            editButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            editButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
        
        // Установка TableView
        skillsCollectionView.register(ProfileSkillCollectionViewCell.self, forCellWithReuseIdentifier: "ProfileSkillCollectionViewCell")
        skillsCollectionView.delegate = self
        skillsCollectionView.dataSource = self
    }

    private func fillData() {
        // Заполнение UI данными пользователя
        photoImageView.image = UIImage(named: user.photoString)
        taglineLabel.text = user.tagline
        locationLabel.text = user.location
        aboutTextView.text = user.about
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { sectionIndex, env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(80), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(56))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = .init(top: 12, leading: 0, bottom: 0, trailing: 0)
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }

    // MARK: - Button Actions
    @objc private func editButtonTapped() {
        let alertController = UIAlertController(title: "Режим редактирования",
                                                message: nil,
                                                preferredStyle: .actionSheet)

        // брать состояние из UI - плохо
        // на не коллекция/таблица должна говорить, редактируемый сейчас кейс или нет
        // а мы сами или в модели должны сохранять isEditing

        isSkillsEditing.toggle()

        if isSkillsEditing {
            // Сохранение изменений, если таблица находится в режиме редактирования
            let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
                self?.editButton.setTitle("Редактировать", for: .normal)
            }
            alertController.addAction(saveAction)
        } else {
            // Вход в режим редактирования
            let editAction = UIAlertAction(title: "Редактировать", style: .default) { [weak self] _ in
                self?.editButton.setTitle("Готово", for: .normal)
            }
            alertController.addAction(editAction)
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

// так как перешли на коллекцию, меняем протоколы

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {

    // В нажатии на ячейки для добавления/удаления скила
    // мы уже не сами редактируем юзера, а просим это сделать dataSource

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.deleteSkill(at: indexPath.item)
        // возможно, понадобится еще collectionView.reloadData()
    }

}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        user.skills.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileSkillCollectionViewCell", for: indexPath) as! ProfileSkillCollectionViewCell
        cell.configure(title: user.skills[indexPath.row])
        return cell
    }

}
