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
		var list = "",
			iptvTy, i, vlanId, vlanArry, len, $selectVlan;

		G.subObj = {};
		vlanArry = $("#vlanBody").children();
		len = vlanArry.length;
		list = G.vlanArr.join(",");
		iptvTy = $("#iptvType").val();
		if (iptvTy == "none") {
			vlanId = "";
		} else if (iptvTy == "manual") {
			$selectVlan = $("[name='selectVlan']:checked");
			vlanId = $selectVlan.parent("td").next().text();
		} else {
			list = "85,51";
			vlanId = $("[name='areaVlan']:checked").val();
		}

		G.subObj = {
			//"iptvEn": $("#iptvEn").val(),
			"stbEn": $("#stbEn").val(),
			"igmpEn": $("#igmpEn").val(),
			"iptvType": $("#iptvType").val(),
			"vlanId": vlanId,
			"list": list
		};
		// if (G.subObj.stbEn == "0") {
		// 	$.extend(G.subObj, {
		// 		"iptvType": G.initObj.iptvType,
		// 		"vlanId": G.initObj.vlanId,
		// 		"list": G.initObj.list
		// 	});
		// }

		//是否要重启,只要stb相关数据改变了就重启
		G.reboot = false;

		if (G.initObj.stbEn != G.subObj.stbEn) {
			G.reboot = true;
        } else if (G.subObj.stbEn == '1'){ //开启时才会比较vlan相关数据
			if (G.initObj.iptvType != G.subObj.iptvType || G.initObj.vlanId != G.subObj.vlanId || G.initObj.list != G.subObj.list) {
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
	checkData: function () {
		var $selectVlan = $("[name='selectVlan']:checked"),
			iptvTy = $("#iptvType").val(),
			vlanId;
		//stb开启&自定义时，必须配置一个vlan
		if ($("#stbEn").val() == "1" && iptvTy == "manual" && G.ispType!= "1") {
			vlanId = $selectVlan.parent().next().text();
			if (!vlanId) {
				return _("Please select a VLAN ID.");
			}
		}
	}
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

	$("#stbEn").on("click", function () {
		if(G.ispType == "2" || G.ispType == "3") return
		if (G.initObj.wl_mode == "ap")
			changeSTBEn();
	});

	$("#igmpEn").on("click", function () {
		if (G.initObj.wl_mode == "ap")
			changeIGMPEn();
	});

	$("#iptvType").on("change", changeType);
	$("#vlanList").delegate(".add", "click", addList);
	$("#vlanList").delegate(".del", "click", delList);

	checkData();

}

function addList() {
	var str = "",
		vlan = $("#vlan").val(),
		checked, _class;

	//验证
	if((G.ispType == 6 ||G.ispType == 7) && vlan == G.wanVlanId){
		showErrMsg("msg-err",_("Internet/IPTV Vlan ID cannot be the same."))
		return
	}
	if (G.listMax >= 8) {
		showErrMsg("msg-err", _("Only a maximum of %s VLANs are allowed.", [8]));
		return;
	}
	if (!(/^[0-9]{1,}$/).test(vlan)) {
		showErrMsg("msg-err",  _("The VLAN ID must consist of only digits."));
		return ;
	} else if (parseInt(vlan, 10) > 4094 || parseInt(vlan, 10) < 4) {
		showErrMsg("msg-err",  _("The VLAN ID range is %s.", ["4-4094"]));
		return;
	} else if ($.inArray(vlan, G.vlanArr) != -1) {
		showErrMsg("msg-err",  _("Duplicate VLAN IDs are not allowed."));
		return;
	}
	//当前条目数为0时，默认选中第一条；
	checked = G.listMax === 0 ? "checked=true" : "";
	//添加条目
	str += "<tr>";
	str += "<td class='fixed'><input type='radio' " + checked + " name='selectVlan'>" + "</td>";
	str += "<td class='fixed' class='vlanID'>" + vlan + "</td>";
	str += "<td class='fixed'><span class='delete del' title='" + _("Delete") + "'></span></td>";
	str += "</tr>";
	$("#vlanBody").append(str);
	G.vlanArr.push(vlan);
	G.listMax++;
	$("#vlan").val("");
	top.initIframeHeight();
}

function delList() {
	var $this = $(this),
		vlan = $this.parents("tr").find("td").eq(1).text(),
		checked = $this.parents("tr").find("[type=radio]")[0].checked;

	$(this).parents("tr").remove();
	if (checked) {
		$("#vlanBody").find("input[type='radio']").eq(0).prop("checked", true);
	}

	G.listMax--;
	delArrElem(G.vlanArr, vlan); //公共变量中去掉该值
	top.initIframeHeight();
}

/**
 * [从数组中删除一个指定元素]
 *
 * @param {Array} arr [待删除某个元素的数组]
 * @param {String} val [待删除的元素]
 *
 */
function delArrElem (arr, val) {
	var i, index;
	for (i = 0; i < arr.length; i++) {
		if (arr[i] === val) {
			arr.splice(i, 1);
			break;
		}
	}
}

function changeType() {
	if ($("#iptvType").val() == "none") {
		$("#vlanList").addClass("none");
		$("#area_set").addClass("none");
	} else if ($("#iptvType").val() == "manual") {
		$("#vlanList").removeClass("none");
		$("#area_set").addClass("none");
	} else {
		$("#vlanList").addClass("none");
		$("#area_set").removeClass("none");
	}
	top.initIframeHeight();
}

function changeIGMPEn() {
	var className = $("#igmpEn").attr("class");
	if (className == "btn-off") {
		$("#igmpEn").attr("class", "btn-on");
		$("#igmpEn").val(1);
	} else {
		$("#igmpEn").attr("class", "btn-off");
		$("#igmpEn").val(0);
	}
	top.initIframeHeight();
}

function changeSTBEn() {
	var className = $("#stbEn").attr("class");
	if (className == "btn-off") {
		$("#stbEn").attr("class", "btn-on");
		$("#stbEn").val(1);
		$("#vlan_set").removeClass("none");
	} else {
		$("#stbEn").attr("class", "btn-off");
		$("#stbEn").val(0);
		$("#vlan_set").addClass("none");
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

	/*if (obj.wl_mode != "ap") {
		showErrMsg("msg-err", _("Please disable Wireless Repeating on the WiFi Settings page first."), true);
		$("#submit")[0].disabled = true;
	}*/

	$("#stbEn").attr("class", (obj.stbEn == "1" ? "btn-off" : "btn-on"));
	changeSTBEn();

	$("#igmpEn").attr("class", (obj.igmpEn == "1" ? "btn-off" : "btn-on"));
	changeIGMPEn();


	$("#iptvType").val(obj.iptvType);
	if ($("#iptvType").val() == "shanghai") {
		$("[name='areaVlan'][value='" + obj.vlanId + "']")[0].checked = true;
	}
	changeType();

	var vlanStr = "",
		vlanArry = obj.list === "" ? [] : obj.list.split(","),
		checked = '',
		len = vlanArry.length,
		hasSelectVlan = false,
		i = 0;

	//add button
	vlanStr += "<tr><td class='fixed'></td>";
	vlanStr += "<td class='fixed'><input alt='vlanIpt' id='vlan' type='text' class='input-small' maxlength='4'></td>";
	vlanStr +="<td class='fixed'><input type='button' class='btn add btn-small btn-action' value='" + _("+New") + "'></td></tr>";

	//vlan list
	for (i = 0; i < len; i++) {
		//vlan列表中的位置
		//判断list中当前vlan是否为已选中的vlan
		if (obj.vlanId === vlanArry[i]) {
			checked = "checked=true";
			hasSelectVlan = true;
		} else {
			checked = "";
		}

		vlanStr += "<tr><td class='fixed'><input type='radio' name='selectVlan' " + checked + ">" + "</td>";
		vlanStr += "<td class='fixed'>" + vlanArry[i] + "</td>";
		vlanStr += "<td class='fixed'><span class='delete del' title='" + _("Delete") + "'></span></td></tr>";
		G.vlanArr.push(vlanArry[i]);
	}

	$("#vlanBody").html(vlanStr);
	//vlanlist不为空 && vlanlist中没有选中的vlan => 默认选择第一项
	if (len > 0 && !hasSelectVlan) {
		$("#vlanBody").find("input[type=radio]").eq(0).attr("checked", true);
	}

	$("#vlanBody input[alt=vlanIpt]").inputCorrect("num");
	G.listMax = len;
	$.getJSON("goform/getWanParameters" + "?" + Math.random(), function (obj) {
		var wanInfo = obj.wanInfo[0]
		G.ispType = wanInfo.ispType
		G.wanVlanId = wanInfo.wanVlanId
		switch (wanInfo.ispType){
			case "0":
				$("#multicast").show()
				break;
			case "5":
				$("#multicast").show()
				break;
			case "1":
				$("#multicast").hide()
				$("#vlan_set").hide()
				break;
			case "3":
			case "2":
				$("#vlan_set").hide()
				$("#stbEn").css('cursor','not-allowed')
				if($("#stbEn").attr("class") == 'btn-off'){
					$("#stbEn").addClass('btn-off-disabled')
				}else{
					$("#stbEn").addClass('btn-on-disabled')
				}
				break;
		}
	});
	top.initIframeHeight();
}

function callback(str) {
	var reboot = G.reboot;
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;

	//top.showSaveMsg(num);
	if (num == 0) {
		//getValue();
		if (reboot) {
			//window.location.href = "redirect.html?3";
            //by xm 关闭弹出时取消了重启的请求，导致重启请求不能正常下发到后台，解决方法，将重启的请求放到外层
            top.toolReboot(function(num) {
                top.$.progress.showPro("reboot")
            })
		} else {
			top.advInfo.initValue();
			top.showSaveMsg(num);
		}

	}
}

window.onload = function () {
	iptvInfo = R.page(pageview, pageModel);
};
