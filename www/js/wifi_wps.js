var wrlWpsInfo;
var G={};
var pageview = R.pageView({ //页面初始化
	init: function () {
		top.loginOut();
		top.$(".main-dailog").removeClass("none");
		top.$(".save-msg").addClass("none");
	}
});
var pageModel = R.pageModel({
	getUrl: "goform/WifiWpsGet",
	setUrl: "goform/WifiWpsSet",
	translateData: function (data) {
		var newData = {};
		newData.wrlWps = data;
		return newData;
	},
	afterSubmit: callback
});

/************************/
var view = R.moduleView({
	initEvent: initEvent
});
var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () {
        var subData = conSetOrGetData();
        G.conSetData = subData;
        return subData;
	}
});

//模块注册
R.module("wrlWps", view, moduleModel);

function initEvent() {
	$("#wpsSubmit").on("click", function () {
		if (!this.disabled){
			$.post("goform/WifiWpsStart", "action=wps", wpsCallback);
			G.unShow = true;
		}
	});
	$("#wpsEn").on("click", function () {
		if (initObj.wl_mode != "ap" || initObj.wl_en == "0") {
			return;
        }
        //禁止点击过快
        if (G.dfsEnable == '1' && !$("#waitingTip").hasClass('none')) {
            return;
        }
		changeWpsEn();
		$("#wpsMethod").addClass("none");
		wrlWpsInfo.submit();
		if ($("#wpsEn").val() == "1") {
			$("#waitingTip").html(_("Enabling WPS...")).removeClass("none");
		    //	after($("<p style='text-align: center;color:#ffba79;margin-top: 5px'>请您等待5G接口起来后再开启WPS</p>"))

		} else {
			$("#waitingTip").html(_("Disabling WPS...")).removeClass("none");
		   // after($("<p style='text-align: center;color:#ffba79;margin-top: 5px'>请您等待5G接口起来后再关闭WPS</p>"))
		}
	});
}

function changeWpsEn() {
	if ($("#wpsEn")[0].className == "btn-off") {
		$("#wpsEn").attr("class", "btn-on");
		$("#wpsEn").val(1);
	} else {
		$("#wpsEn").attr("class", "btn-off");
		$("#wpsEn").val(0);
	}
	top.initIframeHeight();
}

function initValue(obj) {
	initObj = obj;
	$("#pinCode").html(obj.pinCode);
	$("#waitingTip").html(" ").addClass("none");
	if (obj.wl_mode != "ap" || obj.wl_en == "0") {
		if (obj.wl_mode != "ap")
			showErrMsg("msg-err", _("Please disable Wireless Repeating on the WiFi Settings page first."), true);
		if (obj.wl_en == "0")
			showErrMsg("msg-err", _("The WiFi function is disabled. Please enable it first."), true);
		$("#wpsSubmit")[0].disabled = true;
		//$("#submit")[0].disabled = true;
	}
	$("#wpsEn").attr("class", (obj.wpsEn == "1" ? "btn-off" : "btn-on"));
	changeWpsEn();
	if (obj.wpsEn == "1") {
		$("#wpsMethod").removeClass("none");
	} else {
		$("#wpsMethod").addClass("none");
	}
    top.initIframeHeight();
    //保留无线基本数据用于判断
    $.getJSON("goform/WifiBasicGet?" + Math.random, function (data) {
        var secuWPA3 = data.security === "wpa3sae" || data.security === "wpa3saewpa2psk",
            secuWPA3_5g = data.security_5g === "wpa3sae" || data.security_5g === "wpa3saewpa2psk";
        //当无线开启且加密方式为WPA3时，WPS不可用。并提示用户"WPS功能xx"
        if ((data.wrlEn === "1" && secuWPA3) || (data.doubleBand === "0" && data.wrlEn_5g === "1" && secuWPA3_5g)) {
            if (obj.wpsEn === "1") {
                $("#wpsMethod").addClass("none");
            }
            $("#wpsEn").unbind("click").css("cursor", "not-allowed");
            $("#wpsDisabledInfo").removeClass("none");
        }
    });
    //获取dfs
    // $.getJSON("goform/GetDfsCfg?" + Math.random(), function (obj) {
    //     G.dfsEnable = obj.enable;
    // });
    //获取主网络5G是否开启
	$.getJSON("goform/WifiBasicGet?" + Math.random(), function(obj){
		G.main5gEn = obj.wrlEn_5g;
	});
    G.conGetData = conSetOrGetData();
}
function conSetOrGetData(){
    return "wpsEn=" + $("#wpsEn").val();
}

function wpsCallback(str) {
    var num = $.parseJSON(str).errCode;
    if (num == 0) {
        $('.pbc').removeClass('none');
        setTimeout(function () {
            $('.pbc').addClass('none');
        }, 2000);
    }
    callback(str);
}

function callback(str) {
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;
	if (num == 0) {
		if(G.unShow){
			G.unShow = false
		}else{
			top.showSaveMsg(num);
		}
        // if (G.main5gEn =="1" && G.dfsEnable == '1' && G.conGetData && G.conSetData && G.conGetData != G.conSetData) {
        //     top.showDFSMsg(num);
        // }
		top.wrlInfo.initValue();
		setTimeout(function () {
			pageModel.update();
			$("#waitingTip").html(" ").addClass("none");
			// $("#waitingTip").next().remove();
		}, 2000);
	}else if(num == 1) {
		top.showDFSMsg(0)
	} else{
		if ($("#wpsEn").val() == "1"){
			$("#waitingTip").html("<span style='color:#f00;'>请您等待无线接口起来后再开启WPS</span>").removeClass("none")
			$("#wpsEn").attr("class", "btn-off");
		}else{

			$("#waitingTip").html("<span style='color:#f00;'>请您等待无线接口起来后再关闭WPS</span>").removeClass("none")
			$("#wpsEn").attr("class", "btn-on");
		}
	}
}


window.onload = function () {
	wrlWpsInfo = R.page(pageview, pageModel);
};
