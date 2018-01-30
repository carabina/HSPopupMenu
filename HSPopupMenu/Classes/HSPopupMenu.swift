//
//  HSPopupMenu.swift
//  HSPopupMenu
//
//  Created by Hanson on 2018/1/30.
//

import Foundation

fileprivate let ScreenWidth = UIScreen.main.bounds.width
fileprivate let ScreenHeight = UIScreen.main.bounds.height


// MARK: - HSMenu

struct HSMenu {
    var icon: UIImage?
    var title: String?
}


// MARK: - HSPopupMenuDelegate

@objc protocol HSPopupMenuDelegate {
    
    func popupMenu(_ popupMenu: HSPopupMenu, didSelectAt index: Int)
}


// MARK: - HSPopupMenu

enum HSPopupMenuArrowPosition {
    case left
    case right
}

class HSPopupMenu: UIView {
    
    var menuCellSize: CGSize = CGSize(width: 130, height: 44)
    var menuTextFont: UIFont = .systemFont(ofSize: 15)
    var menuTextColor: UIColor = .black
    var menuBackgroundColor: UIColor = .white
    var menuLineColor: UIColor = .black
    
    var arrowWidth: CGFloat = 10
    var arrowHeight: CGFloat = 10
    var arrowOffset: CGFloat = 10
    var arrowPoint: CGPoint = .zero
    var arrowPosition: HSPopupMenuArrowPosition = .right
    
    var contentBgColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    
    weak var delegate: HSPopupMenuDelegate?
    
    fileprivate let CellID = "HSPopupMenuCell"

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.white
        tableView.bounces = false
        tableView.layer.cornerRadius = 5
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(HSPopupMenuCell.self, forCellReuseIdentifier: CellID)
        return tableView
    }()
    
    var menuArray: [HSMenu] = [] {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Initialization
    
    public init(menuArray: [HSMenu], arrowPoint: CGPoint,
         cellSize: CGSize = CGSize(width: 130, height: 44),
         arrowPosition: HSPopupMenuArrowPosition = .right,
         frame: CGRect = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)) {
        
        super.init(frame: frame)
        
        self.arrowPoint = arrowPoint
        self.menuCellSize = cellSize
        self.arrowPosition = arrowPosition
        self.backgroundColor = contentBgColor
        
        switch arrowPosition {
        case .left:
            tableView.frame = CGRect(x: arrowPoint.x - arrowWidth/2 - arrowOffset,
                                     y: arrowPoint.y + arrowHeight,
                                     width: cellSize.width,
                                     height: cellSize.height*CGFloat(menuArray.count))
        case .right:
            tableView.frame = CGRect(x: arrowPoint.x + arrowWidth/2 + arrowOffset,
                                     y: arrowPoint.y + arrowHeight,
                                     width: -cellSize.width,
                                     height: cellSize.height*CGFloat(menuArray.count))
        }
        
        self.addSubview(tableView)
        
        self.menuArray = menuArray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.beginPath()
        if self.arrowPosition == .left {
            let startX = self.arrowPoint.x - arrowWidth/2
            let startY = self.arrowPoint.y + arrowHeight
            context?.move(to: CGPoint(x: startX, y: startY))
            context?.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.y))
            context?.addLine(to: CGPoint(x: startX + arrowWidth, y: startY))
        } else {
            let startX = self.arrowPoint.x + arrowWidth/2
            let startY = self.arrowPoint.y + arrowHeight
            context?.move(to: CGPoint(x: startX, y: startY))
            context?.addLine(to: CGPoint(x: self.arrowPoint.x, y: self.arrowPoint.x))
            context?.addLine(to: CGPoint(x: startX - arrowWidth, y: startY))
        }
        context?.closePath()
        self.tableView.backgroundColor?.setFill()
        self.tableView.backgroundColor?.setStroke()
        context?.drawPath(using: .fillStroke)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}


// MARK: - Public Function

extension HSPopupMenu {
    
    public func popUp() {
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        let frame = self.tableView.frame
        self.tableView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: 0, height: 0)
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame = frame
        }
    }
    
    public func dismiss() {
        UIView.animate(withDuration: 0.2, animations: {
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x, y: self.tableView.frame.origin.y, width: 0, height: 0)
        }) { (finished) in
            self.removeFromSuperview()
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension HSPopupMenu: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.menuCellSize.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID, for: indexPath) as! HSPopupMenuCell
        let menu = self.menuArray[indexPath.row]
        cell.configureCell(menu: menu)
        cell.titleLabel.font = menuTextFont
        cell.titleLabel.textColor = menuTextColor
        cell.line.isHidden = (indexPath.row < menuArray.count - 1) ? false : true
        cell.line.backgroundColor = menuLineColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.delegate?.popupMenu(self, didSelectAt: indexPath.row)
    }
}