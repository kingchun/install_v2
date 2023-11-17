#!/bin/bash 
#默认安装在/usr/local/bin/gost
#配置文件在/etc/systemd/system/gost.service
#如果需要更换配置就卸载了重新安装就好了
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'




function install_docker(){
yum -y install docker curl ||apt update -y&&apt  install curl docker.io -y
service docker start
systemctl enable docker
}
function uninstall(){
docker stop v2ray
docker rm v2ray
echo "Uninstall complete"
}

function info(){
docker ps -a | grep v2ray > /dev/null
install_status=$?
if [ $install_status == 0 ]
then
   install_info="${green}installed${plain}"
else
   install_info="${red}not installed${plain}"
fi
}
info


function write_conf(){
mkdir -p /etc/v2ray
cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [
    {
      "port": 6060,
      "listen": "0.0.0.0",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "0fb3efd6-5b2c-c61a-0879-0185ebb7a442",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/",
          "headers": {}
        }
      },
      "tag": "",
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked",
        "type": "field"
      },
      {
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ],
        "type": "field"
      }
    ]
  }
}
EOF
read  -p "请输入端口: " port
docker run -d -p ${port}:6060 --name v2ray --restart=always -v /etc/v2ray:/etc/v2ray teddysun/v2ray
ufw allow ${port}
}


function install(){
    install_docker
    write_conf
}

echo -e "${green} ******************** ${plain}"
echo -e "${green} 牛逼的v2ray一键安装脚本 ${plain}"
echo -e "${green} ******************** ${plain}"
echo -e "${green} 1安装v2ray ${plain}"
echo -e "${green} 2卸载v2ray ${plain}"
echo -e "${green}install status: ${install_info}${plain}"
read  -p "请输入选项1或2:" xuanxiang
###根据选择执行那个函数###
case $xuanxiang in
 "1")
  install
  ;;
 "2")
  uninstall
  ;;
 *)
  echo -e "${red} 输入有毛病呀老铁 ${plain}"
  ;;
esac
