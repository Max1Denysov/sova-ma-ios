//
//  BtnsCollectionView.swift
//  SOVA
//
//  Created by Мурат Камалов on 18.10.2020.
//

import UIKit

class BtnsCollectonView: UICollectionView{
    
    private var model = [String](){
        didSet{
            guard oldValue != self.model else { return }
            self.reloadData()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        super.init(frame: frame, collectionViewLayout: layout)
        self.isPagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = UIColor(named: "Colors/mainbacground")
        self.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        self.register(BtnsCell.self, forCellWithReuseIdentifier: "BtnsCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: [String]){
        self.model = data
    }
}

extension BtnsCollectonView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BtnsCell", for: indexPath) as? BtnsCell else { return UICollectionViewCell()}
        cell.text = "1-4 класс"
        return cell
    }
}

extension BtnsCollectonView: UICollectionViewDelegate{
    
}

//MARK: BtnsCell
class BtnsCell: UICollectionViewCell{
    
    private var label = UILabel()
    
    public var text: String = "" {
        didSet{
            self.label.text = self.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(named: "Colors/mainbacground")
        self.layer.cornerRadius = 17
        self.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.layer.borderColor = UIColor(named: "Colors/textColor")?.cgColor
        self.layer.borderWidth = 1
        
        self.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        self.label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12).isActive = true
        self.label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
