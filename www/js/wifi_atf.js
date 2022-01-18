var wrlAtf,
	initObj = {};

var pageview = R.pageView({ //页面初始化
	init: function () {}
});

var pageModel = R.pageModel({
	getUrl: "goform/WifiAtfGet",
	setUrl: "goform/WifiAtfSet",
	translateData: function (data) {
		var newData = {};
		newData.atf = data;
		return newData;
	},
	afterSubmit: callback
});

/*********模块注册*********/
var view = R.moduleView({
	initEvent: initEvent
});

var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () {
		return "WifiAtfEn=" + $("[name=WifiAtfEn]:checked").val();
	}
});

R.module("atf", view, moduleModel);

function callback(str) {
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;

	top.showSaveMsg(num);
	if (num == 0) {
		//getValue();
		top.wrlInfo.initValue();
	}
}

function initHtml(str) {
	str = str || "false";
	$("[name=WifiAtfEn][value=" + str + "]").attr("checked", true);
}

function initEvent() {
	$("[name=WifiAtfEn]").on("click", function () {
		wrlAtf.submit();
	});

}

function initValue(obj) {
	initHtml(obj.WifiAtfEn);
	initObj = obj;
}


window.onload = function () {
	wrlAtf = R.page(pageview, pageModel);
};