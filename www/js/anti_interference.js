var wrlInterference,
	initObj = {};

var pageview = R.pageView({ //页面初始化
	init: function () {}
});

var pageModel = R.pageModel({
	getUrl: "goform/WifiAntijamGet",
	setUrl: "goform/WifiAntijamSet",
	translateData: function (data) {
		var newData = {};
		newData.interference = data;
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
		return "WifiAntijamEn=" + $("[name=WifiAntijamEn]:checked").val();
	}
});

R.module("interference", view, moduleModel);

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
	$("[name=WifiAntijamEn][value=" + str + "]").attr("checked", true);
}

function initEvent() {
	$("[name=WifiAntijamEn]").on("click", function () {
		wrlInterference.submit();
	});

}

function initValue(obj) {
	initHtml(obj.WifiAntijamEn);
	initObj = obj;
}


window.onload = function () {
	wrlInterference = R.page(pageview, pageModel);
};