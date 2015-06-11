# ScoreKeeper by al3k and meinwald
# Because, at Ohio State Open Source, we like to keep score
#   
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


bind pub - !score list_score
bind pub - !love add_point
bind pub - !hate take_point

#TODO: perhaps have to restart instead of just rehash, because lines added
#outside of procedures

#NOTE:Make sure to reference $scores as a global when using it!
#open the file for global reading into list
set scores []

set f [open score.dat r]
while {![eof $f]} {
    set line [gets $f]
    if { $line == "" } break
    scan $line "%s %d" nickname score
    set pair [list $nickname $score]
    lappend scores $pair
}
putlog "$scores"
close $f

#Process to list scores.  If no argument is given then list all scores in the file
#If an argument is given then search the list for the argument and return the 
#associated score
proc list_score { nick host hand chan arg } {
 global scores
   if { $arg == "" } {
      set iscore "foo" 
      for {set i 0} {$iscore != ""} {incr i} {  
         set iscore [lindex $scores $i]
         putquick "PRIVMSG $chan :$iscore"
      }
      return 0
    }    
    set iscore [get_score $arg]   
    if {$iscore == ""} {
      putquick "PRIVMSG $chan :There is not score for this entity"
      return 0
    }
    putquick "PRIVMSG $chan :$iscore"
}

#retrieves the score line for a given nickname
proc get_score { nick } {
 global scores 
    set iscore "foo"
    for {set i 0} {$iscore != ""} {incr i} {
       set iscore [lindex $scores $i]
       scan $iscore "%s %d" nickname score
       if { $nickname == $nick } {
       return $iscore
       }
    }
}

#sets the new score after taking or adding points then writes to the file
proc set_score { oldscore newscore } {
 global scores
 if {$oldscore == ""} {
   lappend scores $newscore
   return 0
 }
 set index [ lsearch $scores $oldscore ]
 set scores [ lreplace $scores $index $index $newscore ]
 set w [ open score.dat w]
 set iscore "foo"
 for {set i 0} {$iscore != ""} {incr i} {
    set iscore [lindex $scores $i]
    puts $w $iscore
 }
 close $w
}

proc add_point { nick host hand chan arg } {
   if { $arg == $nick } {
     putquick "PRIVMSG $chan :You can't give yourself points genius"
     return 0
   }
   if {$arg == ""} {
     putquick "PRIVMSG $chan :Who are you giving points to?"
     return 0
   }
   set oldscore [get_score $arg]
   if { $oldscore == "" } {
       set newscore "$arg 1"
       set_score $oldscore $newscore
       return 0
   } 
   scan $oldscore "%s %d" nickname score
   incr score
   set newscore "$nickname $score"
   set_score $oldscore $newscore
}


proc take_point { nick host hand chan arg } {
   if { $arg == $nick } {
     putquick "PRIVMSG $chan :What are you, a masochist"
     return 0
   }
   if {$arg == ""} {
     putquick "PRIVMSG $chan :Who are you taking points from?"
     return 0
   }
   set oldscore [get_score $arg]
   if { $oldscore == "" } {
       set newscore "$arg -1"
       set_score $oldscore $newscore
       return 0
   }
   scan $oldscore "%s %d" nickname score
   incr score -1  
   set newscore "$nickname $score"
   set_score $oldscore $newscore
}

