if [ $(ps aux | grep -e 'node ./bin/www' | grep -v grep | wc -l | tr -s "\n") -eq 0 ]; then cd /home/ec2-user/nodejs/coolplay_web; nohup npm start >>/home/ec2-user/nodejs/coolplay_web/nohup.out; fi
#if [ $(ps aux | grep -e 'coffee crawl2.coffee' | grep -v grep | wc -l | tr -s "\n") -eq 0 ]; then cd /home/ec2-user/nodejs/coolplay_web; nohup coffee crawl2.coffee >>/home/ec2-user/nodejs/coolplay_web/nohup2.out; fi
