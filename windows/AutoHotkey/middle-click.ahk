; Taken from: https://superuser.com/a/1822468

cos_mousedrag_treshold := 20 ; pixels

#HotIf !WinActive("ahk_class ConsoleWindowClass", )

~lButton::
{
 /*
  * Detects a double click and copies text after a short delay
  */
  If (A_TimeSincePriorHotkey != ''){
    If (A_TimeSincePriorHotkey<400) and (A_PriorHotkey="~LButton"){
      Sleep 100
      SendInput("^c")
      return
    }
  }

  MouseGetPos(&cos_mousedrag_x, &cos_mousedrag_y)
  KeyWait("lbutton")
  MouseGetPos(&cos_mousedrag_x2, &cos_mousedrag_y2)
  if (abs(cos_mousedrag_x2 - cos_mousedrag_x) > cos_mousedrag_treshold
    or abs(cos_mousedrag_y2 - cos_mousedrag_y) > cos_mousedrag_treshold)
  {
    cos_class := WinGetClass("A")
    if (cos_class == "Emacs")
      SendInput("!w")
    else
      SendInput("^c")
  }
  return
}

~mbutton::
{
  cos_class := WinGetClass("A")
  if (cos_class == "Emacs")
    SendInput("^y")
  else
    SendInput("^v")
  return
}

#HotIf !WinActive(, )


;; clipx
^mbutton::
{
  SendInput("^+{insert}")
  return
}