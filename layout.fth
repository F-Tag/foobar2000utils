?????6J?A_s??!   QiDUN?Y?????C?   S???w?P4?3??   ??rh?J?#?$?N??p  ???.hx?L?w??H?3?nlj?6?O?7d{?]?&?nlj?6?O?7d{?]?&?  E  !  ???.hx?L?w??H?3;????VG??????L?   ?   T  ?LQ?N??~u???\脝?o?O??;qϸ?W      i        by folder structure??'\nF?t?{kf)?(   |+uVz?^?????!/o   ??f??~.<{?w?QSY       No??	??K??g?>?D^x   ????????    )?????TG?0??ʵ'       ޾M?o??H????R)t?        ?   x       )?I%??H??s??)??        ?   x       I6??tO?B???#??        K   x       ?????&5H?<P2?3        x  x       IN???PD?8??E??        ?   x       ?X??;?H??<??l?0        d   `                   x   ????????    ??S??D??QC\? ?0Ԑ?1??E?v?0???  X  ?   active_frontend_kind 0
has_border true
colors
{
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
    color
    {
        r 0
        g 0
        b 0
        a 1
        override false
    }
}
shade_played true
display_mode 0
flip_display false
downmix_display 0
channel_order
{
    mapping
    {
        channel 16
        enabled true
    }
    mapping
    {
        channel 1
        enabled true
    }
    mapping
    {
        channel 4
        enabled true
    }
    mapping
    {
        channel 2
        enabled true
    }
    mapping
    {
        channel 32
        enabled true
    }
    mapping
    {
        channel 8
        enabled true
    }
    mapping
    {
        channel 64
        enabled false
    }
    mapping
    {
        channel 128
        enabled false
    }
    mapping
    {
        channel 256
        enabled false
    }
    mapping
    {
        channel 512
        enabled false
    }
    mapping
    {
        channel 1024
        enabled false
    }
    mapping
    {
        channel 2048
        enabled false
    }
    mapping
    {
        channel 4096
        enabled false
    }
    mapping
    {
        channel 8192
        enabled false
    }
    mapping
    {
        channel 16384
        enabled false
    }
    mapping
    {
        channel 32768
        enabled false
    }
    mapping
    {
        channel 65536
        enabled false
    }
    mapping
    {
        channel 131072
        enabled false
    }
}
generic_strings ""
{    w???B??@??8d??^      ,         ????????????????       ?  ?     JScript   // ==PREPROCESSOR==
// @name "Duplication Remover"
// @author "Fumiaki Taguchi"
// @feature "dragdrop"
// @import "%fb2k_component_path%docs\helpers.txt"
// ==/PREPROCESSOR==

// var g_font = gdi.Font("ＭＳ 明朝", 16, 1);
var g_font = gdi.Font("メイリオ", 16, 1);

fb.trace("Remove Start.");

function test() {
    // この中に試したいコードを書いてください。マウスクリックで実行されます。
    // マウス中ボタンクリックでこのウィンドウが出ます。

    remove_duplicated_data();
    fb.trace("Removed!");

}

function on_mouse_mbtn_down(x, y, mask) {
    window.ShowConfigure();
}

function on_mouse_lbtn_down(x, y, mask) {
    test();
}

function on_paint(gr) {
    gr.SetTextRenderingHint(5);
    var ww = window.Width;
    var wh = window.Height;
    var txt = "Click to remove duplicates";
    gr.DrawString(txt, g_font, RGB(64, 64, 128), 0, 0, ww, wh, 0x11005000);
}

// メタ文字をエスケープ
var regExpEscape = function (str) {
    if (typeof (str) == "string") {
        // return str.replace(/[-\/\\^$*+?.()|\[\]{}]/g, '\\$&').toLowerCase();
        str = str.replace(/[-\/\\^$*+?.()|\[\]{}]/g, '');
        str = str.replace(/[（）［］'’~～-]/g, "");
        str = str.replace("　", " ");
        return str.toLowerCase();;
    } else {
        return str;
    }
};

//アクティブなプレイリストから重複するトラックを除去
// 2016/11/19 Junya Renno
function remove_duplicated_data() {
    // 設定
    var check1 = true; //同じtitle,かつ同じartist,同じdateの曲を除く
    var check2 = true; //同じtitle,かつ同じartistで,違うdateの曲を除く
    var check3 = true; //ほぼ同じtitle,かつ同じartistの曲を除く（instrumental,remix,var）
    var check4 = false; //同じtitleで違うartistの曲を除く

    // 初期化
    var sorted_list = new Array;
    var delete_items = new Array;
    var tmp_title, tmp_artist, tmp_date, tmp_album;
    var loc = plman.GetPlayingItemLocation();
    var locitem = loc.PlaylistItemIndex;
    var handles = plman.GetPlaylistItems(plman.ActivePlaylist);
    var re_album = new RegExp('come along', 'i');
    var count = plman.PlaylistItemCount(plman.ActivePlaylist);
    if (count <= 0) return;

    // ActivePlaylistから比較用のデータを取り出す
    for (var i = 0; i < count; i++) {
        var pl_tf = fb.TitleFormat("%title% ^^ %artist% ^^ %date% ^^ %albumyear% ^^ %album%").EvalWithMetadb(handles.item(i))
        var pl_el = pl_tf.split(" ^^ ");
        if (pl_el[2] == "?") pl_el[2] = pl_el[3];
        pl_el[2] = pl_el[2].slice(0, 4);
        sorted_list[i] = [regExpEscape(pl_el[0]), i, pl_el[1], pl_el[2], regExpEscape(pl_el[4])];
    }

    // title&dateでソート
    sorted_list.sort(function (a, b) {
        if (a[0] > b[0]) return 1;
        if (a[0] < b[0]) return -1;

        // albumyear は新しい順、例外アルバムは更に後ろ
        if (re_album.test(b[4])) return -1;
        else if (re_album.test(a[4])) return 1;
        else if (a[3] < b[3]) return 1;
        else if (a[3] > b[3]) return -1;
        return 0;
    });

    // 実際の判定処理
    for (var i = 0; i < count; i++) {
        var re = new RegExp('^' + tmp_title, 'i');
        //  remix| version| mix|
        var re2 = new RegExp('live|tv|short|single', 'i');
        var re_inst = new RegExp('instrumental|without vocals|backing track|karaoke|inst|カラオケ', 'i');
        if (re_inst.test(sorted_list[i][0])) {
                    fb.trace("check inst: " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3] + " " + sorted_list[i][4]);
                    delete_items.push(sorted_list[i][1]);
                } else if (sorted_list[i][0] == tmp_title) {
            if (sorted_list[i][2] == tmp_artist) {
                if (re_album.test(sorted_list[i][4])) {
                    fb.trace("check album: " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3] + " " + sorted_list[i][4]);
                    delete_items.push(sorted_list[i][1]);
                } else if (check1 && sorted_list[i][3] == tmp_date) {
                    fb.trace("check1 * " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3]);
                    delete_items.push(sorted_list[i][1]);
                } else if (check2) {
                    fb.trace("check2 * " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3]);
                    delete_items.push(sorted_list[i][1]);
                }
            } else if (check4) {
                fb.trace("check4 * " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3]);
                delete_items.push(sorted_list[i][1]);
            }
        } else if (check3 && re.test(sorted_list[i][0]) && re2.test(sorted_list[i][0])) {
            fb.trace("check3 * " + sorted_list[i][0] + " " + sorted_list[i][2] + " " + sorted_list[i][3]);
            delete_items.push(sorted_list[i][1]);
        } else {
            tmp_title = sorted_list[i][0];
            tmp_artist = sorted_list[i][2];
            tmp_date = sorted_list[i][3];
            tmp_album = sorted_list[i][4];
        }
    }
    // プールしておいた曲を選択
    plman.SetPlaylistSelection(plman.ActivePlaylist, delete_items, true);

    // 選択曲を除去
    // plman.RemovePlaylistSelection(plman.ActivePlaylist);

    // list のクリア
    sorted_list = null;

}

 x   ????????    x   ????????    ????B??%gq??     \脝?o?O??;qϸ?   Album Art Viewer??S??D??QC\? ?   Waveform Seekbar0Ԑ?1??E?v?0??   WSH Panel Mod;????VG??????L   Playlist Tabs?LQ?N??~u???
   Album List???.hx?L?w??H?3   Splitter (top/bottom)?nlj?6?O?7d{?]?&   Splitter (left/right))?????TG?0??ʵ'   Playlist View