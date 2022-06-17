//
//  AddNewVBCViewController.swift
//  VBC
//
//  Created by VELJKO on 14.11.21..
//

import UIKit

class AddNewCardVC: UIViewController {

    // MARK: - Top View
    private let topView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        
        
        return view
    }()
    
    private let logoImage : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "LogoImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
         return imageView
    }()
    
    // MARK: - Scroll View and Page Controll
    private let scrollView = UIScrollView()
    
    private let pageControl : UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.isUserInteractionEnabled = false
        pageControl.tintColor = UIColor.systemGreen
        return pageControl
    }()
  
    // MARK: - Company Stack
    private let companyStack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        
        return stack
    }()
    
    private let companyTextStack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 30
        
        return stack
    }()
    
    private let companyText : UILabel = {
        let label = UILabel()
        label.text = "Company Card"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "Reverse Background Color")
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let companyText2 : UILabel = {
        let label = UILabel()
        label.text = "This Card will be used for your Company.\n\nWhen you create Company Card, others will be able to Find and Contact your Company much easier."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(named: "Reverse Background Color")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var companyButton : UIButton = {
        let button = UIButton()
        button.setTitle("Create Company VBC", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor(named: "Color Dark"), for: .normal)
        button.backgroundColor = UIColor.systemOrange
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(createCompanyVBCPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        return button
    }()
    
    // MARK: - Personal Stack
    private let personalStack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        
        return stack
    }()
    
    private let personalTextStack : UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 30
        
        return stack
    }()
    
    private let personalText : UILabel = {
        let label = UILabel()
        label.text = "Personal Card"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(named: "Reverse Background Color")
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let personalText2 : UILabel = {
        let label = UILabel()
        label.text = "This Card will be used as your Personal Card.\n\nWhen you create Personal Card, other Business people can stay in touch with you very easy."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(named: "Reverse Background Color")
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var personalButton : UIButton = {
        let button = UIButton()
        button.setTitle("Create Personal VBC", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(UIColor(named: "Color Silver"), for: .normal)
        button.backgroundColor = UIColor(named: "Color Dark Blue")
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(createPersonalVBCPressed), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        
        return button
    }()
    
    
    private var createCompanyCard : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        pageControl.addTarget(self,
                              action: #selector(pageControlChanged(_:)),
                              for: .valueChanged)
        
        view.addSubview(topView)
        topView.addSubview(logoImage)
        view.addSubview(scrollView)
        view.addSubview(pageControl)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureTopView()
        
        pageControl.frame = CGRect(x: 0,
                                   y: view.frame.size.height - 50,
                                   width: view.frame.size.width,
                                   height: 30)
        
        scrollView.frame = CGRect(x: 0,
                                  y: view.frame.size.height / 2,
                                  width: view.frame.size.width,
                                  height: view.frame.size.height/2)
        
        if scrollView.subviews.count == 2 {
            configureScrollView()
        }
    }
    
    // MARK: - Configure ScrollView and Pages
    private func configureScrollView() {
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: view.frame.size.width * 2,
                                        height: scrollView.frame.size.height)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        for x in 0..<2 {
            let page = UIView(frame: CGRect(x: CGFloat(x) * view.frame.size.width,
                                            y: 0,
                                            width: view.frame.size.width,
                                            height: scrollView.frame.size.height))
            
            if x == 0 {
                page.addSubview(companyStack)
                companyStack.addSubview(companyTextStack)
                companyStack.addSubview(companyButton)
                companyTextStack.addArrangedSubview(companyText)
                companyTextStack.addArrangedSubview(companyText2)
                
                // Company Stack Constraints
                companyStack.topAnchor.constraint(equalTo: page.topAnchor).isActive = true
                companyStack.bottomAnchor.constraint(equalTo: page.bottomAnchor, constant: -90).isActive = true
                companyStack.leftAnchor.constraint(equalTo: page.leftAnchor).isActive = true
                companyStack.rightAnchor.constraint(equalTo: page.rightAnchor).isActive = true
                // Company Text Stack Constraints
                companyTextStack.topAnchor.constraint(equalTo: companyStack.topAnchor, constant: 10).isActive = true
                companyTextStack.leftAnchor.constraint(equalTo: companyStack.leftAnchor, constant: 10).isActive = true
                companyTextStack.rightAnchor.constraint(equalTo: companyStack.rightAnchor, constant: -10).isActive = true
                // Company Text UILabel Constraints
                companyText.centerXAnchor.constraint(equalTo: companyTextStack.centerXAnchor).isActive = true
                companyText2.centerXAnchor.constraint(equalTo: companyTextStack.centerXAnchor).isActive = true
                // Company Button Constraints
                companyButton.centerXAnchor.constraint(equalTo: companyStack.centerXAnchor).isActive = true
                companyButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
                companyButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
                companyButton.bottomAnchor.constraint(equalTo: companyStack.bottomAnchor).isActive = true
            
            } else if x == 1 {
                page.addSubview(personalStack)
                personalStack.addSubview(personalTextStack)
                personalStack.addSubview(personalButton)
                personalTextStack.addArrangedSubview(personalText)
                personalTextStack.addArrangedSubview(personalText2)
                
                // Personal Stack Constraints
                personalStack.topAnchor.constraint(equalTo: page.topAnchor).isActive = true
                personalStack.bottomAnchor.constraint(equalTo: page.bottomAnchor, constant: -90).isActive = true
                personalStack.leftAnchor.constraint(equalTo: page.leftAnchor).isActive = true
                personalStack.rightAnchor.constraint(equalTo: page.rightAnchor).isActive = true
                // Personal Text Stack Constraints
                personalTextStack.topAnchor.constraint(equalTo: personalStack.topAnchor, constant: 10).isActive = true
                personalTextStack.leftAnchor.constraint(equalTo: personalStack.leftAnchor, constant: 10).isActive = true
                personalTextStack.rightAnchor.constraint(equalTo: personalStack.rightAnchor, constant: -10).isActive = true
                // Personal Text UILabel Constraints
                personalText.centerXAnchor.constraint(equalTo: personalTextStack.centerXAnchor).isActive = true
                personalText2.centerXAnchor.constraint(equalTo: personalTextStack.centerXAnchor).isActive = true
                // Personal Button Constraints
                personalButton.centerXAnchor.constraint(equalTo: personalStack.centerXAnchor).isActive = true
                personalButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
                personalButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
                personalButton.bottomAnchor.constraint(equalTo: personalStack.bottomAnchor).isActive = true
            }
            scrollView.addSubview(page)
        }
    }
    
    // MARK: - Configure Top View with Logo Image
    private func configureTopView() {
        
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topView.bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        logoImage.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        
        logoImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        logoImage.widthAnchor.constraint(equalTo: logoImage.heightAnchor).isActive = true
    }
    
    // MARK: - Create Company Button Pressed
    @objc func createCompanyVBCPressed() {
        createCompanyCard = true
        performSegue(withIdentifier: Constants.Segue.addNew1, sender: self)
    }
    
    // MARK: - Create Personal Button Pressed
    @objc func createPersonalVBCPressed() {
        createCompanyCard = false
        performSegue(withIdentifier: Constants.Segue.addNew1, sender: self)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segue.addNew1 {
            
            let destinationVC = segue.destination as! AddStep1VC
            destinationVC.companyCard = createCompanyCard
        }
    }
    
}

// MARK: - ScrollView Delegate and Page Control Changed
extension AddNewCardVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.size.width)))
    }
    
    @objc private func pageControlChanged(_ sender: UIPageControl) {
        let current = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(current) * view.frame.size.width, y: 0), animated: true)
    }
}
