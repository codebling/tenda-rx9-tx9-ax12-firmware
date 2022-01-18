const { src, dest } = require('gulp');
const {dist} = require("../config");
function copyFile() {
    return src(['./{img,goform,fonts,lang}/**'])
          .pipe(dest(dist));
  }
  
exports.copyFile = copyFile;