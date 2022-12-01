var G = {};

var macCloneInfo;
var pageview = R.pageView({ //页面初始化
	init: function () {
		top.loginOut();
		top.$(".main-dailog").removeClass("none");
		top.$(".save-msg").addClass("none");
		$("#submit").on("click", function () {
			G.validate.checkAll();
		});
	}
});
var pageModel = R.pageModel({
	getUrl: "goform/AdvGetMacMtuWan",
	setUrl: "goform/AdvSetMacMtuWan",
	translateData: function (data) {
		var newData = {};
		newData.macClone = data;
		return newData;
	},
	afterSubmit: callback
});

/************************/
var view = R.moduleView({
	initEvent: initMacCloneEvent
});
var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () {
		var data,
			mac, mac2, serviceName, serverName;
		if ($("#cloneType").val() == "0") {
			mac = G.data.wanInfo[0].defMac.toUpperCase();
		} else if ($("#cloneType").val() == "1") {
			mac = G.data.wanInfo[0].deviceMac.toUpperCase();
		} else {
			mac = $("#mac").val().toUpperCase();
		}

		data = "wanMTU=" + parseInt($("#wanMTU").val(), 10)
                + "&wanSpeed=" + $("#wanSpeed").val()
                + "&cloneType=" + $("#cloneType").val()
				+ "&mac=" + mac;

		//功能宏开启且拨号方式为PPPOE时，需要向后台传值@edit by pjl
		// if (G.hasServiceName) {
		// 	if($("#serviceType").val() == "0"){
		// 		serviceName = "";
		// 	}else {
		// 		serviceName = $("#serviceName").val();
		// 	}
		// 	if($("#serverType").val() == "0"){
		// 		serverName = "";
		// 	}else {
		// 		serverName = $("#serverName").val();
		// 	}
		// 	data += "&serviceName=" + serviceName
		// 		 + "&serverName=" + serverName;
		// }

		if (G.wanNum == 2) {
			if ($("#cloneType2").val() == "0") {
				mac2 = G.data.wanInfo[1].defMac.toUpperCase();
			} else if ($("#cloneType2").val() == "1") {
				mac2 = G.data.wanInfo[1].deviceMac.toUpperCase();
			} else {
				mac2 = $("#mac2").val().toUpperCase();
			}
			data += "&wanMTU2=" + parseInt($("#wanMTU2").val(), 10) + "&wanSpeed2=" + $("#wanSpeed2").val() + "&cloneType2=" + $("#cloneType2").val() + "&mac2=" + mac2;
		}
		return data;
	}
});

//模块注册
R.module("macClone", view, moduleModel);

function initMacCloneEvent() {
	if (top.CONFIG_1000M_ETH == 'n') { //WAN口速率有无 1000M全/半双工
		$("#wanSpeed").find("option[value=0]").html(_("Auto-negotiation"));
		$("#wanSpeed2").find("option[value=0]").html(_("Auto-negotiation"));
	}
	$("#cloneType").on("change", changeType);
	$("#cloneType2").on("change", changeType2);
	// $("#serviceType").on("change",changeServiceType);
    // $("#serverType").on("change",changeServerType);
    checkData();
	$("#wanMTU").inputCorrect("num");
	$("#mac").inputCorrect("mac");
	$("#wanMTU2").inputCorrect("num");
	$("#mac2").inputCorrect("mac");

}

function checkData() {
	G.validate = $.validate({
		custom: function () {
			var wanMac,
				wanMac2;
			if ($("#cloneType").val() == "0") {
				wanMac = G.data.wanInfo[0].defMac.toUpperCase();
			} else if ($("#cloneType").val() == "1") {
				wanMac = G.data.wanInfo[0].deviceMac.toUpperCase();
			} else {
				wanMac = $("#mac").val().toUpperCase();
			}

			if (G.wanNum == 2) {
				if ($("#cloneType2").val() == "0") {
					wanMac2 = G.data.wanInfo[1].defMac.toUpperCase();
				} else if ($("#cloneType2").val() == "1") {
					wanMac2 = G.data.wanInfo[1].deviceMac.toUpperCase();
				} else {
					wanMac2 = $("#mac2").val().toUpperCase();
				}
				if (wanMac == wanMac2) {
					return _("The WAN2 and WAN1 ports cannot use the same MAC address.");
				}
			}
		},

		success: function () {
			macCloneInfo.submit();
		},

		error: function (msg) {
			showErrMsg("msg-err", msg);
			return;
		}
	});
}

function changeType() {
	if ($("#cloneType").val() == "0" || $("#cloneType").val() == "1") {
		$("#other-mac").addClass("none");
		$("#macaddress").removeClass("none");
		if ($("#cloneType").val() == "0") {
			$("#mac-address").html(_("Default: ") + G.data.wanInfo[0].defMac.toUpperCase());
		} else {
			$("#mac-address").html(_("Local: ") + G.data.wanInfo[0].deviceMac.toUpperCase());
		}
	} else {
		$("#other-mac").removeClass("none");
		$("#macaddress").addClass("none");
	}
	top.initIframeHeight();
}

function changeType2() {
	if ($("#cloneType2").val() == "0" || $("#cloneType2").val() == "1") {
		$("#other-mac2").addClass("none");
		$("#macaddress2").removeClass("none");
		if ($("#cloneType2").val() == "0") {
			$("#mac-address2").html(_("Default: ") + G.data.wanInfo[1].defMac.toUpperCase());
		} else {
			$("#mac-address2").html(_("Local: ") + G.data.wanInfo[1].deviceMac.toUpperCase());
		}
	} else {
		$("#other-mac2").removeClass("none");
		$("#macaddress2").addClass("none");
	}
	top.initIframeHeight();
}

// function changeServiceType() {
//     if($("#serviceType").val() == "1"){    //自定义
//         $("#serviceNameText").addClass("none");
//         $("#other-serviceName").removeClass("none");
//     } else {
//         $("#serviceNameText").removeClass("none");
//         $("#other-serviceName").addClass("none");
//         $("#serviceName-Text").html(_("Keep the default unless necessary"));
//     }
//     top.initIframeHeight();
// }
// function changeServerType() {
//     if($("#serverType").val() == "1"){      //自定义
//         $("#serverNameText").addClass("none");
//         $("#other-serverName").removeClass("none");
//     } else {
//         $("#serverNameText").removeClass("none");
//         $("#other-serverName").addClass("none");
//         $("#serverName-Text").html(_("Keep the default unless necessary"));
//     }
//     top.initIframeHeight();
// }


function initValue(obj) {
	top.$(".main-dailog").removeClass("none");
	top.$("iframe").removeClass("none");
	top.$(".loadding-page").addClass("none");
	var wanArr = ["", "2"],
		wanIndex;
	/*obj = {
		wanType: "2",
		wanMTU:"1492",
		wanSpeed: "2",
		cloneType: "2",
		defMac: "22:22:22:22:22:22",
		deviceMac: "33:33:33:33:33:33",
		mac: "44:44:44:44:44:44"
	};*/
	G.wanNum = obj.wanInfo.length;
	G.wanType = obj.wanInfo[0].wanType;

	for (var i = 0; i < obj.wanInfo.length; i++) {
		wanIndex = wanArr[i];
		switch (obj.wanInfo[i].wanType) {
		case "2":
			$("#wanMTU" + wanIndex).attr("data-options", '{"type": "num", "args":[1280,1492]}');
			break;
		//更新russia（3，4，5）下 wanMTU规格
		case "3":
			$("#wanMTU" + wanIndex).attr("data-options", '{"type": "num", "args":[576,1460]}');
			break;
		case "4":
			$("#wanMTU" + wanIndex).attr("data-options", '{"type": "num", "args":[576,1460]}');
			break;
		case "5":
			$("#wanMTU" + wanIndex).attr("data-options", '{"type": "num", "args":[576,1492]}');
			break;
		default:
			$("#wanMTU" + wanIndex).attr("data-options", '{"type": "num", "args":[1280,1500]}');
			break;
		}

		$("#wanMTU" + wanIndex).val(obj.wanInfo[i].wanMTU);
		$("#wanSpeed" + wanIndex).val(obj.wanInfo[i].wanSpeed);
		$("#cloneType" + wanIndex).val(obj.wanInfo[i].cloneType);
		$("#mac" + wanIndex).val(obj.wanInfo[i].mac).addPlaceholder(_("Format: XX:XX:XX:XX:XX:XX"));
	}

	/*wisp模式下，WAN口参数:WAN口速率和MAC地址克隆功能不可用，保存置灰*/
	if (top.sysInfo.data.wl_mode === "wisp") {
		$('#submit').attr('disabled', true);
	}

	//CONFIG_PAGE_HAVE_SERV_NAME == "y" && wanType为PPPOE拨号时CGI会将servie的值传至前台。否则不传
	//@edit by pjl
	//Russia PPPoE 也需支持service name
	//
	//G.hasServiceName = top.CONFIG_PAGE_HAVE_SERV_NAME == "y" && (obj.wanInfo[0].wanType == "2" || obj.wanInfo[0].wanType == "5");
	G.hasServiceName = ( "2" == obj.wanInfo[0].wanType ) || ( "5" == obj.wanInfo[0].wanType );
	// if (G.hasServiceName) {

	// 	if (obj.wanInfo[0].serviceName == "") {
	// 		$("#serviceType").val("0");
	// 	} else {
	// 		$("#serviceType").val("1");
	// 		$("#serviceName").val(obj.wanInfo[0].serviceName);
	// 	}

	// 	if (obj.wanInfo[0].serverName == "") {
	// 		$("#serverType").val("0");
	// 	} else {
	// 		$("#serverType").val("1");
	// 		$("#serverName").val(obj.wanInfo[0].serverName);
	// 	}

	// 	$("#serviceName_set, #serverName_set").removeClass("none");

	// } else {
	// 	$("#serviceName_set, #serverName_set").addClass("none");
	// }

	G.data = obj;

	changeType();
    // changeServiceType();
    // changeServerType();
	if (top.G.wanNum == 2) {
		$("#wan1LabelTips").removeClass("none");
		$("#wan2SetWrap").removeClass("none");
		changeType2();
	} else {
		$("#wan1LabelTips").addClass("none");
		$("#wan2SetWrap").addClass("none");
	}
	switch (obj.wanInfo[0].typeInfo) {
        case "0":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: 1000M full duplex"));
            break;
        case "1":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: 10M full duplex"));
            break;
        case "2":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: 10M half duplex"));
            break;
        case "3":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: 100M full duplex"));
            break;
        case "4":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: 100M half duplex"));
            break;
        case "5":
            $("#wanSpeedInfo").removeClass('none');
            $("#mac-speed").text(_("Current speed: not connected"));
            break;
        default:
            $("#wanSpeedInfo").addClass('none');
	}
}

function callback(str) {
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;
	top.showSaveMsg(num);
	if (num == 0) {
		//getValue();
		top.advInfo.initValue();
	}
}

window.onload = function () {
	macCloneInfo = R.page(pageview, pageModel);
};
