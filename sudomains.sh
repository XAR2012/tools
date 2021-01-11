
python3 ~/tools/Sublist3r/sublist3r.py -d $1 -o $1.txt
cat /home/akshar/Desktop/$1.txt >> ~/Desktop/tmp.txt

echo "sub done"

curl "https://dns.bufferover.run/dns?q=" | jq '.FDNS_A' | grep "," | cut -f 2 -d ',' | sed "s/\"//" >> ~/Desktop/tmp.txt
curl "https://dns.bufferover.run/dns?q=" | jq '.RDNS' | grep "," | cut -f 2 -d ',' | sed "s/\"//" >> ~/Desktop/tmp.txt

echo "bufferover done"

amass enum --passive -d $1 -json $1.json
jq .name $1.json | sed "s/\"//g">> ~/Desktop/tmp.txt

echo "amass done"

curl -s https://crt.sh/\?q\=\%.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' >> ~/Desktop/tmp.txt
curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' >> ~/Desktop/tmp.txt
curl -s https://crt.sh/?Identity=%.$1 | grep ">*.$1" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$1" | sort -u | awk 'NF' >> ~/Desktop/tmp.txt

echo "crtsh done"

curl https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep $1  >> ~/Desktop/tmp.txt

echo "cert done"


cat ~/Desktop/tmp.txt | uniq | sort -u >> $1-uni.txt
rm ~/Desktop/tmp.txt ~/Desktop/$1.txt ~/Desktop/$1.json
