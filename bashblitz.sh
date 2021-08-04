#!/bin/bash
function rep { for i in $(seq 1 1 $2);do printf "%s" "$1";done }
function writeLevel { 
    printf "\e[26;11H\e[33m%3s" "$LEVEL"; 
    local text temp_arr
    if [ -f "bashblitz.max" ]; then
        text=$(cat bashblitz.max)
        readarray -d \| -t temp_arr <<< $text
        MAXLEVEL=${temp_arr[0]};MAXSCORE=${temp_arr[1]}
    else MAXLEVEL="0";MAXSCORE="0 "; fi
    printf "\e[26;22H\e[33m%3s" "$MAXLEVEL"
    printf "\e[31;19H\e[33m%7s" "$MAXSCORE"
}
function writeScore { printf "\e[29;18H\e[33m%7s" "$SCORE"; }
function sound { if ((SPEAKER==1));then (speaker-test --frequency $1 --test sine &> /dev/null)& pid=$!;disown $pid;sleep 0.${2}s;kill -9 $pid;else printf "\a";fi;}
function initCity {
    X=-$PL+2;((Y=CH-5));B=0;BY=0;BLOQLEFT=CW+1
    if ((LEVEL<=7));then SPEED=$(awk -v l=$LEVEL 'BEGIN {printf "%.2f",0.45-l*0.05}');
    else SPEED=$(awk -v l=$LEVEL 'BEGIN {printf "%.2f",0.11-(l-8)*0.01}');fi
    local y x al txt="\e[1;37m"
    for ((y=$((LINES-CH));y<$((LINES-1));y++));do txt+="\e[$((y));$((X0-7*2+1))H$(rep '  ' $((CW+14)) )";done   
    txt+="\e[33m"
    for ((x=0;x<=CW;x++));do 
        A[$x]=4+$RANDOM%15;al=$((4+RANDOM%3))
        for ((y=1;y<=${A[$x]};y++));do txt+="\e[$((Y0-y));$((X0+x*2))H\e[4${al}m··";done
    done
    txt+="\e[22;32m"
    for ((x=-6;x<=CW+6;x++));do txt+="\e[$((Y0));$((X0+x*2))H██";done
    printf "$txt\e[0m\e[40m"
}
function motor {
    function plane {
        local y
        for ((y=-2;y<1;y++));do printf "\e[$((Y0-Y+y));$((X0+X*2))H$(rep ' ' $PL)";done
        ((X++))
        if ((X>=CW+4)); then 
            X=-$PL+2;((Y--));
            if ((BLOQLEFT>=1 && BLOQLEFT<=3)); then
                printf "\e[20;5H\e[3;33mOnly ${BLOQLEFT} buildings\e[21;5Hleft!\e[23m"; TMSG=4
            elif ((BLOQLEFT==0)); then printf "\e[3;33m\e[$((LINES-CH+1));$((X0-7*2+1))HCongratulations pilot! You have bombed all the buildings!\e[$((LINES-CH+2));$((X0-7*2+1))HNow you are going to land and then you will attack another city.\e[23m";  fi
        fi
        printf "\e[33m\e[$((Y0-Y-2));$((X0+X*2))H__\e[$((Y0-Y-1));$((X0+X*2))HE \___\e[$((Y0-Y-0));$((X0+X*2))H \==-_')"
        if ((X>=0 && X<=CW && Y==A[X+PL-5])); then 
            printf "\e[31m";for ((y=-2;y<1;y++));do printf "\e[$((Y0-Y+y));$((X0+X*2))H$(rep '*' $PL)";done
            printf "\e[33m\e[$((LINES-CH+1));$((X0-7*2+1))HOh my God! Your plane has been destroyed!"
            local change=0 key ans
            if ((SCORE>MAXSCORE)); then
                printf "\e[32m\e[$((LINES-CH+2));$((X0-7*2+1))HNew record! You have exceeded your maximum SCORE!";change=1;((MAXSCORE=SCORE))
            fi
            if ((LEVEL>MAXLEVEL)); then
                printf "\e[34m\e[$((LINES-CH+3));$((X0-7*2+1))HNew record! You have exceeded your maximum LEVEL!)";change=1;((MAXLEVEL=LEVEL))
            fi
            if ((change==1)); then echo "$MAXLEVEL|$MAXSCORE" > bashblitz.max ; fi
            printf "\e[36m\e[$((LINES-CH+5));$((X0-7*2+1))HDo you want to play again? Choose 'y' or 'n'" 
            while read -n 1 key; do if [[ $key == y ]]; then ans="y";break; elif [[ $key == n ]]; then ans="n";break;fi;done
            if ((ans=="y"));then init;welcome;else fin;fi
        fi
        sleep $SPEED;
        if ((Y==1 && X==CW));then ((LEVEL++));writeLevel;initCity;fi
    }
    function readkey {
        local y vt
        if ((TMSG>0)); then ((TMSG--)); elif ((TMSG==0)); then for((y=20;y<=23;y++));do printf "\e[${y};5H$(rep ' ' 21 )";done;TMSG=-1;fi
        read k
        if [[ $k = q ]]; then fin; fi
        if ((INICIO==1)); then 
            if [[ $k = s ]]; then TMSG=2;start;fi;
        else 
            if [[ $k = b ]] && ((B==0)); then B=1;((BX=X+2));((BY=0));((BY0=Y-1));fi
            if ((B>0));then 
                for ((M=1;M<=4;M++));do 
                    if ((BY0+BY>=1));then printf "\e[31m\e[$((Y0-BY0-BY-1));$((X0+BX*2))H__\e[$((Y0-BY0-BY));$((X0+BX*2))H\\/";((BY--));fi
                    if ((BY<=-2)); then printf "\e[$((Y0-BY0-BY-4));$((X0+BX*2))H  \e[$((Y0-BY0-BY-3));$((X0+BX*2))H  ";fi
                    if ((B==1 && BY0+BY<=0)); then 
                        printf "\e[31m\e[$((Y0-4));$((X0+BX*2))H  \e[$((Y0-3));$((X0+BX*2))H  \e[$((Y0-2));$((X0+BX*2))H**\e[$((Y0-1));$((X0+BX*2))H**"
                        B=2;break
                    elif ((B==2 && BY0+BY<=0)); then
                        sound 400 200;printf "\e[$((Y0-2));$((X0+BX*2))H  \e[$((Y0-1));$((X0+BX*2))H  "
                        B=0;((vt=A[BX]))
                        if ((BX>=0 && BX<=CW && A[BX]>0));then 
                            printf "\e[20;5H\e[32mObjective reached!\e[21;5H\e[33m$vt-storey building\e[22;5Hdestroyed!\e[23m"; TMSG=4;((SCORE+=A[BX]));((A[BX]=0));((BLOQLEFT--));
                            writeScore
                            if ((BLOQLEFT==0)); then SPEED=0.04;fi
                        else printf "\e[20;5H\e[31mYou have failed!\e[21;5H\e[33mCome on pilot!\e[22;5HYou can do it!\e[23m"; TMSG=4;fi
                        break;
                    fi
                done
            fi
        fi
    }
    if((INICIO==1));then while true; do readkey; done else while true; do plane;readkey;done;fi
}
function init {
    SPEAKER=1;if ! [ -x "$(command -v speaker-test)" ]; then SPEAKER=0;fi
    trap '' 2;trap 'fin' WINCH
    stty -echo -icanon time 0 min 0;printf "\e[40m";clear;printf "\e[0m"
    read -r LINES COLUMNS < <(stty size)
    if ((COLUMNS<97 || LINES<32));then printf "\e[1;44;33m\n /---------\\\ \n |BASHBLITZ| by Diejuse\n \\---------/ \n\nYour terminal has $COLUMNS columns and $LINES lines.\nIt must have 97 or more columns and 32 or more files to play this game.\n\n\e[40;37m\e[?25h";stty echo;exit;fi
    printf "\e[?25l"
    CH=29;CW=19;X0=43;Y0=$((LINES-2));LEVEL=1;SCORE=0;PL=8
    local y x txt="\e[37m"
    txt+="\e[$((LINES-CH-1));$((X0-7*2))H┌$(rep ─ $((2*(CW+14))) )┐"
    for ((y=$((LINES-CH));y<$((LINES-1));y++));do txt+="\e[$((y));$((X0-7*2))H│$(rep '  ' $((CW+14)) )│";done   
    txt+="\e[$((LINES-1));$((X0-7*2))H└$(rep ─ $((2*(CW+14))) )┘"
    printf "\e[40;32m$txt"
    txt=("███████████████████████" "█                     █" "█ ▒▒ ░░░ ▒▒░ ░        █" "█ ▒ ▒░ ░▒  ░ ░        █" "█ ▒▒ ░░░ ▒ ░░░        █" "█ ▒ ▒░ ░  ▒░ ░        █" "█ ▒▒ ░ ░▒▒ ░ ░        █" "█                     █" "█    ██ ▒  ███▒▒▒███  █" "█    █ █▒   █  ▒   █  █" "█    ██ ▒   █  ▒  █   █" "█    █ █▒   █  ▒ █    █" "█    ██ ▒▒▒███ ▒ ███  █" "█                     █" "█          by Diejuse █" "███████████████████████")
    printf "\e[40;34m"
    for ((y=0;y<${#txt};y++));do printf "\e[$((y+3));4H${txt[y]}";done
    txt=("┌─────────────────────┐" "│                     │" "│                     │" "│                     │" "│                     │" "└─────────────────────┘")
    printf "\e[40;37m";for ((y=19;y<25;y++));do printf "\e[${y};4H${txt[y-19]}";done
    printf "\e[25;$((4))H┌──────────┬──────────┐"
    printf "\e[26;$((4))H│ LEVEL:%2s │ MAX:  %2s │" "" ""
    printf "\e[27;$((4))H└──────────┴──────────┘"
        printf "\e[28;$((8))H┌─────────────────┐"
        printf "\e[29;$((8))H│ SCORE:  %7s │" "0"
    printf "\e[30;$((4))H┌───┴─────────────────┤"
    printf "\e[31;$((4))H│ MAX SCORE:  %7s │" ""
    printf "\e[32;$((4))H└─────────────────────┘"
    writeLevel;writeScore
}
function fin { clear;printf "\e[1;1H\e[1;44;33mDiejuse appreciates you played his game. See you soon!\n\n\e[40;37m";stty echo;printf "\e[?25h";exit; }
function start { INICIO=0;initCity;motor; }
function welcome {
    local txt=("\e[32mWelcome pilot!" "" "\e[33mEnemies are attacking our country savagely! We have to try to" "weaken them. You are the best pilot in our country. Tonight we" "need you to bombard with your fighter plane all the buildings of" "the largest number of enemy cities." "During your feat, we will inform you of your achievements in the" "panels that you have on the screen." "This is your night, pilot. We trust you!" "" "\e[35mPulse 's' to start." "Pulse 'b' to bomb the enemy city." "Press 'q' to exit the game.") y
    for ((y=0;y<${#txt};y++));do printf "\e[$((LINES-CH+y));$((X0-7*2+1))H${txt[y]}";done
    INICIO=1;TMSG=-1;motor
}
init;welcome
