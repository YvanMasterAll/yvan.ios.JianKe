//
//  DailyDebateDetailTableViewCell.swift
//  ShuTu
//
//  Created by yiqiang on 2018/1/11.
//  Copyright © 2018年 yiqiang. All rights reserved.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class DailyDebateDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            //WebView
            self.webView.scrollView.showsVerticalScrollIndicator = false
            self.webView.navigationDelegate = self
        }
    }
    
    //声明区域
    open var viewModel: DailyDebateDetailViewModel! {
        didSet {
            self.bindRx()
        }
    }
    open var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //私有成员
    fileprivate lazy var emptyView: EmptyView = {
        let emptyView = EmptyView(target: self)
        emptyView.delegate = self
        return emptyView
    }()
    fileprivate var htmlData: String = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\"><style>article,aside,details,figcaption,figure,footer,header,hgroup,main,nav,section,summary{display:block}audio,canvas,video{display:inline-block}audio:not([controls]){display:none;height:0}html{font-family:sans-serif;-webkit-text-size-adjust:100%}body{font-family:'Helvetica Neue',Helvetica,Arial,Sans-serif;background:#fff;padding-top:0;margin:0}a:focus{outline:thin dotted}a:active,a:hover{outline:0}h1{margin:.67em 0}h1,h2,h3,h4,h5,h6{font-size:16px}abbr[title]{border-bottom:1px dotted}hr{box-sizing:content-box;height:0}mark{background:#ff0;color:#000}code,kbd,pre,samp{font-family:monospace,serif;font-size:1em}pre{white-space:pre-wrap}small{font-size:80%}sub,sup{font-size:75%;line-height:0;position:relative;vertical-align:baseline}sup{top:-.5em}sub{bottom:-.25em}img{border:0;vertical-align:middle;color:transparent;font-size:0}svg:not(:root){overflow:hidden}figure{margin:0}fieldset{border:1px solid silver;margin:0 2px;padding:.35em .625em .75em}legend{border:0;padding:0}table{border-collapse:collapse;border-spacing:0;overflow:hidden}a{text-decoration:none}blockquote{border-left:3px solid #D0E5F2;font-style:normal;display:block;vertical-align:baseline;font-size:100%;margin:.5em 0;padding:0 0 0 1em}ol,ul{padding-left:20px}.main-wrap{max-width:100%;min-width:300px;margin:0 auto}.content-wrap{overflow:hidden;background-color:#f9f9f9}.content-wrap a{word-break:break-all}.headline-title.onlyheading{margin:20px 0}.headline img{max-width:100%;vertical-align:top}.headline-background-link{line-height:2em;position:relative;display:block;padding:20px 45px 20px 20px!important}.icon-arrow-right{position:absolute;top:50%;right:20px;background-image:url(http://static.daily.zhihu.com/img/share-icons.png);background-repeat:no-repeat;display:inline-block;vertical-align:middle;background-position:-70px -20px;width:10px;height:15px;margin-top:-7.5px}.headline-background .heading{color:#999;font-size:15px!important;margin-bottom:8px;line-height:1em}.headline-background .heading-content{color:#444;font-size:17px!important;line-height:1.2em}.headline-title{line-height:1.2em;color:#000;font-size:22px;margin:20px 0 10px;padding:0 20px!important;font-weight:700}.meta{white-space:nowrap;text-overflow:ellipsis;overflow:hidden;font-size:16px;color:#b8b8b8}.meta .source-icon{width:20px;height:20px;margin-right:4px}.meta .time{float:right;margin-top:2px}.content{color:#444;line-height:1.6em;font-size:17px;margin:10px 0 20px}.content img{max-width:100%;display:block;margin:30px auto}.content img+img{margin-top:15px}.content img[src*=\"zhihu.com/equation\"]{display:inline-block;margin:0 3px}.content a{color:#259}.content a:hover{text-decoration:underline}.view-more{margin-bottom:25px;text-align:center}.view-more a{font-size:16px;display:inline-block;width:125px;height:30px;line-height:30px;background:#f0f0f0;color:#B8B8B8}.question{overflow:hidden;padding:0 20px!important}.question+.question{border-top:5px solid #f6f6f6}.question-title{line-height:1.4em;color:#000;font-weight:700;font-size:18px;margin:20px 0}.meta .author{color:#444;font-weight:700}.answer+.answer{border-top:2px solid #f6f6f6;padding-top:20px}.footer{text-align:center;color:#b8b8b8;font-size:13px;padding:20px 0}.footer a{color:#b8b8b8}.question .view-more a{width:100%;display:block}.hot-comment{-webkit-tap-highlight-color:transparent}.comment-label{font-size:16px;color:#333;line-height:1.5em;font-weight:700;border-top:1px solid #eee;border-bottom:1px solid #eee;margin:0;padding:9px 20px}.comment-list{margin-bottom:20px}.comment-item{font-size:15px;color:#666;border-bottom:1px solid #eee;padding:15px 20px}.comment-meta{position:relative;margin-bottom:10px}.comment-meta .author{vertical-align:middle;color:#444}.comment-meta .vote{position:absolute;color:#b8b8b8;font-size:12px;right:0}.night .comment-label{color:#b8b8b8;border-top:1px solid #303030;border-bottom:1px solid #303030}.night .comment-item{color:#7f7f7f;border-bottom:1px solid #303030}.icon-vote,.icon-voted{background-repeat:no-repeat;display:inline-block;vertical-align:0;width:11px;height:12px;margin-right:4px;background-image:url(http://static.daily.zhihu.com/img/app/Comment_Vote.png)!important}.icon-voted{background-image:url(http://static.daily.zhihu.com/img/app/Comment_Voted.png)!important}.night .icon-vote{background-image:url(http://static.daily.zhihu.com/img/app/Dark_Comment_Vote.png)!important}.img-wrap .headline-title{bottom:5px}.img-wrap .img-source{right:10px!important;font-size:9px}.global-header{position:static}.button{width:60px}.button i{margin-right:0}.from-column{width:280px;line-height:30px;height:30px;padding-left:90px;color:#2aacec;background-image:url(http://static.daily.zhihu.com/img/News_Column_Entrance.png);box-sizing:border-box;margin:0 20px 20px}.from-column:active{background-image:url(http://static.daily.zhihu.com/img/News_Column_Entrance_Highlight.png)}.night .headline{border-bottom:4px solid #303030}.night img{-webkit-mask-image:-webkit-gradient(linear,0 0,0 100%,from(rgba(0,0,0,.7)),to(rgba(0,0,0,.7)))}.night .content-wrap,body.night{background:#343434}.night .answer+.answer{border-top:2px solid #303030}.night .question+.question{border-top:4px solid #303030}.night .view-more a{background:#292929;color:#666}.night .icon-arrow-right{background-image:url(http://static.daily.zhihu.com/img/share-icons.png);background-repeat:no-repeat;display:inline-block;vertical-align:middle;background-position:-70px -35px;width:10px;height:15px}.night blockquote,.night sup{border-left:3px solid #666}.night .content a{color:#698ebf}.night .from-column{color:#2b82ac;background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance.png)}.night .from-column:active{background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance_Highlight.png)}.large .question-title{font-size:24px}.large .meta{font-size:18px}.large .content{font-size:20px}.large blockquote,.large sup{line-height:1.6}.meta .meta-item{-o-text-overflow:ellipsis;width:39%;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;display:inline-block;color:#929292;margin-right:7px}.headline .meta{white-space:nowrap;text-overflow:ellipsis;overflow:hidden;font-size:11px;color:#b8b8b8;margin:15px 0;padding:0 20px}.headline .meta a,.headline .meta a:hover{padding-left:1em;margin-top:2px;float:right;font-size:11px;color:#0066cf;text-decoration:none}.highlight{width:auto;overflow:auto;word-wrap:normal}.highlight::-webkit-scrollbar{width:6px;height:6px}.highlight code{overflow:auto}.highlight::-webkit-scrollbar-thumb:horizontal{border-radius:6px;background-color:rgba(0,0,0,.5)}.highlight::-webkit-scrollbar-thumb:horizontal:hover{background-color:rgba(0,0,0,.6)}.highlight pre{margin:0;white-space:pre}.highlight .hll{background-color:#ffc}.highlight .err{color:#a61717;background-color:#e3d2d2}.highlight .cp{color:#999;font-weight:700}.highlight .cs{color:#999;font-weight:700;font-style:italic}.highlight .gd{color:#000;background-color:#fdd}.highlight .gi{color:#000;background-color:#dfd}.highlight .gu{color:#aaa}.highlight .ni{color:purple}.highlight .nt{color:navy}.highlight .w{color:#bbb}.highlight .sr{color:olive}.button span,[hidden]{display:none}.highlight .gs,.highlight .k,.highlight .kc,.highlight .kd,.highlight .kn,.highlight .kp,.highlight .kr,.highlight .o,.highlight .ow,b,strong{font-weight:700}.highlight .ge,dfn{font-style:italic}.meta .source,.meta span{vertical-align:middle}.comment-meta .avatar,.meta .avatar{width:20px;height:20px;border-radius:2px;margin-right:5px}.highlight .bp,.highlight .gh,.meta .bio{color:#999}.highlight .go,.night .comment-meta .author,.night .content,.night .meta .author{color:#888}.night .headline-background .heading-content,.night .headline-title,.night .question-title{color:#B8B8B8}.highlight .c,.highlight .c1,.highlight .cm{color:#998;font-style:italic}.highlight .gr,.highlight .gt{color:#a00}.highlight .gp,.highlight .nn{color:#555}.highlight .kt,.highlight .nc{color:#458;font-weight:700}.highlight .il,.highlight .m,.highlight .mf,.highlight .mh,.highlight .mi,.highlight .mo{color:#099}.highlight .s,.highlight .s1,.highlight .s2,.highlight .sb,.highlight .sc,.highlight .sd,.highlight .se,.highlight .sh,.highlight .si,.highlight .ss,.highlight .sx{color:#d32}.highlight .na,.highlight .nb,.highlight .no,.highlight .nv,.highlight .vc,.highlight .vg,.highlight .vi{color:teal}.highlight .ne,.highlight .nf{color:#900;font-weight:700}.answer h1,.answer h2,.answer h3,.answer h4,.answer h5{font-size:19px}@media only screen and (-webkit-min-device-pixel-ratio2),only screen and (min-device-pixel-ratio2){.icon-arrow-right{background-image:url(http://static.daily.zhihu.com/img/share-icons@2x.png);-webkit-background-size:82px 55px;background-size:82px 55px}.icon-vote,.icon-voted{background-image:url(http://static.daily.zhihu.com/img/app/Comment_Vote@2x.png)!important;background-size:11px 12px}.icon-voted{background-image:url(http://static.daily.zhihu.com/img/app/Comment_Voted@2x.png)!important}.night .icon-vote{background-image:url(http://static.daily.zhihu.com/img/app/Dark_Comment_Vote@2x.png)!important}.from-column{background-image:url(http://static.daily.zhihu.com/img/News_Column_Entrance@2x.png)!important;background-size:280px 30px}.from-column:active{background-image:url(http://static.daily.zhihu.com/img/News_Column_Entrance_Highlight@2x.png)!important}.night .from-column{color:#2b82ac;background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance@2x.png)!important}.night .from-column:active{background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance_Highlight@2x.png)!important}}.meta .meta-item{width:39%;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;display:inline-block;color:#929292;margin-right:7px}.headline .meta{white-space:nowrap;text-overflow:ellipsis;overflow:hidden;font-size:11px;color:#b8b8b8;margin:20px 0;padding:0 20px}.headline .meta a,.headline .meta a:hover{margin-top:2px;float:right;font-size:11px;color:#0066cf;text-decoration:none}.answer h1,.answer h2,.answer h3,.answer h4,.answer h5{font-size:19px}.origin-source,a.origin-source:link{display:block;margin:25px 0;height:50px;overflow:hidden;background:#f0f0f0;color:#888;position:relative;-webkit-touch-callout:none}.origin-source .source-logo,a.origin-source:link .source-logo{float:left;width:50px;height:50px;margin-right:10px}.origin-source .text,a.origin-source:link .text{line-height:50px;height:50px;font-size:13px}.origin-source.with-link .text{color:#333}.origin-source.with-link:after{display:block;position:absolute;border-color:transparent transparent transparent #f0f0f0;border-width:7px;border-style:solid;height:0;width:0;top:18px;right:4px;line-height:0;content:\"\"}.origin-source.with-link:before{display:block;height:0;width:0;position:absolute;top:18px;right:3px;border-color:transparent transparent transparent #000;border-width:7px;border-style:solid;line-height:0;content:\"\"}.origin-source-wrap{position:relative;background:#f0f0f0}.origin-source-wrap .focus-link{position:absolute;right:0;top:0;width:45px;color:#00a2ed;height:50px;display:none;text-align:center;font-size:12px;-webkit-touch-callout:none}.origin-source-wrap .focus-link .btn-label{text-align:center;display:block;margin-top:8px;border-left:solid 1px #ccc;height:34px;line-height:34px}.origin-source-wrap.unfocused .focus-link{display:block}.origin-source-wrap.unfocused .origin-source:after,.origin-source-wrap.unfocused .origin-source:before{display:none}.night .origin-source-wrap{background:#292929}.night .origin-source-wrap .focus-link{color:#116f9e}.night .origin-source-wrap .btn-label{border-left:solid 1px #3f3f3f}.night .origin-source,.night .origin-source.with-link{background:#292929;color:#666}.night .origin-source .text,.night .origin-source.with-link .text{color:#666}.night .origin-source.with-link:after{border-color:transparent transparent transparent #292929}.night .origin-source.with-link:before{border-color:transparent transparent transparent #666}.question-title{color:#494b4d}blockquote{color:#9da3a6;border-left:3px solid #Dfe3e6}.content a{color:#4786b3}.content{font-size:17px;color:#616466}.content-wrap{background:#fff}hr{margin:30px 0;border-top-width:0}p{margin:20px 0!important}.dudu-night .content{color:#797b80}.dudu-night hr{color:#27282b;border-color:#27282b}.dudu-night .meta .author,.dudu-night .meta .bio{color:#555659}.dudu-night .headline-background .heading-content,.dudu-night .headline-title,.dudu-night .question-title{color:#919499}.dudu-night .headline{border-bottom:none}.dudu-night img{-webkit-mask-image:-webkit-gradient(linear,0 0,0 100%,from(rgba(0,0,0,.7)),to(rgba(0,0,0,.7)))}.dudu-night .content-wrap,body.dudu-night{background:#1d1e1f}.dudu-night .answer+.answer{border-top:2px solid #27282b}.dudu-night .question+.question{border-top:4px solid #27282b}.dudu-night .view-more a{background:#1d1e1f;color:#396280}.dudu-night .icon-arrow-right{background-image:url(http://static.daily.zhihu.com/img/share-icons.png);background-repeat:no-repeat;display:inline-block;vertical-align:middle;background-position:-70px -35px;width:10px;height:15px}.dudu-night blockquote,.dudu-night sup{border-left:3px solid #2e3033;color:#555659}.dudu-night .content a{color:#396280}.dudu-night img{opacity:.7}.dudu-night .from-column{color:#2b82ac;background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance.png)}.dudu-night .from-column:active{background-image:url(http://static.daily.zhihu.com/img/Dark_News_Column_Entrance_Highlight.png)}//绂佺敤澶撮儴涓嬮潰鐨勫垎闅旂嚎 .dudu .headline{border-bottom:none}.dudu-night .origin-source,.dudu-night a.origin-source:link{background:#222324}.dudu-night .origin-source.with-link .text{color:#797b80}.dudu-night .origin-source.with-link:after{border-color:transparent transparent transparent #797b80}</style></head><body><div class=\"main-wrap content-wrap\">\n<div class=\"headline\">\n\n<div class=\"img-place-holder\"></div>\n\n\n\n</div>\n\n<div class=\"content-inner\">\n\n\n\n\n<div class=\"question\">\n<h2 class=\"question-title\">当咨询师的「伦理责任」与「法律」发生冲突时，怎样的选择是合理的？</h2>\n\n<div class=\"answer\">\n\n<div class=\"meta\">\n<img class=\"avatar\" src=\"http:/pic1.zhimg.com/2c94a2fc644362fe9e18ab124065a174_is.jpg\">\n<span class=\"author\">银波，</span><span class=\"bio\">（性）犯罪心理矫治，新手</span>\n</div>\n\n<div class=\"content\">\n<p>提问中的咨询师没有明确是“什么领域”的咨询师，我说一说犯罪矫治教育为目的的心理咨询师的情况吧。</p>\r\n<p>我们不论是在开始一个小组、还是开始一段个人心理咨询，都需要跟 client（s）签订『治疗合约』。这一点与一般心理咨询没有什么不同，合约的内容应人、应场合、应咨询目的而异。制定一个咨询师和 client 双方都可以接受并遵守的合约十分之须要、重要和必要。</p>\r\n<p>合约的内容千奇百样，里面可以有对于咨询场所的界定、对于咨询对象的界定（小组治疗时尤其重要）、以及其它更加细致的诸如咨询时间内不能接电话之类的，当然「保密」算是必须的。</p>\r\n<p>这里涉及到「保密」的目的。<strong>「保密」的目的是让双方（主要是 client）能更加真实地、诚实地表达自己所思所想所愿。</strong>「保密」这一行为的主体在个人心理咨询时往往是咨询师；在小组咨询时往往是包括咨询师在内的整个小组成员。——「伦理责任」不完全等于保密原则。如果说「伦理责任」的遵守主体是咨询师的话，「保密」的主体不仅仅限于咨询师。</p>\r\n<p>当然，提问主要还是问的咨询师的保密原则和发现违法行为时的取舍，所以下文说一下犯罪治疗心理咨询时，咨询师遵守的「保密原则」。</p>\r\n<p>题主所说的<strong>“当咨询师发现与法律冲突的这部分恰是来访者的最大利益时”，这个情况很难界定。</strong>但我可以说，以矫治教育为目的的心理咨询中，在咨询中发现更多的犯罪行为的情况很多。说句实际的话，如果 client 一暴露出自己其他的犯罪事实咨询师就要报告的话，咨询师和 Client 的 rapport（信赖关系）会崩溃，不利于咨询的进行、不利于 Client 本人的良性变化。日本药物依赖治疗第一人、松本俊彦医生在他的书里也提到，如果在咨询中患者提到自己复吸，他不会举报。这个跟治疗理念的进步有关：尽管社会上普遍的推崇处分、惩罚为主的司法模式，药物依赖是病、需要的是「治疗」模式——「惩罚和暴力并不能帮助药物依赖患者恢复」。</p>\r\n<p>但是，这个<strong>保密不能没有度。我们在说「保密」时，说的不是无限制的「保密」</strong>，准确来说我们说的「保密」的全称是「保守秘密以及它的限制」（「秘密保持とその限界」)。也就是说<strong>一般情况下我们会保守秘密，但是如果出现某些情况，我们就不能保密了。</strong></p>\r\n<p>这个标准是「会不会对他人、对自己实施伤害」，client 提到自杀和伤人、杀人的情况下，首先需要判断这些话的真实性，然后再判断需不需要告知相关人士。</p>\r\n<p>如果一个犯罪者在咨询中透露出其他犯罪行为，首先咨询师要重新对其进行 risk assessment，也就是重新评定他的危险性。如果现在的处理依旧能够与他的 risk 相当，那么维持现状可以。如果现在的处理已经不能符合他的 risk，那么会与对方说明后，进行报告——这一点在最初的治疗合约中，我们就会明确规定好：“如果在咨询时判断你有可能伤害自己或伤害他人，我会跟你说明我的判断并告知你我要通知能够处理的相关人士”。最初明确这个界限，会使犯罪者在一段治疗关系中作出符合这一段关系的 disclose。</p>\r\n<p>咨询师的「伦理责任」不仅仅是对 client 这一个人，还有一定的对社会的「責任」。</p>\r\n<p>补充一点，「保密」的限度，与咨询实施的环境（Framework）有关。</p>\r\n<p>打个极端一点的比喻，在监狱咨询，一个犯人向你说了一个完整的实施可能性很高的越狱计划，这个也是不能保密的（假设有这么个逗比的犯人）。所处的咨询环境（Framework）有规则（rule）的，也是需要考虑进来的。当然，这个也是在一开始的治疗合约中就要说清楚。</p>\r\n<p>毕竟，咨询师也不能做自己做不到的事情阿。</p>\r\n<p><strong>咨询师需要跟 client 确认好双方都能遵守的规则。</strong>一起制定这个规则的过程很重要，基本上决定了咨询师与 client 最初的信赖关系。</p>\n</div>\n</div>\n\n\n<div class=\"view-more\"><a href=\"http:/www.zhihu.com/question/45406966\">查看知乎讨论<span class=\"js-question-holder\"></span></a></div>\n\n</div>\n\n\n</div>\n</div><script type=“text/javascript”>window.daily=true</script></body></html>"

}

extension DailyDebateDetailTableViewCell {
    //初始化
    fileprivate func bindRx() {
        //Rx
        viewModel.outputs.section!
            .subscribe(onNext: { [weak self] data in
                guard data.body != nil else {
                    return
                }
                //AnswerDetail
                self?.webViewLoad(data: data)
            })
            .disposed(by: disposeBag)
        viewModel.outputs.emptyStateObserver.asObservable()
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .loading(let type):
                    self?.emptyView.show(type: .loading(type: type), frame: CGRect(x: self!.webView.frame.origin.x, y: self!.webView.frame.origin.y, width: SW, height: SH - 280 - 34))
                    break
                case .empty:
                    self?.emptyView.hide()
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        //首次加载
        viewModel.inputs.refreshData.onNext(())
    }
    //WebView Load Data
    fileprivate func webViewLoad(data: AnswerDetail){
        webView.loadHTMLString(self.htmlData, baseURL: nil)
        //webView.loadHTMLString(self.concatHTML(css: data.css!, body: data.body!), baseURL: nil)
    }
    //Deal With Html String
    private func concatHTML(css: [String], body: String) -> String {
        var html = "<html>"
        html += "<head>"
        css.forEach { html += "<link rel=\"stylesheet\" href=\"\($0)\">" }
        //H5 模式
        html += "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
        html += "<style>body{font-size: 30px}img{max-width:320px !important;}</style>"
        html += "</head>"
        html += "<body>"
        html += body
        html += "</body>"
        html += "</html>"
        return html
    }
}

extension DailyDebateDetailTableViewCell: WKNavigationDelegate, EmptyViewDelegate {
    // WKNavigationDelegate
    // --------------------
    //页面开始加载
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    //内容开始返回
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    //页面加载完
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.emptyView.hide()
    }
    //页面加载失败
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.emptyView.hide()
    }
    //EmptyViewDelegate
    func emptyViewClicked() {
        //重新加载
        viewModel.inputs.refreshData.onNext(())
    }
}
