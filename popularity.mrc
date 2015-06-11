on *:text:!luv*:#:{
  if (!$2) { msg # Syntax: !luv <nickname> | return }
  if ($2 !ison #) { msg # [ $+ $nick $+ ]: I don't see anyone by that nickname. | return }
  if ($($+(%,popularity.,$chan,.,$nick),2)) { return }
  set -u600 %popularity. $+ $chan $+ . $+ $nick On
  add.luv $+(#,.,$2)
  .msg # [ $+ $nick $+ ]: You have increased $2 $+ 's popularity rating. It is now $iif($readini(popularity.ini,$+(#,.,$2),popularity),$v1,0)
  .notice $nick [ $+ $nick $+ ]: You must now wait 10 minutes before changing someones popularity rating again.
}

on *:text:!hate*:#:{
  if (!$2) { msg # Synta: !hate <nickname> | return }
  if ($2 !ison #) { msg # [ $+ $nick $+ ]: I don't see anyone by that nickname. | return }
  if ($($+(%,popularity.,$chan,.,$nick),2)) { return }
  set -u600 %popularity. $+ $chan $+ . $+ $nick On
  add.hate $+(#,.,$2)
  .msg # [ $+ $nick $+ ]: You have decreased $2 $+ 's popularity rating. It is now $iif($readini(popularity.ini,$+(#,.,$2),popularity),$v1,0)
  .notice $nick [ $+ $nick $+ ]: You must now wait 10 minutes before changing someones popularity rating again.
}

on *:text:!pop*:#:{
  if (!$2) { msg # [ $+ $nick $+ ]: Your popularity rating is $iif($readini(popularity.ini,$+(#,.,$nick),popularity),$v1,0) | return }
  msg # [ $+ $2 $+ 's $+ ]: popularity rating is $iif($readini(popularity.ini,$+(#,.,$2),popularity),$v1,0)
}

alias -l add.luv { writeini -n popularity.ini $1 popularity $calc($readini(popularity.ini,$1,popularity) + 1) }
alias -l add.hate { writeini -n popularity.ini $1 popularity $calc($readini(popularity.ini,$1,popularity) - 1) }
