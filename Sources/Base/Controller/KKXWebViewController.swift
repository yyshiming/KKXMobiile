//
//  KKXWebViewController.swift
//  KKXMobile
//
//  Created by ming on 2021/5/10.
//

import UIKit
import WebKit

public typealias WebViewInterceptCallback = (KKXWebViewController) -> Void

open class KKXWebViewController: KKXViewController {
    
    // MARK: -------- Properties --------
    
    @objc
    public let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    
    /// 导航栏下方进度条
    public let progressView = UIProgressView(progressViewStyle: .bar)
        
    /// 给H5界面传cookies
    open var cookies: [String: Any] = [:]

    /// 是否显示菊花动画，默认false
    open var showActivity: Bool = false
    
    /// 是否显示进度条，默认true
    open var showProgress: Bool = true {
        didSet {
            progressView.isHidden = !showProgress
        }
    }
    /// 是否显示取消按钮，默认false
    open var showCancelItem: Bool = false {
        didSet {
            reloadRightItems()
        }
    }
    /// 是否显示刷新按钮，默认false
    open var showRefreshItem: Bool = false {
        didSet {
            reloadRightItems()
        }
    }
    
    /// 加载完毕后获取web content的高度
    public var didLoadDataHandler: ((CGFloat) -> Void)?
    
    open var url: URL? {
        didSet {
            load(url)
        }
    }
    
    /// html字符串
    open var htmlString: String? {
        didSet {
            loadHTMLString(htmlString)
        }
    }
    
    /// url拦截和回调
    public var intercepts: [String: WebViewInterceptCallback] {
        _intercepts
    }
    
    // MARK: -------- Public Function --------

    open func loadHTMLString(_ string: String?) {
        if let htmlString = string {
            webView.loadHTMLString(htmlString, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }
    
    open func load(_ url: URL?) {
        if let aUrl = url {
            webView.load(URLRequest(url: aUrl))
        }
    }
    
    open func reload() {
        webView.reload()
    }
    
    open func goBack() {
        webView.goBack()
    }
    
    open func goForward() {
        webView.goForward()
    }
    
    /// 清理缓存
    open func clearAllCaches() {
        let types: Set = [WKWebsiteDataTypeMemoryCache]
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: dateFrom) {
            
        }
    }
    
    /// 标题发生变化调用
    open func titleDidChanged(_ title: String) {
        
    }
    
    public func addIntercept(with urlString: String, callback: @escaping WebViewInterceptCallback) {
        _intercepts[urlString] = callback
    }
    
    // MARK: -------- Private Properties --------

    /// url拦截和回调
    private var _intercepts: [String: WebViewInterceptCallback] = [:]
    
    private var refreshItem: UIBarButtonItem!
    
    private var toolBar: UIToolbar!
    
    private var goBackItem: UIBarButtonItem!
    private var goForwardItem: UIBarButtonItem!
    
    private var toolBarHeight: CGFloat {
        view.kkxSafeAreaInsets.bottom + 49
    }
    
    private var webViewTitleObservation: NSKeyValueObservation?
    private var webViewProgressObservation: NSKeyValueObservation?
    private var webViewCanGoBackObservation: NSKeyValueObservation?
    private var webViewCanGoForwardObservation: NSKeyValueObservation?

    // MARK: -------- Init --------
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public init(htmlString: String?) {
        super.init(nibName: nil, bundle: nil)
        self.htmlString = htmlString
    }
    
    public init(url: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        webView.stopLoading()
        webView.navigationDelegate = nil
        webView.uiDelegate = nil
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSubviews()
        configureNavigationBar()
        configureProgressView()
        
        if !cookies.isEmpty {
            var source = "document.cookie="
            cookies.forEach { (key, value) in
                source.append("'\(key)=\(value)';")
            }
            let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webView.configuration.userContentController.addUserScript(userScript)
        }
        
        if url != nil {
            load(url)
        }
        else if htmlString != nil {
            loadHTMLString(htmlString)
        }
        
        webViewTitleObservation = observe(\.webView.title) { object, _ in
            if let title = object.webView.title,
               object.navigationItem.title == nil {
                object.navigationItem.title = title
                object.titleDidChanged(title)
            }
        }
        webViewProgressObservation = observe(\.webView.estimatedProgress) { object, _ in
            if object.showProgress {
                let progress = object.webView.estimatedProgress
                object.progressView.setProgress(Float(progress), animated: true)
                object.progressView.isHidden = (progress == 1.0)
            }
        }
        webViewCanGoBackObservation = observe(\.webView.title) { object, _ in
            object.reloadWebViewFrame()
        }
        webViewCanGoForwardObservation = observe(\.webView.title) { object, _ in
            object.reloadWebViewFrame()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        reloadWebViewFrame()
        if #available(iOS 13.0, *), UITraitCollection.current.userInterfaceStyle == .dark {
            webView.scrollView.indicatorStyle = .white
        } else {
            webView.scrollView.indicatorStyle = .default
        }
    }
    
    private func reloadWebViewFrame() {
        
        goBackItem.isEnabled = webView.canGoBack
        goForwardItem.isEnabled = webView.canGoForward
        toolBar.isHidden = !webView.canGoBack && !webView.canGoForward
        var webViewHeight = view.bounds.height
        if !toolBar.isHidden {
            let offset = -view.kkxSafeAreaInsets.bottom / 2
            goBackItem.setBackgroundVerticalPositionAdjustment(offset, for: .default)
            goForwardItem.setBackgroundVerticalPositionAdjustment(offset, for: .default)
            toolBar.frame = CGRect(x: 0, y: view.bounds.height - toolBarHeight, width: view.bounds.width, height: toolBarHeight)
            webViewHeight -= toolBarHeight
        }
        
        webView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: webViewHeight)
    }
    
    // MARK: -------- Configuration --------
    
    private func configureNavigationBar() {
        reloadRightItems()
    }
    
    private func configureSubviews() {
        webView.backgroundColor = UIColor.kkxMainBackground
        webView.isOpaque = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        
        if let interactiveGesture = navigationController?.interactivePopGestureRecognizer {
            webView.scrollView.panGestureRecognizer.require(toFail: interactiveGesture)
        }
        
        toolBar = UIToolbar(frame: CGRect(x: 0, y: view.bounds.height - toolBarHeight, width: view.bounds.width, height: toolBarHeight))
        
        view.addSubview(webView)
        view.addSubview(toolBar)
        
        let backConfiguration = UIImage.ItemConfiguration(direction: .left, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 12)
        let forwardConfiguration = UIImage.ItemConfiguration(direction: .right, lineWidth: 2.0, tintColor: .kkxAccessoryBar, width: 12)
        let goBackImage = UIImage.itemImage(with: backConfiguration)
        let goForwardImage = UIImage.itemImage(with: forwardConfiguration)
        
        goBackItem = UIBarButtonItem(image: goBackImage, style: .plain, target: self, action: #selector(goBackAction))
        goBackItem.tintColor = .kkxAccessoryBar
        goBackItem.isEnabled = false
        
        goForwardItem = UIBarButtonItem(image: goForwardImage, style: .plain, target: self, action: #selector(goForwardAction))
        goForwardItem.tintColor = .kkxAccessoryBar
        goForwardItem.isEnabled = false
        
        let fixedSpaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpaceItem.width = 60
        let flexibleSpaceItem1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexibleSpaceItem2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.items = [flexibleSpaceItem1, goBackItem, fixedSpaceItem, goForwardItem, flexibleSpaceItem2]
        toolBar.isHidden = true
        
        refreshItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
    }
    
    private func configureProgressView() {
        progressView.tintColor = UIColor.kkxSystemBlue
        view.addSubview(progressView)
        progressView.isHidden = !showProgress
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        let attributes: [NSLayoutConstraint.Attribute] = [
            .left, .width
        ]
        for attribute in attributes {
            NSLayoutConstraint(item: progressView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0).isActive = true
        }
        NSLayoutConstraint(item: progressView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 2.0).isActive = true
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
        } else {
            NSLayoutConstraint(item: progressView, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        }
    }
    
    private func reloadRightItems() {
        var rightItems: [UIBarButtonItem] = []
        if showCancelItem {
            rightItems.append(kkxCancelItem)
        }
        if let item = refreshItem, showRefreshItem {
            rightItems.append(item)
        }
        navigationItem.rightBarButtonItems = rightItems
    }
    
    private func interceptCallback(_ urlString: String) -> WebViewInterceptCallback? {
        var callback: WebViewInterceptCallback?
        for (key, value) in _intercepts {
            if urlString.contains(key) {
                callback = value
                break
            }
        }
        return callback
    }
    
    // MARK: -------- Actions --------
    
    @objc private func goBackAction() {
        webView.goBack()
    }
    
    @objc private func goForwardAction() {
        webView.goForward()
    }
    
    @objc private func refreshAction() {
        reload()
    }
}

// MARK: ======== WKNavigationDelegate ========

extension KKXWebViewController: WKNavigationDelegate {
    
    /// 发送请求之前，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        if let callback = interceptCallback(urlString) {
            callback(self)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString ?? ""
        if let callback = interceptCallback(urlString) {
            callback(self)
            decisionHandler(.cancel, preferences)
        } else {
            decisionHandler(.allow, preferences)
        }
    }
    
    /// 收到响应之后，决定是否跳转
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        decisionHandler(.allow)
    }
    
    /// 页面开始加载
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if showActivity {
            view.kkxLoading = true
        }
    }
    
    /// 接收到服务器跳转请求
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        kkxPrint("webView didReceiveServerRedirectForProvisionalNavigation")
    }
    
    /// 页面加载失败
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        kkxPrint("webView didFailProvisionalNavigation", error)
    }
    
    /// 内容开始返回
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    /// 页面加载完成
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if showActivity { view.kkxLoading = false }
        
        kkxPrint("webView didFinish navigation")
        var jsString = "document.body.scrollHeight"
        if #available(iOS 13.0, *) {
            jsString = "document.documentElement.scrollHeight"
        }
        webView.evaluateJavaScript(jsString) { [weak self](height, error) in
            if let h = height as? CGFloat {
                self?.didLoadDataHandler?(h)
            }
        }
    }
    
    /// 页面加载失败
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        kkxPrint("webView didFail navigation")
        if showActivity { view.kkxLoading = false }
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
        } else {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
    
    @available(iOS 9.0, *)
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        kkxPrint("webContent process did terminate")
    }
    
    public func webView(_ webView: WKWebView, authenticationChallenge challenge: URLAuthenticationChallenge, shouldAllowDeprecatedTLS decisionHandler: @escaping (Bool) -> Void) {
        decisionHandler(false)
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        
    }
}

// MARK: ======== WKUIDelegate ========

extension KKXWebViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        kkxPrint("webView createWebViewWith")
        if navigationAction.targetFrame?.isMainFrame != true {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    public func webViewDidClose(_ webView: WKWebView) {
        kkxPrint("webViewDidClose")
    }
    
    /// 警告框
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let action = UIAlertAction.init(title: KKXExtensionString("ok"), style: .default) { (action) in
            completionHandler()
        }
        alert(.alert, title: nil, message: message, actions: [action])
    }
    
    
    /// 确认框
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    /// 输入框
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
    }
    
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        true
    }
    
    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController? {
        nil
    }
    
    public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        completionHandler(nil)
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuWillPresentForElement elementInfo: WKContextMenuElementInfo) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuForElement elementInfo: WKContextMenuElementInfo, willCommitWithAnimator animator: UIContextMenuInteractionCommitAnimating) {
        
    }
    
    @available(iOS 13.0, *)
    public func webView(_ webView: WKWebView, contextMenuDidEndForElement elementInfo: WKContextMenuElementInfo) {
        
    }
}

public func fullHTMLString(_ bodyString: String) -> String {
    return """
    <head>
        \(HtmlSring.meta)
        <style>
            img {
                width:100%;
                height: auto;
            }
            @media (prefers-color-scheme: dark) {
                h, h1, h2, h3, h4, h5, h6, b, p, span {
                    color: rgba(235,235,245,0.8) !important;
                }
                body {
                    background: #1C1C1E;
                }
            }
        </style>
    </head>
    <body>
        \(bodyString)
    </body>
    """
}

public struct HtmlSring {
    public static let meta = "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
}
