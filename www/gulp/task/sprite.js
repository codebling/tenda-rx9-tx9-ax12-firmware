
const spritesmith=require('gulp.spritesmith');
const { src, dest } = require('gulp');

const {dist} = require("../config");

function spriteConfig (data) {
    var arr=[];
    data.sprites.forEach(function (sprite) {
        arr.push(".icon-"+sprite.name+
        "{" +
        //"background-image: url('"+sprite.escaped_image+"');"+
        "background-position: "+sprite.px.offset_x+"px "+sprite.px.offset_y+"px;"+
        //"width:"+sprite.px.width+";"+
        //"height:"+sprite.px.height+";"+
        "}\n");
    });
    return arr.join("");
}

function setSpriteImg() {
    
    return src('./img/device/*.png')//需要合并的图片地址
        .pipe(spritesmith({
            imgName: 'img/sprite.png',//保存合并后图片的地址
            cssName: 'css/sprite.css',//保存合并后对于css样式的地址
            padding: 5,//合并时两个图片的间距
            algorithm: 'binary-tree',//注释1
            cssTemplate: spriteConfig

        }))
        .pipe(dest(dist));
}

exports.setSpriteImg = setSpriteImg;


