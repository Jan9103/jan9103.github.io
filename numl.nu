# Nu markup language (aka nu2html)

export def PAGE [
  ...a
  --header: string = ''
  --body-prefix: string = ''
  --body-suffix: string = ''
]: nothing -> string {
  [
    '<!DOCTYPE HTML><html><head>'
    '<meta charset="utf-8">'
    '<meta name="viewport" content="width=device-width, initial-scale=1.0">'
    '<style id="nojscss">.jsonly{display:none;}</style>'
    '<style id="fcss"></style>'
    '<link rel="stylesheet" type="text/css" href="style.css">'
    '<meta name="author" content="Jan9103">'
    '<script>'
    'function ch(btn){btn.classList.toggle("active");btn.parentElement.nextElementSibling.classList.toggle("hidelvl");btn.innerText=btn.innerText=="-"?"+":"-";}'
    'document.getElementById("nojscss").innerText=".hidelvl{display:none;}";'
    #'document.getElementById("fcss").innerText="div.fmt_Video{display:none;}";'
    #'function cf(btn){document.getElementById("fcss").innerText="div.fmt_"+btn.innerText+"{display:none;}";btn.innerText=btn.innerText=="Video"?"Text":"Video";}'
    '</script>'
    $header
    '</head><body><div class="container">'
    $body_prefix
    (numll $a)
    $body_suffix
    '</div><footer><b>Credits:</b><ul>'
    '<li>Code color scheme: <a href="https://draculatheme.com/">dracula</a></li>'
    '</ul></footer></body></html>'
  ] | str join ''
}

def afm [a]: nothing -> string {
  match ($a | describe | split row '<' | get 0) {
    'list' => { $a | each {|i| afm $i } | str join ' ' }
    'string' => { $a }
    'record' => { record_table $a }
    'date' => { $a | format date '%F' }
    'closure' => {
      let source_code = (view source $a)
      let source_code = (
        if $source_code !~ '^\{ *\| *[^ |]' {  # does it take arguments? (remove closure wrapper)
          $source_code
          | str substring 1..-2  # remove brackets
          | str trim --left --char '|'
          | str trim --char "\n"
        } else { $source_code }
      )
      if "\n" in ($source_code | str trim) {
        code --language "nu" $source_code
      } else {
        '<code>' + (highlight_nu_code ($source_code | str trim)) + '</code>'
      }
    }
    'nothing' => ""
    _ => { $a | into string }
  }
}
alias numlal = afm
alias numll = afm

export def c [...a]: nothing -> string {
  $a | each { afm $in } | str join ''
}
export def ul [...a]: nothing -> string {
  '<ul>' + ($a | each {|i|
    $'<li>(numlal $i)</li>'
  } | str join '' ) + '</ul>'
}
export def ol [...a]: nothing -> string {
  '<ol>' + ($a | each {|i|
    $'<li>(numlal $i)</li>'
  } | str join '' ) + '</ol>'
}

export def b [...a]: nothing -> string {
  $'<b>(numll $a)</b>'
}

export def e [a]: nothing -> string {
  $a
  | into string
  | str replace -a '&' '&amp;'
  | str replace -a '<' '&lt;'
  | str replace -a '>' '&gt;'
  | str replace -a '"' '&quot;'
}

def record_table [a: record]: nothing -> string {
  '<table>' + (
    $a | transpose k v | each {|i|
      '<tr><td>' + (e $i.k) + '</td><td>' + (numlal $i.v) + '</td></tr>'
    } | str join ''
  ) + '</table>'
}

export def code [
  --language(-l): string
  code: string
] {
  # fix indent
  let min_space_indent: int = ($code | lines | where ($it | str trim --right) != '' | each {|i| ($i | str length) - ($i | str trim --left --char ' ' | str length)} | math min)
  let min_tab_indent: int = ($code | lines | where ($it | str trim --right) != '' | each {|i| ($i | str length) - ($i | str trim --left --char "\t" | str length)} | math min)
  let code = (
    if $min_space_indent != 0 {
      $code | lines | each {|i| $i | str substring ($min_space_indent).. } | str join "\n" | str trim
    } else if $min_tab_indent != 0 {
      $code | lines | each {|i| $i | str substring ($min_tab_indent).. } | str join "\n" | str trim
    } else {
      $code | str trim
    }
  )

  match $language {
    null => { $'<div class="cb"><pre>(e $code)</pre></div>' }
    "nu" | "nushell" => { '<div class="cb"><pre>' + (highlight_nu_code $code) + '</pre></div>' }
    _ => {
      # syntax-highlight
      $code
      | ^pygmentize -f html
      | str replace '<span></span>' ''
    }
  }
}

def highlight_nu_code [code]: nothing -> string {
  $code
  | nu-highlight
  | split row (0x[1b 5b] | decode "utf-8")
  | where $it != ''
  | each {|i|
    let tmp = ($i | split row -n 2 'm');
    let ccs = ($tmp.0 | split row ';' | where $it in ["30" "31" "32" "33" "34" "35" "36" "37" "40" "41" "42" "43" "44" "45" "46" "47"])
    if ($ccs == []) or (($tmp.1 | str trim) == '') {
      e $tmp.1
    } else {
      '<span class="' + ($ccs | each {|ac| $'a_($ac)'} | str join ' ') + $'">(e $tmp.1)</span>'
    }
  } | str join ''
}

export def link [text: string url: string]: nothing -> string {
  $'<a href="(e $url)">($text)</a>'
}

export def l2 [heading: string ...body --expanded]: nothing -> string {
  if $expanded {
    $"<h2>($heading) <button onclick=\"ch\(this\)\">-</button></h2><div>(numll $body)</div>"
  } else {
    $"<h2>($heading) <button onclick=\"ch\(this\)\" class=\"active\">+</button></h2><div class=\"hidelvl\">(numll $body)</div>"
  }
}
export def l3 [heading: string ...body]: nothing -> string {
  $"<h3>($heading) <button onclick=\"ch\(this\)\">-</button></h3><div>(numll $body)</div>"
}
export def l4 [heading: string ...body]: nothing -> string {
  $"<h4>($heading) <button onclick=\"ch\(this\)\">-</button></h4><div>(numll $body)</div>"
}

export def t [--jsonly, ...a]: nothing -> string {
  if $jsonly {
    $'<p class="jsonly">(numll $a)</p>'
  } else {
    $'<p>(numll $a)</p>'
  }
}

export def notice [a]: nothing -> string {
  $'<div class="notice_box"><b>Notice:</b> ($a)</div>'
}

export def video [video_code, transcript]: nothing -> string {
  $'<div class="fmt_Video">(numlal $video_code)</div><div class="fmt_Text"><p class="cmt">Video transcript:</p>(numlal $transcript)<p class="cmt">Video transcript end</p></div>'
}

export def comment [...a]: nothing -> string {
  $'<p class="cmt">(numll $a)</p>'
}

export def ntable [
  --header-row: list
  ...a: list
]: nothing -> string {
  [
    '<table>'
    ...(
      if $header_row != null {
        [
          '<tr>'
          ...($header_row | each {|cell| $'<th>(afm $cell)</th>'})
          '</tr>'
        ]
      } else { [] }
    )
    ...($a | each {|row|
      [
        '<tr>'
        ...($row | each {|cell| $'<td>(afm $cell)</td>'})
        '</tr>'
      ]
    })
    '</table>'
  ] | flatten | str join ''
}
