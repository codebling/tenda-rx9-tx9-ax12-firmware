/**************** Page *******************************/
var wrlBasicPage;
var storageSSID24,storageSSID24En;
var G = {};
var pageview = R.pageView({ //页面初始化
	init: initPage
}); //page view

//page model
var pageModel = R.pageModel({
	getUrl: "goform/WifiBasicGet", //获取数据接口
	setUrl: "goform/WifiBasicSet", //提交数据接口
	translateData: function (data) { //数据转换
		var newData = {};
		newData.wrlBasic = data;
		return newData;
    },
    afterSubmit: function (str) { //提交数据回调
		callback(str);
	}
});

//5G网络相关的参数（DFS通过这些参数的变化来判断是否提示）
G._5gOption = ["hideSsid_5g","security_5g","ssid_5g","wrlEn_5g","wrlPwd_5g"]


//页面逻辑初始化
function initPage() {
	$.validate.valid.ssid = {
		all: function (str) {
			var ret = this.specific(str);
			//ssid 前后不能有空格，可以输入任何字符包括中文，仅32个字节的长度
			if (ret) {
				return ret;
			}

			/*if (str.charAt(0) == " " || str.charAt(str.length - 1) == " ") {
				return _("The first and last characters of WiFi Name cannot be spaces.");
			}*/

			if (getStrByteNum(str) > 32) {
				return _("The WiFi name can contain only a maximum of %s bytes.", [32]);
			}
		},
		specific: function (str) {
			var ret = str;
			if ((null == str.match(/[^ -~]/g) ? str.length : str.length + str.match(/[^ -~]/g).length * 2) > 32) {
				return _("The WiFi name can contain only a maximum of %s bytes.", [32]);
			}
		}
	};
	$.validate.valid.ssidPwd = {
		all: function (str) {
			var ret = this.specific(str);

			if (ret) {
				return ret;
			}
			if ((/^[0-9a-fA-F]{1,}$/).test(str) && str.length == 64) { //全是16进制 且长度是64

			} else {
				if (str.length < 8 || str.length > 63) {
					return _("The password must consist of %s-%s characters.", [8, 63]);
				}
			}
			//密码不允许输入空格
			//if (str.indexOf(" ") >= 0) {
			//	return _("The WiFi password cannot contain spaces.");
			//}
			//密码前后不能有空格
			/*if (str.charAt(0) == " " || str.charAt(str.length - 1) == " ") {
				return _("The first and last characters of WiFi Password cannot be spaces.");
			}*/
		},
		specific: function (str) {
			var ret = str;
			if (/[^\x00-\x80]/.test(str)) {
				return _("Invalid characters are not allowed.");
			}
		}
	};

	$("#save").on("click", function () {
		G.validate.checkAll();
	});
}

//提交回调
function callback(str) {
	if (!top.isTimeout(str)) {
		return;
	}
    var num = $.parseJSON(str).errCode;
	if(num ==1){
		top.showDFSMsg(0);
	}else{
		top.showSaveMsg(num);
	}
	if (num == 0) {
		$("#wrl_submit").blur();
		top.wrlInfo.initValue();
		top.staInfo.initValue();
	}
}

/****************** Page end ********************/

/****************** Module wireless setting *****/

var view = R.moduleView({
	initHtml: initHtml,
	initEvent: initEvent
});

var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () { //获取模块提交数据
		getCheckbox(["hideSsid", "hideSsid_5g"]);

		var dataObj = {
				"doubleBand":$("#doubleBandEn").attr("class").indexOf("btn-off") == -1 ? "1":"0",
				"wrlEn": $('[name="wrlEn"]').val(),
				"wrlEn_5g": $('[name="wrlEn_5g"]').val(),
				"security": $("#security").val(),
				"security_5g": $("#security_5g").val(),
				"ssid": $("#ssid").val(),
				"ssid_5g": $("#ssid_5g").val(),
				"hideSsid": $("#hideSsid").val(),
				"hideSsid_5g": $("#hideSsid_5g").val(),
				"wrlPwd": $("#wrlPwd").val(),
				"wrlPwd_5g": $("#wrlPwd_5g").val()
			},
			dataStr,
		    compare =['wrlEn_5g','ssid_5g','hideSsid_5g','wrlPwd_5g','security_5g'];
		if(dataObj.doubleBand == "1"){  //双频优选开启时  5g信息保持和24g一样
			for(prop in dataObj){
				if(prop.indexOf("_5g")){
					dataObj[prop] = dataObj[prop.replace(/_5g/,"")];
				}
			}
		}
		G.setWifiData = dataObj;
		if(dataObj.doubleBand == '0'){
			for (var i = 0; i < compare.length ; i++) {
				if(dataObj[compare[i]] != G.initWifiData[compare[i]]){
					dataObj.wifi_chkHz = "1"
					break
				}
			}
		}
		dataStr = objTostring(dataObj);
		return dataStr;
	}
});


//判断是否需要弹出5g相关的DFS提示
function isShowDfs(){
	if(G.setWifiData.wrlEn_5g == 0 && G.setWifiData.wrlEn ==0){
		return false
	}
	for(var item in G._5gOption){
		if(G._5gOption[item] == "wrlEn_5g"){
			if((G.initWifiData[G._5gOption[item]] != G.setWifiData[G._5gOption[item]]) && G.initWifiData[G._5gOption[item]]=="1"){
				return false;
			}
		}
		if(G.initWifiData[G._5gOption[item]] != G.setWifiData[G._5gOption[item]]){
			return true;
		}
	}
	if(G.initWifiData.doubleBand==false&&G.setWifiData.doubleBand=="1"){
		return true;
	}
	return false
}


//模块注册
R.module("wrlBasic", view, moduleModel);

//初始化页面
function initHtml() {
	top.$(".main-dailog").removeClass("none");
	top.$(".save-msg").addClass("none");
}

//事件初始化
function initEvent() {
	$('[name^="wrlEn"], [name^="wrlEn_5g"]').on("click", function () {
		var setVal = $(this).hasClass("btn-off") ? 1: 0;
		var _name = $(this).attr("name");
		changeWireEn(_name, setVal);
	});

	$("#doubleBandEn").on("click",changeDoubleBand);

	$("select").on("change", function () {
		if ($(this).val() === "none") {
			$(this).parent().parent().next().find("input").val("").attr("disabled", true);
			$(this).parent().parent().next().find("input").removeValidateTip(true).removeClass("validatebox-invalid");
		} else {
			$(this).parent().parent().next().find("input").attr("disabled", false);
		}
		//添加提示
		if($(this).val() == 'wpa3sae' || $(this).val() == 'wpa3saewpa2psk' || $(this).val() == 'none'){
            var infoMsg = $(this).val() == 'wpa3sae' ? _("Please confirm that the access terminal supports WPA3-SAE mode. In case of equipment connection problems during use, it is recommended to switch back to WPA/WPA2-PSK") :
                ($(this).val() == 'none' ? _("Wi-Fi is not encrypted, and there is a risk of being misused by unexpected users. It is recommended to set Wi-Fi password") : _("Please confirm that the access terminal supports WPA3-SAE/WPA2-PSK mode. In case of equipment connection problems during use, it is recommended to switch back to WPA/WPA2-PSK"));
			var $info = $("<p style='color: #999999;margin-right: 130px;'>"+infoMsg+"</p>");
			$(this).siblings().remove();
			$(this).after($info)
		}else{
			$(this).siblings().remove();
		}

	});


	top.loginOut();
	checkData();
}

//模块数据验证
function checkData() {
	G.validate = $.validate({
		custom: function () {
			//if ($("#wrlEn").hasClass("btn-on")) {
			if (($("#security").val() !== "none") && ($("#wrlPwd").val() === "")) {
				return _("Please specify your 2.4 GHz WiFi password.");
			}
			//}

			//if ($("#wrlEn_5g").hasClass("btn-on")) {
			if (($("#security_5g").val() !== "none") && ($("#wrlPwd_5g").val() === "")) {
				return _("Please specify your 5 GHz WiFi password.");
			}
			//}
		},

		success: function () {
			wrlBasicPage.submit();
		},

		error: function (msg) {
			if (msg) {
				$("#wrl_save_msg").html(msg);
				setTimeout(function () {
					$("#wrl_save_msg").html("&nbsp;");
				}, 3000);
			}
			return;
		}
	});
}
function initDoubleBand(en){
	var $ssid2Elem = $('[name="wrlEn"]');
	if(en == "0"){//双频合一关闭时   正常显示配置
		$("#doubleBandEn").removeClass("btn-on").addClass("btn-off");
		$("#5g_fieldset").removeClass("none");
	}else{//双频优选合一时，只显示2.4G
		$("#doubleBandEn").removeClass("btn-off").addClass("btn-on");
		$("#5g_fieldset").addClass("none");
		$("#ssidText").html(_("Enable WiFi Network")); //TODO
		$("#ssid_5g").val((storageSSID24.length>29?storageSSID24.substring(0,29):storageSSID24) + "_5G");
		//2.4G开关
		if (storageSSID24En === "0") {
			$ssid2Elem.attr("class", "btn-off").val(0);
			$ssid2Elem.parent().parent().nextAll().addClass("none").val(1);
		} else {
			$ssid2Elem.attr("class", "btn-on");
			$ssid2Elem.parent().parent().nextAll().removeClass("none");
		}
	}
}
function changeDoubleBand(){
	var enabled = $("#doubleBandEn").attr("class").indexOf("btn-off");

	if(enabled == -1){//开启 => 关闭
		$("#doubleBandEn").removeClass("btn-on").addClass("btn-off");
		$("#doubleBandEn").val(0);
		$("#5g_fieldset").removeClass("none");
		$("#ssidText").html(_("2.4 GHz Network"));
		$("#ssid").val(storageSSID24);

		//切换时默认开启无线开关
		changeWireEn("wrlEn", 1);
		changeWireEn("wrlEn_5g", 1);


	}else{//关闭 =》开启
		//2.4G一定开启
		$("#doubleBandEn").removeClass("btn-off").addClass("btn-on");
		$("#doubleBandEn").val(1);
		$("#5g_fieldset").addClass("none");
		$("#ssidText").html(_("Enable WiFi Network")); //TODO

		storageSSID24 = $("#ssid").val();
		$("#ssid").val(storageSSID24.slice(0,storageSSID24.length).replace(/-2.4[g|G]/g,"").replace(/_2.4[g|G]/g,""));
		//切换时默认开启无线开关
		changeWireEn("wrlEn", 1);
	}
}

//设置
function changeWireEn(_name, setVal) {
	var $elem = $("[name=" +_name+ "]");
	$elem.attr("class", setVal === 1 ? "btn-on": "btn-off").val(setVal);

	if (setVal === 1) {
		$elem.parent().parent().nextAll().removeClass("none");
	} else {
		$elem.parent().parent().nextAll().addClass("none");
	}
	top.initIframeHeight();
}

function initEn(ele, en) {
	if (en === "on") {
		ele.attr("class", "btn-on");
		ele.val(1);
		ele.parent().parent().nextAll().removeClass("none");
	} else {
		ele.attr("class", "btn-off");
		ele.val(0);
		ele.parent().parent().nextAll().addClass("none");
	}
}

function initValue(obj) {
	inputValue(obj);
	G.initWifiData= obj;
	if (obj.wrlEn === "1") {
		initEn($('[name="wrlEn"]'), "on");
	} else {
		initEn($('[name="wrlEn"]'), "off");
	}

	if (obj.wrlEn_5g === "1") {
		initEn($('[name="wrlEn_5g"]'), "on");
	} else {
		initEn($('[name="wrlEn_5g"]'), "off");
	}


	storageSSID24 = obj.ssid;
	storageSSID24En = obj.wrlEn;
	initDoubleBand(obj.doubleBand);

	$("#wrlPwd").initPassword("", false, false);
	$("#wrlPwd_5g").initPassword("", false, false);

	//mainPageLogic.validate.checkAll("wrl-form");
	if (obj.security === "none") {
		$("#wrlPwd").val("").attr("disabled", true);
		if ($("#wrlPwd_").length > 0) {
			$("#wrlPwd_").val("").attr("disabled", true);
		}
        $("select").eq(0).after($("<p style='color: #999999;margin-right: 130px;'>" + _("Wi-Fi is not encrypted, and there is a risk of being misused by unexpected users. It is recommended to set Wi-Fi password") +"</p>"))
	} else {
		$("#wrlPwd").attr("disabled", false);
		if ($("#wrlPwd_").length > 0) {
			$("#wrlPwd_").attr("disabled", false);
		}
		if(obj.security === 'wpa3sae'|| obj.security ==='wpa3saewpa2psk' ){
			var infoMsg = obj.security == 'wpa3sae'?  _("Please confirm that the access terminal supports WPA3-SAE mode. In case of equipment connection problems during use, it is recommended to switch back to WPA2-PSK"): _("Please confirm that the access terminal supports WPA3-SAE/WPA2-PSK mode. In case of equipment connection problems during use, it is recommended to switch back to WPA2-PSK");
			var $info = $("<p style='color: #999999;margin-right: 130px;'>"+infoMsg+"</p>");
			$("select").eq(0).after($info)
		}
	}
	if (obj.security_5g === "none") {
		$("#wrlPwd_5g").val("").attr("disabled", true);
		if ($("#wrlPwd_5g_").length > 0) {
			$("#wrlPwd_5g_").val("").attr("disabled", true);
		}
		$("select").eq(1).after( $("<p style='color: #999999;margin-right: 130px;'>" + _("Wi-Fi is not encrypted, and there is a risk of being misused by unexpected users. It is recommended to set Wi-Fi password") + "</p>"))
	} else {
		$("#wrlPwd_5g").attr("disabled", false);
		if ($("#wrlPwd_5g_").length > 0) {
			$("#wrlPwd_5g_").attr("disabled", false);
		}
		if(obj.security_5g === 'wpa3sae' || obj.security_5g ==='wpa3saewpa2psk'){
			var infoMsg = obj.security_5g == 'wpa3sae'?  _("Please confirm that the access terminal supports WPA3-SAE mode. In case of equipment connection problems during use, it is recommended to switch back to WPA2-PSK"): _("Please confirm that the access terminal supports WPA3-SAE/WPA2-PSK mode. In case of equipment connection problems during use, it is recommended to switch back to WPA2-PSK");
			var $info = $("<p style='color: #999999;margin-right: 130px;'>"+infoMsg+"</p>");
			$("select").eq(1).after($info)
		}
	}

	if (obj.hideSsid == 1) {
		$("#hideSsid")[0].checked = true;
	} else {
		$("#hideSsid")[0].checked = false;
	}
	if (obj.hideSsid_5g == 1) {
		$("#hideSsid_5g")[0].checked = true;
	} else {
		$("#hideSsid_5g")[0].checked = false;
    }
    //获取dfs
    // $.getJSON("goform/GetDfsCfg?" + Math.random(), function (obj) {
    //     G.dfsEnable = obj.enable;
    // });
	// $.getJSON("goform/WifiGuestGet?" + Math.random(), function (obj) {
	// 	//5G访客网络是否关闭
	// 	G.wifiGuest = obj.guestEn_5g;
	// });
}

/******************* Module wireless setting end ************/

window.onload = function () {
    wrlBasicPage = R.page(pageview, pageModel);

};
