var G = {};
var initObj = null;

var sysTimeInfo;
var pageview = R.pageView({ //页面初始化
	init: function () {
		top.loginOut();
		top.$(".main-dailog").removeClass("none");
		top.$(".save-msg").addClass("none");
		$("#submit").on("click", function () {
			G.validate.checkAll();
		});
		$("[name='timeType']").on("click", changeTimeType);
		$("#syncTime").on("click", copySyncTime);
	}
});
var pageModel = R.pageModel({
	getUrl: "goform/GetSysTimeCfg",
	setUrl: "goform/SetSysTimeCfg",
	translateData: function (data) {
		var newData = {};
		newData.sysTime = data;
		return newData;
	},
	afterSubmit: callback
});

/************************/
var view = R.moduleView({
	initEvent: checkData
});
var moduleModel = R.moduleModel({
	initData: initValue,
	getSubmitData: function () {
		var data,
			subObj = {},
			timeZone = $("#timeZone").val();

		subObj = {
			"timeType": $("[name='timeType']:checked").val(),
			//"timePeriod": $("#timePeriod").val(initObj.timePeriod),
			//"ntpServer": $("#ntpServer").val(initObj.ntpServer),
			"timePeriod": initObj.timePeriod,
			"ntpServer": initObj.ntpServer,
			"timeZone": timeZone,
			"time": $("#year").val() + '-' + $("#month").val() + '-' + $("#day").val() + ' ' + $("#hour").val() + ':' + $("#minute").val() + ':' + $("#second").val()
		};
		data = objTostring(subObj);
		return data;
	}
});

//模块注册
R.module("sysTime", view, moduleModel);

function checkData() {
	G.validate = $.validate({
		custom: function () {
		    var dateReg = /^((((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(10|12|0?[13578])([-\/\._])(3[01]|[12][0-9]|0?[1-9]))|(((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(11|0?[469])([-\/\._])(30|[12][0-9]|0?[1-9]))|(((1[8-9]\d{2})|([2-9]\d{3}))([-\/\._])(0?2)([-\/\._])(2[0-8]|1[0-9]|0?[1-9]))|(([2468][048]00)([-\/\._])(0?2)([-\/\._])(29))|(([3579][26]00)([-\/\._])(0?2)([-\/\._])(29))(([1][89][0][48])([-\/\._])(0?2)([-\/\._])(29))|(([2-9][0-9][0][48])([-\/\._])(0?2)([-\/\._])(29))|(([1][89][2468][048])([-\/\._])(0?2)([-\/\._])(29))|(([2-9][0-9][2468][048])([-\/\._])(0?2)([-\/\._])(29))|(([1][89][13579][26])([-\/\._])(0?2)([-\/\._])(29))|(([2-9][0-9][13579][26])([-\/\._])(0?2)([-\/\._])(29)))$/;
		    var year = $("#year").val(),
		    	month = $("#month").val(),
		    	day = $("#day").val(),
		    	hrs = +$("#hour").val(),
		    	min = +$("#minute").val(),
		    	sec = +$("#second").val();
		    var timeType = $("[name='timeType']:checked")[0].value;

		    if (timeType === "manual") {
		    	//日期不存在
				if (!dateReg.test(year + "-" + month + "-" + day)) {
			    	return _("Invalid date, Please re-enter");
			    }
			    //时间不存在
			    //0, 23
			    //0, 59
			    //0, 59
			    if (hrs > 23 || min >59 || sec > 59) {
			    	return _("Invalid time, Please re-enter");
			    }
		    }
		},
		success: function () {
			sysTimeInfo.submit();
		},

		error: function (msg) {
			if (msg) {
				$("#msg-err").html(msg);
			}
			return;
		}
	});
}

function changeTimeType() {
	var val = $("[name='timeType']:checked")[0].value;
	$("#msg-err").html("");
	if (val === "sync") {
		$("#manual_set").addClass("none");
		$("#sync_set").removeClass("none");
	} else {
		$("#manual_set").removeClass("none");
		$("#sync_set").addClass("none");
	}
}

function copySyncTime() {
	var date = new Date();
    $("#year").val(date.getFullYear());
    $("#month").val(date.getMonth() + 1);
    $("#day").val(date.getDate());
    $("#hour").val(date.getHours());
    $("#minute").val(date.getMinutes());
    $("#second").val(date.getSeconds());
}

function initValue(obj) {


	initObj = obj;


	var ruTimeZoneList = ["2:00", "3:00", "4:00", "5:00", "6:00", "7:00", "8:00", "9:00", "10:00", "11:00", "12:00", ];
	var timeZoneTemp = obj.timeZone;
	var date = obj.time.split(" ")[0];
	var tm = obj.time.split(" ")[1];

	if (top.G.countryCode === "RU" || top.G.countryCode === "UA") {
		$("#timeZone").val(timeZoneTemp);
	} else {
		//非俄罗斯及乌克兰地区移除新增的时区
		$(".ruTimezone").remove();
		$("#timeZone").val(obj.timeZone);
	}

	$("#sysTime").text(obj.time);
	//2014-01-12 12:22:30
	$("#year").val(date.split("-")[0]);
    $("#month").val(date.split("-")[1]);
    $("#day").val(date.split("-")[2]);
    $("#hour").val(tm.split(":")[0]);
    $("#minute").val(tm.split(":")[1]);
    $("#second").val(tm.split(":")[2]);

	if (obj.isSyncInternetTime == "true") {
		$("#syncInternetTips").text(_("(synchronized with internet time)"));
	} else {
		$("#syncInternetTips").text(_("(unsynchronized with internet time)"));
	}
	/*$("#ntpServer").val(obj.ntpServer);
	$("#timePeriod").val(obj.timePeriod);*/
	$("[name=timeType][value="+obj.timeType+"]").attr("checked", true);
	changeTimeType();
	top.initIframeHeight();
}

function callback(str) {
	if (!top.isTimeout(str)) {
		return;
	}
	var num = $.parseJSON(str).errCode;

	top.showSaveMsg(num);
	if (num == 0) {
		top.advInfo.initValue();
	}
}


window.onload = function () {
	sysTimeInfo = R.page(pageview, pageModel);
};
