export 'pick.dart'
    if (dart.library.html) 'pick_web.dart' //image_picker_webライブラリを使用
    if (dart.library.io) 'pick_mobile.dart'; //image_pickerライブラリを使用