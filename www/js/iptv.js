var G = {
};
G.vlanArr = [];
G.listMax = 0;
G.subObj = {};
G.initObj = {};
var iptvInfo;
var pageview = R.pageView({ //页面初始化
	init: function () {
		top.loginOut();
		top.$(".main-dailog").removeClass("none");
		top.$(".save-msg").addClass("none");
		$("#submit").on("click", function () {
			if (!this.disabled)
				G.validate.checkAll();
		});
	}
});
var pageModel = R.pageModel({
	getUrl: "goform/GetIPTVCfg",
	setUrl: "goform/SetIPTVCfg",
	translateData: function (data) {
		var newData = {};
		newData.iptv = data;
		return newData;
	},
	beforeSubmit: function () {

		G.subObj = {
			"iptvEn": $("#iptvEn").val(),
            "delVlanTag": $("#delVlanTag").val(),
			"bindLan": $("#bindLan").val(),
            "vlanId": $("#vlanId").val(),
		};
		if (G.subObj.iptvEn == "0") {
			$.extend(G.subObj, {
                "delVlanTag": G.initObj.delVlanTag,
				"vlanId": G.initObj.vlanId,
				"bindLan": G.initObj.bindLan,
			});
		}
		//是否要重启,只要stb相关数据改变了就重启
		G.reboot = false;
		if (G.initObj.iptvEn != G.subObj.iptvEn) {
			G.reboot = true;
		} else {
            if (G.initObj.iptvType != G.subObj.iptvType || G.initObj.vlanId != G.subObj.vlanId || G.initObj.bindLan != G.subObj.bindLan || G.initObj.delVlanTag != G.subObj.delVlanTag) {
				G.reboot = true;
			} else {
				G.reboot = false;
			}
		}
		if (G.reboot && !confirm(_("Please reboot the router after changing the IPTV settings. Do you want to reboot the router?"))) {
			return false;
		}

		return true;
	},
	afterSubmit: callback
});

/************************/
var view = R.moduleView({
	initEvent: initIptvEvent,
	checkData: function () {}
});

var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () {
		return objTostring(G.subObj);
	}
});

//模块注册
R.module("iptv", view, moduleModel);

function initIptvEvent() {
	$("#iptvEn").on("click", function () {
		changeIptvEn();
	});
    $("#delVlanTag").on("click", function () {
        changeVlanEn();
    });
	checkData();
}



function changeVlanEn() {
    var className = $("#delVlanTag").attr("class");
    if (className == "btn-off") {
        $("#delVlanTag").attr("class", "btn-on");
        $("#delVlanTag").val(1);
        $(".vlan_set").removeClass("none");
    } else {
        $("#delVlanTag").attr("class", "btn-off");
        $("#delVlanTag").val(0);
        $(".vlan_set").addClass("none");
    }
	top.initIframeHeight();
}

function changeIptvEn() {
	var className = $("#iptvEn").attr("class");
	if (className == "btn-off") {
		$("#iptvEn").attr("class", "btn-on");
		$("#iptvEn").val(1);
		$(".iptv_set").removeClass("none");
	} else {
		$("#iptvEn").attr("class", "btn-off");
		$("#iptvEn").val(0);
		$(".iptv_set").addClass("none");
	}
	top.initIframeHeight();
}

function checkData() {
	G.validate = $.validate({
		custom: function () {},
		success: function () {
			iptvInfo.submit();
		},
		error: function (msg) {
			if (msg) {
				showErrMsg("msg-err", msg);
			}
			return;
		}
	});
}

function initValue(obj) {
	G.initObj = obj;
	$("#iptvEn").attr("class", (obj.iptvEn == "1" ? "btn-off" : "btn-on"));
	changeIptvEn();
	$("#bindLan").val(obj.bindLan);
	if(4<=parseInt(obj.vlanId, 10)&&parseInt(obj.vlanId, 10)<=4094){
		$("#vlanId").val(obj.vlanId);
	}
    $("#delVlanTag").attr("class", (obj.delVlanTag == "1" ? "btn-off" : "btn-on"));
    changeVlanEn();
	top.initIframeHeight();
}

function callback(str) {
	var reboot = G.reboot;
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;
	if (num == 0) {
		if (reboot) {
			//window.location.href = "redirect.html?3";
			$.get("goform/SysToolReboot?" + Math.random(), function (str) {
				//top.closeIframe(num);
				top.$.progress.showPro("reboot");
				// if (top.isTimeout(str)) {
				// 	return;
				// }
			});
		}  else {
			top.advInfo.initValue();
			top.showSaveMsg(num);
		}
	}
}

window.onload = function () {
	iptvInfo = R.page(pageview, pageModel);
};
