var G = {};
var tr069;
var pageview = R.pageView({ //页面初始化
	init: function () {}
});
var pageModel = R.pageModel({
	getUrl: "goform/GetTR069Cfg",
    setUrl: "goform/SetTR069Cfg",
    translateData: function (data) {
		var newData = {};
		newData.tr069 = data;
		return newData;
    },
    afterSubmit: callback
});

var view = R.moduleView({
	initEvent: function () {
        $("#tr069En").on("click",function(){
            $(this).toggleClass("btn-on").toggleClass("btn-off");
            $("#tr069Cfg").toggleClass("none");
        });
        $("#noticeEn").on("click",function(){
            $(this).toggleClass("btn-on").toggleClass("btn-off");
            $("#noticeCfg").toggleClass("none");
        });
        $("#stunEn").on("click",function(){
            $(this).toggleClass("btn-on").toggleClass("btn-off");
            $("#stunCfg").toggleClass("none");
        });
        $(".CA-file").on("change",function(){
            var chooseFilePath = $(".CA-file").val().split("\\");
            if(chooseFilePath && chooseFilePath != "") {
                $("#fileName").html(toHtmlCode(chooseFilePath[chooseFilePath.length-1]));
            }else {
                $("#fileName").html(_("No file selected"));
            }
            $(".uploadFile").attr("title",$("#fileName").html());
        });
        $("#uploadCA").on("click",function(){
            if($(".CA-file").val() == "") {
                showErrMsg("msg-err",_("Please select a file"));
            }else{
                document.forms[0].submit();
                $(this).attr("disabled","");
                $("#submit").attr("disabled","");
            }
        });
        $("#submit").on("click", function () {
            G.validate.checkAll();
        });
        checkData();
	}
});

var moduleModel = R.moduleModel({
    initData: initValue,
    getSubmitData: function () {
        var data,
            subObj = {};

        subObj = {
            "tr069En": $("#tr069En").hasClass("btn-on") ? "1" : "0",
            "tr069Addr": $("[name=tr069Addr]").val(),
            "plateUser": $("[name=plateUser]").val(),
            "platePassword": $("[name=platePassword]").val(),
            "noticeEn": $("#noticeEn").hasClass("btn-on") ? "1" : "0",
            "noticeTime": $("[name=noticeTime]").val(),
            "terminalUser": $("[name=terminalUser]").val(),
            "terminalPwd": $("[name=terminalPwd]").val(),
            "port": $("[name=port]").val(),
            "stunEn": $("#stunEn").hasClass("btn-on") ? "1" : "0",
            "stunAddr": $("[name=stunAddr]").val(),
            "stunPort": $("[name=stunPort]").val(),
        };
        data = objTostring(subObj);
        return data;
    }
});

//模块注册
R.module("tr069", view, moduleModel);

function initValue(obj) {
    inputValue(obj);
    initEnStatus("tr069En","tr069Cfg",obj.tr069En);
    initEnStatus("noticeEn","noticeCfg",obj.noticeEn);
    initEnStatus("stunEn","stunCfg",obj.stunEn);
    $(".uploadFile").attr("title",$("#fileName").html());
	top.initIframeHeight();
}

function initEnStatus(switchId,divId,value){
    if(value == "1"){
        $("#" + switchId).removeClass("btn-off").addClass("btn-on");
        $("#" + divId).removeClass("none");
    }else{
        $("#" + switchId).removeClass("btn-on").addClass("btn-off");
        $("#" + divId).addClass("none");
    }
}

function checkData() {
	G.validate = $.validate({
		custom: function () {},

		success: function () {
			tr069.submit();
		},

		error: function (msg) {
			return;
		}
	});
}
function callback(str) {
	$("#submit").attr("disabled", false);
	if (!top.isTimeout(str)) {
		return;
	}
	top.$("#iframe-msg").html("");

    var num = $.parseJSON(str).errCode;
	top.showSaveMsg(num);
	if (num == 0) {

		top.advInfo.initValue();
	}
}

function afterUpload(){
    var msg = location.search.substring(1);
    if(msg){
        $("#uploadCA").removeAttr("disabled");
        $("#submit").removeAttr("disabled");
        if(msg == "0"){
            showSaveMsg(_("Uploaded"));
        }else{
            $("#uploadCA").removeAttr("disabled");
            $("#submit").removeAttr("disabled");
            // TODO:确定上传失败的msg
            // showErrMsg("msg-err",_("Uploaded"));
        }
    }
}

/*************************************************/
window.onload = function () {
    tr069 = R.page(pageview, pageModel);
    afterUpload();
};