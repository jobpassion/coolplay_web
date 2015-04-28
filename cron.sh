if [ $(ps aux | grep -e 'node fixItemDetail3.js' | grep -v grep | wc -l | tr -s "\n") -eq 0 ]; then cd ~/nodejs/coolplay_web; ./startFix.sh; fi
