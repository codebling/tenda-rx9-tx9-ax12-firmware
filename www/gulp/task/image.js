const { src, dest, series } = require('gulp');
const {dist} = require("../config");
function copyIco() {
    return src(['./gulp/otherStyle/*.ico'])
        .pipe(dest(dist));
}

function copyImg() {
    return src(['./gulp/otherStyle/*.*', '!./gulp/otherStyle/*.ico'])
        .pipe(dest(dist + '/img'));
}
  
exports.copyImg = series(copyIco, copyImg);