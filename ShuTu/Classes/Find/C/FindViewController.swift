//
//  FindViewController.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/7.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class FindViewController: BaseViewController {

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.register(UINib(nibName: "FindGayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width = SW
            self.collectionView.showsVerticalScrollIndicator = false
            self.collectionView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var pin1: UIView! {
        didSet {
            self.pin1.layer.cornerRadius = 1.5
            self.pin1.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var pin2: UIView! {
        didSet {
            self.pin2.layer.cornerRadius = 1.5
            self.pin2.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var pagerView1: FSPagerView! {
        didSet {
            self.pagerView1.tag = 10003
            self.pagerView1.register(UINib(nibName: "FindHotCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "findHotPagerCell")
            self.pagerView1.itemSize = CGSize.init(width: SW - 40, height: 100)
            self.pagerView1.interitemSpacing = 4
        }
    }
    @IBOutlet weak var pagerView2: FSPagerView! {
        didSet {
            self.pagerView2.tag = 10004
            self.pagerView2.register(UINib(nibName: "FindYetCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "findYetPagerCell")
            self.pagerView2.itemSize = CGSize.init(width: SW - 40, height: 100)
            self.pagerView2.interitemSpacing = 4
        }
    }
    @IBOutlet weak var thumbnail: UIImageView! {
        didSet {
                self.thumbnail.layer.cornerRadius = self.thumbnail.frame.height/2
            self.thumbnail.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindRx()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //私有成员
    fileprivate var disposeBag = DisposeBag()
    fileprivate var viewModel: FindViewModel!
    fileprivate lazy var emptyView1: EmptyView = {
        return EmptyView.init(target: self.pagerView1)
    }()
    fileprivate lazy var emptyView2: EmptyView = {
        return EmptyView.init(target: self.pagerView2)
    }()
    fileprivate lazy var emptyView3: EmptyView = {
        return EmptyView.init(target: self.collectionView)
    }()
    fileprivate var models1: [Debate] = []
    fileprivate var models2: [DebateCollect] = []
    fileprivate var models3: [User] = []

}

extension FindViewController {
    //初始化
    fileprivate func setupUI() {
        //CollectionView
        self.collectionViewHeightConstraint.constant = 62 * 3
    }
    fileprivate func bindRx() {
        //ViewModel
        self.viewModel = FindViewModel.init(disposeBag: disposeBag)
        viewModel.outputs.models1.asObservable()
            .subscribe(onNext: { [weak self] response in
                let data = response.0
                let result = response.1
                switch result {
                case .failed:
                    self?.emptyView1.show(type: .empty2, frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: (self?.pagerView1.frame.height)!)))
                    break
                case .ok:
                    self?.models1 = data
                    self?.emptyView1.hide()
                    self?.pagerView1.reloadData()
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.models2.asObservable()
            .subscribe(onNext: { [weak self] response in
                let data = response.0
                let result = response.1
                switch result {
                case .failed:
                    guard let _ = self else { return }
                    self!.emptyView2.show(type: .empty2, frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: self!.pagerView2.frame.height)))
                    break
                case .ok:
                    self?.models2 = data
                    self?.emptyView2.hide()
                    self?.pagerView2.reloadData()
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        viewModel.outputs.models3.asObservable()
            .subscribe(onNext: { [weak self] response in
                let data = response.0
                let result = response.1
                switch result {
                case .failed:
                    guard let _ = self else { return }
                    self!.emptyView3.show(type: .empty2, frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: self!.collectionView.frame.height)))
                    break
                case .ok:
                    self?.models3 = data
                    self?.emptyView3.hide()
                    self?.collectionView.reloadData()
                    break
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //加载数据
        viewModel.inputs.refreshNewData1.onNext(true)
        self.emptyView1.show(type: .loading(type: .indicator1), frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: self.pagerView1.frame.height)))
        viewModel.inputs.refreshNewData2.onNext(true)
        self.emptyView2.show(type: .loading(type: .indicator1), frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: self.pagerView2.frame.height)))
        viewModel.inputs.refreshNewData3.onNext(true)
        self.emptyView3.show(type: .loading(type: .indicator1), frame: CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: CGSize.init(width: SW, height: self.collectionView.frame.height)))
    }
}

extension FindViewController: FSPagerViewDelegate, FSPagerViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    //FSPagerView Delegate && DataSource
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        if pagerView.tag == 10003 {
            return self.models1.count
        } else {
            return self.models2.count
        }
    }
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if pagerView.tag == 10003 {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "findHotPagerCell", at: index) as! FindHotCollectionViewCell
            cell.title.text = self.models1[index].title
            cell.score.text = "\(self.models1[index].supports ?? 0)声援 \(self.models1[index].opposes ?? 0)殊途"
            
            return cell
        } else {
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "findYetPagerCell", at: index) as! FindYetCollectionViewCell
            cell.title.text = self.models2[index].title
            cell.id = self.models2[index].topicid
            cell.disposeBag = self.disposeBag
            if cell.viewModel == nil {
                cell.viewModel = self.viewModel
            }
            
            return cell
        }
    }
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
        pagerView.scrollToItem(at: index, animated: true)
    }
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
    //CollectionViewDelegate && DataSource
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.models3.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FindGayCollectionViewCell
        cell.thumbnail.kf.setImage(with: URL.init(string: self.models3[indexPath.row].portrait!)!)
        cell.name.text = self.models3[indexPath.row].nickname
        cell.sign.text = self.models3[indexPath.row].signature
        cell.id = self.models3[indexPath.row].id
        cell.disposeBag = self.disposeBag
        if cell.viewModel == nil {
            cell.viewModel = self.viewModel
        }
        
        return cell
    }
}
