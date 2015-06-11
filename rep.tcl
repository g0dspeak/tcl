## Rep.tcl-v.1.1.1
## Author: Luminous
## Support: pm on egghelp.org

## This is a private script for users to add or remove reputation points to/from users. Its intended use is to keep track of positively and negatively contributing users, similar to forums with reputation systems. Points will be logged to the file "~/eggdrop/rep.txt". Note that everyone starts off at 0 or "neutral" points and does not show up as having reputation via !rep or !rep NICK until they reach negative or positive points. If points are removed from a user not in the file, they are automatically given -1. If rep is added to a user not in the file, they are automatically given 1. The plus/minus increments work normally from there unless the user reaches 0, or neutral, again.

## Commands

# All commands are public

# To add a reputation point to a user, use "NICK++"

# To remove a reputation point, use "NICK--"

# To view the reputation points of a specific user, use "!rep NICK"

# To view all reputation, use "!rep". A list will be privmsg'd to you slowly to avoid flooding.

# Set below the char you want to trigger the "rep" functions with:

set bchar "!"

## Code starts, edit beyond here at your own risk

bind msgm * * rep
proc rep {nick host hand text} {
 global bchar
    if {[regexp -nocase {^\S+(\+\+|--)$} $text] || [regexp "^${bchar}rep.*" $text]} {
        if {![file exists "rep.txt"]} {
            close [open "rep.txt" w]
        }
        set fs [open "rep.txt"]
        set data [split [read -nonewline $fs] \n]
        close $fs
        if {[regexp -nocase {^\S+\+\+$} $text]} {
            set whom [join [lindex [split $text +] 0]]
            if {[string equal -nocase "[string map {"\[" "\\\[" "\]" "\\\]" "\}" "\\\}"} $whom]" "[string map {"\[" "\\\[" "\]" "\\\]" "\}" "\\\}"} $nick]"]} {
                putserv "PRIVMSG $nick :You cannot rep yourself."
                return
            }
            set match [lsearch $data "[string map {"\[" "\\\[" "\]" "\\\]" "\}" "\\\}"} $whom] *"]   
            if {$match == -1} {
                if {![llength $data]} {
                    set fs [open "rep.txt" w]
                } else {
                    set fs [open "rep.txt" a]
                }
                puts $fs "$whom 1"
                close $fs
                putserv "PRIVMSG $nick :$whom now has 1 reputation point."
                return 0
            } else {
                set line [lindex $data $match]
                set rep [lindex $line 1]
                  incr rep
      if {$rep == 0} {
                    set lines [lreplace $data $match $match]
      } else {
                    set newline "$whom $rep"
                    set lines [lreplace $data $match $match $newline]
                }
                set fs [open "rep.txt" w]
                puts $fs [join $lines "\n"]
                close $fs
      if {$rep == 0} {
                    putserv "PRIVMSG $nick :$whom now has neutral reputation points."
      } elseif {$rep == -1} {
                    putserv "PRIVMSG $nick :$whom now has $rep reputation point."
      } else {
                    putserv "PRIVMSG $nick :$whom now has $rep reputation points."
      }
       }
        } elseif {[regexp -nocase {^\S+--$} $text]} {
            set whom [join [lindex [split $text -] 0]]
            set match [lsearch $data "[string map {"\[" "\\\[" "\]" "\\\]" "\}" "\\\}"} $whom] *"]
            if {$match == -1} {
                if {![llength $data]} {
                    set fs [open "rep.txt" w]
                } else {
                    set fs [open "rep.txt" a]
                }
                puts $fs "$whom -1"
                close $fs
                putserv "PRIVMSG $nick :$whom now has -1 reputation point."
                return
            }
            set line [lindex $data $match]
            set rep [lindex $line 1]
            incr rep -1
            set newline "$whom $rep"
            if {$rep == 0} {
                set lines [lreplace $data $match $match]
                set check 0
            } elseif {$rep == 1} {
                set lines [lreplace $data $match $match $newline]
                set check 1
            } else {
                set lines [lreplace $data $match $match $newline]
                set check 2   
       }
            set fs [open "rep.txt" w]
            puts $fs [join $lines "\n"]
            close $fs
            if {$check == 0} {
                putserv "PRIVMSG $nick :$whom now has neutral reputation points."
            } elseif {$check == 1} {
      putserv "PRIVMSG $nick :$whom now has 1 reputation point."
            } else {
            putserv "PRIVMSG $nick :$whom now has $rep reputation points."
       }
   } elseif {[string equal "${bchar}rep" $text]} {
            if {![llength $data]} {
      putserv "PRIVMSG $nick :No one currently has any reputation points."
                return 0
       }
            putserv "PRIVMSG $nick :   The reputation list is as follows:"
            set fs [open "rep.txt"]
            while {[gets $fs line] >= 0} {
                set rep [join [lindex [split $line] 1]]
                if {$rep == 1 || $rep == -1} {
                    puthelp "PRIVMSG $nick :[join [lindex [split $line] 0]] has $rep reputation point."
                } else {
                    puthelp "PRIVMSG $nick :[join [lindex [split $line] 0]] has $rep reputation points."
                }
            }
            puthelp "PRIVMSG $nick :   End of reputation list"
            close $fs
        } elseif {[string match -nocase "${bchar}rep *" $text]} {
            if {[llength [split $text]] != 2} {
              return
            }
        set whom [string map {"\[" "\\\[" "\]" "\\\]" "\}" "\\\}"} [join [lindex [split $text] end]]]
       regsub -all {\s} $whom ""
        set line [lsearch $data "$whom *"]
        if {$line != -1} {
        set line [lindex $data $line]
        set whom [string map {"\\\]" "\]" "\\\[" "\[" "\\\{" "\{" "\\\}" "\}"} $whom]
            if {[lindex [split $line] 1] == 1 || [lindex [split $line] 1] == -1} {
           putserv "PRIVMSG $nick :$whom has [lindex [split $line] 1] reputation point."
            } else {
           putserv "PRIVMSG $nick :$whom has [lindex [split $line] 1] reputation points."
            }
        } else {
           putserv "PRIVMSG $nick :$whom has no reputation points"
        }
   }
    }       
  return
}

putlog " -rep.tcl loaded"	
