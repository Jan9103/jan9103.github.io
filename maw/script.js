const ITEM_LISTS = [
  {"name": "items.json", "url": "./items.json", "image": ""}
];
const g = (name) => document.getElementById(name);
const j = (e) => JSON.stringify(e);
const t = (e) => document.createTextNode(e);
const n = (e) => document.createElement(e);
//const oc = (e, c) => e.addEventListener("click", (i) => {console.log(i); return c(i);});
const oc = (e, c) => e.addEventListener("click", c);
const cn = (e) => { while (e.lastChild) { e.removeChild(e.lastChild); } };

function html_escape(r){
  return r.replace(/[\x26\x0A\<>'"]/g,function(r){return"&#"+r.charCodeAt(0)+";"})  // "
}
const DEFAULT_PAGESIZE = 50;
let que_index = 0;
let que = [];
let available_items = [];
let show_filter = [];
let hide_filter = [];
let filter_text = "";
let current_page = 0;
let pagesize = DEFAULT_PAGESIZE;
let tag_min_count = 0;

function play_previous() {
  play_index(que_index - 1);
}

function play_next() {
  play_index(que_index + 1);
}

function play_index(index) {
  if (index < 0) { return; }
  if (index >= que.length) { return; }
  var old_idx = que_index;
  que_index = index;
  var item = available_items[que[que_index]];
  g("player_img").src = item["image"];
  g("player_title").innerText = item["name"];
  g("player_author").innerText = item["author"];
  g("player_audio_src").src = item["audio"];
  var a = g("player_audio");
  a.load(); a.play();
  var que_items = g("que_items");
  que_items.children[old_idx].classList.remove("active");
  que_items.children[index].classList.add("active");
}

function enque(idx) {
  var item = available_items[idx];
  que.push(idx);

  var q_node = n("li");
  var img_node = n("img");
  img_node.src = item["image"];
  q_node.appendChild(img_node);
  var div_node = n("div");
  div_node.appendChild(t(item["name"]));
  div_node.appendChild(n("br"));
  div_node.appendChild(t(item["author"]));
  q_node.appendChild(div_node);
  var qi = g("que_items");
  var qid = qi.children.length;
  oc(q_node, (_) => {play_index(qid);})
  qi.appendChild(q_node);

  if (que.length == 1) { play_index(0); }
}

function get_filtered_itemlist() {
  var filtered = available_items;
  for (var i = 0; i < show_filter.length; i++) {
    filtered = filtered.filter((item) => {return item["tags"].includes(show_filter[i]);});
  }
  for (var i = 0; i < hide_filter.length; i++) {
    filtered = filtered.filter((item) => {return !(item["tags"].includes(hide_filter[i]));});
  }
  filtered = filtered.filter((item) => {return item["name"].toLowerCase().includes(filter_text);});
  return filtered;
}

function render_page(page) {
  var tpl = g("top-pagelist");
  if (tpl.length > current_page) {
    tpl.children[current_page].classList.remove("active");
    g("bottom-pagelist").children[current_page].classList.remove("active");
  }
  current_page = page;
  var filtered = get_filtered_itemlist();

  var itemlist = g("itemlist");
  cn(itemlist);
  var until_idx = Math.min(((page + 1) * pagesize), filtered.length);
  for (var i = (page * pagesize); i < until_idx; i++) {
    let item = filtered[i];
    var tr_node = n("tr");
    oc(tr_node, (_) => {enque(item["index"]); return false;});
    var td_node = n("td");
    var img_node = n("img");
    img_node.src = item["image"];
    td_node.appendChild(img_node);
    tr_node.appendChild(td_node);
    td_node = n("td");
    td_node.innerText = item["name"];
    a_node = n("a");
    a_node.href = item["audio"];
    a_node.innerText = " 🔗 ";
    td_node.appendChild(a_node);
    // td_node.appendChild(t(item["name"]));
    tr_node.appendChild(td_node);
    td_node = n("td");
    td_node.appendChild(t(item["author"]))
    tr_node.appendChild(td_node);
    itemlist.appendChild(tr_node);
  }

  if (tpl.length > page) {
    tpl.children[page].classList.add("active");
    g("bottom-pagelist").children[page].classList.add("active");
  } else {
    console.log("ISSUE: #top-pagelist.children.length <= page")
  }
}

function update_pagesize(new_pagesize) {
  pagesize = new_pagesize;
  var filtered = get_filtered_itemlist();
  var tpl = g("top-pagelist");
  cn(tpl);
  var bpl = g("bottom-pagelist");
  cn(bpl);
  for (var i = 0; i < filtered.length; i += pagesize) {
    var li_node = n("li");
    var btn_node = n("button");
    let rpi = (i / pagesize);
    oc(btn_node, (_) => {render_page(rpi);});
    btn_node.innerText = "" + (rpi);
    li_node.appendChild(btn_node);
    tpl.appendChild(li_node);

    li_node = n("li");
    btn_node = n("button");
    oc(btn_node, (_) => {render_page(rpi);});
    li_node.appendChild(btn_node);
    btn_node.innerText = "" + (rpi);
    bpl.appendChild(li_node);
  }
  render_page(0);
}

function apply_text_filter() {
  filter_text = g("text_filter").value.toLowerCase();
  update_pagesize(pagesize);
}

function filter_radio_change(e) {
  if (e.target.value != "show") {
    show_filter = show_filter.filter(i => i !== e.target.name);
  } else {
    show_filter.push(e.target.name);
  }
  if (e.target.value != "hide") {
    hide_filter = hide_filter.filter(i => i !== e.target.name);
  } else {
    hide_filter.push(e.target.name);
  }

  update_pagesize(pagesize);
}

function update_filter_view() {
  var all_tags = available_items
    .map((i) => {return i["tags"];})
    .flat()
  var uniq_tags = all_tags.filter((v, i, a) => {return a.indexOf(v) === i;});
  uniq_tags.sort();
  var ft = g("filter_table");
  cn(ft);
  for (var i = 0; i < uniq_tags.length; i++) {
    var tag = uniq_tags[i];
    var tag_count = all_tags.filter((v, i, a) => {return v === tag;}).length;
    if (tag_count < tag_min_count) { continue; }
    var etag = tag.replace(/[^a-zA-Z0-9_]/g, "_");
    var radio = n("input");
    radio.type = "radio";
    radio.name = tag;
    radio.value = "show";
    radio.classList.add("filter_show");
    radio.addEventListener("change", filter_radio_change);
    oc(radio, (b) => filter_radio_change);
    ft.appendChild(radio);
    radio = n("input");
    radio.type = "radio";
    radio.name = tag;
    radio.value = "none";
    radio.checked = true;
    radio.classList.add("filter_none");
    radio.addEventListener("change", filter_radio_change);
    ft.appendChild(radio);
    radio = n("input");
    radio.type = "radio";
    radio.name = tag;
    radio.value = "hide";
    radio.classList.add("filter_hide");
    radio.addEventListener("change", filter_radio_change);
    ft.appendChild(radio);
    ft.appendChild(t(tag + " [" + tag_count + "]"));
    ft.appendChild(n("br"));
  }
}

window.addEventListener("DOMContentLoaded", () => {
  var params = new URLSearchParams(window.location.search);
  var itemlist_url = params.get("items") || "./items.json";
  if (itemlist_url != null) {
    try {
      var tmp = parseInt(params.get("pagesize"));
      if ((!isNaN(tmp)) && (tmp > 0)) { pagesize = tmp; }
    } catch (e) {}
    try {
      var tmp = parseInt(params.get("tag_min_count"));
      if (!isNaN(tmp)) { tag_min_count = tmp; }
    } catch (e) {}
    fetch(itemlist_url)
      .then(x => x.json())
      .then(response_json => {
        available_items = response_json.map((element, index) => { return { "index": index, ...element}; });
        update_pagesize(pagesize);
        update_filter_view();
      });
  } else {
    var il = g("itemlist");
    for (var i = 0; i < ITEM_LISTS.length; i++) {
      var tr_node = n("tr");
      var td_node = n("td");
      var img_node = n("img");
      img_node.src = ITEM_LISTS[i]["image"];
      td_node.appendChild(img_node);
      tr_node.appendChild(td_node);
      td_node = n("td");
      var a_node = n("a");
      a_node.href = ".?items=" + encodeURIComponent(ITEM_LISTS[i]["url"]);
      a_node.innerText = ITEM_LISTS[i]["name"];
      td_node.appendChild(a_node);
      tr_node.appendChild(td_node);
      il.appendChild(tr_node);
    }
  }
  // have to set this here since the "apply_text_filter" function does not exist in html space
  oc(g("text_filter_apply_button"), (_) => apply_text_filter());
});

// ask before leaving
window.addEventListener('beforeunload', function (event) {
  event.preventDefault();
  return (event.returnValue = "");
});
