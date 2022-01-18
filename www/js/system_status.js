var sysStatus;
var pageview = R.pageView({ //页面初始化
	init: initPage
}); //page view

//page model
var pageModel = R.pageModel({
	getUrl: "goform/GetSystemStatus", //获取数据接口
	translateData: function (data) { //数据转换
		var newData = {};
		//系统状态数据
		newData.sysStatus = R.configData(data, ["adv_sys_time", "adv_run_time", "adv_firm_ver", "adv_hard_ver"]);

		//WAN状态数据
		var dataWan = ["adv_connect_type", "adv_connect_status", "adv_connect_time", "adv_ip", "adv_mask", "adv_gateway", "adv_dns1", "adv_dns2", "adv_mac"];
		newData.wanStatus = data.wanInfo;

		//LAN状态数据
		newData.lanStatus = {
			adv_lan_ip: data.adv_lan_ip,
			adv_lan_mask: data.adv_lan_mask,
			adv_lan_mac: data.adv_lan_mac.toUpperCase(),
		};

		//无线状态数据
		newData.wrlStatus = {
			adv_wrl_en: data.adv_wrl_en,
			adv_wrl_ssid: toHtmlCode(data.adv_wrl_ssid),
			adv_wrl_sec: data.adv_wrl_sec,
			adv_wrl_channel: data.adv_wrl_channel,
			adv_wrl_band: data.adv_wrl_band,
			adv_wrl_mac: data.adv_wrl_mac.toUpperCase(),

			adv_wrl_en_5g: data.adv_wrl_en_5g,
			adv_wrl_ssid_5g: toHtmlCode(data.adv_wrl_ssid_5g),
			adv_wrl_sec_5g: data.adv_wrl_sec_5g,
			adv_wrl_channel_5g: data.adv_wrl_channel_5g,
			adv_wrl_band_5g: data.adv_wrl_band_5g,
			adv_wrl_mac_5g: data.adv_wrl_mac_5g.toUpperCase(),

			wifi_enable: data.wifi_enable,
			wifi_enable_5g: data.wifi_enable_5g
        };

        //IPv6状态数据
        newData.ipv6Status = {
			conType: data.conType,
			wanAddr: data.wanAddr,
			gateway: data.gateway,
			lanAddr: data.lanAddr,
			wanPreDNS: data.wanPreDNS,
            		wanAltDNS: data.wanAltDNS,
            		ipv6En: data.ipv6En
        };

		return newData;
	}
});
function initPage() {
	top.loginOut();
	top.$(".main-dailog").removeClass("none");
	top.$(".save-msg").addClass("none");
}


/*****************/
var viewSysStatus = R.moduleView();

var modelSysStatus = R.moduleModel({
	initData: initSysStatus
});


function initSysStatus(data) {
	for (var prop in data) {
		$("#" + prop).html(data[prop]);
	}
	$("#adv_run_time").html(formatSeconds(data["adv_run_time"]));
}

R.module("sysStatus", viewSysStatus, modelSysStatus);

/**********************************/

/*****************/
var viewWanStatus = R.moduleView();

var modelWanStatus = R.moduleModel({
	initData: initWanStatus,
	translateData: function () {

	}
});

function initWanStatus(data) {
	var connectType = [_("Dynamic IP Address"), _("Static IP Address"), _("PPPoE"), _("PPTP"), _("L2TP"), _("PPPoE MODE2")],
		i = 0,
		len = data.length,
		wanArr = ["", "2"],
		wanIndex = "";
	if (top.G.workMode == "client+ap" || top.G.workMode == "ap") {
		$("#wanStatusWrap").addClass("none");
        $("#wanSpeedWrap").addClass("none");
		return;
	} else {
		$("#wanStatusWrap").removeClass("none");
		if (top.G.wanNum == 2) {
			$("#wan1Label").html(_("WAN1 Status"));
			$("#wan2StatusWrap").removeClass("none");
		} else {
			$("#wan1Label").html(_("WAN Status"));
			$("#wan2StatusWrap").addClass("none");
		}
	}

	//从状态页面进来
	if (top.$("[href='#system-status']").parent().hasClass("active") && top.G.wanNum == 2) {
		$("#wanSpeedWrap").removeClass("none");
	} else {
		$("#wanSpeedWrap").addClass("none");
	}
	clearTimeout(refreshTimer);
	refreshTimer = setTimeout(function () {
		sysStatus.model.update();
	}, 5000);

	for (i = 0; i < len; i++) {
		wanIndex = wanArr[i];
		for (var prop in data[i]) {
			if ($("#" + prop + wanIndex).length == "1") {
				$("#" + prop + wanIndex).html(data[i][prop]);
			}
		}
		$("#adv_mac" + wanIndex).html(data[i].adv_mac.toUpperCase());
		$("#adv_connect_time" + wanIndex).html(formatSeconds(data[i].adv_connect_time));
		$("#wanUploadSpeed" + wanIndex).html(translateSpeed(data[i].wanUploadSpeed));
		$("#wanDownloadSpeed" + wanIndex).html(translateSpeed(data[i].wanDownloadSpeed));

		$("#adv_connect_type" + wanIndex).html(connectType[data[i].adv_connect_type]);

		if (data[i].adv_connect_status == 0) {
			$("#adv_connect_status" + wanIndex).html(_("Ethernet cable disconnected"));
		} else if (data[i].adv_connect_status == 1) {
			$("#adv_connect_status" + wanIndex).html(_("Disconnected"));
		} else if (data[i].adv_connect_status == 2) {
			$("#adv_connect_status" + wanIndex).html(_("M#ATI#Connecting…"));
		} else if (data[i].adv_connect_status == 3) {
			$("#adv_connect_status" + wanIndex).html(_("Connected"));
		} else {
			$("#adv_connect_status" + wanIndex).html(_("Disconnected"));
		}
	}
}

R.module("wanStatus", viewWanStatus, modelWanStatus);

/***************************/

var viewLanStatus = R.moduleView();

var modelLanStatus = R.moduleModel({
	initData: initLanStatus
});


function initLanStatus(data) {
	for (var prop in data) {
		$("#" + prop).html(data[prop]);
	}
}

R.module("lanStatus", viewLanStatus, modelLanStatus);
/*************************************/

/***************************/

var viewWrlStatus = R.moduleView();

var modelWrlStatus = R.moduleModel({
	initData: initWrlStatus
});


function initWrlStatus(data) {

	var connectStatusMsg = {
		"none": _("None "),
		"wpawpa2psk": _("WPA/WPA2-PSK"),
		"wpapsk": _("WPA-PSK"),
        "wpa2psk": _("WPA2-PSK"),
        "wpa3sae": _("WPA3-SAE"),
        "wpa3saewpa2psk": _("WPA3-SAE/WPA2-PSK")
	};
	for (var prop in data) {
		$("#" + prop).html(data[prop]);
	}

	if (data.wifi_enable == 0) {
		//表示wifi 2.4G关闭
		$("#adv_wrl_en").html(_("Disable"));
		$(".wifi-enable").addClass("none");
	} else {
		$(".wifi-enable").removeClass("none");

		if (data["adv_wrl_en"] == 1) {
			$("#adv_wrl_en").html(_("Network invisible"));
		} else {
			$("#adv_wrl_en").html(_("Visible"));
		}
		if (data["adv_wrl_band"] == "auto") {
			$("#adv_wrl_band").html(_("20/40"));
		}

		$("#adv_wrl_sec").html(connectStatusMsg[data.adv_wrl_sec]);
	}

	if (data.wifi_enable_5g == 0) {
		//表示wifi关闭了

		$("#adv_wrl_en_5g").html(_("Disable"));

		$(".wifi-enable_5g").addClass("none");
	} else {
		$(".wifi-enable_5g").removeClass("none");

		if (data["adv_wrl_en_5g"] == 1) {
			$("#adv_wrl_en_5g").html(_("Network invisible"));
		} else {
			$("#adv_wrl_en_5g").html(_("Visible"));
		}

		$("#adv_wrl_sec_5g").html(connectStatusMsg[data.adv_wrl_sec_5g]);
	}

}
R.module("wrlStatus", viewWrlStatus, modelWrlStatus);

var refreshTimer = null;
/******************************************/
var viewIPv6Status = R.moduleView();

var modelIPv6Status = R.moduleModel({
	initData: initIPv6Status
});

function initIPv6Status(data) {
    var innerHtml = "",
        wan_type = {
            "dhcp": _("DHCPv6"),
            "pppoe": _("PPPoEv6"),
            "static": _("Static IPv6 Address"),
            "6in4": _("6in4 Tunnel"),
            "6to4": _("6to4 Tunnel"),
            "6rd": _("6rd Tunnel")
        },
        conType;

    if(top.G.workMode !== "router" || data.ipv6En == "0" || top.CONFIG_IPV6_SUPPORT === "n") {
       $("#ipv6Wrap").addClass("none");
        return;
    }

    for (var prop in data) {
		if (prop == "wanAddr" || prop == "lanAddr") {
			for (var i = 0; i < data[prop].length; i++) {
				if (i == 0) {
					innerHtml += "<div>" + data[prop][i] + "</div>";
				} else {
					innerHtml += "<div style='margin-top:7px'>" + data[prop][i] + "</div>";
				}
			}
			$("#" + prop).html(innerHtml);
			innerHtml = "";
        }else if(prop == "conType"){
            conType = data[prop].toLowerCase();
            $("#conType").html(wan_type[conType]);
        } else {
            if(data[prop] != "") {
                $("#" + prop).parents(".control-group").removeClass("none");
                $("#" + prop).html(data[prop]);
            } else {
                $("#" + prop).parents(".control-group").addClass("none");
            }
        }

        if (conType == "6in4" || conType == "6to4") {
            $("#gateway").parents(".control-group").addClass("none");
        }
	}
}

R.module("ipv6Status", viewIPv6Status, modelIPv6Status);
/******************************************/
window.onload = function () {
    sysStatus = R.page(pageview, pageModel);
};

/*************************************/
