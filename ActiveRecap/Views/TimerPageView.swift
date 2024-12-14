//
//  TimerPageView.swift
//  ActiveRecap
//
//  Created by Jacob Heathcoat on 12/13/24.
//

import SwiftUI
import UIKit

class PageVC: UIViewController {
    let pageIndex: Int
    let contentView: UIView
    
    init(index: Int, content: UIView) {
        self.pageIndex = index
        self.contentView = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        contentView.frame = view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

class TimerPageViewController: UIPageViewController {
    let pages: [PageVC]
    let timerProgress = UIPageControlTimerProgress(preferredDuration: 4)
    let pageControl = UIPageControl()
    var suspensionTimer: Timer?
    
    init(pages: [PageVC]) {
        self.pages = pages
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        self.setViewControllers([pages.first!], direction: .forward, animated: true)
        
        addPagerControlGradient()
        configurePageControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerProgress.resumeTimer()
    }
    
    func configurePageControl() {
        timerProgress.delegate = self
        timerProgress.resetsToInitialPageAfterEnd = false
        
        pageControl.numberOfPages = pages.count
        pageControl.progress = timerProgress
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func addPagerControlGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.cgColor]
        gradient.startPoint = .zero
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        self.view.layer.addSublayer(gradient)
    }
}

// Extensions for TimerPageViewController
extension TimerPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = getPageIndex(from: viewController)
        let previousIndex = currentIndex - 1 >= 0 ? currentIndex - 1 : nil
        return previousIndex.map { pages[$0] }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = getPageIndex(from: viewController)
        let nextIndex = currentIndex + 1 < pages.count ? currentIndex + 1 : nil
        return nextIndex.map { pages[$0] }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        timerProgress.pauseTimer()
        suspensionTimer?.invalidate()
        
        suspensionTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            self.timerProgress.resumeTimer()
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageControl.currentPage = getPageIndex(from: pageViewController.viewControllers?.first)
    }
    
    func getPageIndex(from viewController: UIViewController?) -> Int {
        (viewController as? PageVC)?.pageIndex ?? 0
    }
}

extension TimerPageViewController: UIPageControlTimerProgressDelegate {
    func pageControlTimerProgress(_ progress: UIPageControlTimerProgress, shouldAdvanceToPage page: Int) -> Bool {
        if page >= pages.count {
            // Dismiss the view when we've shown all pages
            return false
        }
        self.setViewControllers([pages[page]], direction: .forward, animated: true)
        return true
    }
}

struct TimerPageView: UIViewControllerRepresentable {
    var pages: [AnyView]
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> TimerPageViewController {
        let pageVCs = pages.enumerated().map { index, view in
            let hostController = UIHostingController(rootView: view)
            return PageVC(index: index, content: hostController.view)
        }
        let pageViewController = TimerPageViewController(pages: pageVCs)
        return pageViewController
    }
    
    func updateUIViewController(_ uiViewController: TimerPageViewController, context: Context) {}
}
